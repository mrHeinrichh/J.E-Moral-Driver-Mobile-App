import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('User Menu'),
            decoration: BoxDecoration(
              color: Color(0xFFBD2019),
            ),
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
