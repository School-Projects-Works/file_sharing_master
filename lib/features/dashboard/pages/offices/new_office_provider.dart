import 'package:file_sharing/core/views/custom_dialog.dart';
import 'package:file_sharing/features/offices/data/office_model.dart';
import 'package:file_sharing/features/offices/services/office_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/services/user_services.dart';
import '../../../users/data/user_model.dart';

final newOfficeProvider = StateNotifierProvider<NewOffice, OfficeModel>((ref) {
  return NewOffice();
});

class NewOffice extends StateNotifier<OfficeModel> {
  NewOffice() : super(OfficeModel.empty());

  void setName(String s) {
    state = state.copyWith(name: s);
  }

  void setPhone(String s) {
    state = state.copyWith(officePhone: s);
  }

  void setEmail(String s) {
    state = state.copyWith(officeEmail: s);
  }

  void saveOffice(WidgetRef ref) async {
    try {
      CustomDialogs.loading(message: 'Saving Office...');
      state = state.copyWith(
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: OfficeServices.getOfficeId(),
        status: 'active',
      );
      //create new firebase user with email and password
      var user = UserModel(
        email: state.officeEmail,
        name: state.name,
        phone: state.officePhone,
        id: '',
        password: '123456',
        role: 'office',
        status: 'active',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      var (status, message) = await AuthServices.createUser(user);
      if (status) {
        //save office to firestore
        await OfficeServices.createOffice(state);
        CustomDialogs.dismiss();
        CustomDialogs.toast(message: message, type: DialogType.success);
      } else {
        CustomDialogs.dismiss();
        CustomDialogs.showDialog(message: message, type: DialogType.error);
      }
    } catch (e) {
      CustomDialogs.showDialog(message: e.toString(), type: DialogType.error);
    }
  }
}

final editOfficeProvider =
    StateNotifierProvider<EditOffice, OfficeModel>((ref) {
  return EditOffice();
});

class EditOffice extends StateNotifier<OfficeModel> {
  EditOffice() : super(OfficeModel.empty());

  void setOffice(OfficeModel office) {
    state = office;
  }

  void setName(String s) {
    state = state.copyWith(name: s);
  }

  void setPhone(String s) {
    state = state.copyWith(officePhone: s);
  }

  void setEmail(String s) {
    state = state.copyWith(officeEmail: s);
  }

  void updateOffice(WidgetRef ref) async {
    try {
      CustomDialogs.loading(message: 'Updating Office...');
      //update user email
      var user = UserModel.empty().copyWith(
        email: state.officeEmail,
        name: state.name,
        phone: state.officePhone,
      );
      await AuthServices.updateUser(id: user.id, data: user.toMap());
      //update office
      await OfficeServices.updateOffice(state);
      reset();
      CustomDialogs.dismiss();
      CustomDialogs.toast(
          message: 'Office updated successfully', type: DialogType.success);
    } catch (e) {
      CustomDialogs.showDialog(message: e.toString(), type: DialogType.error);
    }
  }

  void reset() {
    state = OfficeModel.empty();
  }
}
