import 'package:flutter/material.dart';
import 'quiz_game_screen.dart';

class QuizSelectionScreen extends StatelessWidget {
  const QuizSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Quiz Category'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test your knowledge!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a category to start the 60-second quiz.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildCategoryCard(context, 'Language', 'language', Icons.language, Colors.blue),
            const SizedBox(height: 16),
            _buildCategoryCard(context, 'Culture', 'culture', Icons.festival, Colors.orange),
            const SizedBox(height: 16),
            _buildCategoryCard(context, 'History', 'history', Icons.history_edu, Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String category, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizGameScreen(category: category, categoryTitle: title),
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Icon(icon, size: 50, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
