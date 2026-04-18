import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'article_detail_screen.dart';

// ignore: must_be_immutable
class ArticleScreen extends StatelessWidget {
  ArticleScreen({super.key});

  final TextEditingController articleSearchController = TextEditingController();
  List<ArticleModel> articles = [
    ArticleModel(
        title: 'Why are we growing old?',
        detil:
            "Lorem ipsum dolor sit amet consectetur. Donec ultrices enim purus at nisl morbi pretium elit. Sit aliquam tempus felis porttitor arcu. Placerat viverra feugiat tristique etiam volutpat. Mi faucibus in arcu integer ipsum. Iaculis cursus orci nunc laoreet sed et tortor mollis id. Dolor pulvinar turpis aenean facilisi dignissim. Proin mi nullam nibh adipiscing mauris facilisi aliquam urna adipiscing. Orci sagittis velit amet elit condimentum enim purus. Dolor volutpat est facilisi enim sit pulvinar diam malesuada. Est pellentesque lorem laoreet sit blandit amet maecenas. Turpis ornare in nunc ornare. Sed tellus ut lorem enim morbi cursus sagittis. Nibh ipsum lacus lectus eros et pharetra pretium et porta. Arcu risus interdum tellus mattis. Mi mus sagittis adipiscing lectus nunc orci risus. Leo aliquet pellentesque adipiscing sit viverra morbi porttitor viverra et. Accumsan nisi nec dolor dictumst a faucibus. In id iaculis feugiat justo. Risus urna egestas adipiscing elementum. Gravida fringilla fermentum augue diam massa mauris imperdiet in. Eu ultricies aliquam nisl condimentum arcu viverra. Pretium enim sed faucibus mi. Vel sed in id vitae. Duis ultrices leo tortor nisi libero maecenas.",
        imageurl: 'assets/images/old_woman.png'),
    ArticleModel(
        title: 'why  old',
        detil:
            "Lorem ipsum dolor sit amet consectetur. Donec ultrices enim purus at nisl morbi pretium elit. Sit aliquam tempus felis porttitor arcu. Placerat viverra feugiat tristique etiam volutpat. Mi faucibus in arcu integer ipsum. Iaculis cursus orci nunc laoreet sed et tortor mollis id. Dolor pulvinar turpis aenean facilisi dignissim. Proin mi nullam nibh adipiscing mauris facilisi aliquam urna adipiscing. Orci sagittis velit amet elit condimentum enim purus. Dolor volutpat est facilisi enim sit pulvinar diam malesuada. Est pellentesque lorem laoreet sit blandit amet maecenas. Turpis ornare in nunc ornare. Sed tellus ut lorem enim morbi cursus sagittis. Nibh ipsum lacus lectus eros et pharetra pretium et porta. Arcu risus interdum tellus mattis. Mi mus sagittis adipiscing lectus nunc orci risus. Leo aliquet pellentesque adipiscing sit viverra morbi porttitor viverra et. Accumsan nisi nec dolor dictumst a faucibus. In id iaculis feugiat justo. Risus urna egestas adipiscing elementum. Gravida fringilla fermentum augue diam massa mauris imperdiet in. Eu ultricies aliquam nisl condimentum arcu viverra. Pretium enim sed faucibus mi. Vel sed in id vitae. Duis ultrices leo tortor nisi libero maecenas.",
        imageurl: 'assets/images/old_woman.png'),
    ArticleModel(
        title: 'why gett old',
        detil:
            "Lorem ipsum dolor sit amet consectetur. Donec ultrices enim purus at nisl morbi pretium elit. Sit aliquam tempus felis porttitor arcu. Placerat viverra feugiat tristique etiam volutpat. Mi faucibus in arcu integer ipsum. Iaculis cursus orci nunc laoreet sed et tortor mollis id. Dolor pulvinar turpis aenean facilisi dignissim. Proin mi nullam nibh adipiscing mauris facilisi aliquam urna adipiscing. Orci sagittis velit amet elit condimentum enim purus. Dolor volutpat est facilisi enim sit pulvinar diam malesuada. Est pellentesque lorem laoreet sit blandit amet maecenas. Turpis ornare in nunc ornare. Sed tellus ut lorem enim morbi cursus sagittis. Nibh ipsum lacus lectus eros et pharetra pretium et porta. Arcu risus interdum tellus mattis. Mi mus sagittis adipiscing lectus nunc orci risus. Leo aliquet pellentesque adipiscing sit viverra morbi porttitor viverra et. Accumsan nisi nec dolor dictumst a faucibus. In id iaculis feugiat justo. Risus urna egestas adipiscing elementum. Gravida fringilla fermentum augue diam massa mauris imperdiet in. Eu ultricies aliquam nisl condimentum arcu viverra. Pretium enim sed faucibus mi. Vel sed in id vitae. Duis ultrices leo tortor nisi libero maecenas.",
        imageurl: 'assets/images/old_woman.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: LayoutBuilder(
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
                        color: const Color.fromRGBO(110, 182, 255, 0.25),
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: const Color.fromRGBO(110, 182, 255, 1),
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
                      "Articles",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                        fontFamily: "PlusJakartaSans",
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.04,
                      // left: screenWidth * 0.39,
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                        left: screenWidth * 0.48,
                      ),
                      width: screenWidth * 0.04,
                      height: screenWidth * 0.04,
                      child: SvgPicture.asset(
                        'assets/images/Vector.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              CommentInputField(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  icon: Icons.search,
                  controller: articleSearchController,
                  inputAction: TextInputAction.search,
                  hintText: 'Search For Articles',
                  onChanged: null,
                  suffixIcon: 'Icons/setting.svg'),
              Container(
                height: screenHeight * 0.8,
                color: Colors.transparent,
                child: ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: articles[index].title,
                        detail: articles[index].detil,
                        imageurl: articles[index].imageurl);
                  },
                ),
              )
            ],
          );
        },
      )),
      resizeToAvoidBottomInset: false,
    );
  }
}

