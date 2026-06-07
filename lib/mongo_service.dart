import 'package:mongo_dart/mongo_dart.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MongoService {
  static const String mongoUrl = "mongodb+srv://1004166_db_user:GxEzMoo9WPNIzCx8@damg2.e8pwzgj.mongodb.net/?appName=DAMg2";
  static var db;
  static var userCollection;

  // Variável global de sessão
  static Map<String, dynamic>? utilizadorLogado;

  static Future<void> connect() async {
    if (kIsWeb) {
      print("Ambiente Web detetado. Conexão MongoDB em modo Simulação.");
      return;
    }
    try {
      db = await Db.create(mongoUrl);
      await db.open();
      userCollection = db.collection('utilizadores');
      print("Conexão ao MongoDB efetuada com sucesso!");
    } catch (e) {
      print("Erro ao ligar ao MongoDB: $e");
    }
  }

  static Future<bool> registarUtilizador({
    required String nome,
    required String email,
    required String telefone,
    required String password,
  }) async {
    if (kIsWeb) {
      utilizadorLogado = {
        "nome": nome,
        "email": email,
        "telefone": telefone,
        "tipo": "UTILIZADOR"
      };
      return true; 
    }
    if (userCollection == null) return false;
    try {
      String hash = DBCrypt().hashpw(password, DBCrypt().gensalt());
      var utilizador = {
        "_id": ObjectId(),
        "nome": nome,
        "email": email,
        "telefone": telefone,
        "passwordHash": hash,
        "tipo": "UTILIZADOR",
        "createdAt": DateTime.now().toUtc().toIso8601String(),
      };
      await userCollection.insertOne(utilizador);
      utilizadorLogado = utilizador;
      return true;
    } catch (e) {
      print("Erro ao inserir utilizador: $e");
      return false;
    }
  }

  static Future<bool> verificarLogin({
    required String email,
    required String password,
  }) async {
    if (kIsWeb) {
      // Criação forçada dos dados para o cabeçalho funcionar sempre no Chrome
      String nomeSimulado = email.split('@')[0];
      nomeSimulado = nomeSimulado[0].toUpperCase() + nomeSimulado.substring(1);

      utilizadorLogado = {
        "nome": nomeSimulado,
        "email": email,
        "telefone": "911445562",
        "tipo": "UTILIZADOR"
      };
      return true;
    }

    if (userCollection == null) return false;
    try {
      var utilizador = await userCollection.findOne(where.eq('email', email));
      if (utilizador == null) return false;

      String passwordHash = utilizador['passwordHash'];
      bool passwordCorreta = DBCrypt().checkpw(password, passwordHash);
      if (passwordCorreta) {
        utilizadorLogado = utilizador;
      }
      return passwordCorreta;
    } catch (e) {
      return false;
    }
  }

  static void efetuarLogout() {
    utilizadorLogado = null;
  }
}
