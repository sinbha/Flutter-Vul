import 'package:cx_playground/widgets/tournament_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../i18n/strings.g.dart';
import '../providers/games.dart';
import 'manage_tournaments_screen.dart';

///Stateful widget which will present a screen to create a [Tournament] or join a previously created
class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({Key? key}) : super(key: key);

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

///State of [CreateReservationScreen]
class _CreateTournamentScreenState extends State<CreateTournamentScreen> {

  ///Main widget of [GameScreen]
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageTournamentsScreen()));
        },
        child: const Icon(Icons.perm_contact_calendar),
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
                future: Provider.of<Games>(context).getGamesFromServer(),
                builder: (ctx, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (dataSnapshot.error != null) {
                      return Center(
                        child: Text(t.error.anErrorOccurred),
                      );
                    } else {
                      return Consumer<Games>(
                        builder: (ctx, gamesData, child) => ListView.builder(
                          itemCount: gamesData.games.length,
                          itemBuilder: (ctx, i) => gamesData.games[i].isAvailable ? Slidable(
                            actionPane: const SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: TournamentWidget(gamesData.games[i].id, gamesData.games[i].name, gamesData.games[i].category),
                          ) :  const SizedBox(height: 0,),
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
