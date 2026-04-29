import 'package:flutter/material.dart';
import 'package:shams_mobile_app/utils/constants.dart';

class ShamsCommentTile extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final String commentText;
  final String? avatarUrl;
  final VoidCallback onLikePressed;

  const ShamsCommentTile({
    super.key,
    required this.userName,
    required this.timeAgo,
    required this.commentText,
    this.avatarUrl,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEEF0F4),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null 
                ? const Icon(Icons.person, color: ShamsColors.textGray) 
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userName,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeAgo,
                      style: textTheme.bodySmall?.copyWith(color: ShamsColors.textGray),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  commentText,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
               
                   InkWell(
                    onTap: onLikePressed,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 16, color: ShamsColors.textGray),
                          const SizedBox(width: 4),
                          Text(
                            'إعجاب',
                            style: textTheme.labelMedium?.copyWith(color: ShamsColors.textGray),
                          ),
                        ],
                      ),
                    ),
                  ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}