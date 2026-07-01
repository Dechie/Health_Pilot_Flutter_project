import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:healthpilot/features/ads/ads_provider.dart';
import '../../theme/app_theme.dart';

class AdWidget extends StatefulWidget {
  const AdWidget({super.key});

  @override
  State<AdWidget> createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    final ads = context.watch<AdsProvider>().ads;

    // No ads → don't reserve space.
    if (ads.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: size.height * 0.2,
      decoration: AppTheme.homeOverviewBoxDecoration(context),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return GestureDetector(
                onTap: () => context.read<AdsProvider>().recordClick(ad.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        ad.title,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (ad.body != null && ad.body!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        ad.body!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          Container(
            alignment: const Alignment(0, 0.75),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: ads.length,
              effect: ExpandingDotsEffect(
                  activeDotColor: cs.primary, dotColor: cs.primaryContainer),
            ),
          )
        ],
      ),
    );
  }
}
