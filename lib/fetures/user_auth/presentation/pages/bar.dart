// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:TafweejHub/fetures/user_auth/presentation/pages/ChatScreen.dart';


class Bar extends StatelessWidget {
  const Bar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chat'),
            onTap: () {
              // Ensure ChatScreen is implemented properly
             // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatAppp()));
            },
          ),
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text('Tracking'),
            onTap: () => print('Track'),
          ),
          ListTile(
            leading: Icon(Icons.timeline),
            title: Text('Timeline'),
            onTap: () {
              // Ensure time1line is implemented correctly
            //  Navigator.push(context, MaterialPageRoute(builder: (context) => time1line()));
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Contact us'),
            onTap: () => print('Contact'),
          ),
          ListTile(
            title: Text('Log out'),
            onTap: () => print('Log out'),
          ),
        ],
      ),
    );
  }
}
