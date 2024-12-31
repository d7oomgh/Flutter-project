// marker.dart

import 'package:flutter/material.dart';

class Marker extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;
  final String snippet;

  const Marker({super.key, required this.latitude, required this.longitude, required this.title, required this.snippet});

  @override
  _MarkerState createState() => _MarkerState();

  
}



class _MarkerState extends State<Marker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.snippet,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}