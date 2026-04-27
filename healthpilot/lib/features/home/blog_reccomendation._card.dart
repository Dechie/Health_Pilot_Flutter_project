import 'package:flutter/material.dart';
import 'package:healthpilot/core/widgets/safe_assets.dart';
import 'package:healthpilot/theme/app_theme.dart';

import 'package:healthpilot/features/articles/article_screen.dart';

class BlogRecomendationCard extends StatelessWidget {
  final String img;
  final String title;
  final String description;
  final String blogType;
  const BlogRecomendationCard({
    super.key,
    required this.img,
    required this.title,
    required this.description,
    required this.blogType,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        if (blogType == 'articles') {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const ArticleScreen()));
        }

        if (blogType == 'consult') {}
      },
      child: Stack(
        children: [
          Container(
            width: size.width * 0.04,
            height: size.height * 0.3,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                blurRadius: 30,
                spreadRadius: 0,
                color: const Color.fromRGBO(46, 46, 46, 0.07),
              )
            ]),
          ),
          Container(
            margin: EdgeInsets.only(left: size.width * 0.05),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(size.width * 0.03),
            ),
            width: size.width * 0.5,
            height: size.height * 0.3,
            child: Column(
              children: [
                Card(
                  // elevation: 3,
                  color: Colors.transparent,
                  child: Container(
                    height: size.height * 0.15,
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                        gradient: AppTheme.homeOverviewGradient(context)),
                    child: SafeSvgAsset(
                      img,
                      height: size.height * 0.12,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                    size.width * 0.02,
                  ),
                  width: double.infinity,
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: cs.onSurface),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: size.width * 0.02,
                  ),
                  width: double.infinity,
                  child: Text(
                    description,
                    style: AppTheme.blogCardDescription(context)
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
