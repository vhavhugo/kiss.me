import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_entity.dart';
import 'ai_trust_badge.dart';
import 'authenticity_badge.dart';

/// Perfil em tela cheia: a foto principal ocupa todo o espaço visível e,
/// ao rolar, aparecem os dados do perfil e as demais fotos.
class ProfileDetailView extends StatelessWidget {
  final UserEntity user;
  final double heroHeight;

  const ProfileDetailView({
    super.key,
    required this.user,
    required this.heroHeight,
  });

  @override
  Widget build(BuildContext context) {
    final photos = user.allPhotos;
    final morePhotos = photos.skip(1).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(user: user, height: heroHeight, photo: photos.isEmpty ? null : photos.first),
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoChips(user: user),
                if (user.bio.isNotEmpty)
                  _Section(title: 'Sobre', child: Text(user.bio, style: _bodyStyle)),
                if (user.dream != null && user.dream!.isNotEmpty)
                  _Section(
                    title: 'Sonho',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.dream!, style: _bodyStyle),
                        if (user.acceptsSponsor) ...[
                          const SizedBox(height: 10),
                          const _SponsorChip(),
                        ],
                      ],
                    ),
                  ),
                if (user.affinity != null && user.affinity!.commonInterests.isNotEmpty)
                  _Section(
                    title: 'Em comum',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.affinity!.commonInterests
                          .map((i) => Chip(
                                label: Text(i),
                                backgroundColor: AppColors.primary.withAlpha(25),
                                side: BorderSide.none,
                              ))
                          .toList(),
                    ),
                  ),
                if (user.icebreakers.isNotEmpty)
                  _Section(
                    title: 'Quebra-gelo',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: user.icebreakers
                          .map((q) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.chat_bubble_outline_rounded,
                                        size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(q.text, style: _bodyStyle)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                if (morePhotos.isNotEmpty)
                  _Section(
                    title: 'Mais fotos',
                    child: Column(
                      children: morePhotos
                          .map((url) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: _NetImage(url: url),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _bodyStyle = TextStyle(fontSize: 15, height: 1.4, color: Colors.black87);
}

class _Hero extends StatelessWidget {
  final UserEntity user;
  final double height;
  final String? photo;

  const _Hero({required this.user, required this.height, required this.photo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photo != null)
            _NetImage(url: photo!)
          else
            Container(color: AppColors.offline, child: const Icon(Icons.person, size: 80, color: Colors.white)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(190)],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AuthenticityBadge(level: user.authenticity.level),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _distanceText(user.distanceInMeters),
                      style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14),
                    ),
                  ],
                ),
                if (user.affinity != null) ...[
                  const SizedBox(height: 10),
                  AiTrustBadge(
                    label: '${(user.affinity!.score * 100).toInt()}% COMPATÍVEL',
                    description: user.affinity!.justification,
                  ),
                ],
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Text('Deslize para ver mais',
                          style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withAlpha(220)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _distanceText(double m) {
    if (m <= 0) return 'A poucos metros de você';
    if (m < 1000) return 'A ${m.round()} m de você';
    return 'A ${(m / 1000).toStringAsFixed(1)} km de você';
  }
}

class _NetImage extends StatelessWidget {
  final String url;
  const _NetImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: AppColors.primary.withAlpha(20),
              child: const Center(child: CircularProgressIndicator()),
            ),
      errorBuilder: (_, _, _) => Container(
        color: AppColors.offline,
        child: const Icon(Icons.broken_image_outlined, color: Colors.white, size: 48),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoChips extends StatelessWidget {
  final UserEntity user;
  const _InfoChips({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      if (user.profession?.isNotEmpty ?? false) (Icons.work_outline_rounded, user.profession!),
      if (user.education?.isNotEmpty ?? false) (Icons.school_outlined, user.education!),
      if (user.city?.isNotEmpty ?? false) (Icons.home_outlined, user.city!),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((e) => Chip(
                avatar: Icon(e.$1, size: 18, color: AppColors.primary),
                label: Text(e.$2),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.primary.withAlpha(60)),
              ))
          .toList(),
    );
  }
}

class _SponsorChip extends StatelessWidget {
  const _SponsorChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.volunteer_activism_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 6),
          Text('Aceita um patrocinador',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
