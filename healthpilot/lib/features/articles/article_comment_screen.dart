//This is the screen where the user commets on the post

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'article_screen.dart';

import 'article_detail_screen.dart';

// ignore: must_be_immutable
class ArticleCommentScreen extends StatelessWidget {
  ArticleCommentScreen({super.key});

  TextEditingController controller = TextEditingController();
  List<CommentModel> comments = [
    CommentModel(
        reply: [
          Reply(
            replier: 'Ashkay Mauray',
            reply: 'I agree, growing up sucks. Age is coming for us.',
            replyDate: '7 months',
            replierImage: 'assets/images/ashkay.png',
            isUSer: false,
          ),
          Reply(
              replier: 'Mohamed Ibrahim',
              reply: 'I agree, growing up sucks. Age is coming for us.',
              replyDate: '7 months',
              isUSer: true,
              replierImage: 'assets/images/mohamed.png')
        ],
        poster: 'Amanda Richarlson',
        postedDate: '9 months ago',
        post:
            'It is sad we’re getting old so quick wish we could stay at this age fot more years to come. It is sad we’re getting old so quick wish we could stay at this age fot more years to come ... ',
        imageUrl: 'assets/images/amanda.png')
  ];
// The Widget tree starts here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final size = constraints.biggest;
        final screenWidth = size.width;
        final screenHeight = size.height;
        return SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Stack(
              children: [
                Hero(
                  tag: 'hyh',
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.4,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/old_woman.png'),
                            fit: BoxFit.cover)),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomAppBar(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenHeight * 0.04,
                                vertical: screenHeight * 0.04),
                            child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'jfhshfuish',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      height: 25.0 / 20.0,
                                      letterSpacing: -0.165,
                                      color: Colors.white,
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.3,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(55),
                        topRight: Radius.circular(55),
                      ),
                    ),
                    height: screenHeight * 0.654,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.04),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: screenWidth * 0.04,
                              left: screenWidth * 0.02,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Comments',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "PlusJakartaSans",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Filter',
                                      style: TextStyle(
                                        color: Color.fromARGB(76, 0, 0, 0),
                                        fontFamily: "PlusJakartaSans",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.16,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.02,
                                    ),
                                    ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                          Color.fromRGBO(42, 42, 42, 0.5),
                                          BlendMode.srcIn),
                                      child: SvgPicture.asset(
                                          'assets/Icons/setting.svg'),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            children: [
                              Container(
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.1,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/images/mohamed.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.07,
                                width: screenWidth * 0.8,
                                child: CommentInputField(
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                    icon: null,
                                    controller: controller,
                                    inputAction: TextInputAction.done,
                                    hintText: 'What is on your mind?',
                                    onChanged: (st) {},
                                    suffixIcon: null),
                              )
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      right: screenWidth * 0.05),
                                  child: const Button())),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          if (comments.isEmpty)
                            Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                SizedBox(
                                    height: screenHeight * 0.3,
                                    child: Image.asset(
                                        'assets/images/Notebook.png')),
                                const Text(
                                  'There are no comments',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    height: 25.0 / 20.0,
                                    letterSpacing: -0.165,
                                  ),
                                ),
                                const Text(
                                  'Be the first to comment',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    height: 25.0 / 20.0,
                                    letterSpacing: -0.165,
                                  ),
                                )
                              ],
                            )
                          else
                            Container(
                              margin: EdgeInsets.only(top: screenHeight * 0.01),
                              color: Colors.transparent,
                              height: screenHeight * 0.38,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: ListView.builder(
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    return CommentCard(
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      imageUrl: comments[index].imageUrl,
                                      post: comments[index].post,
                                      postedDate: comments[index].postedDate,
                                      poster: comments[index].poster,
                                      replies: comments[index].reply,
                                    );
                                  },
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ));
      }),
      resizeToAvoidBottomInset: false,
    );
  }
}

//  a  button that used for posting the comment

class Button extends StatelessWidget {
  const Button({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
          width: 74,
          height: 30,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(110, 182, 255, 1),
          ), // Adjust the width as needed
          child: Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Post",
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontFamily: "PlusJakartaSans",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.16,
                ),
              ),
            ),
          )),
    );
  }
}

