import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

class MongoService {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  static Map<String, dynamic>? utilizadorLogado;
  static String? ultimoErro;

  static Future<void> connect() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/health'));
      if (response.statusCode == 200) {
        debugPrint('API MongoDB ligada em $apiUrl.');
      } else {
        debugPrint('API MongoDB respondeu com estado ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('API MongoDB indisponivel em $apiUrl: $e');
    }
  }

  static Future<bool> registarUtilizador({
    required String nome,
    required String email,
    required String telefone,
    required String password,
  }) async {
    final response = await _post('/register', {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'password': password,
    });

    if (response == null || response['ok'] != true) {
      ultimoErro = response?['message']?.toString();
      return false;
    }
    utilizadorLogado = Map<String, dynamic>.from(response['utilizador']);
    return true;
  }

  static Future<bool> verificarLogin({
    required String email,
    required String password,
  }) async {
    final response = await _post('/login', {
      'email': email,
      'password': password,
    });

    if (response == null || response['ok'] != true) {
      ultimoErro = response?['message']?.toString();
      return false;
    }
    utilizadorLogado = Map<String, dynamic>.from(response['utilizador']);
    return true;
  }

  static Future<bool> criarAlertaAnimal({
    required String estadoAnimal,
    required String nomeAnimal,
    required String especie,
    required String raca,
    required String cor,
    required String descricaoAlerta,
    String? fotoBase64,
    String? fotoMimeType,
    String? fotoNome,
    Map<String, dynamic>? localizacao,
  }) async {
    final utilizador = utilizadorLogado;
    if (utilizador == null) return false;

    final response = await _post('/alerts', {
      'utilizadorId': utilizador['_id'],
      'estadoAnimal': _normalizarEstadoAnimal(estadoAnimal),
      'descricao': descricaoAlerta,
      'animal': {
        'nome': nomeAnimal,
        'especie': especie,
        'raca': raca,
        'cor': cor,
      },
      'foto': {
        'base64': fotoBase64,
        'mimeType': fotoMimeType,
        'nome': fotoNome,
      },
      'localizacao': localizacao,
    });

    if (response == null || response['ok'] != true) {
      ultimoErro = response?['message']?.toString();
      return false;
    }

    ultimoErro = null;
    return true;
  }

  static Future<List<Map<String, dynamic>>> listarAlertasDoUtilizador() async {
    final utilizador = utilizadorLogado;
    if (utilizador == null) return [];

    final response = await _get('/alerts?utilizadorId=${utilizador['_id']}');
    return _parseAlertasResponse(response);
  }

  static Future<List<Map<String, dynamic>>> listarHistoricoAlertas() async {
    final response = await _get('/alerts');
    return _parseAlertasResponse(response);
  }

  static Future<Map<String, dynamic>?> atualizarStatusAlerta({
    required String alertaId,
    required String statusAlerta,
  }) async {
    final utilizador = utilizadorLogado;
    if (utilizador == null) return null;

    final response = await _patch('/alerts/$alertaId/status', {
      'utilizadorId': utilizador['_id'],
      'statusAlerta': statusAlerta,
    });

    if (response == null || response['ok'] != true) {
      ultimoErro = response?['message']?.toString();
      return null;
    }

    ultimoErro = null;
    final alerta = response['alerta'];
    return alerta is Map ? Map<String, dynamic>.from(alerta) : null;
  }

  static List<Map<String, dynamic>> _parseAlertasResponse(
    Map<String, dynamic>? response,
  ) {
    if (response == null || response['ok'] != true) return [];

    final alertas = response['alertas'];
    if (alertas is! List) return [];

    return alertas
        .whereType<Map>()
        .map((alerta) => Map<String, dynamic>.from(alerta))
        .toList();
  }

  static void efetuarLogout() {
    utilizadorLogado = null;
  }

  static String _normalizarEstadoAnimal(String estadoAnimal) {
    switch (estadoAnimal.toLowerCase()) {
      case 'ferido':
        return 'FERIDO';
      case 'perdido':
        return 'PERDIDO';
      default:
        return 'OUTRO';
    }
  }

  static Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl$path'));
      return _decodeResponse(response);
    } catch (e) {
      ultimoErro = e.toString();
      debugPrint('Erro HTTP GET $path: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl$path'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _decodeResponse(response);
    } catch (e) {
      ultimoErro = e.toString();
      debugPrint('Erro HTTP POST $path: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl$path'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _decodeResponse(response);
    } catch (e) {
      ultimoErro = e.toString();
      debugPrint('Erro HTTP PATCH $path: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return null;

    final result = Map<String, dynamic>.from(decoded);
    if (response.statusCode >= 400) {
      ultimoErro = result['message']?.toString() ?? response.body;
    }
    return result;
  }
}
