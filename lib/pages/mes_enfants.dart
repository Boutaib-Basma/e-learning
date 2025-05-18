import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'dart:convert';

class MesEnfantsPage extends StatefulWidget {
  const MesEnfantsPage({Key? key}) : super(key: key);

  @override
  _MesEnfantsPageState createState() => _MesEnfantsPageState();
}

class _MesEnfantsPageState extends State<MesEnfantsPage> {
  List<dynamic> _enfants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEnfants();
  }

  Future<void> _fetchEnfants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getInt('userId');
      final token = prefs.getString('authToken');

      if (parentId == null || token == null) {
        throw Exception('Informations utilisateur non disponibles');
      }

      final HttpClient client = HttpClient()
        ..badCertificateCallback = 
            (X509Certificate cert, String host, int port) => true;
      
      final ioClient = IOClient(client);
      
      final response = await ioClient.get(
        Uri.parse('https://192.168.1.128:5001/api/Parents/$parentId/Children'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _enfants = responseData;
          _isLoading = false;
        });
      } else {
        throw Exception('Échec du chargement des enfants');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Enfants'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erreur: $_errorMessage'))
              : _enfants.isEmpty
                  ? const Center(child: Text('Aucun enfant trouvé'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _enfants.length,
                      itemBuilder: (context, index) {
                        final enfant = _enfants[index];
                        return _buildEnfantCard(enfant);
                      },
                    ),
    );
  }

  Widget _buildEnfantCard(Map<String, dynamic> enfant) {
    final fullName = '${enfant['firstName'] ?? ''} ${enfant['lastName'] ?? ''}'.trim();
    final email = enfant['email'] ?? 'Email non disponible';
    final classe = enfant['class'] ?? 'Classe non spécifiée';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 24,
                      color: Color(0xFF8687E7),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isNotEmpty ? fullName : 'Nom non disponible',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.school,
                  size: 16,
                  color: Color(0xFF26A69A),
                ),
                const SizedBox(width: 8),
                Text(
                  classe,
                  style: const TextStyle(
                    color: Color(0xFF26A69A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}