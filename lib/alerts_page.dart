import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'mongo_service.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late Future<List<Map<String, dynamic>>> _alertasFuture;
  bool _somenteMeusAlertas = true;

  @override
  void initState() {
    super.initState();
    _alertasFuture = _carregarAlertas();
  }

  void _recarregarAlertas() {
    setState(() {
      _alertasFuture = _carregarAlertas();
    });
  }

  Future<List<Map<String, dynamic>>> _carregarAlertas() {
    return _somenteMeusAlertas
        ? MongoService.listarAlertasDoUtilizador()
        : MongoService.listarHistoricoAlertas();
  }

  @override
  Widget build(BuildContext context) {
    final user = MongoService.utilizadorLogado;
    final String nomeUsuario = user != null ? user['nome'] : 'Utilizador Teste';
    final String emailUsuario = user != null
        ? user['email']
        : 'teste@damg2.com';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border(
                  bottom: BorderSide(color: Colors.black12, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF2E2E2E),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ola, $nomeUsuario!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          emailUsuario,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () {
                      MongoService.efetuarLogout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5733),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'ANIMAL SOS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _recarregarAlertas,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF2E2E2E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _somenteMeusAlertas ? 'Meus Alertas' : 'Historico',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.person),
                        label: Text('Meus'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.history),
                        label: Text('Historico'),
                      ),
                    ],
                    selected: {_somenteMeusAlertas},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _somenteMeusAlertas = selection.first;
                        _alertasFuture = _carregarAlertas();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _alertasFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final alertas = snapshot.data ?? [];
                        if (alertas.isEmpty) {
                          return Center(
                            child: Text(
                              _somenteMeusAlertas
                                  ? 'Ainda nao existem alertas criados.'
                                  : 'Ainda nao existem alertas no historico.',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: alertas.length,
                          itemBuilder: (context, index) {
                            return _buildAlertCard(alertas[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alerta) {
    final animal = alerta['animal'] as Map<String, dynamic>?;
    final estado = alerta['estadoAnimal']?.toString() ?? 'OUTRO';
    final status = alerta['statusAlerta']?.toString() ?? 'ENVIADO';
    final data = _formatarData(alerta['dataHora'] ?? alerta['createdAt']);
    final cor = _corEstado(estado);
    final titulo = animal?['nome']?.toString() ?? 'Animal reportado';
    final detalhe = [
      animal?['especie']?.toString(),
      animal?['raca']?.toString(),
      animal?['cor']?.toString(),
    ].where((value) => value != null && value.trim().isNotEmpty).join(' - ');
    final fotoBytes = _fotoBytes(alerta);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () => _mostrarDetalhes(alerta),
        leading: fotoBytes == null
            ? CircleAvatar(
                backgroundColor: cor.withValues(alpha: 0.2),
                child: Icon(Icons.pets, color: cor),
              )
            : CircleAvatar(backgroundImage: MemoryImage(fotoBytes)),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$detalhe\nData: $data'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$estado\n$status',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhes(Map<String, dynamic> alerta) {
    final animal = alerta['animal'] as Map<String, dynamic>?;
    final fotoBytes = _fotoBytes(alerta);
    final estado = alerta['estadoAnimal']?.toString() ?? 'OUTRO';
    final status = alerta['statusAlerta']?.toString() ?? 'ENVIADO';
    final descricao = alerta['descricao']?.toString() ?? 'Sem descricao';
    final data = _formatarData(alerta['dataHora'] ?? alerta['createdAt']);
    final localizacao = _localizacaoText(alerta['localizacao']);
    final dialogWidth = math.min(MediaQuery.sizeOf(context).width - 48, 460.0);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(animal?['nome']?.toString() ?? 'Detalhes do alerta'),
          content: SizedBox(
            width: dialogWidth,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (fotoBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: dialogWidth,
                        height: 220,
                        child: Image.memory(fotoBytes, fit: BoxFit.cover),
                      ),
                    ),
                  if (fotoBytes != null) const SizedBox(height: 14),
                  _detailRow('Estado', estado),
                  _detailRow('Status', status),
                  _detailRow('Data', data),
                  _detailRow('Especie', animal?['especie']?.toString()),
                  _detailRow('Raca', animal?['raca']?.toString()),
                  _detailRow('Cor', animal?['cor']?.toString()),
                  _detailRow('Localizacao', localizacao),
                  const SizedBox(height: 10),
                  const Text(
                    'Descricao',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(descricao),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String? value) {
    final safeValue = value == null || value.trim().isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: safeValue),
          ],
        ),
      ),
    );
  }

  Color _corEstado(String estado) {
    switch (estado) {
      case 'FERIDO':
        return Colors.red;
      case 'PERDIDO':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatarData(dynamic valor) {
    DateTime? data;
    if (valor is DateTime) {
      data = valor.toLocal();
    } else if (valor != null) {
      data = DateTime.tryParse(valor.toString())?.toLocal();
    }

    if (data == null) return 'Sem data';

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}, $hora:$minuto';
  }

  Uint8List? _fotoBytes(Map<String, dynamic> alerta) {
    final fotos = alerta['fotos'];
    if (fotos is! List || fotos.isEmpty) return null;

    final primeiraFoto = fotos.first;
    if (primeiraFoto is! Map) return null;

    final url = primeiraFoto['url']?.toString() ?? '';
    final marker = ';base64,';
    final markerIndex = url.indexOf(marker);
    if (markerIndex == -1) return null;

    try {
      return base64Decode(url.substring(markerIndex + marker.length));
    } catch (_) {
      return null;
    }
  }

  String _localizacaoText(dynamic localizacao) {
    if (localizacao is! Map) return 'Sem localizacao';

    final coordinates = localizacao['coordinates'];
    if (coordinates is List && coordinates.length >= 2) {
      return 'Lat ${coordinates[1]}, Lng ${coordinates[0]}';
    }

    final lat = localizacao['latitude'];
    final lng = localizacao['longitude'];
    if (lat != null && lng != null) return 'Lat $lat, Lng $lng';

    return 'Sem localizacao';
  }
}
