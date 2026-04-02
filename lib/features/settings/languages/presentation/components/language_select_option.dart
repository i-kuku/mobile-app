import 'package:flutter/widgets.dart';
import 'package:ikuku/features/settings/languages/model/language.dart';
import 'package:ikuku/features/settings/languages/presentation/components/language_option_widget.dart';

class LanguageSelectOption extends StatelessWidget {
  const LanguageSelectOption({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return LanguageOptionWidget(language: languages[index]);
      },
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemCount: languages.length,
    );
  }
}
