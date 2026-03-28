import 'package:flutter/material.dart';
import '../data/history_model.dart';
import '../data/history_service.dart';
import '../data/history_pdf_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final int historyId;
  final String title;

  const HistoryDetailScreen({
    super.key,
    required this.historyId,
    required this.title,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final HistoryService _service = HistoryService();
  HistoryModel? _history;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistoryDetail();
  }

  Future<void> _loadHistoryDetail() async {
    try {
      final data = await _service.fetchHistoryDetail(widget.historyId);
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const maroonColor = Color(0xFF8B0000);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Match overall app background
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: maroonColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: maroonColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: maroonColor),
            onPressed: () => _downloadPdf(),
            tooltip: 'Download PDF',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: maroonColor))
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _history == null || _history!.sections == null || _history!.sections!.isEmpty
                  ? const Center(child: Text('No history content found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: _history!.sections!.length,
                      itemBuilder: (context, index) {
                        final section = _history!.sections![index];
                        return _buildClassicSection(section, index + 1);
                      },
                    ),
    );
  }

  Future<void> _downloadPdf() async {
    const maroonColor = Color(0xFF8B0000);
    if (_history != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record is downloading in pdf...'),
          backgroundColor: maroonColor,
          duration: Duration(seconds: 2),
        ),
      );

      await HistoryPdfService.generateAndDownloadPdf(_history!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record is downloaded in pdf'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildClassicSection(HistorySectionModel section, int sectionNumber) {
    const maroonColor = Color(0xFF8B0000);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: maroonColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
            ),
            child: Text(
              'SECTION $sectionNumber',
              style: const TextStyle(
                color: maroonColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          if (section.image != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    section.image!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator(color: maroonColor)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Text(
              section.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF333333),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.justify,
            ),
          ),

          // Footer separator
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: maroonColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
