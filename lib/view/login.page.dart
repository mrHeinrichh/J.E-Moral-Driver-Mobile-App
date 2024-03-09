import 'package:driver_app/routes/app_routes.dart';
import 'package:driver_app/view/user_provider.dart';
import 'package:driver_app/widgets/custom_button.dart';
import 'package:driver_app/widgets/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController =
      TextEditingController(text: 'rider@gmail.com');
  TextEditingController passwordController =
      TextEditingController(text: 'rider');

  Future<Map<String, dynamic>> login(
      String? email, String? password, BuildContext? context) async {
    if (email == null || password == null) {
      print('Email or password is null');
      return {'error': 'Invalid email or password'};
    }

    print('Email: $email, Password: $password');

    try {
      final response = await http.post(
        Uri.parse(
            'https://lpg-api-06n8.onrender.com/api/v1/users/authenticate/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          '__t': 'Rider',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        print('Login Response: $data');

        if (data['status'] == 'success') {
          if (context != null) {
            final List<dynamic>? userData = data['data'];
            if (userData != null && userData.isNotEmpty) {
              // Accessing the correct nested values
              String userId = userData[0]['_id'] ?? '';

              print('User ID: $userId');

              // Set the user ID in the app state
              Provider.of<UserProvider>(context, listen: false)
                  .setUserId(userId);

              // You can also save other user details to the provider if needed
            } else {
              return {'error': 'User data is missing or empty'};
            }
          }

          return data;
        } else {
          return {'error': 'Login failed'};
        }
      } else {
        return {'error': 'Login failed'};
      }
    } catch (error, stackTrace) {
      print('Error: $error');
      print('Stack trace: $stackTrace');
      return {'error': 'An error occurred during login'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 60.0),
                Image.network(
                  'https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/png/logo-main.png',
                  width: 550.0,
                  height: null,
                ),
                const SizedBox(height: 50.0),
                LoginTextField(
                  controller: emailController,
                  labelText: "Email Address",
                  hintText: "Enter your Email Address",
                ),
                LoginTextField(
                  controller: passwordController,
                  obscureText: true,
                  labelText: "Password",
                  hintText: "Enter your Password",
                ),
                const SizedBox(height: 30.0),
                Column(
                  children: [
                    LoginButton(
                      onPressed: () async {
                        final loginResult = await login(
                          emailController.text,
                          passwordController.text,
                          context,
                        );

                        print('Login Result: $loginResult');

                        if (loginResult.containsKey('error')) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Login Failed'),
                                content: Text(loginResult['error']),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          Navigator.pushNamed(context, homeRoute);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
