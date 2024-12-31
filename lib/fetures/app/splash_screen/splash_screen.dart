// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';




class Splash_screen extends StatefulWidget {

  final Widget? child;
  const Splash_screen({super.key, this.child});


  @override
  State<Splash_screen> createState() => _Splash_screenState();
}






class _Splash_screenState extends State<Splash_screen> {




@override
  void initState() {
    
    Future.delayed(
      Duration(seconds: 3),(){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget.child! ), (route) => false);
      }
      );
    
    super.initState();
  }













  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Welcom to TafweejHub",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
