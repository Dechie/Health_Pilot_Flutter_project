// This is the screen where the user sees the detail of the article

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/features/articles/article_comment_screen.dart';
import 'package:healthpilot/features/articles/article_feed_item.dart';
import 'package:share_plus/share_plus.dart';

class ArticleDetail extends StatelessWidget {
  const ArticleDetail({super.key});

  ArticleFeedItem _itemFromRoute(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is ArticleFeedItem) return raw;
    if (raw is List<Map<String, dynamic>>) {
      return ArticleFeedItem.fromLegacyArguments(raw);
    }
    return ArticleFeedItem(
      id: 'fallback',
      title: 'Article',
      body: '',
      imageUrl: 'assets/images/old_woman.png',
      author: 'HealthPilot Team',
      publishedAt: DateTime(2022, 10, 23),
      readMinutes: 5,
      likes: 23,
      commentsCount: 12,
    );
  }

  void _share(ArticleFeedItem item) {
    Share.share(
      '${item.title}\n\n${item.body}',
      subject: item.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _itemFromRoute(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final screenWidth = size.width;
          final screenHeight = size.height;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.42,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(item.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomAppBar(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          onShare: () => _share(item),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenHeight * 0.04,
                            vertical: screenHeight * 0.03,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: screenWidth * 0.047,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.165,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                            'assets/Icons/stopwatch .png',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        '${item.readMinutes} min',
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          height: 1.0,
                                          letterSpacing: -0.165,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: screenWidth * 0.1),
                                  Row(
                                    children: [
                                      ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                        child: Image.asset('assets/Icons/like.png'),
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        '${item.likes}',
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          height: 1.0,
                                          letterSpacing: -0.165,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: screenWidth * 0.1),
                                  Row(
                                    children: [
                                      ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (context) =>
                                                    ArticleCommentScreen(
                                                  article: item,
                                                  comments: const [],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Image.asset(
                                            'assets/Icons/comment.png',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        '${item.commentsCount}',
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          height: 1.0,
                                          letterSpacing: -0.165,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.formattedPublishedDate,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 13.0 / 10.0,
                              letterSpacing: -0.165,
                            ),
                          ),
                          Text(
                            item.author,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 13.0 / 10.0,
                              letterSpacing: -0.165,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      IconButton(
                        onPressed: () => _share(item),
                        icon: const Icon(Icons.share_outlined),
                        tooltip: 'Share',
                      ),
                      Text(
                        item.body,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    this.onShare,
  });

  final double screenWidth;
  final double screenHeight;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.04,
            screenHeight * 0.02,
            0,
            0,
          ),
          child: Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(110, 182, 255, 0.7),
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back,
                  size: screenWidth * 0.06,
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
                iconSize: screenWidth * 0.055,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.05,
            screenHeight * 0.03,
            0,
            0,
          ),
          child: Text(
            'Articles',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ),
        const Spacer(),
        if (onShare != null)
          IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'Share',
          ),
        Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.04, right: 8),
          child: SizedBox(
            width: screenWidth * 0.04,
            height: screenWidth * 0.04,
            child: ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: SvgPicture.asset(
                'assets/images/Vector.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
