import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/map_camera_marker_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late StreamSubscription<Position> positionStream;
  late Future<Position> currentLocation = getCurrentIfPossible();
  late LocationSettings locationSettings;
  late CameraPosition stoCameraPosition;
  Set<Marker> _markers = {};
  bool isMapCameraMove = false;
  @override
  void initState() {
    super.initState();
    currentLocation = getCurrentIfPossible();
    // locationSettings = determineLocationSetting();// updatable : 이 함수가 readme그대로 한건데,,, 동작하지 않아서 임시로 기본코드 아래 입력
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    positionStream = Geolocator.getPositionStream(
            locationSettings:
                locationSettings) // 최소 1m 움직였을때 listen해서 아래 updateMapCameraPosition 실행
        .listen((Position position) {
      // updateMapCameraPosition(position);
    });
  }

  Future<void> updateMapCameraPosition(Position position) async {
    final GoogleMapController controller = await _controller.future;
    LatLng latLng = LatLng(position.latitude, position.longitude);
    // CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 15);
    // controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    updateMyMarkerPosition(latLng);
  }

  // 현재 위치를 표시하는 빨간색 마커, 내 위치를 다른 아이콘으로 표기하고싶을때 사용할것같다.
  void updateMyMarkerPosition(LatLng latLng) {
    Marker marker = Marker(
      markerId: const MarkerId('current_location'),
      position: latLng,
    );
    setState(() {
      _markers = <Marker>{marker};
    });
  }

  // 마커 추가하느 함수
  void addMarker() {
    int randomInt = Random().nextInt(100);
    LatLng latLng = LatLng(
      37.540853 + (randomInt * 0.001),
      127.078971 + (randomInt * 0.001),
    );
    Marker marker = Marker(
      markerId: MarkerId(randomInt.toString()),
      position: latLng,
    );

    setState(() {
      _markers.add(marker);
    });
  }

  @override
  void dispose() {
    // 끝날때 스트리밍 종료
    positionStream.cancel();
    super.dispose();
  }

  static const CameraPosition initCameraPosition = CameraPosition(
    target: LatLng(
      // 건국대 위치
      37.540853,
      127.078971,
    ),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Test'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 500,
            child: Stack(children: [
              GoogleMap(
                mapType: MapType.normal, // hybrid, normal
                initialCameraPosition: initCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true, // 내 위치를 중앙 파란점 + 방향 화살표
                myLocationButtonEnabled: false, // 우측 상단 내위치로 버튼
                compassEnabled: true, // 맵 회전시 다시 북쪽을 향하게하는 나침반
                mapToolbarEnabled: false, // 모르겠음
                markers: _markers,
                onCameraIdle: () {
                  // 카메라가 멈추면
                  setState(() {
                    isMapCameraMove = false;
                  });
                },
                onCameraMoveStarted: () {
                  // 카메라가 움직이기 시작하면
                  setState(() {
                    isMapCameraMove = true;
                  });
                },
              ),
              MapCameraMarkerWidget(isMapCameraMove: isMapCameraMove),
            ]),
          ),
          IconButton(
            onPressed: addMarker,
            icon: Icon(Icons.add_location_alt_outlined),
            iconSize: 30,
          ),
          IconButton(
            onPressed: addMarker,
            icon: Icon(Icons.check_outlined),
            iconSize: 30,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToCurrentPosition,
        label: const Text('current location!'),
        icon: const Icon(Icons.location_on_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // 현재 위치를 읽어오는 기준 세팅
  LocationSettings determineLocationSetting() {
    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 안드로이드
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // 불러오는 최소 수평이동거리
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
                "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // ios
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      // 디폴트
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
    return locationSettings;
  }

  // map camera를 현재위치로 이동
  Future<void> goToCurrentPosition() async {
    final GoogleMapController controller = await _controller.future;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('Location: ${position.latitude}, ${position.longitude}');

    CameraPosition currentCamera = CameraPosition(
      // 다른 파라미터로는  bearing과 tilt가 있다
      target: LatLng(
        position.latitude,
        position.longitude,
      ),
      zoom: 19.151926040649414,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(currentCamera));
  }

  // 위치권한이 있다면 현재 위치 불러오기
  Future<Position> getCurrentIfPossible() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
