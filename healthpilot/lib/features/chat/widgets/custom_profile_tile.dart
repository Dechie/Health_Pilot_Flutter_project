import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomChatProfileTile extends StatelessWidget {
  final String name;
  final String profilePic;
  final String chat;
  final bool? isPro;
  final int? unreadMessage;
  final VoidCallback? onPressed;

  CustomChatProfileTile(
      {super.key,
      required this.name,
      required this.profilePic,
      required this.chat,
      this.unreadMessage = 0,
      this.isPro = false,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: size.height * 0.15,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(profilePic),
              ),
              title: SizedBox(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    isPro!
                        ? Icon(
                            Icons.star,
                            size: size.width * 0.05352,
                            color: const Color.fromRGBO(110, 182, 255, 1),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
              subtitle: Text(
                chat,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: unreadMessage != 0
                  ? CircleAvatar(
                      backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
                      radius: 16,
                      child: Text(
                        unreadMessage! > 2
                            ? '${unreadMessage!}+'
                            : unreadMessage!.toString(),
                        style: TextStyle(
                            color: const Color.fromRGBO(42, 42, 42, 1),
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13.sp,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.165),
                      ))
                  : const SizedBox.shrink(),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 32.0, right: 29),
              child: Divider(
                color: Color.fromRGBO(42, 42, 42, 0.15),
                thickness: 0.5,
              ),
            )
          ],
        ),
      ),
    );
  }
}
