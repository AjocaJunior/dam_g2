import 'dart:convert';
import 'dart:io';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:mongo_dart/mongo_dart.dart';

const _defaultMongoUrl =
    'mongodb+srv://2501419_db_user:assis4109@damg2.e8pwzgj.mongodb.net/animal_sos_db?retryWrites=true&w=majority&appName=DAMg2';

late final Db _db;
late final DbCollection _utilizadores;
late final DbCollection _animais;
late final DbCollection _alertas;
late final DbCollection _notificacoes;
late final String _activeDatabaseName;

Future<void> main() async {
  final mongoUrl = Platform.environment['MONGO_URL'] ?? _defaultMongoUrl;
  final port = int.tryParse(Platform.environment['API_PORT'] ?? '') ?? 8080;
  _activeDatabaseName = _databaseName(mongoUrl);

  if (mongoUrl.contains('<db_username>') ||
      mongoUrl.contains('<db_password>')) {
    stderr.writeln(
      'Configure MONGO_URL com o utilizador e a senha reais do MongoDB Atlas.',
    );
    stderr.writeln(
      'Exemplo: \$env:MONGO_URL="mongodb+srv://USER:PASSWORD@damg2.e8pwzgj.mongodb.net/animal_sos_db?retryWrites=true&w=majority&appName=DAMg2"',
    );
    exitCode = 64;
    return;
  }

  _db = await Db.create(mongoUrl);
  await _db.open();
  _utilizadores = _db.collection('utilizadores');
  _animais = _db.collection('animais');
  _alertas = _db.collection('alertas_sos');
  _notificacoes = _db.collection('notificacoes');

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('API SOS Animal ligada em http://127.0.0.1:$port');
  stdout.writeln('MongoDB ligado com sucesso em $_activeDatabaseName.');

  await for (final request in server) {
    await _handleRequest(request);
  }
}

Future<void> _handleRequest(HttpRequest request) async {
  _addCorsHeaders(request.response);

  if (request.method == 'OPTIONS') {
    await _sendJson(request.response, {'ok': true});
    return;
  }

  try {
    final path = request.uri.path;

    if (request.method == 'GET' && path == '/health') {
      await _sendJson(request.response, {'ok': true});
      return;
    }

    if (request.method == 'POST' && path == '/register') {
      await _register(request);
      return;
    }

    if (request.method == 'POST' && path == '/login') {
      await _login(request);
      return;
    }

    if (request.method == 'POST' && path == '/alerts') {
      await _createAlert(request);
      return;
    }

    if (request.method == 'GET' && path == '/alerts') {
      await _listAlerts(request);
      return;
    }

    if (request.method == 'GET' && path == '/debug/counts') {
      await _debugCounts(request);
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Rota nao encontrada.',
    });
  } catch (e) {
    request.response.statusCode = HttpStatus.internalServerError;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Erro interno: $e',
    });
  }
}

Future<void> _register(HttpRequest request) async {
  final body = await _readJson(request);
  final nome = body['nome']?.toString().trim() ?? '';
  final email = body['email']?.toString().trim() ?? '';
  final telefone = body['telefone']?.toString().trim() ?? '';
  final password = body['password']?.toString() ?? '';

  if (nome.isEmpty || email.isEmpty || telefone.isEmpty || password.isEmpty) {
    request.response.statusCode = HttpStatus.badRequest;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Dados de registo incompletos.',
    });
    return;
  }

  final existente = await _utilizadores.findOne(where.eq('email', email));
  if (existente != null) {
    request.response.statusCode = HttpStatus.conflict;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Email ja registado.',
    });
    return;
  }

  final utilizador = {
    '_id': ObjectId(),
    'nome': nome,
    'email': email,
    'telefone': telefone,
    'passwordHash': DBCrypt().hashpw(password, DBCrypt().gensalt()),
    'tipo': 'UTILIZADOR',
    'createdAt': DateTime.now().toUtc(),
  };

  await _utilizadores.insertOne(utilizador);
  stdout.writeln('Utilizador registado: $email');
  await _sendJson(request.response, {
    'ok': true,
    'utilizador': _safeUser(utilizador),
  });
}

Future<void> _login(HttpRequest request) async {
  final body = await _readJson(request);
  final email = body['email']?.toString().trim() ?? '';
  final password = body['password']?.toString() ?? '';

  final utilizador = await _utilizadores.findOne(where.eq('email', email));
  final passwordHash = utilizador?['passwordHash']?.toString() ?? '';
  final passwordOk =
      utilizador != null && DBCrypt().checkpw(password, passwordHash);

  if (!passwordOk) {
    request.response.statusCode = HttpStatus.unauthorized;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Credenciais invalidas.',
    });
    return;
  }

  await _sendJson(request.response, {
    'ok': true,
    'utilizador': _safeUser(utilizador),
  });
}

