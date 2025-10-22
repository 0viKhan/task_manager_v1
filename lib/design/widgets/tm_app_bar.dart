import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/Ui/controller/auth_controller.dart';
import '../../screejn/sign_In.dart';
import '../../screejn/update_profile_screen.dart';

class TMAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TMAppBar({super.key});

  @override
  State<TMAppBar> createState() => _TMAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _TMAppBarState extends State<TMAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      title: GestureDetector(
        onTap: _onTapProfileBar,
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: _buildProfileImage(AuthController.userModel?.photo),
              child: AuthController.userModel?.photo == null || AuthController.userModel!.photo.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),


            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AuthController.userModel!.fullName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    AuthController.userModel!.email,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: _onTapLogOutButton, icon: Icon(Icons.logout)),
          ],
        ),
      ),
    );

  }
  ImageProvider? _buildProfileImage(String? photo) {
    if (photo == null || photo.isEmpty) return null;

    try {
      if (photo.startsWith('http')) {
        return NetworkImage(photo);
      } else if (photo.contains('/') && !photo.contains('base64')) {
        return FileImage(File(photo));
      } else {
        return MemoryImage(base64Decode(photo));
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> _onTapLogOutButton() async {
    await AuthController.clearData();
    Navigator.pushNamedAndRemoveUntil(
      context,
      SignIn.name,
          (predicate) => false,
    );
  }

  void _onTapProfileBar() {
    if (ModalRoute.of(context)!.settings.name != UpdateProfileScreen.name) {
      Navigator.pushNamed(context, UpdateProfileScreen.name);
    }
  }
}