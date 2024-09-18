import 'package:cx_playground/providers/team.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/strings.g.dart';
import '../providers/auth.dart';

///Widget to represent a [Reserve] in the [CreateReservationScreen]
class TeamWidget extends StatefulWidget {
  String teamId = '';
  String teamName = '';
  List<Auth> elements = [];
  bool full = false;

  TeamWidget(this.teamId, this.teamName, this.elements, this.full);

  @override
  State<TeamWidget> createState() => _TeamWidgetState();
}

///State of [ReserveWidget]
class _TeamWidgetState extends State<TeamWidget> {
  var _expanded = false;

  void _launchURL(String email) async {
    try {
      String convertedEmail = email;
      convertedEmail = convertedEmail.replaceAll('.', '%2E').replaceAll('@', '%40');
      final url = Uri.parse(
          GlobalConfiguration().getValue("teams") + convertedEmail);
      await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
    } catch (error) {
      Fluttertoast.showToast(msg: t.error.anErrorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              title: Text(widget.teamName),
              subtitle: Text(widget.elements.first.username),
              trailing: Wrap(
                spacing: 12,
                children: [
                  if(!widget.full) IconButton(icon: const Icon(Icons.add), onPressed: () async {await Team(widget.teamName, widget.elements.first.userId).addUserToTeam(widget.teamId, Provider.of<Auth>(context, listen: false).userId); widget.elements.add(Provider.of<Auth>(context, listen: false)); setState(() {widget.full = true;}); Navigator.of(context).pop();},),
                  IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more), onPressed: () {setState(() {_expanded = !_expanded;});},),
                  ]),
            ),
            if(_expanded) Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: 120,
              child: Consumer<Auth>(
                  builder: (ctx, users, child) => ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.elements.length,
                    itemBuilder:  (ctx, i) => ListTile(
                      title: Text(widget.elements[i].username),
                      subtitle: Text(widget.elements[i].email, style: const TextStyle(fontSize: 10),),
                      leading: CircleAvatar(child: Image.asset(t.image(avatar: widget.elements[i].avatarNumber))),
                      trailing: widget.elements[i].userId != Provider.of<Auth>(context, listen: false).userId ? IconButton(onPressed: () => _launchURL(widget.elements[i].email), icon: const Icon(Icons.message)) : null,
                    ),
                  )
                ),
            )
          ],
        ),
      ),
    );
  }
}
