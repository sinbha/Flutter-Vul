import 'package:cx_playground/providers/users_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../providers/auth.dart';
import '../widgets/user_widget.dart';

///Alert dialog tho avoid deleting necessary user profiles
showAlertDialog(BuildContext context, String userId, String userName, Function setState) {
  Widget cancelButton = TextButton(
    child: Text(t.yesNo.no),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = TextButton(
    child: Text(t.yesNo.yes),
    onPressed:  () async {await UsersAdmin().deleteUser(Provider.of<Auth>(context, listen: false).userId, userId); setState(() {}); Navigator.of(context).pop(true);},
  );
  AlertDialog alert = AlertDialog(
    title: Text(t.delete.delete),
    content: Text(t.delete.areUSure(userName: userName)),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

///Stateful widget of UserScreen which will present all users and some basic operations on them
class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

///State of UserScreen
class _UsersScreenState extends State<UsersScreen> {

  ///Main widget of UserScreen
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(13, 155, 241, 1).withOpacity(1),
              const Color.fromRGBO(241, 83, 126, 1).withOpacity(1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 1],
          ),
        ),
        child: Center(
          child: SizedBox(
            height: deviceSize.height - 200,
            width: deviceSize.width - 40,
            child: FutureBuilder(
              future: Provider.of<UsersAdmin>(context).getUsersFromServer(),
              builder: (ctx, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (dataSnapshot.error != null) {
                    return Center(
                      child: Text(t.error.anErrorOccurred),
                    );
                  } else {
                    return Consumer<UsersAdmin>(
                      builder: (ctx, usersData, child) => ListView.builder(
                        itemCount: usersData.users.length,
                        itemBuilder: (ctx, i) => Slidable(
                          actionPane: const SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          actions: [
                            if(usersData.users[i].userId == Provider.of<Auth>(context).userId) IconSlideAction(
                              caption: t.usersAdmin.checkYourPage,
                              color: Theme.of(context).primaryColor,
                              icon: Icons.person,
                              onTap: () {}
                            ),
                            if(usersData.users[i].userId != Provider.of<Auth>(context).userId) IconSlideAction(
                              caption: t.usersAdmin.delete,
                              color: Theme.of(context).errorColor,
                              icon: Icons.delete,
                              onTap: () {showAlertDialog(context,usersData.users[i].userId, usersData.users[i].username, setState);},
                          ),
                            if(!usersData.users[i].isAdmin) IconSlideAction(
                              caption:  t.usersAdmin.turnAdmin,
                              color: Colors.amberAccent,
                              icon: Icons.admin_panel_settings,
                              onTap: () async {
                                try{
                                  await UsersAdmin().turnAdmin(Provider.of<Auth>(context, listen: false).userId, usersData.users[i].userId);
                                  Fluttertoast.showToast(msg: t.usersAdmin.turnAdminMessage);
                                } catch (error){
                                  Fluttertoast.showToast(msg: error.toString());
                                }
                                setState(() {});
                              }
                            ),
                            if(usersData.users[i].isAdmin && usersData.users[i].userId != Provider.of<Auth>(context).userId) IconSlideAction(
                              caption:  t.usersAdmin.removeAdmin,
                              color: Theme.of(context).secondaryHeaderColor,
                              icon: Icons.admin_panel_settings_outlined,
                              onTap: () async {
                                try{
                                  await UsersAdmin().removeAdmin(Provider.of<Auth>(context, listen: false).userId, usersData.users[i].userId);
                                  Fluttertoast.showToast(msg: t.usersAdmin.removeAdminMessage);
                                } catch (error){
                                  Fluttertoast.showToast(msg: error.toString());
                                }
                                setState(() {});
                              }
                            )
                          ],
                          child: UserWidget(usersData.users[i].userId, usersData.users[i].username, usersData.users[i].email, usersData.users[i].avatarNumber.toString(), usersData.users[i].isAdmin),
                        ),
                      ),
                    );
                  }
                }
              },
            )
          ),
        ),
      ),
    );
  }
}
