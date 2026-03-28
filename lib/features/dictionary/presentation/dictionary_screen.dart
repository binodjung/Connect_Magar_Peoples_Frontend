import 'dart:async';
import 'package:flutter/material.dart';
import '../data/word_model.dart';
import '../data/dictionary_service.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final DictionaryService _service = DictionaryService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Word> _words = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasNext = false;
  String? _error;
  int _currentPage = 1;
  String _searchQuery = '';
  String _activeLetter = '';
  Timer? _debounce;

  // All letters A-Z for the filter chips
  static const List<String> _letters = [
    'ALL', 'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  @override
  void initState() {
    super.initState();
    _loadWords(reset: true);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text == _searchQuery) return;
    
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = _searchController.text;
      _activeLetter = '';       // clear letter filter when typing
      _loadWords(reset: true);
    });
  }

  void _onLetterTap(String letter) {
    final newLetter = letter == 'ALL' ? '' : letter;
    if (newLetter == _activeLetter) return;
    setState(() {
      _activeLetter = newLetter;
      _searchController.clear();
      _searchQuery = '';
    });
    _loadWords(reset: true);
  }

  Future<void> _loadWords({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _words = [];
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final result = await _service.fetchWords(
        search: _searchQuery,
        letter: _activeLetter,
        page: _currentPage,
      );
      if (!mounted) return;
      setState(() {
        _words = reset ? result.words : [..._words, ...result.words];
        _hasNext = result.hasNext;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadMore() {
    _currentPage++;
    _loadWords();
  }

  // Group words by first letter for section headers
  Map<String, List<Word>> get _grouped {
    final map = <String, List<Word>>{};
    for (final w in _words) {
      final key = w.magarWord.isNotEmpty
          ? w.magarWord[0].toUpperCase()
          : '#';
      map.putIfAbsent(key, () => []).add(w);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Magar Dictionary',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Magar or English word…',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8B0000)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ── Letter filter chips ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _letters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final letter = _letters[index];
                  final isActive = letter == 'ALL'
                      ? _activeLetter.isEmpty
                      : _activeLetter == letter;
                  return GestureDetector(
                    onTap: () => _onLetterTap(letter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF8B0000)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: letter == 'ALL' ? 10 : 14,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B0000)),
                  )
                : _error != null
                    ? _buildError()
                    : _words.isEmpty
                        ? _buildEmpty()
                        : _buildWordList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList() {
    final grouped = _grouped;
    final sections = grouped.keys.toList();

    // Build flat list of: section headers + word tiles + optional load more
    final List<Widget> items = [];

    for (final letter in sections) {
      // Section header
      items.add(_buildSectionHeader(letter));
      for (final word in grouped[letter]!) {
        items.add(_buildWordCard(word));
      }
    }

    // Pagination footer
    if (_hasNext) {
      items.add(_buildLoadMoreButton());
    } else if (_words.isNotEmpty) {
      items.add(_buildEndCaption());
    }

    return RefreshIndicator(
      color: const Color(0xFF8B0000),
      onRefresh: () => _loadWords(reset: true),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: items,
      ),
    );
  }

  Widget _buildSectionHeader(String letter) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(height: 1, width: 60, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildWordCard(Word word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.magarWord,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  word.englishMeaning,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _isLoadingMore
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B0000),
                strokeWidth: 2,
              ),
            )
          : OutlinedButton.icon(
              onPressed: _loadMore,
              icon: const Icon(Icons.expand_more),
              label: const Text('Load more words'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B0000),
                side: const BorderSide(color: Color(0xFF8B0000)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
    );
  }

  Widget _buildEndCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          '${_words.length} word${_words.length == 1 ? '' : 's'} found',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No words found for "$_searchQuery"'
                : _activeLetter.isNotEmpty
                    ? 'No words starting with "$_activeLetter"'
                    : 'Dictionary is empty',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty || _activeLetter.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _activeLetter = '');
                _loadWords(reset: true);
              },
              child: const Text('Clear filter',
                  style: TextStyle(color: Color(0xFF8B0000))),
            ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Failed to load dictionary',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _loadWords(reset: true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
