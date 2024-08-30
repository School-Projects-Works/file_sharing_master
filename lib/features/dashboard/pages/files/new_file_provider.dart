import 'dart:typed_data';

import 'package:file_sharing/core/views/custom_dialog.dart';
import 'package:file_sharing/features/dashboard/pages/files/files_page.dart';
import 'package:file_sharing/features/files/data/file_model.dart';
import 'package:file_sharing/features/files/provider/file_provider.dart';
import 'package:file_sharing/features/files/services/file_services.dart';
import 'package:file_sharing/features/users/data/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/functions/sms_gpt_model.dart';
import '../../../auth/provider/user_provider.dart';
import 'data/upload_model.dart';

final newFileProvider = StateNotifierProvider<NewFileNotifier, FileModel>(
  (ref) => NewFileNotifier(),
);

class NewFileNotifier extends StateNotifier<FileModel> {
  NewFileNotifier() : super(FileModel.empty());

  void setTitle(String s) {
    state = state.copyWith(title: s);
  }

  void setDescription(String s) {
    state = state.copyWith(description: s);
  }

  void createFile(WidgetRef ref) async {
    CustomDialogs.loading(message: 'Creating file.....');
    state = state.copyWith(
      creatorId: ref.read(userProvider).id,
      creator: ref.read(userProvider).toMap(),
      usersIds: [ref.read(userProvider).id],
      users: [ref.read(userProvider).toMap()],
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: FileServices.getId(),
      status: 'opened',
    );
    var results = await FileServices.createFile(state);
    CustomDialogs.dismiss();
    if (results) {
      ref.read(editFileProvider.notifier).reset();
      ref.read(isNewFile.notifier).state = false;
      CustomDialogs.toast(
          message: 'File created successfully', type: DialogType.success);
    } else {
      CustomDialogs.toast(
          message: 'Failed to create file', type: DialogType.error);
    }
  }
}

final editFileProvider = StateNotifierProvider<EditFileNotifier, FileModel>(
  (ref) => EditFileNotifier(),
);

class EditFileNotifier extends StateNotifier<FileModel> {
  EditFileNotifier() : super(FileModel.empty());

  void reset() {
    state = FileModel.empty();
  }

  void updateOffice(WidgetRef ref) async {
    CustomDialogs.loading(message: 'Updating file.....');
    var results = await FileServices.updateFile(state);
    CustomDialogs.dismiss();
    if (results) {
      ref.read(isNewFile.notifier).state = false;
      CustomDialogs.toast(
          message: 'File updated successfully', type: DialogType.success);
    } else {
      CustomDialogs.toast(
          message: 'Failed to update file', type: DialogType.error);
    }
  }

  void setTitle(String s) {
    state = state.copyWith(title: s);
  }

  void setDescription(String s) {
    state = state.copyWith(description: s);
  }

  void setOffice(FileModel file) {
    state = file;
  }
}

final newUploadProvider = StateNotifierProvider<NewUploadNotifier, Upload>(
  (ref) => NewUploadNotifier(),
);

class NewUploadNotifier extends StateNotifier<Upload> {
  NewUploadNotifier() : super(Upload.empty());

  void setDescription(String s) {
    state = state.copyWith(description: s);
  }

  void setFolderId(String s) {
    state = state.copyWith(folderId: s);
  }

  void createUpload(WidgetRef ref) async {
    CustomDialogs.loading(message: 'Uploading file.....');
    var user = ref.read(userProvider);
    var folders = ref.watch(filesProvider).items;
    var folder = folders.firstWhere((element) => element.id == state.folderId);
    var file = ref.watch(selectedFileProvider).file;
    if (file != null) {
      var url = await FileServices.uploadFile(file, state.id);
      state = state.copyWith(
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        folderId: folder.id,
        uploadBy: user.id,
        fileUrl: url,
      );
      var existedFile = folder.files.toList();
      existedFile.add(state.toMap());
      folder.files = existedFile;
      folder.usersIds = folder.usersIds.toSet().toList();
      folder.users = folder.users.toSet().toList();
      if (!folder.usersIds.contains(user.id)) {
        folder.users.add(user.toMap());
        folder.usersIds.add(user.id);
      }

      var results = await FileServices.updateFile(folder);
      CustomDialogs.dismiss();
      if (results) {
        if (user.id != folder.creatorId) {
          var creator = UserModel.fromMap(folder.creator);
          await SmsGptModel.sendMessage(
              creator.phone, 'A new file has been uploaded to your folder');
        }
        ref.read(editFileProvider.notifier).reset();
        ref.read(isNewFile.notifier).state = false;
        ref.read(selectedFileProvider.notifier).state = SelectedFile();
        CustomDialogs.toast(
            message: 'File uploaded successfully', type: DialogType.success);
      } else {
        CustomDialogs.toast(
            message: 'Failed to upload file', type: DialogType.error);
      }
    } else {
      CustomDialogs.toast(
          message: 'Please select a file', type: DialogType.error);
    }
  }

  void reset() {
    state = Upload.empty();
  }
}

class SelectedFile {
  Uint8List? file;
  String? path;
  SelectedFile({this.file, this.path});
}

final selectedFileProvider =
    StateProvider<SelectedFile>((ref) => SelectedFile());

final shareFileUserProvider =
    StateNotifierProvider<ShareToProvider, List<UserModel>>(
        (ref) => ShareToProvider());

class ShareToProvider extends StateNotifier<List<UserModel>> {
  ShareToProvider() : super([]);

  void setUser(UserModel user) {
    //check if user already exist
    var list = state.toList();
    if (!state.contains(user)) {
      list.add(user);
      state = list;
    }
  }

  void removeUser(UserModel user) {
    var list = state.toList();
    list.remove(user);
    state = list;
  }

  void shareFile(WidgetRef ref) async {
    CustomDialogs.loading(message: 'Sharing file....');
    var file = ref.watch(iShareFile);
    var users = file!.users.toList();
    var ids = file.usersIds.toList();
    for (var user in state) {
      users.add(user.toMap());
      ids.add(user.id);
    }
    file = file.copyWith(users: users, usersIds: ids);
    var results = await FileServices.updateFile(file);
    if (results) {
      for (var user in state) {
        await SmsGptModel.sendMessage(
            user.phone, 'A new file has been shared to you');
      }

      ref.read(iShareFile.notifier).state = null;
      state = [];
      CustomDialogs.dismiss();
      CustomDialogs.toast(
          message: 'File shred to user.', type: DialogType.success);
    } else {
      CustomDialogs.dismiss();
      CustomDialogs.toast(
          message: 'Unable to share file', type: DialogType.error);
    }
  }
}
