import 'package:cx_playground/models/tournament_full_exception.dart';
import 'package:cx_playground/models/tournament_mode.dart';
import 'package:cx_playground/screens/add_tournament_screen.dart';
import 'package:cx_playground/screens/create_team_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../providers/auth.dart';
import '../providers/game.dart';
import '../providers/tournament.dart';

///Widget to represent a [Reserve] in the [CreateReservationScreen]
class TournamentWidget extends StatefulWidget {
  String gameId = '';
  String name = '';
  String category = '';

  TournamentWidget(this.gameId, this.name, this.category);

  @override
  State<TournamentWidget> createState() => _TournamentWidgetState();
}

///State of [ReserveWidget]
class _TournamentWidgetState extends State<TournamentWidget> {
  var _expanded = false;

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
              title: Text(widget.name),
              subtitle: Text(widget.category),
              trailing: Wrap(
                spacing: 12,
                children: [
                  IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async {Game game = await Game().getGame(widget.gameId); Navigator.push(context,MaterialPageRoute(builder:(context)=> AddTournamentScreen(TournamentMode.create, widget.gameId, game.name, game.nMax))).then((value) => setState(() {}));},),
                  IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more), onPressed: () {setState(() {_expanded = !_expanded;});},),
                  ]),
            ),
            if(_expanded) Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: 120,
              child: FutureBuilder(
                future: Provider.of<Tournament>(context, listen: false).getTournamentsWhereUserNotIn(widget.gameId, Provider.of<Auth>(context, listen: false).userId),
                builder: (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator()) :
                Consumer<Tournament>(
                  builder: (ctx, tournaments, child) => tournaments.tournaments.isNotEmpty ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: tournaments.tournaments.length,
                    itemBuilder:  (ctx, i) => ListTile(
                      title: Text(tournaments.users.firstWhere((element) => element.userId == tournaments.tournaments[i].idUser).username),
                      subtitle: Text(DateFormat.yMMMd().format(tournaments.tournaments[i].matchDate), style: const TextStyle(fontSize: 10),),
                      leading: CircleAvatar(child: Image.asset(t.image(avatar: tournaments.users.firstWhere((element) => element.userId == tournaments.tournaments[i].idUser).userId))),
                      trailing: IconButton(icon: const Icon(Icons.edit_calendar), onPressed: () async {
                        try {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTeamScreen(tournaments.tournaments[i].idTournament, tournaments.tournaments[i].nPlayers, tournaments.tournaments[i].nTeams))).then((value) => setState(() {}));
                        } on TournamentFullException{
                          Fluttertoast.showToast(msg: TournamentFullException().toString());
                        } catch (error){
                          Fluttertoast.showToast(msg: error.toString());
                        }
                      },),
                    ),
                  ) : Text(t.tournaments.notAnyTournament, textAlign: TextAlign.justify, style: const TextStyle(color: Colors.black54),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
