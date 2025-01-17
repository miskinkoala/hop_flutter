import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:shared_preferences/shared_preferences.dart';

class EditFavoriteLocationsPage extends StatefulWidget {
  const EditFavoriteLocationsPage({super.key});

  @override
  EditFavoriteLocationsPageState createState() =>
      EditFavoriteLocationsPageState();
}

class EditFavoriteLocationsPageState extends State<EditFavoriteLocationsPage> {
  final List<String> _cityOptions = [
    'Arnavutköy',
    'Ataşehir',
    'Avcılar',
    'Bağcılar',
    'Bakırköy',
    'Bayrampaşa',
    'Beşiktaş',
    'Beykoz',
    'Beylikdüzü',
    'Beyoğlu',
    'Bostancı',
    'Büyükçekmece',
    'Çekmeköy',
    'Derince',
    'Dilovası',
    'Dudullu',
    'Esenler',
    'Esenyurt',
    'Eyüp',
    'Fatih',
    'Gebze',
    'Gölcük',
    'Güngören',
    'İçerenköy',
    'İzmit',
    'İzmit Merkez',
    'Kandıra',
    'Karamürsel',
    'Kağıthane',
    'Kadıköy',
    'Kartal',
    'Küçükçekmece',
    'Maltepe',
    'Maltepe',
    'Mehmet Ali Paşa',
    'Ömerbey',
    'Pendik',
    'Sancaktepe',
    'Sarıyer',
    'Silivri',
    'Şile',
    'Şişli',
    'Sultangazi',
    'Tuzla',
    'Üsküdar',
    'Ümraniye',
    'Yuvacık',
    'Zeytinburnu'
  ];

  List<String> favoriteLocations = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteLocations().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _fetchFavoriteLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');

    if (userId == null) {
      print('Error: User ID not found in SharedPreferences.');
      return;
    }

    const String apiUrl =
        'http://209.38.227.170:3000/users/profile-page/get-favorite-locations';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'_id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          favoriteLocations =
              List<String>.from(responseData['favourites'] ?? []);
        });
        print('Favorite locations: $favoriteLocations');
      } else {
        print(
            'Failed to fetch favorite locations. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorite locations: $e');
    }
  }

  Future<bool> _addLocationToBackend(String location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('id')!;
    const String apiUrl =
        'http://209.38.227.170:3000/users/profile-page/add-favorite-locations';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'_id': userId, 'location': location}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Location added successfully: ${responseData['favourites']}');
        return true;
      } else {
        print('Failed to add location');
        return false;
      }
    } catch (e) {
      print('Error adding location: $e');
      return false;
    }
  }

  Future<bool> _deleteLocationFromBackend(String location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('id')!;
    const String apiUrl =
        'http://209.38.227.170:3000/users/profile-page/delete-favorite-locations';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'_id': userId, 'location': location}),
      );

      if (response.statusCode == 200) {
        print('Location deleted successfully.');
        return true;
      } else {
        print('Failed to delete location');
        return false;
      }
    } catch (e) {
      print('Error deleting location: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Favorite Locations'),
        backgroundColor: Colors.green[600],
      ),
      body: favoriteLocations.isEmpty
          ? const Center(
              child: Text('No favorite locations added yet.'),
            )
          : ListView.builder(
              itemCount: favoriteLocations.length,
              itemBuilder: (context, index) {
                final location = favoriteLocations[index];
                return ListTile(
                  title: Text(
                    location,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red, // Change the delete icon color to red
                    ),
                    onPressed: () async {
                      final success =
                          await _deleteLocationFromBackend(location);
                      if (success) {
                        setState(() {
                          favoriteLocations.remove(location);
                        });
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationModal(context),
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddLocationModal(BuildContext context) {
    String searchQuery = '';
    List<String> filteredCityOptions = List.from(_cityOptions);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SizedBox(
                height: 400,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search locations',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (query) {
                          searchQuery = query.toLowerCase();
                          setModalState(() {
                            filteredCityOptions = _cityOptions
                                .where((city) =>
                                    city.toLowerCase().contains(searchQuery))
                                .toList();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCityOptions.length,
                        itemBuilder: (context, index) {
                          final city = filteredCityOptions[index];
                          return ListTile(
                            title: Text(city),
                            onTap: () async {
                              if (!favoriteLocations.contains(city)) {
                                final success =
                                    await _addLocationToBackend(city);
                                if (success) {
                                  setState(() {
                                    favoriteLocations.add(city);
                                  });
                                  Navigator.pop(context);
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
