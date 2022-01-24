import 'dart:async';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:url_launcher/url_launcher.dart';

class DeliveryOrdersMapController {

  BuildContext? context;
  Function? refresh;
  Position? _position;
  String? addressName;
  LatLng? addressLatLng;
  CameraPosition initialPosition = CameraPosition(
      target: LatLng(4.6359348,-74.0911402),
      zoom: 14 // 1 - 20
  );
  Completer<GoogleMapController> _mapController = Completer();
  BitmapDescriptor? deliveryMarker;
  BitmapDescriptor? homeMarker;
  Map<MarkerId, Marker>? markers = <MarkerId, Marker>{};
  Order? order;
  Set<Polyline> polylines = Set();
  List<LatLng> points = [];
  StreamSubscription? _positionStream;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    order = Order.fromJson(
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>
    );
    print('orden: ${order!.toJson()}');

    deliveryMarker = await createMarkerFromAssets('assets/img/delivery2.png');
    homeMarker = await createMarkerFromAssets('assets/img/home.png');
    checkGPS();
  }

  Future<void> setPolylines(LatLng from, LatLng to) async {
    PointLatLng pointFrom = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointTo = PointLatLng(to.latitude, to.longitude);
    PolylineResult result = await PolylinePoints()
        .getRouteBetweenCoordinates(Environment.API_KEY_MAPS, pointFrom, pointTo);
    
    for(PointLatLng point in result.points){
      points.add(LatLng(point.latitude, point.longitude));
    }
    Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: MyColors.primaryColor,
        points: points,
        width: 6,
    );

    polylines.add(polyline);

    refresh!();
  }

  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker){
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content)
    );
    markers![id] = marker;
    refresh!();
  }

  void selectRefPoint(){
    Map<String, dynamic> data = {
      'address': addressName,
      'lat': addressLatLng!.latitude,
      'lng': addressLatLng!.longitude
    };
    Navigator.pop(context!, data);
  }

  Future<BitmapDescriptor> createMarkerFromAssets(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;
  }

  Future<Null> setLocationDraggableInfo() async {
    if(initialPosition != null){
      double lat = initialPosition.target.latitude;
      double lng = initialPosition.target.longitude;

      List<Placemark> address = await placemarkFromCoordinates(lat, lng);
      if(address != null){
        if(address.length > 0){
          String direction = address[0].thoroughfare ?? '';
          String street = address[0].subThoroughfare ?? '';
          String department = address[0].administrativeArea ?? '';
          String city = address[0].locality ?? '';
          String country = address[0].country ?? '';

          addressName = '$direction #$street, $city, $department';
          addressLatLng = LatLng(lat, lng);

          //print('LAT: ${addressLatLng!.latitude}');
          //print('LNG: ${addressLatLng!.longitude}');
          refresh!();
        }
      }
    }
  }

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle('[{"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]}]');
    _mapController.complete(controller);
  }

  void dispose(){
    _positionStream!.cancel();
  }

  void updateLocation() async {
    try {
      await _determinePosition(); // obtener posicion actual y solicitar permisos
      _position = await Geolocator.getLastKnownPosition(); // lat y lng

      animateCameraToPosition(_position!.latitude, _position!.longitude);

      // delivery marker
      addMarker(
          'delivery',
          _position!.latitude,
          _position!.longitude,
          'Tu posicion',
          '',
          deliveryMarker!
      );

      // home marker
      addMarker(
          'home',
          order!.address!.lat!,
          order!.address!.lng!,
          'Lugar de entrega',
          '',
          homeMarker!
      );

      LatLng from = LatLng(_position!.latitude, _position!.longitude);
      LatLng to = LatLng(order!.address!.lat!, order!.address!.lng!);

      setPolylines(from, to);


      LocationSettings? locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1
      );
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _position = position; // assign the new position
        // move the delivery marker
        addMarker(
            'delivery',
            _position!.latitude,
            _position!.longitude,
            'Tu posicion',
            '',
            deliveryMarker!
        );

        animateCameraToPosition(_position!.latitude, _position!.longitude);
        refresh!();

      });

    } catch(e){
      print('Error: $e');
    }
  }
  
  void call() async {
    String url = 'tel:${order!.client!.phone}';
    if (order!.client!.phone != null && await canLaunch(url)) {
      print('llamando a $url');
      launch(url);
    } else {
      Fluttertoast.showToast(msg: 'El usuario no posee numero registrado');
      throw 'Could not launch $url';
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(isLocationEnabled){
      updateLocation();
    } else {
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        updateLocation();
      }
    }
  }

  Future? animateCameraToPosition(double lat, double lng) async {
    GoogleMapController controller = await _mapController.future;
    if(controller != null){
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15,
        )
      ));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}