//  A Comment Card : A widget that used to render the commetnts in card  and it is a statefull widget

class CommentCard extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String poster;
  final String postedDate;
  final String post;

  final String imageUrl;
  final List<Reply> replies;

  const CommentCard({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.poster,
    required this.postedDate,
    required this.post,
    required this.imageUrl,
    required this.replies,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool showReplies = false;

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // This list tile is for the commenter infomation
        ListTile(
          leading: CircleAvatar(
            maxRadius: widget.screenWidth * 0.04,
            backgroundImage: AssetImage(widget.imageUrl),
            // child: Image.asset(
            //   imageUrl,
            //   fit: BoxFit.cover,
            // ),
          ),
          title: Text(
            widget.poster,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              height: 25.0 / 20.0,
              letterSpacing: -0.165,
            ),
          ),
          trailing: Padding(
            padding: EdgeInsets.only(right: widget.screenWidth * 0.12),
            child: Text(widget.postedDate,
                style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 10)),
          ),
        ),
        SizedBox(
          height: widget.screenHeight * 0.01,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.024),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: widget.screenWidth * 0.029),

                // This readmore widget is used to render the detal of the  comment and have a feature to extend whe the show more button is pressed
                // child: ReadMoreText(
                //   widget.post,
                //   trimLines: 2,
                //   colorClickableText: Colors.blue,
                //   trimMode: TrimMode.Line,
                //   trimCollapsedText: 'Show more',
                //   trimExpandedText: 'Show less',
                //   moreStyle: const TextStyle(fontSize: 10, color: Colors.blue),
                //   lessStyle: const TextStyle(fontSize: 10, color: Colors.blue),
                //   textAlign: TextAlign.justify,
                //   style: const TextStyle(
                //     fontSize: 10,
                //     color: Colors.black,
                //     fontFamily: 'Plus Jakarta Sans',
                //     fontWeight: FontWeight.w400,
                //     height: 13 / 10,
                //     letterSpacing: 0,
                //   ),
                // ),
              ),
              SizedBox(
                height: widget.screenHeight * 0.01,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: widget.screenWidth * 0.024),
                  child: CommentIcons(
                    onPrssed: () {
                      setState(() {
                        showReplies = !showReplies;
                      });
                    },
                  )),

              // is used to show the replies for  a comment
              if (showReplies && widget.replies.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var reply in widget.replies)
                        ReplyCard(
                          screenWidth: widget.screenWidth,
                          screenHeight: widget.screenHeight,
                          replier: reply.replier,
                          repliedDate: reply.replyDate,
                          reply: reply.reply,
                          imageUrl: reply.replierImage,
                          isUser: reply.isUSer,
                          replies: const [],
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
      ],
    );
  }
}

//  A comment model used to deecribe what a a cmment looks like
//  A commennt can have list of replies

class CommentModel {
  final String poster;
  final String postedDate;
  final String post;
  final String imageUrl;
  final List<Reply> reply;

  CommentModel(
      {required this.reply,
      required this.poster,
      required this.postedDate,
      required this.post,
      required this.imageUrl});
}

// A data model for replies used to express what a reply looks like
class Reply {
  final String replier;
  final String reply;
  final String replyDate;
  final String replierImage;
  final bool isUSer;

  Reply({
    required this.isUSer,
    required this.replier,
    required this.reply,
    required this.replyDate,
    required this.replierImage,
  });
}

