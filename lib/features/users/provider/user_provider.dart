import 'package:file_sharing/core/views/custom_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_sharing/features/users/data/user_model.dart';
import 'package:file_sharing/features/users/services/user_services.dart';

final userStreamProvider =
    StreamProvider.autoDispose<List<UserModel>>((ref) async* {
  var data = UserServices.getUsers();
  await for (var item in data) {
    var withoutAdmin =
        item.where((element) => element.role != 'admin').toList();
    ref.read(usersProvider.notifier).setItems(withoutAdmin);
    yield withoutAdmin;
  }
});

class UserFilter {
  List<UserModel> items;
  List<UserModel> filteredItems;
  UserFilter({required this.items, required this.filteredItems});

  UserFilter copyWith({
    List<UserModel>? items,
    List<UserModel>? filteredItems,
  }) {
    return UserFilter(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
    );
  }
}

final usersProvider = StateNotifierProvider<UserProvider, UserFilter>((ref) {
  return UserProvider();
});

class UserProvider extends StateNotifier<UserFilter> {
  UserProvider() : super(UserFilter(items: [], filteredItems: []));

  void setItems(List<UserModel> items) {
    state = state.copyWith(items: items, filteredItems: items);
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredItems: state.items);
    } else {
      var filteredItems = state.items
          .where((element) =>
              element.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      state = state.copyWith(filteredItems: filteredItems);
    }
  }

  void block(UserModel lecturer) async {
    CustomDialogs.dismiss();
    try {
      CustomDialogs.loading(message: 'Blocking User...');
      await UserServices.updateUser(lecturer.copyWith(status: 'banned'));
      CustomDialogs.dismiss();
      CustomDialogs.toast(message: 'User Blocked', type: DialogType.success);
    } catch (e) {
      CustomDialogs.showDialog(message: e.toString(), type: DialogType.error);
    }
  }

  void unblock(UserModel lecturer) async {
    CustomDialogs.dismiss();
    try {
      CustomDialogs.loading(message: 'Unblocking User...');
      await UserServices.updateUser(lecturer.copyWith(status: 'active'));
      CustomDialogs.dismiss();
      CustomDialogs.toast(message: 'User Unblocked', type: DialogType.success);
    } catch (e) {
      CustomDialogs.showDialog(message: e.toString(), type: DialogType.error);
    }
  }
}
