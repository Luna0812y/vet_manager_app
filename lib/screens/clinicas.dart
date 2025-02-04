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

  @override
  void initState() {
    super.initState();
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
  void _loadClinics() {
    final List<Map<String, dynamic>> clinics = [
      {
        'nome': 'UDVet - Unidade de Diagnóstico Veterinário',
        'endereco': 'R. Prof. Pires Gayoso, 335 - Noivos, Teresina - PI, 64046-350',
        'latitude': -5.0700,
        'longitude': -42.7800,
        'nota': 4.8,
        'avaliacoes': 141,
        'descricao': 'Exames rápidos e confiáveis para seu pet. Agende agora!',
        'imagem': 'assets/images/clinica1.jpg',
      },
      {
        'nome': 'HVT Hospital Veterinário de Teresina',
        'endereco': 'Av. Mal. Juarez Távora, Quadra 57 - Casa 08 - Parque Piaui, Teresina - PI, 64025-196',
        'latitude': -5.1000,
        'longitude': -42.8100,
        'nota': 4.3,
        'avaliacoes': 856,
        'descricao': 'Hospital Veterinário de referência em Teresina.',
        'imagem': 'assets/images/clinica2.jpg',
      },
      {
        'nome': 'UbPet Teresina',
        'endereco': 'R. Barroso, 1928 - Vermelha, Teresina - PI, 64018-520',
        'latitude': -5.0800,
        'longitude': -42.7900,
        'nota': 4.9,
        'avaliacoes': 552,
        'descricao': 'Clínica especializada em atendimento personalizado para seu pet.',
        'imagem': 'assets/images/clinica3.jpeg',
      },
      {
        'nome': "Hospital Veterinário Animal's 24 Horas",
        'endereco': 'Av. Nossa Sra. de Fátima, 1525 - Fátima, Teresina - PI, 64048-180',
        'latitude': -5.0600,
        'longitude': -42.7700,
        'nota': 4.2,
        'avaliacoes': 700,
        'descricao': 'Atendimento 24 horas para emergências veterinárias.',
        'imagem': 'assets/images/clinica4.jpeg',
      },
      {
        'nome': 'Criar - Hospital Veterinário 24h',
        'endereco': 'Av. Jóquei Clube, 2176 - Letra B - São Cristóvão, Teresina - PI, 64052-160',
        'latitude': -5.0500,
        'longitude': -42.7600,
        'nota': 4.8,
        'avaliacoes': 233,
        'descricao': 'Atendimento veterinário especializado 24h.',
        'imagem': 'assets/images/clinica5.jpeg',
      },
    ];

    setState(() {
      markers = clinics.map((clinic) {
        return Marker(
          markerId: MarkerId(clinic['nome']),
          position: LatLng(clinic['latitude'], clinic['longitude']),
          infoWindow: InfoWindow(
            title: clinic['nome'],
            snippet: "${clinic['nota']} ★ (${clinic['avaliacoes']} avaliações)\n${clinic['descricao']}",
            onTap: () => _showClinicDetails(clinic),
          ),
        );
      }).toSet();
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
              target: _currentPosition ?? LatLng(-5.08921, -42.8016), // Posição inicial: Teresina, PI
              zoom: 12,
            ),
            markers: markers.union(
              _currentPosition != null
                ? {
                    Marker(
                      markerId: MarkerId("current_location"),
                      position: _currentPosition!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                      infoWindow: InfoWindow(title: "Você está aqui"),
                    ),
                  }
                : {},
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
