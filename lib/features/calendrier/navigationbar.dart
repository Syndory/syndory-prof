import 'package:flutter/material.dart';
import 'package:syndory_prof/features/calendrier/calendrier.dart';
import 'package:syndory_prof/features/calendrier/cours.dart';


class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MyNavigationBarState createState() => _MyNavigationBarState();

}


class _MyNavigationBarState extends State<MyNavigationBar>{
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
   Center(child: Text('Acceuil')),
   const Calendrier(), 
   const Cours(),
    Center(child: Text('Ressources')),
    Center(child: Text('Profil')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 0, 76, 137),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Acceuil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendrier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Mes cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Ressources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      )
    );
  }
} 