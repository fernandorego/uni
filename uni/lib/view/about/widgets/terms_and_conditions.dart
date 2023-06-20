import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uni/controller/load_static/terms_and_conditions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni/generated/l10n.dart';


class TermsAndConditions extends StatelessWidget {

  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String termsAndConditionsSaved = S.of(context).loading_terms;
    final Future<String> termsAndConditionsFuture = readTermsAndConditions();
    return FutureBuilder(
        future: termsAndConditionsFuture,
        builder:
            (BuildContext context, AsyncSnapshot<String> termsAndConditions) {
          if (termsAndConditions.connectionState == ConnectionState.done &&
              termsAndConditions.hasData) {
            termsAndConditionsSaved = termsAndConditions.data!;
          }
          return MarkdownBody(
            styleSheet: MarkdownStyleSheet(),
            shrinkWrap: false,
            data: termsAndConditionsSaved,
            onTapLink: (text, url, title) async {
              if (await canLaunchUrl(Uri.parse(url!))) {
                await launchUrl(Uri.parse(url));
              }
            },
          );
        });
  }
}
