import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pages/trip_info.dart';
import 'pages/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteLocationsPage extends StatefulWidget {
  const FavoriteLocationsPage({super.key});

  @override
  _FavoriteLocationsPageState createState() => _FavoriteLocationsPageState();
}

class _FavoriteLocationsPageState extends State<FavoriteLocationsPage> {
  late Future<List<Map<String, dynamic>>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = fetchTrips();
  }

  Future<List<Map<String, dynamic>>> fetchTrips() async {
    const String apiUrl =
        "http://209.38.227.170:3000/trip/list-fav-location-trips";

    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    String? userId = prefs2.getString('id');

    if (userId == null) {
      throw Exception("User ID not found in shared preferences.");
    }

    try {
      final response = await http.get(Uri.parse("$apiUrl?userId=$userId"));

      if (response.statusCode == 200) {
        List<dynamic> tripsData = jsonDecode(response.body);
        return tripsData.map((trip) => trip as Map<String, dynamic>).toList();
      } else {
        throw Exception(
            "Failed to load trips. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching trips: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            automaticallyImplyLeading: false, // Removes the back button
            backgroundColor: Colors.green,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Color.fromARGB(255, 13, 95, 31)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ],
            toolbarHeight: 30,
            title: Text(
              "Favorite Locations",
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color.fromARGB(255, 13, 95, 31),
                ),
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _tripsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No trips found"));
            }

            final trips = snapshot.data!;
            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('tripId', trip['_id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripInfoPage(
                          departureTime: trip['time'],
                          startLocation: trip['departure'],
                          endLocation: trip['arrival'],
                          date: trip['date'],
                          price: trip['price'].toString(),
                          driverName: trip['driverName'],
                          rating: trip['rating'].toString(),
                          seatsAvailable: trip['seatsAvailable'].toString(),
                          carDetails: trip['carDetails'],
                        ),
                      ),
                    );
                  },
                  child: _buildLocationCard(trip),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> trip) {
    return Card(
      color: const Color.fromARGB(255, 206, 234, 214),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeLocationRow(trip['time'], trip['departure']),
                Text(
                  '${trip['price']} \$',
                  style: GoogleFonts.inriaSans(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Column(
              children: [
                Icon(Icons.arrow_downward, size: 32, color: Colors.black54),
                SizedBox(height: 4),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeLocationRow('', trip['arrival']),
                Row(
                  children: [
                    Text(
                      trip['numberOfPassengers'].toString(),
                      style: GoogleFonts.inriaSans(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.person, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  trip['driverName'],
                  style: GoogleFonts.inriaSans(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    trip['rating'].round(),
                    (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              trip['date'],
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLocationRow(String time, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: GoogleFonts.inriaSans(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          location,
          style: GoogleFonts.inriaSans(
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
