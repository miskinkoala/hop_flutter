import 'package:flutter/material.dart';
import 'favourite_locations_page.dart';
import 'search_trip.dart';
import 'createTrip.dart';
import 'chat_page.dart';
import 'profile_page.dart';
//import 'placeholder_widget.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  AppContainerState createState() => AppContainerState();
}

class AppContainerState extends State<AppContainer> {
  int _currentIndex = 0; // Default to the Profile page7
  final List<Widget> _pages = [
    const FavoriteLocationsPage(),
    const SearchTripPage(),
    const CreateTrip(),
    const ChatPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search Trip',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
                size: 40, // Increase the size of the icon
              ),
              label: 'Create Trip',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.green,
            ),
          ],
          selectedItemColor: const Color.fromARGB(255, 13, 95, 31),
          unselectedItemColor: Colors.white,
        ),
      ),
    );
  }
}
