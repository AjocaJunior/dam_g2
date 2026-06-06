import 'package:mongo_dart/mongo_dart.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Deteta se é ambiente Web

class MongoService {
  static const String mongoUrl = "mongodb+srv://1004166_db_user:GxEzMoo9WPNIzCx8@damg2.e8pwzgj.mongodb.net/?appName=DAMg2";
  static var db;
  static var userCollection;

  // Inicializa a ligação à base de dados
  static Future<void> connect() async {
    // Se for Web (Chrome), ignora a ligação via Sockets para não dar erro
    if (kIsWeb) {
      print("Ambiente Web detetado. Conexão MongoDB em modo Simulação (Mock).");
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

  // Lógica para registar o utilizador
  static Future<bool> registarUtilizador({
    required String nome,
    required String email,
    required String telefone,
    required String password,
  }) async {
    // Se estiver no Chrome, simula que guardou com sucesso para o teu fluxo funcionar!
    if (kIsWeb) {
      print("--- MOCK REGISTO (WEB) ---");
      print("Nome: $nome | Email: $email");
      print("A simular encriptação BCrypt...");
      await Future.delayed(const Duration(milliseconds: 800)); // Simula delay de rede
      return true; 
    }

    if (userCollection == null) return false;

    try {
      // Gera o hash seguro da password utilizando BCrypt
      String hash = DBCrypt().hashpw(password, DBCrypt().gensalt());

      // Monta o documento com o padrão exato da tua base de dados
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
      return true;
    } catch (e) {
      print("Erro ao inserir utilizador: $e");
      return false;
    }
  }
}