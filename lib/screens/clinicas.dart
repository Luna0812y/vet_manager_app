import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vet_manager/services/clinica_service.dart';

class ClinicasScreen extends StatefulWidget {
  @override
  _ClinicasScreenState createState() => _ClinicasScreenState();
}

class _ClinicasScreenState extends State<ClinicasScreen> {
  late GoogleMapController mapController;
  final ClinicaService clinicService = ClinicaService();
  Set<Marker> markers = {};
  LatLng? _currentPosition;
  bool isLoading = true;
  BitmapDescriptor? _customIcon;
  BitmapDescriptor? customIconPerson;

  @override
  void initState() {
    super.initState();
    loadIcon();
    _getCurrentLocation();
    _loadClinics();
  }

  /// Obtém a localização atual do usuário
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Serviço de localização desativado.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permissão de localização negada.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permissão de localização negada permanentemente.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  /// Carrega as clínicas de Teresina
  void _loadClinics() async {
    final clinicas = await ClinicaService().fetchClinics();

    setState(() {
      markers = clinicas.map((clinic) {
        return Marker(
          markerId: MarkerId(clinic['nome_clinica']),
          position: LatLng(clinic["localizacao"]["latitude"],
              clinic["localizacao"]["longitude"]),
          infoWindow: InfoWindow(
            title: clinic['nome_clinica'],
            snippet:
                "${clinic['avaliacao_clinica']} ★ (${clinic['total_avaliacoes']} avaliações)\n",
            onTap: () => _showClinicDetails(clinic),
          ),
          icon: _customIcon ?? BitmapDescriptor.defaultMarker,
        );
      }).toSet();
    });
  }

  Future<BitmapDescriptor> _getCustomIcon(String path) async {
    return await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)),
      path,
    );
  }

  loadIcon() async {
    BitmapDescriptor customIcon =
        await _getCustomIcon('assets/images/logo.png');
    setState(() {
      _customIcon = customIcon;
    });
  }

  void _showClinicDetails(Map<String, dynamic> clinic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(clinic['nome']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(clinic['imagem'], height: 150, fit: BoxFit.cover),
              SizedBox(height: 10),
              Text("📍 ${clinic['endereco']}"),
              Text("⭐ ${clinic['nota']} (${clinic['avaliacoes']} avaliações)"),
              Text("📖 ${clinic['descricao']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Fechar"),
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (markers.isNotEmpty) {
      final firstClinic = markers.first.position;
      mapController.animateCamera(CameraUpdate.newLatLngZoom(firstClinic, 12));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clínicas Veterinárias"),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadClinics,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition ??
                  LatLng(-5.08921, -42.8016), // Posição inicial: Teresina, PI
              zoom: 12,
            ),
            markers: markers.union(
              _currentPosition != null
                  ? {
                      Marker(
                        markerId: MarkerId("current_location"),
                        position: _currentPosition!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        infoWindow: InfoWindow(title: "Você está aqui"),
                      ),
                    }
                  : {},
            ),
          ),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}