import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ride_info_page.dart';
import 'reservation_info_page.dart';
import 'package:intl/intl.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  _MyTripsPageState createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  List<Map<String, dynamic>> _myRides = [];
  bool _isLoading = false;
  String _selectedOption = 'myRides'; // Default option: "myRides"
  String _noDataMessage = ''; // To hold the no data message

  // Date formatter
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  Future<void> fetchData(String option) async {
    setState(() {
      _isLoading = true; // Show loading indicator
      _myRides = []; // Reset trips before fetching new ones
      _noDataMessage = ''; // Reset no data message
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('id');
      String url;

      if (option == 'myRides') {
        url = 'http://209.38.227.170:3000/trip/list-my-rides';
      } else {
        url = 'http://209.38.227.170:3000/trip/list-my-reservation';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'_id': userId}),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _myRides = data['enrichedTrips'] != null
              ? List<Map<String, dynamic>>.from(data['enrichedTrips'])
              : [];

          // Set the no data message if the list is empty
          if (_myRides.isEmpty) {
            _noDataMessage = option == 'myRides'
                ? 'No rides available'
                : 'No reservations available';
          }
        });
      } else {
        throw Exception('Failed to fetch rides');
      }
    } catch (e) {
      print('Error fetching rides: $e');
      setState(() {
        _noDataMessage = 'No Info';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(
        'myRides'); // Automatically fetch 'myRides' when the page is first opened
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('My Trips'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Toggle Options Row
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // My Rides Option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOption = 'myRides';
                    });
                    fetchData('myRides'); // Fetch My Rides
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car,
                        color: _selectedOption == 'myRides'
                            ? Colors.green
                            : Colors.grey,
                        size: 40,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'My Rides',
                        style: TextStyle(
                          color: _selectedOption == 'myRides'
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 40), // Add spacing between the two options
                // My Reservations Option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOption = 'myReservations';
                    });
                    fetchData('myReservations'); // Fetch My Reservations
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.flag,
                        color: _selectedOption == 'myReservations'
                            ? Colors.green
                            : Colors.grey,
                        size: 40,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'My Reservations',
                        style: TextStyle(
                          color: _selectedOption == 'myReservations'
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Loading Indicator or ListView
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _myRides.isEmpty
                  ? Center(
                      child: Text(_noDataMessage,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.grey)))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _myRides.length,
                        itemBuilder: (context, index) {
                          final ride = _myRides[index];
                          final date = ride['date'] != null
                              ? dateFormatter
                                  .format(DateTime.parse(ride['date']))
                              : ''; // Format the date
                          final time =
                              ride['time'] ?? ''; // Time directly from database

                          return GestureDetector(
                            onTap: () {
                              // Navigate to the appropriate page based on the selected option
                              if (_selectedOption == 'myRides') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RideInfoPage(
                                      departureTime: time,
                                      startLocation: ride['departure'] ?? '',
                                      endLocation: ride['arrival'] ?? '',
                                      date: date,
                                      price: (ride['price'] ?? 0)
                                          .toString(), // Convert int to String
                                      driverName: ride['driverName'] ?? '',
                                      rating: (ride['driverRating'] ?? 0)
                                          .toString(), // Convert rating to String if it's a number
                                      seatsAvailable: (ride['seatsAvailable'] ??
                                              0)
                                          .toString(), // Convert seats to String if it's a number
                                      carDetails: ride['carDetails'] ?? '',
                                    ),
                                  ),
                                );
                              } else if (_selectedOption == 'myReservations') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservationInfoPage(
                                      departureTime: time,
                                      startLocation: ride['departure'] ?? '',
                                      endLocation: ride['arrival'] ?? '',
                                      date: date,
                                      price: (ride['price'] ?? 0)
                                          .toString(), // Convert int to String
                                      driverName: ride['driverName'] ?? '',
                                      rating: (ride['driverRating'] ?? 0)
                                          .toString(), // Convert rating to String if it's a number
                                      seatsAvailable: (ride['seatsAvailable'] ??
                                              0)
                                          .toString(), // Convert seats to String if it's a number
                                      carDetails: ride['carDetails'] ?? '',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              color: const Color.fromARGB(255, 206, 234, 214),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From: ${ride['departure'] ?? 'Unknown'}\n'
                                      'To: ${ride['arrival'] ?? 'Unknown'}\n'
                                      'Date: $date\n'
                                      'Time: $time', // Display time directly
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      '${ride['driverName'] ?? 'Unknown Driver'}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
     );
  }
}