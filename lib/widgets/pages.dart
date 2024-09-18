import 'package:cx_playground/screens/games_screen.dart';
import 'package:cx_playground/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../providers/auth.dart';
import '../screens/create_reservation_screen.dart';
import '../screens/create_tournament_screen.dart';
import '../screens/manage_reservations_screen.dart';
import '../screens/user_screen.dart';

///Creates the pages of the application
class Pages extends StatefulWidget{
  const Pages({Key? key}) : super(key: key);

  @override
  State<Pages> createState() => _PagesState();
}

///State of Pages
class _PagesState extends State<Pages> {
  int _currentIndex=0;
  final List _screens=[const CreateReservationScreen(), const CreateTournamentScreen(), const UserScreen(), const UsersScreen(), const GamesScreen()];

  void _updateIndex(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  ///Main widget of Pages
  @override
  Widget build(BuildContext context) {
    bool isAdmin = Provider.of<Auth>(context).isAdmin;
    return Scaffold(
      appBar: AppBar(title: const Text('CxPlayground')),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _updateIndex,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        selectedItemColor: const Color.fromRGBO(241, 83, 126, 1),
        unselectedItemColor: const Color.fromRGBO(13, 155, 241, 1),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: t.pages.book
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.videogame_asset),
              label: t.pages.tournament
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: t.pages.user
          ),
          if(isAdmin)BottomNavigationBarItem(
              icon: const Icon(Icons.person_search),
              label: t.pages.manageUsers
          ),
          if(isAdmin)BottomNavigationBarItem(
              icon: const Icon(Icons.sports_volleyball),
              label: t.pages.manageGames
          ),
        ],
      ),
    );
  }
}