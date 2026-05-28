import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalTip {
  final String title;
  final String source;
  final Uri url;

  ExternalTip({required this.title, required this.source, required this.url});
}

class ExternalTipCard extends StatelessWidget {
  const ExternalTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ExternalTip> externalTips = [
      ExternalTip(
        title: 'PoultryWorldBasics: Biosecurity Basics',
        source: 'Poultry World',
        url: Uri.parse(
          'https://www.poultryworld.net/health-nutrition/biosecurity/',
        ),
      ),
      ExternalTip(
        title: 'ILRI: African Poultry Insights',
        source: 'ILRI',
        url: Uri.parse('https://www.ilri.org/tags/poultry'),
      ),
      ExternalTip(
        title: 'CGIAR: Smallholder Poultry Resources',
        source: 'CGIAR',
        url: Uri.parse('https://www.cgiar.org/initiative/animal-source-foods/'),
      ),
    ];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      itemCount: externalTips.length,
      itemBuilder: (context, index) {
        final externalTip = externalTips[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: Icon(Icons.public, color: Colors.blueGrey),
            title: Text(externalTip.title),
            subtitle: Text(externalTip.source),
            trailing: Icon(Icons.open_in_new),
            onTap: () async {
              if (await canLaunchUrl(externalTip.url)) {
                final launched = await launchUrl(
                  externalTip.url,
                  mode: LaunchMode.externalApplication,
                );
                if (!launched && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open link')),
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No app found to open link'),
                      ),
                    );
                  }
                }
              }
            },
          ),
        );
      },
    );
  }
}
