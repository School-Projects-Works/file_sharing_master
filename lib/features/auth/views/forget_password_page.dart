import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/functions/email_validation.dart';
import '../../../core/views/custom_button.dart';
import '../../../core/views/custom_dialog.dart';
import '../../../core/views/custom_input.dart';
import '../../../generated/assets.dart';
import '../../../router/router.dart';
import '../../../router/router_items.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../services/user_services.dart';

class ForgetPasswordPage extends ConsumerStatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends ConsumerState<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var style = Styles(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            style.isMobile
                ? _buildForm()
                : Container(
                    width:
                        style.isDesktop ? style.width * .6 : style.width * .7,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ]),
                    child: Row(
                      children: [
                        Container(
                          height: 450,
                          width: style.width * .3,
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: Image.asset(
                            Assets.imagesLogin,
                          ),
                        ),
                        Expanded(child: _buildForm())
                      ],
                    ),
                  ),
          ],
        )),
      ),
    );
  }

  String? _email;
  Widget _buildForm() {
    var style = Styles(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (style.isMobile)
              Image.asset(
                Assets.imagesLogin,
                width: 200,
                height: 200,
              ),
            if (style.isMobile) const SizedBox(height: 12),
            Text('SYSTEM LOGIN',
                style: style.title(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: style.isDesktop
                        ? 35
                        : style.isTablet
                            ? 30
                            : 20)),
            const Divider(
              height: 22,
              thickness: 3,
            ),
            const SizedBox(height: 15),
            CustomTextFields(
              label: 'Email',
              prefixIcon: Icons.email,
              hintText: 'Enter your email',
              onSaved: (value) {
                setState(() {
                  _email = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty || !isValid(value)) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            CustomButton(
                text: 'Reset Password',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _resetPassword();
                  }
                }),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Back to'),
                const SizedBox(
                  width: 5,
                ),
                TextButton(
                    onPressed: () {
                      MyRouter(context: context, ref: ref)
                          .navigateToRoute(RouterItem.loginRoute);
                    },
                    child: const Text('Login',
                        style: TextStyle(color: primaryColor)))
              ],
            )
          ],
        ),
      ),
    );
  }

  void _resetPassword() async {
    CustomDialogs.loading(message: 'Resetting password...');
    var result = await AuthServices.resetPassword(_email!);
    CustomDialogs.dismiss();
    if (result) {
      CustomDialogs.toast(
          message: 'Password reset link has been sent to your email',
          type: DialogType.success);
      MyRouter(context: context, ref: ref)
          .navigateToRoute(RouterItem.loginRoute);
    } else {
      CustomDialogs.toast(
          message: 'Failed to reset password', type: DialogType.error);
    }
  }
}
