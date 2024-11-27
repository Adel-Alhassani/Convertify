import 'package:convertify/model/downloadable_file_model.dart';
import 'package:flutter/material.dart';

class CustomAnimatedList extends StatefulWidget {
  final int itemsLength;
  final GlobalKey<AnimatedListState> listKey;
  final Widget Function(BuildContext, int, Animation<double>) itemBuilder;

  const CustomAnimatedList(
      {super.key,
      required this.itemsLength,
      required this.itemBuilder,
      required this.listKey});

  @override
  State<CustomAnimatedList> createState() => _CustomAnimatedListState();
}

class _CustomAnimatedListState extends State<CustomAnimatedList> {
  @override
  Widget build(BuildContext context) {
    return AnimatedList(
        key: widget.listKey,
        initialItemCount: widget.itemsLength,
        itemBuilder: widget.itemBuilder);
  }
}
