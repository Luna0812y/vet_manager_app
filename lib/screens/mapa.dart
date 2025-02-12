import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vet_manager/services/clinica_service.dart';

class ClinicasScreen extends StatefulWidget {
  const ClinicasScreen({super.key});

  @override
  _ClinicasScreenState createState() => _ClinicasScreenState();
}

class _ClinicasScreenState extends State<ClinicasScreen> {
  // Controladores e variáveis de estado para o mapa
  late GoogleMapController mapController;
  final ClinicaService clinicService = ClinicaService();
  Set<Marker> markers = {};
  LatLng? _currentPosition;
  bool isLoading = true;
  // Ícones personalizados para os marcadores do mapa
  BitmapDescriptor? _customIcon; // Ícone para clínicas
  BitmapDescriptor? _personIcon; // Ícone para localização do usuário

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
      setState(() {
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      isLoading = false;
    });

    mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }

  /// Carrega as clínicas de Teresina
  void _loadClinics() async {
    final clinicas = await ClinicaService().fetchClinics();

    setState(() {
      // Cria marcadores para cada clínica no mapa
      markers = clinicas.map((clinic) {
        return Marker(
          markerId: MarkerId(clinic['nome_clinica']),
          position: LatLng(clinic["localizacao"]["latitude"],
              clinic["localizacao"]["longitude"]),
          infoWindow: InfoWindow(
            title: clinic['nome_clinica'],
            // Exibe avaliação e número de avaliações no snippet
            snippet:
                "${clinic['avaliacao_clinica']} ★ (${clinic['total_avaliacoes']} avaliações)\n",
            onTap: () => _showClinicDetails(clinic),
          ),
          icon: _customIcon ?? BitmapDescriptor.defaultMarker,
        );
      }).toSet();
      isLoading = false;
    });
  }

  Future<BitmapDescriptor> _getCustomIcon(String path) async {
    return await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)), path);
  }

  loadIcon() async {
    BitmapDescriptor customIcon =
        await _getCustomIcon('assets/images/logo.png');

    BitmapDescriptor personIcon =
        await _getCustomIcon('assets/images/person-marker.png');

    setState(() {
      _customIcon = customIcon;
      _personIcon = personIcon;
    });
  }

  void _showClinicDetails(Map<String, dynamic> clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 15),
                    Text(
                      clinic['nome_clinica'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            clinic['endereco'] ?? 'Endereço não disponível',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 5),
                        Text(
                          "${clinic['avaliacao_clinica']} ★ (${clinic['total_avaliacoes']} avaliações)",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
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
                    const SizedBox(height: 15),
                    Text(
                      clinic['descricao'] ?? 'Descrição não disponível',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Fechar'),
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
        title: const Text("Clínicas Veterinárias"),
        actions: [
          // Botão para centralizar o mapa na localização atual
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          // Botão para recarregar as clínicas
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _loadClinics();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(-5.08921, -42.8016),
              zoom: 12,
            ),
            markers: markers.union(
              _currentPosition != null
                  ? {
                      Marker(
                        markerId: const MarkerId("current_location"),
                        position: _currentPosition!,
                        icon: _personIcon ?? BitmapDescriptor.defaultMarker,
                        infoWindow: const InfoWindow(title: "Você está aqui"),
                      ),
                    }
                  : {},
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
