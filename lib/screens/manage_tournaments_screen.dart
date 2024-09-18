import 'package:cx_playground/models/tournaments_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../i18n/strings.g.dart';
import '../providers/auth.dart';
import '../providers/reservation.dart';
import '../providers/tournament.dart';
import '../widgets/app_bar_with_back_button.dart';
import '../widgets/tournament_widget_my_tournaments.dart';
import 'manage_tournaments_admin_screen.dart';

///Alert dialog for [Reservation] deleting or leaving
showAlertDialog(BuildContext context, String tournamentId, Function setState) {
  Widget cancelButton = TextButton(
    child: Text(t.yesNo.no),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = TextButton(
    child: Text(t.yesNo.yes),
    onPressed:  () async {
      await Tournament().deleteTournament(tournamentId, Provider.of<Auth>(context, listen: false).userId);
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

///Class responsible to display a screen with all [Reservation]s a user can manage
class ManageTournamentsScreen extends StatefulWidget {
  const ManageTournamentsScreen({Key? key}) : super(key: key);

  @override
  State<ManageTournamentsScreen> createState() => _ManageTournamentsScreenState();
}

///State of [ManageReservationScreen]
class _ManageTournamentsScreenState extends State<ManageTournamentsScreen> {
  TournamentsMode tournamentsMode = TournamentsMode.all;
  ///Main widget of [ManageReservationScreen]
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBarWithBackButton().build(context),
      floatingActionButton: Provider.of<Auth>(context, listen: false).isAdmin ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageTournamentsAdminScreen()));
          setState((){});
        },
        child: const Icon(Icons.edit_calendar),
      ) : null,
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
                  });
                }, style: ButtonStyle(backgroundColor: tournamentsMode == TournamentsMode.all ? MaterialStateProperty.all(const Color.fromRGBO(241, 83, 126, 1).withOpacity(1)) : MaterialStateProperty.all(Colors.white)),
                    child: Text(t.reservations.all)),
                TextButton(onPressed: () {
                  setState(() {
                    tournamentsMode = TournamentsMode.myTournaments;
                  });
                }, style: ButtonStyle(backgroundColor: tournamentsMode == TournamentsMode.myTournaments ? MaterialStateProperty.all(const Color.fromRGBO(241, 83, 126, 1).withOpacity(1)) : MaterialStateProperty.all(Colors.white)),
                    child: Text(t.tournaments.myTournaments)),
                TextButton(onPressed: () {
                  setState(() {
                    tournamentsMode = TournamentsMode.participating;
                  });
                }, style: ButtonStyle(backgroundColor: tournamentsMode == TournamentsMode.participating ? MaterialStateProperty.all(const Color.fromRGBO(241, 83, 126, 1).withOpacity(1)) : MaterialStateProperty.all(Colors.white)),
                    child: Text(t.reservations.participating)),
                const SizedBox(width: 20,)
              ],
            ),
            Center(
              child: SizedBox(
                  height: deviceSize.height - 210,
                  width: deviceSize.width - 40,
                  child: FutureBuilder(
                    future: Provider.of<Tournament>(context).getAllTournamentsUser(Provider.of<Auth>(context, listen: false).userId, tournamentsMode),
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
                            builder: (ctx, tournamentData, child) => ListView.builder(
                              itemCount: tournamentData.tournaments.length,
                              itemBuilder: (ctx, i) => tournamentData.tournaments[i].isAuthor ? Slidable(
                                actionPane: const SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                actions: [
                                  IconSlideAction(
                                    caption: t.usersAdmin.delete,
                                    color: Theme.of(context).errorColor,
                                    icon: Icons.delete,
                                    onTap: () {showAlertDialog(context, tournamentData.tournaments[i].idTournament, setState);},
                                  )
                                ],
                                child: TournamentWidgetMyTournaments(tournamentData.tournaments[i]),
                              ) :  Slidable(
                                actionPane: const SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                actions: [
                                  IconSlideAction(
                                    caption: t.reservations.leave,
                                    color: Theme.of(context).errorColor,
                                    icon: Icons.cancel_rounded,
                                    onTap: () {showAlertDialog(context, tournamentData.tournaments[i].idTournament, setState);},
                                  )
                                ],
                                child: TournamentWidgetMyTournaments(tournamentData.tournaments[i]),
                              ),
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
