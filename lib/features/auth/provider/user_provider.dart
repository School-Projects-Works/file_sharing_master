import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/local_storage.dart';
import '../../../core/views/custom_dialog.dart';
import '../../../router/router.dart';
import '../../../router/router_items.dart';
import '../../users/data/user_model.dart';
import '../data/login_model.dart';
import '../services/user_services.dart';

final userImageProvider = StateProvider<Uint8List?>((ref) => null);
final userProvider = StateNotifierProvider<UserProvider, UserModel>((ref) {
  var user = LocalStorage.getData('user');
  if (user != null) {
    return UserProvider()..updateUer(UserModel.fromJson(user).id);
  }
  return UserProvider();
});

class UserProvider extends StateNotifier<UserModel> {
  UserProvider() : super(UserModel.empty());

  void setUser(UserModel user) {
    LocalStorage.saveData('user', user.toJson());
    state = user;
  }

  void logout({required BuildContext context, required WidgetRef ref}) async {
    CustomDialogs.dismiss();
    CustomDialogs.loading(message: 'Logging out...');
    LocalStorage.removeData('user');
    await FirebaseAuth.instance.signOut();
    state = UserModel.empty();
    CustomDialogs.dismiss();
    MyRouter(context: context, ref: ref).navigateToRoute(RouterItem.loginRoute);
  }

  updateUer(String? id) async {
    var userData = await AuthServices.getUserData(id!);
    if (userData != null) {
      if (userData.status.toLowerCase() == 'banned') {
        LocalStorage.removeData('user');
        CustomDialogs.toast(
            message:
                'You are band from accessing this platform. Contact admin for more information',
            type: DialogType.error);
        return;
      }

      state = userData;
    }
  }

  void setName(String? s) {
    state = state.copyWith(name: s);
  }

  void setPhone(String? s) {
    state = state.copyWith(phone: s);
  }

  void updateProfile(WidgetRef ref) async {
    CustomDialogs.loading(message: 'Updating user...');
    var status =
        await AuthServices.updateUser(id: state.id, data: state.toMap());
    // save in local storage
    LocalStorage.saveData('user', state.toJson());
    CustomDialogs.dismiss();
    if (status) {
      CustomDialogs.toast(message: 'User updated successfully');
    } else {
      CustomDialogs.toast(message: 'User not updated', type: DialogType.error);
    }
  }
}

final newUserProvider = StateNotifierProvider<NewUser, UserModel>((ref) {
  return NewUser();
});

class NewUser extends StateNotifier<UserModel> {
  NewUser() : super(UserModel.empty());

  void setName(String s) {
    state = state.copyWith(name: s);
  }

  void setEmail(String s) {
    state = state.copyWith(email: s);
  }

  void setPhone(String s) {
    state = state.copyWith(phone: s);
  }

  void setPassword(String s) {
    state = state.copyWith(password: s);
  }

  void registerUser(
      {required BuildContext context, required WidgetRef ref}) async {
    CustomDialogs.loading(
      message: 'Registering User...',
    );
    state = state.copyWith(
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    var (status, message) = await AuthServices.createUser(state);
    if (status) {
      CustomDialogs.dismiss();
      CustomDialogs.toast(message: message, type: DialogType.success);
      MyRouter(context: context, ref: ref)
          .navigateToRoute(RouterItem.loginRoute);
    } else {
      CustomDialogs.dismiss();
      CustomDialogs.toast(message: message, type: DialogType.error);
    }
  }
}

final loginProvider = StateNotifierProvider<LoginProvider, LoginModel>((ref) {
  return LoginProvider();
});

class LoginProvider extends StateNotifier<LoginModel> {
  LoginProvider() : super(LoginModel(email: '', password: ''));

  void setEmail(String s) {
    state = state.copyWith(email: s);
  }

  void setPassword(String s) {
    state = state.copyWith(password: s);
  }

  void loginUser(
      {required BuildContext context, required WidgetRef ref}) async {
    try {
      CustomDialogs.loading(
        message: 'Logging in...',
      );
      var (user, userModel, message) = await AuthServices.loginUser(state);
      if (user != null) {
        if (user.emailVerified || (userModel!.role == 'admin')) {
          if (userModel == null) {
            CustomDialogs.dismiss();
            CustomDialogs.toast(
                message: 'Unable to get User Data', type: DialogType.error);
            return;
          }
          if (userModel.status.toLowerCase() == 'banned') {
            LocalStorage.removeData('user');
            CustomDialogs.dismiss();
            CustomDialogs.toast(
                message:
                    'You are band from accessing this platform. Contact admin for more information',
                type: DialogType.error);
            return;
          }
          CustomDialogs.dismiss();
          CustomDialogs.toast(message: message, type: DialogType.success);
          ref.read(userProvider.notifier).setUser(userModel);
          if (userModel.role == 'admin') {
            MyRouter(context: context, ref: ref)
                .navigateToRoute(RouterItem.dashboardRoute);
          } else {
            MyRouter(context: context, ref: ref)
                .navigateToRoute(RouterItem.filesRoute);
          }
        } else {
          CustomDialogs.dismiss();
          CustomDialogs.showDialog(
              message: 'Please verify your email',
              type: DialogType.error,
              secondBtnText: 'Resend Email',
              onConfirm: () async {
                CustomDialogs.dismiss();
                CustomDialogs.loading(message: 'Resending email...');
                var status = await AuthServices.resendEmailVerification(user);
                CustomDialogs.dismiss();
                CustomDialogs.toast(
                    message: message,
                    type: status ? DialogType.success : DialogType.error);
              });
        }
      } else {
        CustomDialogs.dismiss();
        CustomDialogs.toast(message: message, type: DialogType.error);
      }
    } on PlatformException catch (e) {
      CustomDialogs.dismiss();
      CustomDialogs.toast(
          message: e.message.toString(), type: DialogType.error);
    } catch (e) {
      CustomDialogs.dismiss();
      CustomDialogs.toast(message: e.toString(), type: DialogType.error);
    }
  }
}
