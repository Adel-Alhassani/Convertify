import 'package:convertify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// File → Format → Convert. Steps before [current] show a check.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.current});

  /// 0, 1 or 2.
  final int current;

  @override
  Widget build(BuildContext context) {
    final labels = ["step_file".tr, "step_format".tr, "step_convert".tr];
    final c = context.colors;
    final children = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      if (i > 0) {
        children.add(Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: i <= current ? c.success.withValues(alpha: 0.45) : c.border,
          ),
        ));
      }
      children.add(_Step(
        number: i + 1,
        label: labels[i],
        state: i < current
            ? _StepState.done
            : i == current
                ? _StepState.active
                : _StepState.upcoming,
      ));
    }
    return Semantics(
      label: "step_semantics".trParams(
          {"n": "${current + 1}", "total": "3", "step": labels[current]}),
      excludeSemantics: true,
      child: Row(children: children),
    );
  }
}

enum _StepState { done, active, upcoming }

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label, required this.state});

  final int number;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme.labelMedium!;
    final (Color fg, Widget dot) = switch (state) {
      _StepState.done => (
          c.success,
          _Dot(
            color: c.successSoft,
            child: Icon(Icons.check_rounded, size: 15, color: c.success),
          ),
        ),
      _StepState.active => (
          c.primaryInk,
          _Dot(
            color: c.primary,
            child: Text("$number",
                style: text.copyWith(color: c.onPrimary, fontSize: 12)),
          ),
        ),
      _StepState.upcoming => (
          c.muted,
          _Dot(
            border: c.border,
            child: Text("$number",
                style: text.copyWith(color: c.muted, fontSize: 12)),
          ),
        ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 8),
        Text(label,
            style: text.copyWith(
                color: fg,
                fontWeight: state == _StepState.active
                    ? FontWeight.w700
                    : FontWeight.w600)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.child, this.color, this.border});

  final Widget child;
  final Color? color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border == null ? null : Border.all(color: border!, width: 1.5),
      ),
      child: child,
    );
  }
}
