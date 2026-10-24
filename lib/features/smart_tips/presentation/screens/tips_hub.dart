import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/smart_tips/model/smart_tips_model.dart';
import 'package:ikuku/features/smart_tips/presentation/widgets/external_tip_card.dart';
import 'package:ikuku/features/smart_tips/presentation/widgets/news_article_card.dart';
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
final Map<String, Map<String, String>> blogDataMap = {
  '1': {
    'emoji': '🐔',
    'title': 'farm_records_blog_title'.tr(),
    'summary': 'farm_records_blog_summary'.tr(),
    'content': "farm_records_blog_content".tr(),
  },
  '2': {
    'emoji': '🧫',
    'title': 'disease_management_blog_title'.tr(),
    'summary': 'disease_management_blog_summary'.tr(),
    'content': 'disease_management_blog_content'.tr(),
  },
  '3': {
    'emoji': '🏠',
    'title': 'housing_biosecurity_blog_title'.tr(),
    'summary': 'housing_biosecurity_blog_summary'.tr(),
    'content': 'housing_biosecurity_blog_content'.tr(),
  },
  '4': {
    'emoji': '🐣',
    'title': 'chicken_breed_blog_title'.tr(),
    'summary': 'chicken_breed_blog_summary'.tr(),
    'content': 'chicken_breed_blog_content'.tr(),
  },
  '5': {
    'emoji': '🌾',
    'title': 'climate_smart_blog_title'.tr(),
    'summary': 'climate_smart_blog_summary'.tr(),
    'content': 'climate_smart_blog_content'.tr(),
  },
  '6': {
    'emoji': '💰',
    'title': 'finance_management_blog_title'.tr(),
    'summary': 'finance_management_blog_summary'.tr(),
    'content': 'finance_management_blog_content'.tr(),
  },
};

class TipsHub extends StatefulWidget {
  const TipsHub({super.key});

  @override
  State<TipsHub> createState() => _TipsHubState();
}

class _TipsHubState extends State<TipsHub> {
  late Future<NewsFeed> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Falls back to the articles saved last time when offline.
    _newsFuture = RssService().loadNews();
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.tryParse(url);
    var opened = false;
    try {
      if (uri != null && url.isNotEmpty && await canLaunchUrl(uri)) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not open $url: $e');
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('could_not_open_article'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(
            Icons.arrow_back,
            size: 18,
            color: CustomColors.primary,
          ),
        ),
        title: Text(
          "smart_tips_title".tr(),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: CustomColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "educational_resources".tr(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: CustomColors.text,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "educational_blog_subtitle".tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: CustomColors.text),
              ),
              SizedBox(height: 16),

              ...educationaltips.map(
                (currentTip) => TipCard(
                  tip: currentTip,
                  onReadMorePressed: () {
                    final selectedBlog = blogDataMap[currentTip.id];
                    if (selectedBlog != null) {
                      context.push(
                        '/smart-tips/tip_detail',
                        extra: selectedBlog,
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                "latest_poultry_news".tr(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 20,
                  color: CustomColors.text,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "latest_Poultry_news_summary".tr(),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: CustomColors.text,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<NewsFeed>(
                future: _newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final feed = snapshot.data;
                  final articles = feed?.articles ?? const <NewsArticle>[];
                  final offline = feed?.isSaved ?? true;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (offline)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cloud_off_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'news_offline'.tr(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (articles.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'no_news_articles_available'.tr(),
                              style: TextStyle(color: CustomColors.text),
                            ),
                          ),
                        )
                      else
                        for (final currentArticle in articles)
                          NewsArticleCard(
                            article: currentArticle,
                            onTap: () {
                              _openArticle(currentArticle.link);
                            },
                          ),
                    ],
                  );
                },
              ),
              ...poultryTips.map(
                (currentTip) => TipCard(
                  tip: currentTip,
                  onReadMorePressed: () {
                    final selectedBlog = blogDataMap[currentTip.id];
                    if (selectedBlog != null) {
                      context.push(
                        '/smart-tips/tip_detail',
                        extra: selectedBlog,
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Text(
                "more_tips_from_trusted_African_poultry_farmers".tr(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: CustomColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              ExternalTipCard(),
            ],
          ),
        ),
      ),
    );
  }
}
