import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/public_profile_screen.dart';
import 'package:healthpilot/features/chat/user_detail_screen.dart';
import 'package:healthpilot/features/community/community_models.dart';
import 'package:healthpilot/features/community/community_provider.dart';
import 'package:healthpilot/features/profile/language_translation.dart';
import 'package:provider/provider.dart';

class SimilarPeopleScreen extends StatefulWidget {
  const SimilarPeopleScreen({super.key});

  @override
  State<SimilarPeopleScreen> createState() => _SimilarPeopleScreenState();
}

class _SimilarPeopleScreenState extends State<SimilarPeopleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CommunityProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final peers = provider.suggestedPeers;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leadingWidth: double.infinity,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Components.customeAppBar(
                Icons.arrow_back, 'Similar People', context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IconButton(
                tooltip: 'Translate',
                onPressed: () => openLanguageScreen(context),
                icon: SvgPicture.asset(
                  translateIcon,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: provider.status == CommunityStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : peers.isEmpty
                      ? const Center(child: Text('No users found.'))
                      : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          20, 15, 20, 24),
                      itemCount: peers.length,
                      itemBuilder: (context, index) {
                        final peer = peers[index];
                        return _DiscoverablePeerCard(peer: peer);
                      },
                    ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: CustomeButton(
                  titleOfButton: 'Update Public Profile',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PublicProfileScreen()));
                  }),
            ),
          ],
        ));
  }
}

class _DiscoverablePeerCard extends StatelessWidget {
  final SuggestedPeer peer;
  const _DiscoverablePeerCard({required this.peer});

  void _connect(BuildContext context) async {
    final provider = context.read<CommunityProvider>();
    try {
      await provider.sendConnectionRequest(peer.id);
      if (context.mounted) {
        _showCommunityFloatingSnackBar(
          context,
          backgroundColor: const Color.fromRGBO(76, 217, 100, 1),
          icon: Icons.done_rounded,
          message: 'Connection request sent to ${peer.fullName}.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showCommunityFloatingSnackBar(
          context,
          backgroundColor: Colors.red,
          icon: Icons.error_outline,
          message: 'Failed to connect. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UserDetailScreen(peer: peer),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(devsImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peer.fullName,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      peer.reason.isNotEmpty
                          ? peer.reason
                          : 'Health community member',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 12, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Score: ${peer.score}',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${peer.age} yrs',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _connect(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Connect',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            UserDetailScreen(peer: peer),
                      ));
                    },
                    child: Text(
                      'View profile',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showCommunityFloatingSnackBar(
  BuildContext context, {
  required Color backgroundColor,
  required IconData icon,
  required String message,
}) {
  final size = MediaQuery.of(context).size;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
        bottom: size.height * 0.15,
        left: size.width * 0.07,
        right: size.width * 0.07,
      ),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(
            width: size.width * 0.03,
          ),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class CustomeButton extends StatelessWidget {
  final String titleOfButton;
  final VoidCallback onPressed;
  const CustomeButton(
      {super.key, required this.titleOfButton, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        splashFactory: null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        backgroundColor: cs.primary,
      ),
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.06,
        width: size.width * 0.5,
        child: Text(
          titleOfButton,
          style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.onPrimary),
        ),
      ),
    );
  }
}
