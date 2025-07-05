import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../themes/text_field_widget.dart';

class AnimatedSearchHint extends StatefulWidget {
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final bool? enable;
  final bool? obscureText;
  final int? maxLine;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onchange;
  final TextInputAction? textInputAction;
  final String? fontFamily;
  final Color? fillColor;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final List<String>? hints;
  final Duration? interval;

  const AnimatedSearchHint({
    Key? key,
    this.controller,
    this.prefix,
    this.suffix,
    this.enable,
    this.obscureText,
    this.maxLine,
    this.textInputType,
    this.inputFormatters,
    this.onchange,
    this.textInputAction,
    this.fontFamily,
    this.fillColor,
    this.textStyle,
    this.hintTextStyle,
    this.hints,
    this.interval,
  }) : super(key: key);

  @override
  State<AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<AnimatedSearchHint> {
  late final List<String> _hints;
  int _currentHint = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _hints = widget.hints ?? [
      "Search 'cake'",
      "Search 'biryani'",
      "Search 'ice cream'",
      "Search 'pizza'",
      "Search 'burger'",
      "Search 'sushi'",
      "Search 'Restaurants or dish'",
    ];
    _timer = Timer.periodic(widget.interval ?? const Duration(seconds: 2), (timer) {
      setState(() {
        _currentHint = (_currentHint + 1) % _hints.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: TextFieldWidget(
        key: ValueKey(_hints[_currentHint]),
        hintText: _hints[_currentHint],
        controller: widget.controller,
        enable: widget.enable,
        prefix: widget.prefix,
        suffix: widget.suffix,
        obscureText: widget.obscureText,
        maxLine: widget.maxLine,
        textInputType: widget.textInputType,
        inputFormatters: widget.inputFormatters,
        onchange: widget.onchange,
        textInputAction: widget.textInputAction,
        fontFamily: widget.fontFamily,
        fillColor: widget.fillColor,
        textStyle: widget.textStyle,
        hintTextStyle: widget.hintTextStyle,
      ),
    );
  }
} 