import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child});
     final Widget child;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
      
          children: [
            Image.network('https://images.unsplash.com/photo-1731398916709-19c7ae1be371?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8YXBwJTIwYmFja2dyb3VuZHxlbnwwfHwwfHx8MA%3D%3D&fm=jpg&q=60&w=3000',
              height: double.maxFinite,width:  double.maxFinite,fit: BoxFit.cover,),
             SafeArea(child: child),
          ],
        ),
      
      
      
      ),
    );
  }
}
