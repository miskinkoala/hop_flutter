import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservationInfoPage extends StatelessWidget {
  final String departureTime;
  final String startLocation;
  final String endLocation;
  final String date;
  final String price;
  final String driverName;
  final String rating;
  final String seatsAvailable;
  final String carDetails;

  const ReservationInfoPage({
    Key? key,
    required this.departureTime,
    required this.startLocation,
    required this.endLocation,
    required this.date,
    required this.price,
    required this.driverName,
    required this.rating,
    required this.seatsAvailable,
    required this.carDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Reservation Details",
          style: GoogleFonts.inriaSans(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReservationCard(),
            const SizedBox(height: 20),
            _buildDriverInfo(),
            const SizedBox(height: 10),
            _buildCarDetails(),
            const Spacer(),
            _buildCancelButton(),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Developed by SUDO",
                style: GoogleFonts.inriaSans(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 206, 234, 214),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeLocation(departureTime, startLocation),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.arrow_downward, color: Colors.black54),
                SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            _buildTimeLocation('', endLocation),
            Text(
              "$date",
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$price \$',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLocation(String time, String location) {
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

  Widget _buildDriverInfo() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage('images/logo.jpeg'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              driverName,
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.inriaSans(
                    textStyle: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            carDetails,
            style: GoogleFonts.inriaSans(),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () {
        // Add your cancel reservation logic here
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "Cancel Reservation",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}