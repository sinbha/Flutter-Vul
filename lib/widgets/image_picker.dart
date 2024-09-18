import 'dart:math';

import 'package:cx_playground/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class ImageSelector extends StatefulWidget with ChangeNotifier {
  static const routeName = '/images_selector';
  int selectedPicture = 1;
  static const List<Map<String, dynamic>> avatars = <Map<String, dynamic>>[
    <String, dynamic>{
      'img': './assets/images/avatar_1.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_2.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_3.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_4.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_5.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_6.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_7.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_8.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_9.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_10.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_11.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_12.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_13.png',
    },<String, dynamic>{
      'img': './assets/images/avatar_14.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_15.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_16.png',
    },
    <String, dynamic>{
      'img': './assets/images/avatar_17.png',
    },
  ];

  void setPicture(int pictureId){
    selectedPicture = pictureId;
    notifyListeners();
  }

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  int selectedOption = 0;

  void selectOption(int selected){
    selectedOption = selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select your avatar!'),
      ),
      body: GridView.count(
        scrollDirection: Axis.vertical,
        crossAxisCount: 2,
        children: <Widget>[
          for (int i = 0; i < ImageSelector.avatars.length; i++)
            AvatarOption(
              img: ImageSelector.avatars[i]['img'] as String,
              onTap: () { selectOption(i + 1);},
              image: i + 1,
            ),
        ],
      ),
    );
  }
}


class AvatarOption extends StatelessWidget {
  const AvatarOption({
    required this.img,
    required this.onTap,
    required this.image
  });

  final String img;
  final VoidCallback onTap;
  final int image;

  Widget build(BuildContext context) {
    return Ink.image(
      fit: BoxFit.cover,
      image: AssetImage(img),
      child: InkWell(
        onTap: () {Provider.of<Auth>(context, listen: false).avatarNumber = image; Navigator.pop(context);},
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8.0),
            child: Row(children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}