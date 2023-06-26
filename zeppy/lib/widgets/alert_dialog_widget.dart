import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class alert_dialog_widget extends StatelessWidget {
  const alert_dialog_widget({
    super.key,
    required this.titleString,
    required this.contentString,
  });

  final String titleString;
  final String contentString;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showDialog(
          context: context,
          builder: (BuildContext) => AlertDialog(
                title: Text(titleString),
                content: Text(contentString),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
              )),
      icon: Icon(Icons.download_outlined),
      iconSize: 30,
    );
  }
}
