import 'package:flutter/material.dart';
import 'package:shams_mobile_app/utils/constants.dart';

class ShamsChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const ShamsChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? ShamsColors.primaryBlue : const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 0 : 16),
            topRight: Radius.circular(isMe ? 16 : 0),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: isMe ? ShamsColors.bgWhite : ShamsColors.textGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                time,
                style: textTheme.labelSmall?.copyWith(
                  color: isMe ? Colors.white70 : const Color(0xFF9EA3B0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}