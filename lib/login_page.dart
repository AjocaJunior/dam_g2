import 'package:flutter/material.dart';
import 'mongo_service.dart';
import 'recover_email_page.dart'; // Importação necessária para a rota estática
import 'register_page.dart';      // Importação necessária para a rota estática

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _executarLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    bool sucesso = await MongoService.verificarLogin(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() { _isLoading = false; });

    if (sucesso) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao efetuar login.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(child: _DogFootHeader(title: 'Login')),
                const SizedBox(height: 32),
                const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Digite seu email',
                    filled: true,
                    fillColor: Color(0xFFE0E0E0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Insira um email válido' : null,
                ),
                const SizedBox(height: 16),
                const Text('Senha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Digite sua senha',
                    filled: true,
                    fillColor: Color(0xFFE0E0E0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || value.length < 4) ? 'A senha deve ter 4+ caracteres' : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _executarLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E2E2E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                  ),
                ),

                // =========================================================================
                //  OPÇÕES ADICIONADAS: RECUPERAR SENHA E REGISTAR CONTA
                // =========================================================================
                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RecoverEmailPage.routeName);
                  },
                  child: const Text(
                    'Esqueci a senha, recuperar',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RegisterPage.routeName);
                  },
                  child: Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                        children: [
                          TextSpan(text: 'Ainda não tem conta? '),
                          TextSpan(
                            text: 'Registar',
                            style: TextStyle(
                              color: Color(0xFFFF5733), // Cor padrão do teu tema
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DogFootHeader extends StatelessWidget {
  final String title;
  const _DogFootHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.pets, size: 64, color: Color(0xFF2E2E2E)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
