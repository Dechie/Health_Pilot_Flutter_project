import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/group_chat_screen.dart';
import 'package:healthpilot/features/chat/similar_people_screen.dart';
import 'package:healthpilot/features/chat/widgets/custom_profile_tile.dart';

class GeneralChatScreen extends StatefulWidget {
  const GeneralChatScreen({super.key, this.showBackButton = false});

  /// When true (e.g. pushed from assessment flow), show an app bar back control.
  /// When false, used inside [HomePageScreen] bottom navigation without a back affordance.
  final bool showBackButton;

  @override
  State<GeneralChatScreen> createState() => _GeneralChatScreenState();
}

class _GeneralChatScreenState extends State<GeneralChatScreen> {
  List<User> userList = [];
  List<GroupChat> groupChat = [];

  List<AllChat> allChatData = [];
  List<AllChat> chatData = [
    AllChat(
      id: '1',
      name: 'John Doe',
      lastMessage: 'How are you today?',
      isPro: true,
      isGroupChat: false,
    ),
    AllChat(
      id: '2',
      name: 'Emma Smith',
      lastMessage: 'Are you free for a call later?',
      isPro: false,
      isGroupChat: false,
    ),
    AllChat(
      id: '3',
      name: 'Alice Johnson',
      lastMessage: 'Nice to meet you!',
      isPro: true,
      isGroupChat: false,
    ),
    // Add more individual chats as needed

    // Group Chats
    AllChat(
      id: 'g1',
      name: 'Schizophrenia Support',
      lastMessage: 'By the way, have you seen the latest movie?',
      isPro: true,
      isGroupChat: true,
    ),
    AllChat(
      id: 'g2',
      name: 'Schizophrenia Support',
      lastMessage: 'By the way, have you seen the latest movie?',
      isPro: false,
      isGroupChat: true,
    ),
    AllChat(
      id: 'g3',
      name: 'Schizophrenia Support',
      lastMessage: 'By the way, have you seen the latest movie?',
      isPro: false,
      isGroupChat: true,
    ),
    // Add more group chats as needed
  ];

