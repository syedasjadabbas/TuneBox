import 'package:flutter/material.dart';
import 'package:music_player/config/colors.dart';

class SongTile extends StatelessWidget {
  final String songName;
  final String? subtitle;
  final VoidCallback onPress;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;
  final VoidCallback? onAddToPlaylist;
  const SongTile({
    super.key,
    required this.songName,
    required this.onPress,
    this.subtitle,
    this.onToggleFavorite,
    this.isFavorite = false,
    this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPress,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: div_color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: primary_color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note, color: primary_color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      songName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onAddToPlaylist != null)
                    _ActionIcon(
                      icon: Icons.playlist_add,
                      onTap: onAddToPlaylist!,
                    ),
                  if (onToggleFavorite != null)
                    _ActionIcon(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? primary_color : Colors.white,
                      onTap: onToggleFavorite!,
                    ),
                  _ActionIcon(
                    icon: Icons.play_arrow_rounded,
                    onTap: onPress,
                    color: primary_color,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  const _ActionIcon(
      {required this.icon, required this.onTap, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
