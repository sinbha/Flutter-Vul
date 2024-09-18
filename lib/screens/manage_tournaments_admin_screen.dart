import 'package:cx_playground/providers/tournament.dart';
import 'package:cx_playground/widgets/app_bar_with_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../i18n/strings.g.dart';
import '../models/tournaments_mode.dart';
import '../providers/auth.dart';
import '../providers/games.dart';
import '../providers/reservation.dart';
import '../widgets/tournament_widget_my_tournaments.dart';

///Alert dialog for [Reservation] deleting or leaving
showAlertDialog(BuildContext context, String tournamentId, Function setState) {
  Widget cancelButton = TextButton(
    child: Text(t.yesNo.no),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = TextButton(
    child: Text(t.yesNo.yes),
    onPressed:  () async {
      await Tournament().deleteTournamentAdmin(tournamentId, Provider.of<Auth>(context, listen: false).userId);
      setState(() {}); Navigator.of(context).pop(true);
      },
  );
  AlertDialog alert = AlertDialog(
    title: Text(t.usersAdmin.delete),
    content: Text(t.areUSure),
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

///Class responsible to display a screen with all [Tournaments]s a user can manage
class ManageTournamentsAdminScreen extends StatefulWidget {
  const ManageTournamentsAdminScreen({Key? key}) : super(key: key);

  @override
  State<ManageTournamentsAdminScreen> createState() => _ManageTournamentsAdminScreenState();
}

///State of [ManageTournamentsAdminScreen]
class _ManageTournamentsAdminScreenState extends State<ManageTournamentsAdminScreen> {
  TournamentsMode tournamentsMode = TournamentsMode.all;
  int game = -1;
  String gameName = '';

  ///Main widget of [ManageTournamentsAdminScreen]
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBarWithBackButton().build(context),
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
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20,),
                TextButton(onPressed: () {
                  setState(() {
                    tournamentsMode = TournamentsMode.all;
                    game = -1;
                  });
                }, style: ButtonStyle(backgroundColor: tournamentsMode == TournamentsMode.all ? MaterialStateProperty.all(const Color.fromRGBO(241, 83, 126, 1).withOpacity(1)) : MaterialStateProperty.all(Colors.white)),
                    child: Text(t.reservations.all)),
                IconButton(
                  onPressed: () => setState(() {
                    tournamentsMode = TournamentsMode.filter;
                  }),
                  color: tournamentsMode == TournamentsMode.filter ? const Color.fromRGBO(241, 83, 126, 1).withOpacity(1) : Colors.white,
                  icon: const Icon(Icons.filter_list_alt)
                ),
                if(tournamentsMode == TournamentsMode.filter)SizedBox(
                  height: 15,
                  child: FutureBuilder(
                    future: Provider.of<Games>(context).getGamesFromServer(),
                    builder: (ctx, dataSnapshot) {
                      if (dataSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                      } else {
                        if (dataSnapshot.error != null) {
                          return Center(
                            child: Text(t.error.anErrorOccurred),
                          );
                        }
                        else {
                          List<DropdownMenuItem<String>> menuItems = [];
                          Provider.of<Games>(context, listen: false).games.reversed.forEach((value) { menuItems.add(DropdownMenuItem(value: value.id, child: Text(value.name)));});
                          if(gameName == '') gameName = menuItems.first.value!;
                          return Consumer<Games>(
                              builder: (ctx, gamesData, child) => SizedBox(
                                width: 90,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      focusColor: Colors.white38,
                                      dropdownColor: Colors.grey,
                                      isDense: true,
                                      isExpanded: true,
                                      hint: Text(t.reservations.startTime),
                                      style: const TextStyle(color: Colors.white),
                                      iconEnabledColor: Colors.white,
                                      items: menuItems,
                                      elevation: 5,
                                      value: gameName,
                                      onChanged: (value) {
                                        setState(() {
                                          gameName = value.toString();
                                          game = int.tryParse(value!) ?? -1;
                                          tournamentsMode = TournamentsMode.filter;
                                        });
                                      }),
                                ),
                              )
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20,)
              ],
            ),
            Center(
              child: SizedBox(
                  height: deviceSize.height - 210,
                  width: deviceSize.width - 40,
                  child: FutureBuilder(
                    future: Provider.of<Tournament>(context).getAllTournamentsUser(Provider.of<Auth>(context, listen: false).userId, tournamentsMode, game),
                    builder: (ctx, dataSnapshot) {
                      if (dataSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        if (dataSnapshot.error != null) {
                          return Center(
                            child: Text(t.error.anErrorOccurred),
                          );
                        } else {
                          return Consumer<Tournament>(
                            builder: (ctx, tournamentsData, child) => ListView.builder(
                              itemCount: tournamentsData.tournaments.length,
                              itemBuilder: (ctx, i) => Slidable(
                                actionPane: const SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                actions: [
                                  IconSlideAction(
                                    caption: t.usersAdmin.delete,
                                    color: Theme.of(context).errorColor,
                                    icon: Icons.delete,
                                    onTap: () {showAlertDialog(context, tournamentsData.tournaments[i].idTournament, setState);},
                                  )
                                ],
                                child: TournamentWidgetMyTournaments(tournamentsData.tournaments[i]),
                              )
                            ),
                          );
                        }
                      }
                    },
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