Future<void> _createAlert(HttpRequest request) async {
  final body = await _readJson(request);
  final utilizadorId = _parseObjectId(body['utilizadorId']);
  final estadoAnimal = _normalizarEstado(body['estadoAnimal']?.toString());
  final descricao =
      body['descricao']?.toString() ?? 'Alerta criado pela aplicacao mobile.';
  final animalBody = body['animal'] is Map
      ? Map<String, dynamic>.from(body['animal'] as Map)
      : <String, dynamic>{};
  final fotoBody = body['foto'] is Map
      ? Map<String, dynamic>.from(body['foto'] as Map)
      : <String, dynamic>{};
  final localizacaoBody = body['localizacao'] is Map
      ? Map<String, dynamic>.from(body['localizacao'] as Map)
      : <String, dynamic>{};
  stdout.writeln(
    'Pedido de alerta recebido | gps=${localizacaoBody.isNotEmpty} '
    'foto=${(fotoBody['base64']?.toString() ?? '').isNotEmpty}',
  );

  if (utilizadorId == null) {
    request.response.statusCode = HttpStatus.badRequest;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Utilizador invalido.',
    });
    return;
  }

  final agora = DateTime.now().toUtc();
  final animalId = ObjectId();
  final alertaId = ObjectId();
  final animal = {
    '_id': animalId,
    'nome': _textoOuPadrao(animalBody['nome'], 'Animal nao identificado'),
    'especie': _textoOuPadrao(animalBody['especie'], 'Nao informada'),
    'raca': _textoOuPadrao(animalBody['raca'], 'Nao informada'),
    'cor': _textoOuPadrao(animalBody['cor'], 'Nao informada'),
    'descricao': descricao,
    'identificadorTracker': 'APP-${animalId.oid.substring(0, 6).toUpperCase()}',
    'createdAt': agora,
  };
  final fotos = _montarFotos(fotoBody, agora);
  final localizacao = _montarLocalizacao(localizacaoBody, agora);

  if (localizacao == null) {
    request.response.statusCode = HttpStatus.badRequest;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Localizacao GPS obrigatoria para criar alerta SOS.',
    });
    return;
  }

  final alerta = {
    '_id': alertaId,
    'utilizadorId': utilizadorId,
    'animalId': animalId,
    'dataHora': agora,
    'estadoAnimal': estadoAnimal,
    'descricao': descricao,
    'statusAlerta': 'ENVIADO',
    'origem': 'APP_MOBILE',
    'localizacao': localizacao,
    'fotos': fotos,
    'createdAt': agora,
    'updatedAt': agora,
  };

  try {
    _ensureWriteSuccess(await _animais.insertOne(animal), 'inserir animal');
    _ensureWriteSuccess(await _alertas.insertOne(alerta), 'inserir alerta SOS');

    final alertaPersistido = await _alertas.findOne(where.id(alertaId));
    if (alertaPersistido == null) {
      throw StateError(
        'Alerta ${alertaId.oid} nao foi encontrado apos insertOne.',
      );
    }

    _ensureWriteSuccess(
      await _notificacoes.insertOne({
        '_id': ObjectId(),
        'alertaId': alertaId,
        'utilizadorId': utilizadorId,
        'mensagem': 'O seu alerta SOS foi enviado com sucesso.',
        'tipo': 'CONFIRMACAO',
        'dataEnvio': agora,
        'lida': false,
      }),
      'inserir notificacao',
    );
  } catch (e) {
    await _animais.deleteOne(where.id(animalId));
    await _alertas.deleteOne(where.id(alertaId));
    stderr.writeln('Erro ao criar alerta SOS: $e');
    request.response.statusCode = HttpStatus.internalServerError;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Erro ao gravar alerta SOS: $e',
    });
    return;
  }

  final localizacaoPersistida = alerta['localizacao'] as Map<String, dynamic>;
  final coordinates = localizacaoPersistida['coordinates'] as List;
  stdout.writeln(
    'Alerta SOS criado: ${alertaId.oid} | utilizador ${utilizadorId.oid} | '
    'lat ${coordinates[1]} lng ${coordinates[0]} | '
    'fotos ${fotos.length}',
  );

  await _sendJson(request.response, {
    'ok': true,
    'alerta': _toJsonValue({...alerta, 'animal': animal}),
  });
}

