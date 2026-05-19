import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class TipDetailPage extends StatelessWidget {
  final Map<String, String> blogDataMap;

  const TipDetailPage({
    super.key,
    required this.blogDataMap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
         centerTitle: false,
         titleSpacing: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          blogDataMap['title'] ?? '',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold,fontSize: 15),
        ),
       
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(blogDataMap['emoji'] ?? '', style: TextStyle(fontSize: 32)),

                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    blogDataMap['title'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width:double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal),
              ),
              child: Text(
                blogDataMap['summary'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: CustomColors.text,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 16),
            MarkdownBody(
              data:blogDataMap['content']?? '',
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                strong: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.primary
              ),
              onPressed: (){context.pop();
              }, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close,size:16,color: Colors.white,),
                  SizedBox(width: 8),
                  Text('close article'.tr(),
                  style: 
                  Theme.of(context).textTheme.bodyLarge?.copyWith(color:Colors.white,fontSize: 16),
                  ),
                ],
              )
              )
          ],
        ),
      ),
    );
  }
}
