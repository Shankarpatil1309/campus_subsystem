import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../firebase/auth.dart';

class FacultySignup extends StatefulWidget {
  const FacultySignup({Key? key}) : super(key: key);

  @override
  State<FacultySignup> createState() => _FacultySignupState();
}

class _FacultySignupState extends State<FacultySignup> {
  static const String _title = 'Faculty Sign Up';
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final departmentController = TextEditingController();
  final contactController = TextEditingController();
  bool isVisible = false;
  bool isClicked = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    departmentController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible =
        KeyboardVisibilityProvider.isKeyboardVisible(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(_title),
        backgroundColor: Colors.indigo[300],
      ),
      body: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                isKeyboardVisible
                    ? SizedBox(
                        width: 150,
                        child: Image.asset("assets/images/keyboardLoad.gif"),
                      )
                    : Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/icons/teacher_login.gif",
                            ),
                          ],
                        ),
                      ),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Faculty Registration',
                      style: TextStyle(fontSize: 30, fontFamily: 'Custom'),
                    )),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, bottom: 20),
                        child: TextFormField(
                          controller: nameController,
                          validator: (name) {
                            if (name == null || name.isEmpty) {
                              return 'Enter Full Name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Full Name',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, bottom: 20),
                        child: TextFormField(
                          controller: emailController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-z]|[A-Z]|[0-9]|\.|@'))
                          ],
                          validator: (email) {
                            if (email == null || email.isEmpty) {
                              return 'Enter Email Address';
                            }
                            if (!email.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, bottom: 20),
                        child: TextFormField(
                          controller: departmentController,
                          validator: (dept) {
                            if (dept == null || dept.isEmpty) {
                              return 'Enter Department';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Department',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, bottom: 20),
                        child: TextFormField(
                          controller: contactController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (contact) {
                            if (contact == null || contact.isEmpty) {
                              return 'Enter Contact Number';
                            }
                            if (contact.length != 10) {
                              return 'Enter valid 10-digit number';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Contact Number',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, bottom: 20),
                        child: TextFormField(
                          obscureText: !isVisible,
                          validator: (pswd) {
                            if (pswd == null || pswd.isEmpty) {
                              return 'Enter Password';
                            }
                            if (pswd.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          controller: passwordController,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isVisible = !isVisible;
                                    });
                                  },
                                  icon: const Icon(Icons.remove_red_eye))),
                        ),
                      ),
                      isClicked
                          ? FloatingActionButton(
                              heroTag: null,
                              onPressed: null,
                              backgroundColor: Colors.indigo[300],
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : FloatingActionButton.extended(
                              heroTag: null,
                              backgroundColor: Colors.indigo[300],
                              label: const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 17),
                              ),
                              onPressed: () async {
                                setState(() => isClicked = true);
                                if (formKey.currentState!.validate()) {
                                  try {
                                    final userCreated = await Auth().createUser(
                                      username: emailController.text.trim(),
                                      password: passwordController.text,
                                      isStudent: false,
                                    );

                                    if (userCreated != null && userCreated) {
                                      // Store additional faculty information in Firestore
                                      await FirebaseFirestore.instance
                                          .collection('faculty')
                                          .doc(emailController.text.trim())
                                          .set({
                                        'name': nameController.text,
                                        'email': emailController.text.trim(),
                                        'department': departmentController.text,
                                        'contact': contactController.text,
                                        'createdAt': DateTime.now(),
                                      });

                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Registration successful!")));
                                        Navigator.pop(context);
                                      }
                                    }
                                  } on FirebaseException catch (e) {
                                    String message = "Registration failed";
                                    if (e.code == 'email-already-in-use') {
                                      message = "Email already registered";
                                    } else if (e.code ==
                                        'network-request-failed') {
                                      message = "Check Internet Connection";
                                    }
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text(message)));
                                    }
                                  }
                                }
                                setState(() => isClicked = false);
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
