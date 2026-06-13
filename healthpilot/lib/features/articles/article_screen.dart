import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/asset_paths.dart';
import 'package:healthpilot/features/articles/article_detail_screen.dart';
import 'package:healthpilot/features/articles/article_feed_item.dart';
import 'package:healthpilot/features/articles/article_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final TextEditingController _articleSearchController =
      TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _articleSearchController.dispose();
    super.dispose();
  }

  void _showFilterShell() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Newest first'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              title: const Text('Oldest first'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              title: const Text('Most discussed'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(ArticleFeedItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(arguments: item),
        builder: (context) => const ArticleDetail(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<ArticleProvider>();
    final visible = _query.isEmpty
        ? provider.articles
        : provider.articles
            .where((a) => a.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final screenWidth = size.width;
            final screenHeight = size.height;

            return Column(
              children: [
                Row(
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
                          color: cs.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          color: cs.onSurface,
                          iconSize: screenWidth * 0.055,
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
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PlusJakartaSans',
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.04,
                        right: screenWidth * 0.04,
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.045,
                        height: screenWidth * 0.045,
                        child: SvgPicture.asset(
                          'assets/images/Vector.svg',
                          fit: BoxFit.contain,
                          colorFilter:
                              ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                CommentInputField(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  icon: Icons.search,
                  controller: _articleSearchController,
                  inputAction: TextInputAction.search,
                  hintText: 'Search For Articles',
                  onChanged: (v) => setState(() => _query = v.trim()),
                  suffixIcon: 'assets/Icons/setting.svg',
                  onSuffixTap: _showFilterShell,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      return ArticleCard(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        item: visible[index],
                        onOpen: _openDetail,
                        onShare: (item) {
                          Share.share(
                            '${item.title}\n\n${item.body}',
                            subject: item.title,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.item,
    required this.onOpen,
    required this.onShare,
  });

  final double screenWidth;
  final double screenHeight;
  final ArticleFeedItem item;
  final void Function(ArticleFeedItem item) onOpen;
  final void Function(ArticleFeedItem item) onShare;

  @override
  Widget build(BuildContext context) {
    final snippetLen = item.body.length < 125 ? item.body.length : 125;
    final snippet = item.body.substring(0, snippetLen);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onOpen(item),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        color: cs.surfaceContainerHighest,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              child: Image.asset(
                item.imageUrl,
                width: double.infinity,
                height: screenHeight * 0.12,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.17,
                          color: cs.onSurface,
                        ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.1),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurfaceVariant,
                              height: 1.0,
                              letterSpacing: -0.165,
                            ),
                        children: [
                          TextSpan(text: snippet),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => onOpen(item),
                              child: const Text(
                                '   Read more.',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.0,
                                  letterSpacing: -0.165,
                                  color: Color.fromRGBO(110, 182, 255, 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      cs.onSurface, BlendMode.srcIn),
                                  child: Image.asset(AssetPaths.articleLikePng),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  '${item.likes}',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                    letterSpacing: -0.165,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      cs.onSurface, BlendMode.srcIn),
                                  child:
                                      Image.asset(AssetPaths.articleCommentPng),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  '${item.commentsCount}',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                    letterSpacing: -0.165,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        cs.onSurface, BlendMode.srcIn),
                                    child: Image.asset(
                                        'assets/Icons/stopwatch .png'),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  '${item.readMinutes} min',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
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
                      ),
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.share_outlined,
                              size: 18,
                              color: cs.onSurface,
                            ),
                            onPressed: () => onShare(item),
                          ),
                          Icon(
                            Icons.more_vert_rounded,
                            size: 16,
                            color: cs.onSurface,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentInputField extends StatefulWidget {
  const CommentInputField({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.icon,
    required this.controller,
    required this.inputAction,
    required this.hintText,
    required this.onChanged,
    required this.suffixIcon,
    this.onSuffixTap,
  });

  final double screenWidth;
  final double screenHeight;
  final IconData? icon;
  final TextEditingController controller;
  final TextInputAction inputAction;
  final String hintText;
  final String? suffixIcon;
  final void Function(String)? onChanged;
  final VoidCallback? onSuffixTap;

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.04),
      child: Column(
        children: [
          SizedBox(
            height: widget.screenHeight * 0.07,
            child: TextFormField(
              onChanged: widget.onChanged,
              controller: widget.controller,
              textInputAction: widget.inputAction,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.165,
                  height: 18 / 14,
                ),
                prefixIcon: widget.icon != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.screenWidth * 0.03,
                        ),
                        child: Icon(
                          widget.icon,
                          color: cs.onSurfaceVariant,
                        ),
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? IconButton(
                        padding:
                            EdgeInsets.only(right: widget.screenWidth * 0.02),
                        onPressed: widget.onSuffixTap,
                        icon: SvgPicture.asset(
                          widget.suffixIcon!,
                          colorFilter:
                              ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  gapPadding: 12,
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1, color: cs.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  gapPadding: 12,
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1, color: cs.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  gapPadding: 12,
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1.5, color: cs.primary),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.screenHeight * 0.07,
                  horizontal: widget.screenWidth * 0.07,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
