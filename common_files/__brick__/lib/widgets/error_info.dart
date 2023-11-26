import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    required this.e,
    required this.s,
    super.key,
  });

  final Object e;
  final StackTrace s;

  @override
  Widget build(BuildContext context) {
    return kDebugMode
        ? Column(
            children: [
              Text(e.toString()),
              const Divider(),
              Card(child: Text(s.toString())),
            ],
          )
        : Center(child: Text(e.toString()));
  }
}
