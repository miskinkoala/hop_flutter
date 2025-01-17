import 'package:flutter/material.dart';

class ReviewsPage extends StatelessWidget {
  final List<Map<String, dynamic>> reviews = [
    {
      'reviewer': 'John Doe',
      'rating': 5,
      'comment': 'Great driver! The trip was smooth and enjoyable.',
      'date': '2024-12-10'
    },
    {
      'reviewer': 'Jane Smith',
      'rating': 4,
      'comment': 'Good experience overall. The car was clean and comfortable.',
      'date': '2024-11-25'
    },
    {
      'reviewer': 'Alice Johnson',
      'rating': 3,
      'comment': 'Decent trip, but there was a slight delay at the start.',
      'date': '2024-11-15'
    },
  ];

  ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Reviews'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review['reviewer'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < review['rating']
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.yellow[700],
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(review['comment'],
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(review['date'],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
