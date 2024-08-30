import 'package:file_sharing/core/views/custom_dialog.dart';
import 'package:file_sharing/features/auth/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/file_model.dart';
import '../services/file_services.dart';

final fileStreamProvider =
    StreamProvider.autoDispose<List<FileModel>>((ref) async* {
  var data = FileServices.getFiles();
  await for (var item in data) {
    var user = ref.watch(userProvider);
    if (user.role == 'admin') {
      ref.read(filesProvider.notifier).setItems(item);
    } else {
      var list = item
          .where((item) =>
              item.usersIds.contains(user.id) || item.creatorId == user.id)
          .toList();
      ref.read(filesProvider.notifier).setItems(list);
    }
    yield item;
  }
});

class FileFilter {
  List<FileModel> items;
  List<FileModel> filteredItems;
  FileFilter({required this.items, required this.filteredItems});

  FileFilter copyWith({
    List<FileModel>? items,
    List<FileModel>? filteredItems,
  }) {
    return FileFilter(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
    );
  }
}

final filesProvider = StateNotifierProvider<FileProvider, FileFilter>((ref) {
  return FileProvider();
});

class FileProvider extends StateNotifier<FileFilter> {
  FileProvider() : super(FileFilter(items: [], filteredItems: []));

  void setItems(List<FileModel> items) {
    state = state.copyWith(items: items, filteredItems: items);
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredItems: state.items);
    } else {
      var filteredItems = state.items
          .where((element) =>
              element.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      state = state.copyWith(filteredItems: filteredItems);
    }
  }

  void delete(FileModel file, WidgetRef ref) async {
    CustomDialogs.dismiss();
    CustomDialogs.loading(message: 'Deleting file...');
    var result = await FileServices.deleteFile(file.id);
    CustomDialogs.dismiss();
    if (result) {
      CustomDialogs.showDialog(message: 'File deleted successfully',type: DialogType.success);
    } else {
      CustomDialogs.showDialog(message: 'Failed to delete file',type: DialogType.error);
    }
  }
}
