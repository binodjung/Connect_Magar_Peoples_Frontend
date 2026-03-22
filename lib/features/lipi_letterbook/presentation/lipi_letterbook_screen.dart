import 'package:flutter/material.dart';

class LipiLetterbookScreen extends StatelessWidget {
  const LipiLetterbookScreen({Key? key}) : super(key: key);

  final Color maroonColor = const Color(0xFF801520); // Maroon from the image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: maroonColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Magarlipi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // MAROON HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: maroonColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: const Text(
              'Vowels and Consonants',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // WHITE CONTENT AREA WITH SHADOW CARD (like in the image)
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Maroon background part extending below header
                Container(
                  height: 100,
                  width: double.infinity,
                  color: maroonColor,
                ),
                
                // Actual Image Content in a Card/Container
                Positioned.fill(
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.asset(
                              'Images/Akkha lipi.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Text('Image not found. Ensure "Images/Akkha lipi.png" exists and is registered in pubspec.yaml.'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom area to complete the design from image
          Container(
            height: 100,
            width: double.infinity,
            color: maroonColor,
          ),
        ],
      ),
    );
  }
}
