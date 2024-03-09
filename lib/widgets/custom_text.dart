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

class EditTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  // final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EditTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    // this.obscureText = false,
    this.keyboardType,
    this.maxLines,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  _EditTextFieldState createState() => _EditTextFieldState();
}

class _EditTextFieldState extends State<EditTextField> {
  // late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      // obscureText: _obscureText,
      cursorColor: const Color(0xFF050404),
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF050404).withOpacity(0.6),
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF050404).withOpacity(0.7),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF050404)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF050404)),
        ),
        // suffixIcon: widget.obscureText
        //     ? IconButton(
        //         icon: Icon(
        //           _obscureText ? Icons.visibility_off : Icons.visibility,
        //           color: const Color(0xFF050404),
        //         ),
        //         onPressed: () {
        //           setState(() {
        //             _obscureText = !_obscureText;
        //           });
        //         },
        //       )
        //     : null,
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
