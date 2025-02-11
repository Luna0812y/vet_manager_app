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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      clinic['nome_clinica'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            clinic['endereco'] ?? 'Endereço não disponível',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 5),
                        Text(
                          "${clinic['avaliacao_clinica']} ★ (${clinic['total_avaliacoes']} avaliações)",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    if (clinic['imagem'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          clinic['imagem'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 15),
                    Text(
                      clinic['descricao'] ?? 'Descrição não disponível',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Fechar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
