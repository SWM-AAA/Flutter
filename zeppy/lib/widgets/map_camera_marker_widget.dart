import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MapCameraMarkerWidget extends StatelessWidget {
  const MapCameraMarkerWidget({
    super.key,
    required this.isMapCameraMove,
  });

  final bool isMapCameraMove;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 50,
        height: 50,
        child: IconButton(
          icon: isMapCameraMove
              ? Icon(Icons.location_on_sharp)
              : Icon(Icons.location_on_outlined),
          onPressed: () {},
          iconSize: 30,
        ),
      ),
    );
  }
}
