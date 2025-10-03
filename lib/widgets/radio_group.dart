import 'package:flutter/material.dart';

/// Lightweight RadioGroup abstraction to modernize away from deprecated
/// direct groupValue / onChanged patterns sprinkled inline. Wraps
/// a list of values and builds radios with consistent spacing and
/// accessibility semantics.
class RadioGroup<T> extends StatelessWidget {
  const RadioGroup({
    super.key,
    required this.values,
    required this.value,
    required this.onChanged,
    this.direction = Axis.vertical,
    this.itemBuilder,
    this.padding = const EdgeInsets.all(0),
    this.spacing = 8,
    this.labelBuilder,
  });

  final List<T> values;
  final T value;
  final ValueChanged<T> onChanged;
  final Axis direction;
  final EdgeInsets padding;
  final double spacing;
  final Widget Function(BuildContext context, T v)? itemBuilder;
  final String Function(T v)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final v in values) {
      final selected = v == value;
      final label = labelBuilder?.call(v) ?? v.toString();
      final radio = Radio<T>(
        value: v,
        groupValue: value,
        onChanged: (nv) {
          if (nv != null) onChanged(nv);
        },
      );
      final built = itemBuilder?.call(context, v) ?? Text(label);
      children.add(
        InkWell(
          borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(v),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                    : null,
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [radio, built],
              ),
            ),
        ),
      );
    }
    final wrapped = direction == Axis.vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _withSpacing(children),
          )
        : Row(children: _withSpacing(children));
    return Padding(padding: padding, child: wrapped);
  }

  List<Widget> _withSpacing(List<Widget> items) {
    if (items.isEmpty) return items;
    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i != items.length - 1) {
        spaced.add(SizedBox(
          width: direction == Axis.horizontal ? spacing : 0,
          height: direction == Axis.vertical ? spacing : 0,
        ));
      }
    }
    return spaced;
  }
}
