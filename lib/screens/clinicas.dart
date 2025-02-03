import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_manager/services/clinica_service.dart';

class ClinicasScreen extends StatefulWidget {
  @override
  _ClinicasScreenState createState() => _ClinicasScreenState();
}

class _ClinicasScreenState extends State<ClinicasScreen> {
  late GoogleMapController mapController;
  final ClinicaService clinicService = ClinicaService();
  Set<Marker> markers = {};
  final LatLng _initialPosition = LatLng(-23.5505, -46.6333); 

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  void _loadClinics() async {
    try {
      List<Map<String, dynamic>> clinics = await clinicService.fetchClinics();
      setState(() {
        markers = clinics.map((clinic) {
          return Marker(
            markerId: MarkerId(clinic['id'].toString()),
            position: LatLng(clinic['latitude'], clinic['longitude']),
            infoWindow: InfoWindow(title: clinic['name'], snippet: clinic['address']),
          );
        }).toSet();
      });
    } catch (e) {
      print("Erro ao carregar clínicas: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clínicas Veterinárias")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 12),
        markers: markers,
      ),
    );
  }
}
