// lib/features/home/presentation/pages/map_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _ctrl = Completer();
  LatLng? _pos;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final loc = Location();

    // 1) Comprueba permisos
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await loc.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await loc.requestService();
      if (!serviceEnabled) {
        setState(() {
          _error = 'El servicio de ubicación está deshabilitado.';
          _loading = false;
        });
        return;
      }
    }

    permissionGranted = await loc.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await loc.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _error = 'Permiso de ubicación denegado.';
          _loading = false;
        });
        return;
      }
    }

    // 2) Obtiene la ubicación
    try {
      final data = await loc.getLocation();
      setState(() {
        _pos = LatLng(data.latitude!, data.longitude!);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error obteniendo ubicación: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Mapa')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: Center(child: Text(_error!)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _pos!, zoom: 15),
        myLocationEnabled: true,
        onMapCreated: (c) => _ctrl.complete(c),
      ),
    );
  }
}
