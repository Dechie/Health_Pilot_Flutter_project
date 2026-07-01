import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:healthpilot/core/widgets/user_avatar.dart';

class CustomChatProfileTile extends StatelessWidget {
  final String name;
  final String profilePic;

  /// Network avatar URL; falls back to [profilePic] asset when null/empty.
  final String? avatarUrl;
  final String chat;
  final bool? isPro;
  final int? unreadMessage;
  final VoidCallback? onPressed;

  const CustomChatProfileTile(
      {super.key,
      required this.name,
      required this.profilePic,
      this.avatarUrl,
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
              leading: UserAvatar(
                url: avatarUrl,
                radius: 40,
                fallbackAsset: profilePic,
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
                        unreadMessage! > 9
                            ? '9+'
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
