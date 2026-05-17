import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/smart_tips/model/smart_tips_model.dart';
import 'package:ikuku/features/smart_tips/presentation/widgets/tip_card.dart';
import 'package:ikuku/services/rss_service.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

final List<SmartTips> educationaltips = [
  SmartTips(
    id: '1',
    title: "farm_records_blog_title".tr(),
    description: "farm_records_blog_summary".tr(),
    emoji: '🐔',
  ),
  SmartTips(
    id: '2',
    title: 'disease_management_blog_title'.tr(),
    description: 'disease_management_blog_summary'.tr(),
    emoji: '🧫',
  ),
];
final List<SmartTips> poultryTips = [
  SmartTips(
    id: '3',
    title: 'housing_biosecurity_blog_title'.tr(),
    description: 'housing_biosecurity_blog_summary'.tr(),
    emoji: '🏠',
  ),
  SmartTips(
    id: '4',
    title: 'chicken_breed_blog_title'.tr(),
    description: 'chicken_breed_blog_summary'.tr(),
    emoji: '🐣',
  ),
  SmartTips(
    id: '5',
    title: 'climate_smart_blog_title'.tr(),
    description: 'climate_smart_blog_summary'.tr(),
    emoji: '🌾',
  ),
  SmartTips(
    id: '6',
    title: 'finance_management_blog_title'.tr(),
    description: 'finance_management_blog_summary'.tr(),
    emoji: '💰',
  ),
];

class TipsHub extends StatefulWidget {
  
  const TipsHub({super.key});

  @override
  State<TipsHub> createState() => _TipsHubState();
}

class _TipsHubState extends State<TipsHub> {

   Future<void> _openArticle(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid article URL')));
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
      appBar: AppBar(
  backgroundColor: Colors.grey[400],
  elevation: 0,
  leading: InkWell(
    onTap: () => context.pop(),
    child: const Icon(Icons.arrow_back, size: 18, color: Colors.black),
  ),
  title: Text(
    "smart_tips_title".tr(),
    style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: CustomColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
  ),
  centerTitle: false, 
  titleSpacing: 0, 
),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "educational_resources".tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: CustomColors.text,fontSize: 25),
              ),
              SizedBox(height: 16),
              Text("educational_blog_subtitle".tr(),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: CustomColors.text),
              ),
              SizedBox(height: 16),

              ...educationaltips.map(
                (currentTip) =>
                    TipCard(tip: currentTip, onReadMorePressed: () {}),
              ),
              SizedBox(height: 16),
              Text(
                "Latest Poultry News",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 20,
                  color: CustomColors.text,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Stay updated with the latest poultry farming news and insights",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: CustomColors.text),
              ),
              SizedBox(height: 16),
               FutureBuilder<List<NewsArticle>>(
              future: RssService().fetchLatestNews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No news articles available',
                        style: TextStyle(
                          color: CustomColors.text,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.map((article) {
                    return GestureDetector(
                      onTap: () => _openArticle(article.link),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    '${article.source} • ${DateFormat.yMMMd().format(article.publishDate)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CustomColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    article.description,
                                    style: TextStyle(
                                      color: CustomColors.text,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _openArticle(article.link),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Read Full Article'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
              ...poultryTips.map(
                (currentTip) =>
                    TipCard(tip: currentTip, onReadMorePressed: () {}),
              ),
              SizedBox(height: 10),
              Text(
                "More tips from trusted African poultry farmers",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: CustomColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}
