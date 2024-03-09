import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BodyMedium extends StatelessWidget {
  final String text;

  const BodyMedium({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF050404).withOpacity(0.9),
          ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class BodyMediumText extends StatelessWidget {
  final String text;

  const BodyMediumText({required this.text});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split(':');
    final String prefix = parts.length > 1 ? '${parts[0]}:' : '';
    final String restOfText =
        parts.length > 1 ? parts.sublist(1).join(':') : text;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class BodyMediumOver extends StatelessWidget {
  final String text;

  const BodyMediumOver({required this.text});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split(':');
    final String prefix = parts.length > 1 ? '${parts[0]}:' : '';
    final String restOfText =
        parts.length > 1 ? parts.sublist(1).join(':') : text;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }
}
