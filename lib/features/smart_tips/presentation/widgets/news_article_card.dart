import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/smart_tips/presentation/widgets/local_ai_service.dart';
import 'package:ikuku/services/rss_service.dart';
import 'package:ikuku/theme/app_theme.dart';

class NewsArticleCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  State<NewsArticleCard> createState() => _NewsArticleCardState();
}

class _NewsArticleCardState extends State<NewsArticleCard> {
  bool _showAiSummary = false;
  String _summaryText = "";
  bool _isAiThinking = false;

  void _getOfflineSummary() async {
    setState(() {
      _isAiThinking = true;
      _showAiSummary = true;
    });

    final ai = LocalAiService();
    final summary = await ai.summarizeArticle(
      widget.article.title,
      widget.article.description,
    );

    if (mounted) {
      setState(() {
        _summaryText = summary;
        _isAiThinking = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.article.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  widget.article.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.article.source} • ${DateFormat.yMMMd().format(widget.article.publishDate)}',
                    style: TextStyle(fontSize: 14, color: CustomColors.text),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.article.description,
                    style: TextStyle(color: CustomColors.text, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: widget.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Read Full Article'),
                      ),
                  OutlinedButton.icon(
                        onPressed: _getOfflineSummary,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomColors.primary,
                          side: const BorderSide(color: CustomColors.primary),
                        ),
                        icon: const Icon(Icons.psychology, size: 18),
                        label: const Text('AI Summary'),
                      ),
                    ],
                  ),
            
                  if (_showAiSummary) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: _isAiThinking
                          ? Column(
                              children: [
                                LinearProgressIndicator(color: CustomColors.primary),
                                SizedBox(height: 8),
                                Text("On-Device AI is analyzing...", style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: CustomColors.text,
                      fontWeight: FontWeight.bold,
                                )
                      ),
                              ],
                            )
                          : Text(
                              _summaryText,
                              style: TextStyle(
                                color: CustomColors.text,
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ],
                  ],
                
              ),
      
              
            ),
            ]
        ),
    )
    );
    
  }
}