// Data structure of an article
class ArticleModel {
  final String title;
  final String detil;
  final String imageurl;

  ArticleModel(
      {required this.title, required this.detil, required this.imageurl});
}

// thsi  is the article card widget  for all comments to have  one card for each
class ArticleCard extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title;
  final String detail;
  final String imageurl;
  const ArticleCard(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.title,
      required this.detail,
      required this.imageurl});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> arg = [
      {'title': title},
      {'detail': detail}
    ];
    return InkWell(
      onTap: null,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenHeight * 0.05),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10)),
                  child: Image.asset(
                    imageurl,
                    width: double.infinity,
                    height: screenHeight * 0.12,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.17,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: screenWidth * 0.1,
                    ),
                    child: RichText(
                      text: TextSpan(
                          text: detail.substring(0, 125),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(42, 42, 42, 0.85),
                            height: 1.0,
                            letterSpacing: -0.165,
                          ),
                          children: [
                            TextSpan(
                                text: '   Read more.',
                                style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.0,
                                    letterSpacing: -0.165,
                                    color: Color.fromRGBO(110, 182, 255, 1)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      settings: RouteSettings(
                                        arguments: arg,
                                      ),
                                      builder: (context) {
                                        return const ArticleDetail();
                                      },
                                    ));
                                  })
                          ]),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                    Colors.black, BlendMode.srcIn),
                                child: Image.asset('assets/Icons/like.png'),
                              ),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              const Text(
                                '25',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                  letterSpacing: -0.165,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            width: screenWidth * 0.1,
                          ),
                          Row(
                            children: [
                              ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                    Colors.black, BlendMode.srcIn),
                                child: Image.asset('assets/Icons/comment.png'),
                              ),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              const Text(
                                '12',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                  letterSpacing: -0.165,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            width: screenWidth * 0.1,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                  child: Image.asset(
                                      'assets/Icons/stopwatch .png'),
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              const Text(
                                '5 min',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                  letterSpacing: -0.165,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.share_outlined,
                                size: 16,
                              ),
                              SizedBox(
                                width: screenWidth * 0.01,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.more_vert_rounded,
                                size: 16,
                              ),
                              SizedBox(
                                width: screenWidth * 0.01,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This is an input field which is used for inderting a comment
class CommentInputField extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final IconData? icon;
  final TextEditingController controller;
  final TextInputAction inputAction;

  final String hintText;
  final String? suffixIcon;
  final Function(String)? onChanged;
  const CommentInputField(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.icon,
      required this.controller,
      required this.inputAction,
      required this.hintText,
      required this.onChanged,
      required this.suffixIcon});

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  @override
  Widget build(BuildContext context) {
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
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(193, 193, 193, 1),

                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.165,
                  height: 18 / 14, // line-height / font-size
                ),
                prefixIcon: widget.icon != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.screenWidth * 0.03),
                        child: const Icon(
                          Icons.search,
                          color: Color.fromRGBO(193, 193, 193, 1),
                        ),
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? Container(
                        margin:
                            EdgeInsets.only(right: widget.screenWidth * 0.06),
                        child: SvgPicture.asset(widget.suffixIcon!))
                    : null,
                border: OutlineInputBorder(
                    gapPadding: 12,
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        width: 1, color: Color.fromRGBO(193, 193, 193, 1))),
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.screenHeight * 0.07, // No vertical padding
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