// Mostly the same to comment card but for the current user it will prvide a remove option on the reaction secton of this ReplyCard
class ReplyCard extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String replier;
  final String repliedDate;
  final String reply;
  final bool isUser;
  final String imageUrl;
  final List<Reply> replies;

  const ReplyCard({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.replier,
    required this.repliedDate,
    required this.reply,
    required this.imageUrl,
    required this.replies,
    required this.isUser,
  });

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  bool showReplies = false;

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            maxRadius: widget.screenWidth * 0.04,
            backgroundImage: AssetImage(widget.imageUrl),
            // child: Image.asset(
            //   imageUrl,
            //   fit: BoxFit.cover,
            // ),
          ),
          title: Text(
            widget.replier,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              height: 25.0 / 20.0,
              letterSpacing: -0.165,
            ),
          ),
          trailing: Padding(
            padding: EdgeInsets.only(right: widget.screenWidth * 0.12),
            child: Text(widget.repliedDate,
                style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 10)),
          ),
        ),
        SizedBox(
          height: widget.screenHeight * 0.01,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.024),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: widget.screenWidth * 0.029),
                // child: ReadMoreText(
                //   widget.reply,
                //   trimLines: 1,
                //   colorClickableText: Colors.blue,
                //   trimMode: TrimMode.Line,
                //   trimCollapsedText: 'Show more',
                //   trimExpandedText: 'Show less',
                //   moreStyle: const TextStyle(fontSize: 10, color: Colors.blue),
                //   lessStyle: const TextStyle(fontSize: 10, color: Colors.blue),
                //   textAlign: TextAlign.justify,
                //   style: const TextStyle(
                //     fontSize: 10,
                //     color: Colors.black,
                //     fontFamily: 'Plus Jakarta Sans',
                //     fontWeight: FontWeight.w400,
                //     height: 13 / 10,
                //     letterSpacing: 0,
                //   ),
                // ),
              ),
              SizedBox(
                height: widget.screenHeight * 0.01,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: widget.screenWidth * 0.024),
                child: ReplyCommentIcons(
                  onPrssed: () {
                    setState(() {
                      showReplies = !showReplies;
                    });
                  },
                  isUser: widget.isUser,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

//  This is a section that i used it to be in the bottom of the reply and comment card but for the reply card it will show the delete option if the replier is the curret user

class CommentIcons extends StatefulWidget {
  final VoidCallback onPrssed;

  const CommentIcons({
    super.key,
    required this.onPrssed,
  });

  @override
  State<CommentIcons> createState() => _CommentIconsState();
}

class _CommentIconsState extends State<CommentIcons> {
  bool isToogled = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isToogled = !isToogled;
                });
              },
              child: ColorFiltered(
                colorFilter: isToogled
                    ? const ColorFilter.mode(Colors.blue, BlendMode.srcIn)
                    : const ColorFilter.mode(Colors.black38, BlendMode.srcIn),
                child: Image.asset('assets/Icons/like.png'),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: widget.onPrssed,
                child: const Text(
                  'Reply',
                  style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 10),
                )),
            const SizedBox(
              width: 15,
            ),
            const Text(
              'Report',
              style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 10),
            ),
          ],
        ),
        Row(
          children: [
            Image.asset('assets/Icons/pen.png'),
          ],
        )
      ],
    );
  }
}

//  This is a section that i used it to be in the bottom of the reply and comment card but for the reply card it will show the delete option if the replier is the curret user

class ReplyCommentIcons extends StatefulWidget {
  final VoidCallback onPrssed;
  final bool isUser;
  const ReplyCommentIcons({
    super.key,
    required this.onPrssed,
    required this.isUser,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ReplyCommentIconsState createState() => _ReplyCommentIconsState();
}

class _ReplyCommentIconsState extends State<ReplyCommentIcons> {
  bool isToogled = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isToogled = !isToogled;
                });
              },
              child: ColorFiltered(
                colorFilter: isToogled
                    ? const ColorFilter.mode(Colors.blue, BlendMode.srcIn)
                    : const ColorFilter.mode(Colors.black38, BlendMode.srcIn),
                child: Image.asset('assets/Icons/like.png'),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: widget.onPrssed,
                child: const Text(
                  'Reply',
                  style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 10),
                )),
            const SizedBox(
              width: 15,
            ),
            const Text(
              'Report',
              style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 10),
            ),
          ],
        ),
        Row(
          children: [
            widget.isUser
                ? Image.asset('assets/Icons/trash.png')
                : const SizedBox(),
            const SizedBox(
              width: 5,
            ),
            Image.asset('assets/Icons/pen.png'),
          ],
        )
      ],
    );
  }
}
