import 'package:flutter/material.dart';
import '../i18n/strings.g.dart';

///Generic [AppBar] with a title and a back button
class AppBarWithBackButton extends AppBar {

  AppBar build(BuildContext context) {
    return AppBar(
        title: Text(t.appName),
        leading : IconButton(icon : const Icon(Icons.arrow_back), onPressed :()=> Navigator.of(context).pop())
    );
  }

}