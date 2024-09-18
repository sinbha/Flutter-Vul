import 'package:cx_playground/models/reserve_mode.dart';
import 'package:cx_playground/providers/tournament.dart';
import 'package:cx_playground/providers/users_admin.dart';
import 'package:cx_playground/screens/add_tournament_screen.dart';
import 'package:cx_playground/widgets/team_widget.dart';
import 'package:cx_playground/widgets/tournament_widget.dart';
import 'package:cx_playground/widgets/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../models/tournament_mode.dart';
import '../providers/auth.dart';
import '../providers/game.dart';
import '../providers/games.dart';
import '../providers/reservation.dart';
import '../providers/team.dart';
import '../screens/add_reservation_screen.dart';

///Widget used to represent a [Reservation] in the [CreateReservationScreen]
class TournamentWidgetMyTournaments extends StatefulWidget {
  Tournament tournament = Tournament();

  TournamentWidgetMyTournaments(this.tournament);

  @override
  State<TournamentWidgetMyTournaments> createState() => _TournamentWidgetMyTournamentsState();
}

///State of [TournamentWidgetMyTournaments]
class _TournamentWidgetMyTournamentsState extends State<TournamentWidgetMyTournaments> {
  bool _expanded = false;

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
              title: Text(widget.tournament.gameName, style: const TextStyle(color: Colors.black54),),
              subtitle: Text(t.reservations.dates(initDate: DateFormat('hh:mm a dd-MM').format(widget.tournament.matchDate), endDate: DateFormat('hh:mm a dd-MM').format(widget.tournament.matchDateEnd))),
              trailing: Wrap(
                spacing: 12,
                children: [
                  if(widget.tournament.isAuthor) IconButton(onPressed: () async {
                        List<Game> games = await Games().getGamesFromServer();
                        Game game = games.firstWhere((element) => element.id == widget.tournament.game);
                        List<Team> teams = await Team().getTeamsFromServer();
                        Team team = teams.firstWhere((element) => element.idTeamLeader == widget.tournament.idUser);
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => AddTournamentScreen(TournamentMode.edit, game.id, game.name, game.nMax, widget.tournament, Provider.of<Auth>(context, listen: false).isAdmin, team))).then((value) => setState((){}));
                      }, icon: const Icon(Icons.edit)),
                  if(!widget.tournament.isAuthor) IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more), onPressed: () {setState(() {_expanded = !_expanded;});},),
                ]),
            ),
            if(_expanded) FutureBuilder(
              future: Provider.of<Team>(context, listen: false).getTeamsFromServer(),
              builder: (ctx, resultSnapshot) => resultSnapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator()) :
              Consumer<Team>(
                builder: (ctx, teams, child) => ListView.builder(
                    itemCount: teams.teams.length,
                    itemBuilder: (ctx, i) => TeamWidget(
                      teams.teams[i].idTeam,
                      teams.teams[i].name,
                      teams.teams[i].users,
                      true
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
