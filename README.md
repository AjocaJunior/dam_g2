# DAMg2

DAM Grupo 2

## Execucao com Flutter Web e MongoDB

Executar num terminal a API em Dart

```powershell
dart run bin/api_server.dart
```

Noutro terminal Flutter:

```powershell
flutter run -d chrome
```

Para testar num telemovel Android na mesma rede, gerar o APK indicando o IP
local da maquina onde a API esta a correr:

```powershell
flutter build apk --debug --dart-define=API_URL=http://10.42.0.112:8080
```

Quando a API estiver ativa, o console do Flutter deve mostrar:

```text
API MongoDB ligada em http://127.0.0.1:8080.
```

```API disponivel em
https://dam-g2.onrender.com
```

As colecoes usadas sao `utilizadores`, `animais`, `alertas_sos` e
`notificacoes`.

