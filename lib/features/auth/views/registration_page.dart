import 'package:file_sharing/features/auth/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/functions/email_validation.dart';
import '../../../core/views/custom_button.dart';
import '../../../core/views/custom_input.dart';
import '../../../generated/assets.dart';
import '../../../router/router.dart';
import '../../../router/router_items.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
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
        ))));
  }

  Widget _buildForm() {
    var style = Styles(context);
    var notifier = ref.read(newUserProvider.notifier);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Form(
            key: _formKey,
            child: Column(children: [
              if (style.isMobile)
                Image.asset(
                  Assets.imagesLogin,
                  width: 200,
                  height: 200,
                ),
              if (style.isMobile) const SizedBox(height: 12),
              Text('USER REGISTRATION',
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
                label: 'Full Name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
                onSaved: (name) {
                  notifier.setName(name!);
                },
              ),
              const SizedBox(height: 20),
              CustomTextFields(
                label: 'User Email',
                prefixIcon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty || !isValid(value)) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (email) {
                  notifier.setEmail(email!);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              //phone
              CustomTextFields(
                label: 'Phone number',
                prefixIcon: Icons.phone,
                isDigitOnly: true,
                validator: (phone) {
                  if (phone == null) {
                    return 'Phone number is required';
                  } else if (phone.length != 10) {
                    return 'Enter a valid phone number of 10 digits';
                  }
                  return null;
                },
                onSaved: (phone) {
                  notifier.setPhone(phone!);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextFields(
                label: 'User Password',
                hintText: 'Enter your password',
                prefixIcon: Icons.lock,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (password) {
                  notifier.setPassword(password!);
                },
                obscureText: _isObscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomButton(
                text: 'Register',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    notifier.registerUser(context: context, ref: ref);
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  const SizedBox(
                    width: 10,
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
            ])));
  }
}
