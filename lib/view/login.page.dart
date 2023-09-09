import 'package:driver_app/widgets/login_text_field.dart';
import 'package:flutter/material.dart';

import '../widgets/login_elevated_button.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                'https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/png/logo-main.png',
                width: 550.0,
                height: null,
              ),
              const SizedBox(height: 50.0),
              const LoginTextField(
                labelText: 'Email Address',
                hintText: 'Enter your Email Address',
              ),
              const SizedBox(height: 10.0),
              const LoginTextField(
                labelText: 'Password',
                hintText: 'Enter your Password',
              ),
              const SizedBox(
                height: 65.0,
              ),
              LoginElevatedButton(
                text: 'Login',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
