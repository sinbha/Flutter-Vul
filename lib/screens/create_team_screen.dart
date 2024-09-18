import 'package:cx_playground/models/team_mode.dart';
import 'package:cx_playground/screens/add_team_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../i18n/strings.g.dart';
import '../providers/team.dart';
import '../widgets/team_widget.dart';

///Stateful widget which will present a screen to create a [Reservation] or join a previously created
class CreateTeamScreen extends StatefulWidget {
  String tournamentId = '';
  int maxPlayers = 0;
  int maxTeams = 0;

  CreateTeamScreen(this.tournamentId, this.maxPlayers, this.maxTeams);

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

///State of [CreateReservationScreen]
class _CreateTeamScreenState extends State<CreateTeamScreen> {

  ///Main widget of [GameScreen]
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FutureBuilder(
        future: Provider.of<Team>(context, listen: false).getTeamsFromServer(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 0, width: 0,);
          } else {
            return Provider.of<Team>(context, listen: false).teams.length < widget.maxTeams ? IconButton(icon: const Icon(Icons.add), onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => AddTeamScreen(TeamMode.create, widget.tournamentId, widget.maxPlayers))).then((value) => Navigator.of(context).pop());
            },) : const SizedBox(height: 0, width: 0,);;
          }
        },
      ),
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
                future: Provider.of<Team>(context, listen: false).getTeamsFromServer(),
                builder: (ctx, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (dataSnapshot.error != null) {
                      return Center(
                        child: Text(t.error.anErrorOccurred),
                      );
                    } else {
                      return Consumer<Team>(
                        builder: (ctx, teamsData, child) => ListView.builder(
                          itemCount: teamsData.teams.length,
                          itemBuilder: (ctx, i) => Slidable(
                            actionPane: const SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: TeamWidget(teamsData.teams[i].idTeam, teamsData.teams[i].name, teamsData.teams[i].users, teamsData.teams[i].users.length < widget.maxPlayers ? false : true),
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
