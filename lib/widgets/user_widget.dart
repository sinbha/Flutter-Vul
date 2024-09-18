import 'package:cx_playground/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/strings.g.dart';

///This widget will show basic user information's such as username, email, avatar and if it is admin
class UserWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String email;
  final String avatarNumber;
  final bool isAdmin;
  bool hasTeams = false;

  UserWidget(this.userId, this.userName, this.email, this.avatarNumber, this.isAdmin, [this.hasTeams = false]);

  @override
  UserWidgetState createState() => UserWidgetState();
}

///State of UserWidget
class UserWidgetState extends State<UserWidget> {
  void _launchURL() async {
    try {
      String convertedEmail = widget.email;
      convertedEmail = convertedEmail.replaceAll('.', '%2E').replaceAll('@', '%40');
      print(convertedEmail);
      final url = Uri.parse(
          GlobalConfiguration().getValue("teams") + convertedEmail);
      await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
    } catch (error) {
      Fluttertoast.showToast(msg: t.error.anErrorOccurred);
    }
  }

  ///Main widget of UserWidget
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(10),
        child: ListTile(
          leading: widget.avatarNumber == '0' ? CircleAvatar( foregroundImage: AssetImage(t.logo)) : CircleAvatar(child: Image.asset(t.image(avatar: widget.avatarNumber))),
          title: Text(widget.userName),
          subtitle: Text(widget.email),
          trailing: widget.isAdmin ? const Icon(Icons.admin_panel_settings) : (widget.hasTeams? IconButton(onPressed: () => _launchURL(), icon: const Icon(Icons.message)) : null),
        ),
      ),
    );
  }
}