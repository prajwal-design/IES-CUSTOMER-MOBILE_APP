import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ies_mobile/providers/loin_logout.dart';
import 'package:ies_mobile/res/colors.dart';
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              const Color(0xff1A4B9F).withOpacity(0.2),
              CustomColors.appThemeColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: width * 0.25),
              // --- Logo/Image ---
              Hero(
                tag: 'login_logo',
                child: Container(
                  width: width * 0.35,
                  height: width * 0.35,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Image.asset("assets/login.png", fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 30),
              // --- Title ---
              GradientText(
                "Intelligent Monitoring",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                colors: const [
                  Color(0xFF64B5F6),
                  Color(0xFF2196F3),
                  Color(0xFF1976D2),
                ],
              ),
              Text(
                "Earth Pit Monitoring System",
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              // --- Login Form Card ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CustomColors.cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sign In",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      TextFormField(
                        controller: emailController,
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          hintStyle: GoogleFonts.outfit(color: Colors.white38),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                const BorderSide(color: Color(0xFF2196F3)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          return null;
                        },
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_focusNode);
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      TextFormField(
                        controller: passwordController,
                        focusNode: _focusNode,
                        obscureText: _obsecureText.value,
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: GoogleFonts.outfit(color: Colors.white38),
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: Colors.white54),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _obsecureText.value = !_obsecureText.value;
                              setState(() {});
                            },
                            icon: Icon(
                              _obsecureText.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility,
                              color: Colors.white38,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide:
                                const BorderSide(color: Color(0xFF2196F3)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                loginUser(emailController.text,
                                    passwordController.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(
                              "LOG IN",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
