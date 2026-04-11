import 'package:flutter/material.dart';

class LipiLetterbookScreen extends StatefulWidget {
  const LipiLetterbookScreen({super.key});

  @override
  State<LipiLetterbookScreen> createState() => _LipiLetterbookScreenState();
}

class _LipiLetterbookScreenState extends State<LipiLetterbookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color maroonColor = const Color(0xFF8B0000); // Updated to match other screens

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Akkha Magar Lipi'),
        backgroundColor: maroonColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Alphabets', icon: Icon(Icons.sort_by_alpha)),
            Tab(text: 'Numbers', icon: Icon(Icons.format_list_numbered)),
            Tab(text: 'Words', icon: Icon(Icons.menu_book)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImagePanel(
            context,
            'Images/Akkha lipi.png',
            'Vowels & Consonants',
            'Learn the foundational alphabets of the Magar language.',
          ),
          _buildImagePanel(
            context,
            'Images/number script (1).png',
            'Numbers Script',
            'Learn how to write numbers in Magar Lipi.',
          ),
          _buildWordsGrid(context),
        ],
      ),
    );
  }

  Widget _buildImagePanel(BuildContext context, String imagePath, String title, String subtitle) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: maroonColor.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: maroonColor.withOpacity(0.1))),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: maroonColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        Expanded(
          child: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => _buildErrorWidget(imagePath),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordsGrid(BuildContext context) {
    final List<String> wordLabels = [
      'paaka', 'thuppa', 'ijjhat', 'ijjhata', 'birseyo',
      'haraeyo', 'selayo', 'hidaleyo', 'pidaluu', 'gichhaeyo',
      'biraloo karaune', 'hudeyaa', 'dieyako', 'gayo'
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: maroonColor.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: maroonColor.withOpacity(0.1))),
          ),
          child: Column(
            children: [
              Text(
                'Vocabulary Practice',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: maroonColor),
              ),
              const SizedBox(height: 8),
              const Text(
                'Explore basic words constructed with Akkha Lipi.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 48,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: 14,
            itemBuilder: (context, index) {
              // file names are word1 akkha.png, word2 script.png, ... word14 script.png
              String assetName = index == 0 ? 'Images/word1 akkha.png' : 'Images/word${index + 1} script.png';
              
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, assetName),
                child: Container(
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
                    border: Border.all(color: maroonColor.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              assetName,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: maroonColor.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    wordLabels[index],
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.open_in_full,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                              ],
                            ),
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
    );
  }

  void _showFullScreenImage(BuildContext context, String assetName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  maxScale: 5.0,
                  minScale: 1.0,
                  child: Image.asset(
                    assetName, 
                    fit: BoxFit.contain, 
                    width: double.infinity, 
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String path) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text(
          'Image not found:\n$path',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
