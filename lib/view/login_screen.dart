import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/providers/loin_logout.dart';
import 'package:ies_mobile/res/colors.dart';
import 'package:ies_mobile/utils/auth_button.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _focusNode = FocusNode();
  final ValueNotifier<bool> _obsecureText = ValueNotifier<bool>(true);

  loginUser(email, pass) {
    var loginLogoutProvider = Provider.of<LoginLogout>(context, listen: false);
    loginLogoutProvider.loginUser(context, email, pass);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColors.appThemeColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: width * 0.4,
              ),
              GradientText(
                "Intelligent Earth Pit Monitoring and Alarm System",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 27,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                colors: [
                  Colors.greenAccent.shade400,
                  Colors.pinkAccent.shade100,
                  Colors.teal.shade300,
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: width * 0.3,
                height: width * 0.3,
                child: Image.asset("assets/login.png"),
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white54),
                        decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.white54),
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.white54,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.white),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.white),
                            )),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Email";
                          }
                          return null;
                        },
                        onFieldSubmitted: (val){
                          FocusScope.of(context).requestFocus(_focusNode);
                        },
                      ),
                      SizedBox(
                        height: width * 0.04,
                      ),
                      TextFormField(
                        controller: passwordController,
                        focusNode: _focusNode,
                        obscureText: _obsecureText.value,
                        style: const TextStyle(color: Colors.white54),
                        decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white54),
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(
                              Icons.lock_open_rounded,
                              color: Colors.white54,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _obsecureText.value = !_obsecureText.value;
                                setState(() {});
                              },
                              icon: Icon(
                                _obsecureText.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility,
                                color: Colors.white54,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.white),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.white),
                            )),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Password";
                          }
                          return null;
                        },
                      ),
                    ],
                  )),
              SizedBox(
                height: width * 0.1,
              ),
              AuthButton(
                  title: "LOG IN",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      loginUser(emailController.text, passwordController.text);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
