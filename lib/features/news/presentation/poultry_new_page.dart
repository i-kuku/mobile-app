import 'package:flutter/material.dart';
import 'package:ikuku/services/rss_service.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PoultryNewsPage extends StatefulWidget {
  const PoultryNewsPage({super.key});

  @override
  State<PoultryNewsPage> createState() => _PoultryNewsPageState();
}

class _PoultryNewsPageState extends State<PoultryNewsPage> {
  final RssService _rssService = RssService();
  bool _isLoading = true;
  List<NewsArticle> _articles = [];
  final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final cachedArticles = await _rssService.getCachedArticles();
      if (mounted) {
        setState(() {
          _articles = cachedArticles;
          _isLoading = cachedArticles.isEmpty;
        });
      }
      final freshArticles = await _rssService.fetchLatestNews();
      if (mounted) {
        setState(() {
          _articles = freshArticles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading news: $e')));
      }
    }
  }

  Future<void> _openArticle(String url) async {
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid article URL')));
      }
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Cannot open URL: $url')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening article: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poultry News')),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return GestureDetector(
                    onTap: () => _openArticle(article.link),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.imageUrl != null)
                            if (article.imageUrl != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  article.imageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          height: 200,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
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
                                  article.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: CustomColors.text,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${article.source} • ${_dateFormat.format(article.publishDate)}',
                                        style: TextStyle(
                                          color: CustomColors.text,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          _openArticle(article.link),
                                      child: const Text('Read More'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
  }