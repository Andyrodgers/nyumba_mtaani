import 'package:flutter/material.dart';

/// A custom radio group widget to provide a selection state to its descendants.
class NyumbaRadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  const NyumbaRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return NyumbaRadioGroupScope<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }

  static NyumbaRadioGroupScope<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NyumbaRadioGroupScope<T>>();
  }
}

/// The scope that holds the radio group state. Public to avoid library_private_types_in_public_api.
class NyumbaRadioGroupScope<T> extends InheritedWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;

  const NyumbaRadioGroupScope({
    required this.groupValue,
    required this.onChanged,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(NyumbaRadioGroupScope<T> oldWidget) {
    return oldWidget.groupValue != groupValue || oldWidget.onChanged != onChanged;
  }
}

/// A custom list tile that integrates with [NyumbaRadioGroup].
class NyumbaRadioListTile<T> extends StatelessWidget {
  final Widget title;
  final T value;
  final Widget? subtitle;

  const NyumbaRadioListTile({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scope = NyumbaRadioGroup.of<T>(context);
    if (scope == null) {
      throw FlutterError('NyumbaRadioListTile must be a descendant of NyumbaRadioGroup');
    }

    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: Radio<T>(
        value: value,
        // ignore: deprecated_member_use
        groupValue: scope.groupValue,
        // ignore: deprecated_member_use
        onChanged: scope.onChanged,
      ),
      onTap: () => scope.onChanged(value),
    );
  }
}