Future<void> _listAlerts(HttpRequest request) async {
  final utilizadorId = _parseObjectId(
    request.uri.queryParameters['utilizadorId'],
  );
  final onlyMine = request.uri.queryParameters.containsKey('utilizadorId');
  if (onlyMine && utilizadorId == null) {
    request.response.statusCode = HttpStatus.badRequest;
    await _sendJson(request.response, {
      'ok': false,
      'message': 'Utilizador invalido.',
    });
    return;
  }

  final selector = where.sortBy('createdAt', descending: true);
  if (utilizadorId != null) {
    selector.eq('utilizadorId', utilizadorId);
  }

  final alertas = await _alertas.find(selector).toList();

  for (final alerta in alertas) {
    final animalId = alerta['animalId'];
    if (animalId != null) {
      alerta['animal'] = await _animais.findOne(where.id(animalId));
    }
  }

  await _sendJson(request.response, {
    'ok': true,
    'alertas': _toJsonValue(alertas),
  });
}

Future<void> _debugCounts(HttpRequest request) async {
  await _sendJson(request.response, {
    'ok': true,
    'database': _activeDatabaseName,
    'utilizadores': await _utilizadores.count(),
    'animais': await _animais.count(),
    'alertas_sos': await _alertas.count(),
    'notificacoes': await _notificacoes.count(),
  });
}

Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
  final rawBody = await utf8.decoder.bind(request).join();
  if (rawBody.trim().isEmpty) return {};

  final decoded = jsonDecode(rawBody);
  if (decoded is Map) return Map<String, dynamic>.from(decoded);

  return {};
}

Future<void> _sendJson(HttpResponse response, Map<String, dynamic> body) async {
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(_toJsonValue(body)));
  await response.close();
}

void _addCorsHeaders(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
}

Map<String, dynamic> _safeUser(Map<String, dynamic> user) {
  final safe = Map<String, dynamic>.from(user)..remove('passwordHash');
  return Map<String, dynamic>.from(_toJsonValue(safe) as Map);
}

ObjectId? _parseObjectId(dynamic value) {
  if (value is ObjectId) return value;
  if (value == null) return null;

  try {
    return ObjectId.parse(value.toString());
  } catch (_) {
    return null;
  }
}

String _normalizarEstado(String? estado) {
  switch (estado?.toLowerCase()) {
    case 'ferido':
      return 'FERIDO';
    case 'perdido':
      return 'PERDIDO';
    default:
      if (estado == 'FERIDO' || estado == 'PERDIDO') return estado!;
      return 'OUTRO';
  }
}

String _textoOuPadrao(dynamic value, String padrao) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? padrao : text;
}

List<Map<String, dynamic>> _montarFotos(
  Map<String, dynamic> fotoBody,
  DateTime agora,
) {
  final base64 = fotoBody['base64']?.toString() ?? '';
  if (base64.isEmpty) return [];

  final mimeType = _textoOuPadrao(fotoBody['mimeType'], 'image/jpeg');
  final nome = _textoOuPadrao(fotoBody['nome'], 'foto-animal.jpg');

  return [
    {
      'url': 'data:$mimeType;base64,$base64',
      'nome': nome,
      'descricao': 'Foto do animal no local',
      'dataCaptura': agora,
    },
  ];
}

Map<String, dynamic>? _montarLocalizacao(
  Map<String, dynamic> localizacaoBody,
  DateTime agora,
) {
  final latitude = _toDouble(localizacaoBody['latitude']);
  final longitude = _toDouble(localizacaoBody['longitude']);
  if (latitude == null || longitude == null) return null;

  final precisao = _toDouble(localizacaoBody['precisao']) ?? 15.5;
  final timestamp =
      DateTime.tryParse(localizacaoBody['timestamp']?.toString() ?? '') ??
      agora;

  return {
    'type': 'Point',
    'coordinates': [longitude, latitude],
    'precisao': precisao,
    'timestamp': timestamp.toUtc(),
  };
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

void _ensureWriteSuccess(dynamic result, String operation) {
  final isSuccess = result.isSuccess == true;
  if (isSuccess) return;

  throw StateError(
    'Falha ao $operation. Resultado MongoDB: ${result.serverResponses}',
  );
}

dynamic _toJsonValue(dynamic value) {
  if (value is ObjectId) return value.oid;
  if (value is DateTime) return value.toIso8601String();
  if (value is Map) {
    return value.map((key, mapValue) {
      return MapEntry(key.toString(), _toJsonValue(mapValue));
    });
  }
  if (value is List) return value.map(_toJsonValue).toList();
  return value;
}

String _databaseName(String mongoUrl) {
  final uri = Uri.parse(mongoUrl);
  final path = uri.path.replaceFirst('/', '');
  return path.isEmpty ? 'test' : path;
}
