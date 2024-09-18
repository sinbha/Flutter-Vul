import 'package:cx_playground/models/game_mode.dart';
import 'package:cx_playground/providers/categories.dart';
import 'package:cx_playground/widgets/app_bar_with_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../providers/auth.dart';
import '../providers/game.dart';
import '../providers/games.dart';

GameMode _gameMode = GameMode.create;
Game _game = Game();

///Stateless widget of the screen to create and update game data
class AddGameScreen extends StatelessWidget {
  static const routeName = '/game';

  AddGameScreen(GameMode gameMode, [var game]){
    _gameMode = gameMode;
    if (game != null) _game = game;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBarWithBackButton().build(context),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(13, 155, 241, 1).withOpacity(0.5),
                  const Color.fromRGBO(241, 83, 126, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
                height: deviceSize.height - 150,
                width: deviceSize.width,
                child: const GameCard()
            ),
          ),
        ],
      ),
    );
  }
}

///Widget responsible for presenting and update the screen according to user input
class GameCard extends StatefulWidget {
  const GameCard({Key? key}) : super(key: key);


  @override
  GameCardState createState() => GameCardState();
}

///State of Game Card
class GameCardState extends State<GameCard> {
  String category = '';
  bool switchOn = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _gameData = {
    'name': '',
    'duration': '',
    'nMax': '',
    'nMin': '',
    'description': '',
    'isAvailable': '',
    'idCategory': ''
  };
  var _isLoading = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  ///Simple error dialog just to dismiss
  void _showErrorDialog(String message){
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(t.error.anErrorOccurred), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.ok))],));
  }

  ///Method that collects the user inputs in TextFormFields and updates the game data
  Future<void> _submit() async{
    if (_formKey.currentState?.validate() == null) {
      return;
    }
    _formKey.currentState?.save();
    if(!allValid(_gameData['name']!, _gameData['duration']!, _gameData['nMax']!, _gameData['nMin']!, _gameData['description']!, _gameData['isAvailable']!, _gameData['idCategory']!)) return;
    setState(() {
      _isLoading = true;
    });
    try {
      if(_gameMode == GameMode.edit) {
        if(_gameData['name'] == '') _gameData['name'] = _game.name;
        if(_gameData['duration'] == '') _gameData['duration'] = _game.duration.toString();
        if(_gameData['nMax'] == '') _gameData['nMax'] = _game.nMin.toString();
        if(_gameData['nMin'] == '') _gameData['nMin'] = _game.nMin.toString();
        if(_gameData['description'] == '') _gameData['description'] = _game.description;
        if(_gameData['isAvailable'] == '') _gameData['isAvailable'] = _game.isAvailable == true? '1' : '0';
        if(_gameData['idCategory'] == '') _gameData['idCategory'] = _game.category;
        await Games().updateGame(Provider.of<Auth>(context, listen: false).userId, _game.id, _gameData['name']!, _gameData['duration']!, _gameData['nMax']!, _gameData['nMin']!, _gameData['description']!, _gameData['isAvailable']!, _gameData['idCategory']!);
        Navigator.of(context).pop();
      } else {
        _gameData['isAvailable'] = switchOn == true ? '1' : '0';
        await Games().createGame(Provider.of<Auth>(context, listen: false).userId, _gameData['name']!, _gameData['duration']!, _gameData['nMax']!, _gameData['nMin']!, _gameData['description']!, _gameData['isAvailable']!, _gameData['idCategory']!,);
        Navigator.of(context).pop();
      }
    } catch (error) {
      var errorMessage = t.error.unableNow;
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  ///Checks if all data is set up
  bool allValid(String name, String duration, String nMax, String nMin, String description, String isAvailable, String idCategory){
    if(name != '' && duration != '' && nMax != '' && nMin != '' && description != '' && isAvailable != '' && idCategory != '') return true;
    return false;
  }

  ///Alert dialog for category creation
  Future openDialog() async {
    return showDialog(
      context: context,
      builder: (context) =>
        AlertDialog(
          title: Text(t.game.createCategory),
          content: TextField(
            decoration: InputDecoration(hintText: t.game.categoryName),
            autofocus: true,
            controller: controller,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(),
                child: Text(t.yesNo.no)),
            TextButton(onPressed: () async {
              if (controller.text == '') return;
              try {
                await Categories().createCategory(Provider.of<Auth>(context, listen: false).userId, controller.text);
                Navigator.of(context).pop();
              } catch (error) {
                var errorMessage = t.error.unableNow;
                _showErrorDialog(errorMessage);
              }
            }, child: Text(t.yesNo.yes))
          ],
        )
    );
  }

  ///Alert dialog for category deletion
  Future _showAlertDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.game.deleteCategory),
          content: Text(t.game.areUSureCategory(category: Provider.of<Games>(context, listen: false).categories[category]!)),
          actions: [
            TextButton(
              child: Text(t.yesNo.no),
              onPressed:  () {Navigator.of(context).pop();},
            ),
            TextButton(
              onPressed: () async {
                try {
                  await Categories().deleteCategory(Provider.of<Auth>(context, listen: false).userId, category);
                  setState(() {});
                  Navigator.of(context).pop(true);
                } catch(error) {
                  showDialog(context: context, builder: (BuildContext context) { return AlertDialog(actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.ok))]);});
                }
              },
              child: Text(t.yesNo.yes),
            ),
          ],
        );
      },
    );
  }


  @override
  void didChangeDependencies() {
    List<DropdownMenuItem<String>> menuItems = [];
    Provider.of<Games>(context, listen: false).categories.forEach((key, value) { menuItems.add(DropdownMenuItem(value: key, child: Text(value)));});
    if(_gameMode == GameMode.edit) {
      category = menuItems.firstWhere((element) => element.child.toString().contains(_game.category)).value ?? '';
      switchOn = _game.isAvailable;
    }
    if(category == '') category = menuItems.first.value!;
    _gameData['idCategory'] = category;
    _gameData['isAvailable'] = switchOn == true ? '1' : '0';
    super.didChangeDependencies();
  }

    ///Main widget of [GameCard]
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> menuItems = [];
    Provider.of<Games>(context, listen: false).categories.forEach((key, value) { menuItems.add(DropdownMenuItem(value: key, child: Text(value)));});
    if(_gameMode == GameMode.edit) {
      category = menuItems.firstWhere((element) => element.child.toString().contains(_game.category)).value ?? '';
      switchOn = _game.isAvailable;
    }
    if(category == '') category = menuItems.first.value!;
    _gameData['idCategory'] = category;
    _gameData['isAvailable'] = switchOn == true ? '1' : '0';
    int duration = 1;
    int nMin = 1;
    int nMax = 10;

    final deviceSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: (deviceSize.height - 720)/2,),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Container(
            height: 510,
            constraints: const BoxConstraints(minHeight: 400),
            width: deviceSize.width * 0.75,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: t.game.name),
                      initialValue: _gameMode == GameMode.edit ? _game.name : null,
                      keyboardType: TextInputType.name,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: (value) {
                        if(value == null || value == '') {
                          return t.game.error.cantBeNull;
                        } else if (value.length > 15) {
                          return t.game.error.nameTooLong;
                        }
                        return null;
                      },
                      toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                      onSaved: (value) {
                        _gameData['name'] = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: t.game.duration),
                      initialValue: _gameMode == GameMode.edit ? _game.duration.toString() : null,
                      ///Vulnerability: Autocorrection Keystroke Logging
                      ///Fix:Use the text tree flags, with the TextInputType set to TextInputType.name
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: (value) {
                        try{
                          duration = int.parse(value!);
                        } catch (error) {
                          return t.game.error.onlyInt;
                        }
                        if(value == '') {
                          return t.game.error.cantBeNull;
                        } else if (duration < 1 ) {
                          return t.game.error.moreTanOne;
                        }
                        return null;
                      },
                      toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                      onSaved: (value) {
                        _gameData['duration'] = duration.toString();
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: t.game.nMin),
                      initialValue: _gameMode == GameMode.edit ? _game.nMin.toString() : null,
                      ///Vulnerability: Autocorrection Keystroke Logging
                      ///Fix:Use the text tree flags, with the TextInputType set to TextInputType.name
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: (value) {
                        try{
                          nMin = int.parse(value!);
                        } catch (error) {
                          return t.game.error.onlyInt;
                        }
                        if(value == '') {
                          return t.game.error.cantBeNull;
                        } else if (nMin < 1 ) {
                          return t.game.error.tooShort;
                        } else if (nMin > 10 ) {
                          return t.game.error.tooLong;
                        }
                        return null;
                      },
                      toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                      onSaved: (value) {
                        _gameData['nMin'] = nMin.toString();
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: t.game.nMax),
                      initialValue: _gameMode == GameMode.edit ? _game.nMax.toString() : null,
                      ///Vulnerability: Autocorrection Keystroke Logging
                      ///Fix:Use the text tree flags, with the TextInputType set to TextInputType.name
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: (value) {
                        try{
                          nMax = int.parse(value!);
                        } catch (error) {
                          return t.game.error.onlyInt;
                        }
                        if(value == '') {
                          return t.game.error.cantBeNull;
                        } else if (nMax < 1 ) {
                          return t.game.error.tooShort;
                        } else if (nMax > 10 ) {
                          return t.game.error.tooLong;
                        }
                        return null;
                      },
                      toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                      onSaved: (value) {
                        _gameData['nMax'] = nMax.toString();
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: t.game.description),
                      initialValue: _gameMode == GameMode.edit ? _game.description : null,
                      keyboardType: TextInputType.name,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: (value) {
                        if(value == '') {
                          return t.game.error.cantBeNull;
                        } else if (value!.length > 45) {
                          return t.game.error.descTooLong;
                        }
                        return null;
                      },
                      toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                      onSaved: (value) {
                        _gameData['description'] = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(t.game.isAvailable, style: const TextStyle(color: Colors.black54),),
                        const SizedBox(width: 100),
                        FlutterSwitch(
                            activeColor: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1),
                            duration: const Duration(microseconds: 50),
                            showOnOff: true,
                            value: switchOn,
                            onToggle: (bool val){
                              setState(() {
                                switchOn = !switchOn;
                                _gameData['isAvailable'] = switchOn == true ? '1' : '0';
                                _game.isAvailable = switchOn;
                              });
                            }),
                      ],
                    ),
                    const SizedBox(height:8),
                    Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                focusColor: Colors.white38,
                                isDense: true,
                                isExpanded: true,
                                hint: Text(t.game.idCategory),
                                style: const TextStyle(color: Colors.black54),
                                iconEnabledColor: Colors.black54,
                                items: menuItems,
                                elevation: 5,
                                value: category,
                                onChanged: (value) {
                                  setState(() {
                                    category = value.toString();
                                  });}),
                          ),
                        ),
                        IconButton(
                          color: Colors.black54,
                          onPressed: () async {
                            await openDialog();
                            await Provider.of<Games>(context, listen: false).getGamesFromServer();
                            menuItems = [];
                            super.setState(() {
                              Provider.of<Games>(context, listen: false).categories.forEach((key, value) { menuItems.add(DropdownMenuItem(value: key, child: Text(value)));});
                              category = menuItems.last.value!;
                            });},
                          icon: const Icon(Icons.add)),
                        IconButton(
                          color: Colors.black54,
                          onPressed: () async {
                            await _showAlertDialog(context);
                            await Provider.of<Games>(context, listen: false).getGamesFromServer();
                            menuItems = [];
                            super.setState(() {
                              Provider.of<Games>(context, listen: false).categories.forEach((key, value) { menuItems.add(DropdownMenuItem(value: key, child: Text(value)));});
                              category = menuItems.first.value!;
                            });},
                          icon: const Icon(Icons.remove))
                      ],
                    ),
                    const SizedBox(height: 20,),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else SizedBox(
                      width: deviceSize.width * 0.80,
                      child: ElevatedButton(
                        onPressed: () {_submit();},
                        style: ElevatedButton.styleFrom(primary: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1)),
                        child: Text(t.save),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
