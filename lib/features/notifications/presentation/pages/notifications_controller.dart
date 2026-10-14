import 'package:flutter/material.dart';

/// Filtre + okundu state'i.
mixin NotificationsControllerMixin<T extends StatefulWidget> on State<T> {
  int filter = 0;
  final Set<int> read = {};

  void setFilter(int i) => setState(() => filter = i);
  void markRead(int index) => setState(() => read.add(index));
  void markAllRead(Iterable<int> indexes) =>
      setState(() => read.addAll(indexes));

  void showMarkedAllReadMessage() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        duration: Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