  @override
  void initState() {
    userList = Users.users;
    groupChat = GroupChats.groupChats;
    allChatData = chatData;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  // All chat list

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: widget.showBackButton,
            toolbarHeight: 70,
            elevation: 0,
            backgroundColor: Colors.white,
            title: _buildTabBar(),
            centerTitle: true,
          ),
          floatingActionButton: _buildFloatingActionButton(),
          body: Column(children: [
            _buildSearchBar(context),
            Expanded(
              child: TabBarView(children: [
                //All chats
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Flexible(
                          child: GroupedListView(
                            elements: allChatData,
                            groupBy: (chatData) => chatData.isPro.toString(),
                            order: GroupedListOrder.DESC,
                            itemBuilder: (context, chatData) {
                              return CustomChatProfileTile(
                                name: chatData.name,
                                isPro: chatData.isPro,
                                unreadMessage: 3,
                                profilePic: devsImage,
                                chat: chatData.lastMessage,
                                onPressed: () {
                                  if (!chatData.isGroupChat) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            senderId: chatData.id,
                                            userId: '123'),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => GroupChatScreen(
                                            groupId: chatData.id, userId: '1'),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            // useStickyGroupSeparators: true,
                            groupHeaderBuilder: (element) => Container(
                              height: size.height * 0.05,
                            ),
                            itemComparator: (item1, item2) =>
                                item1.name.compareTo(item2.name),
                            groupComparator: (value1, value2) =>
                                value1.compareTo(value2),
                            groupSeparatorBuilder: (value) => SizedBox(
                              height: size.height * 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //People chats
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GroupedListView(
                    elements: userList,
                    groupBy: (user) => user.isPro.toString(),
                    order: GroupedListOrder.DESC,
                    itemBuilder: (context, user) {
                      return CustomChatProfileTile(
                        name: user.displayName,
                        isPro: user.isPro,
                        unreadMessage: user.chatHistory.length,
                        profilePic: devsImage,
                        chat: user.chatHistory.isNotEmpty
                            ? user.chatHistory.last.content
                            : '',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  senderId: user.userId, userId: '123'),
                            ),
                          );
                        },
                      );
                    },

                    // useStickyGroupSeparators: true,
                    groupHeaderBuilder: (element) => Container(
                      height: size.height * 0.05,
                    ),
                    itemComparator: (item1, item2) =>
                        item1.displayName.compareTo(item2.displayName),
                    groupComparator: (value1, value2) =>
                        value1.toString().compareTo(value2.toString()),
                    groupSeparatorBuilder: (value) => SizedBox(
                      height: size.height * 0.2,
                    ),
                  ),
                ),

                // group chats
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Flexible(
                          child: GroupedListView(
                            elements: groupChat,
                            groupBy: (chatData) => chatData.isPro.toString(),
                            order: GroupedListOrder.DESC,
                            itemBuilder: (context, groupChatData) {
                              return CustomChatProfileTile(
                                name: groupChatData.groupName,
                                isPro: groupChatData.isPro,
                                unreadMessage:
                                    groupChatData.groupChatHistory.length,
                                profilePic: devsImage,
                                chat:
                                    groupChatData.groupChatHistory.last.content,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => GroupChatScreen(
                                          groupId: groupChatData.groupId,
                                          userId: '1')));
                                },
                              );
                            },
                            // useStickyGroupSeparators: true,
                            groupHeaderBuilder: (element) => Container(
                              height: size.height * 0.05,
                            ),
                            itemComparator: (item1, item2) =>
                                item1.groupName.compareTo(item2.groupName),
                            groupComparator: (value1, value2) =>
                                value1.compareTo(value2),
                            groupSeparatorBuilder: (value) => SizedBox(
                              height: size.height * 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.only(left: 29.0.w, right: 23.w, top: 17),
      child: SizedBox(
        height: 44,
        child: TextFormField(
          onChanged: (value) {
            final q = value.toLowerCase();
            setState(() {
              userList = Users.users
                  .where((element) =>
                      element.displayName.toLowerCase().contains(q) ||
                      element.chatHistory.any(
                        (m) => m.content.toLowerCase().contains(q),
                      ))
                  .toList();
              allChatData = chatData
                  .where((element) =>
                      element.name.toLowerCase().contains(q) ||
                      element.lastMessage.toLowerCase().contains(q))
                  .toList();
              groupChat = GroupChats.groupChats
                  .where((element) =>
                      element.groupName.toLowerCase().contains(q) ||
                      element.groupChatHistory.any(
                        (m) => m.content.toLowerCase().contains(q),
                      ))
                  .toList();
            });
          },
          decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
              ),
              hintText: 'Search people, groups, or messages',
              hintStyle: const TextStyle(
                color: Color.fromRGBO(193, 193, 193, 1),
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      width: 1, color: Color.fromRGBO(217, 217, 217, 1)))),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SimilarPeopleScreen()));
      },
      backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
      child: const Icon(
        Icons.person_search_outlined,
        size: 30,
      ),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
        tabAlignment: TabAlignment.center,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: const Color.fromRGBO(110, 182, 255, 1),
        unselectedLabelColor: const Color.fromRGBO(42, 42, 42, 0.45),
        unselectedLabelStyle: TextStyle(
          color: const Color.fromRGBO(42, 42, 42, 0.45),
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16.sp,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.165.sp,
        ),
        labelStyle: TextStyle(
          color: const Color.fromRGBO(110, 182, 255, 1),
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16.sp,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.165.sp,
        ),
        indicatorColor: Theme.of(context).colorScheme.primary,
        tabs: const [
          Tab(
            text: 'All',
          ),
          Tab(
            text: 'People',
          ),
          Tab(
            text: 'Groups',
          ),
        ]);
  }
}

// dummy data
class AllChat {
  final String id;
  final String name;
  final String lastMessage;
  final bool isPro;
  final bool isGroupChat;

  AllChat({
    required this.isGroupChat,
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.isPro,
  });
}
