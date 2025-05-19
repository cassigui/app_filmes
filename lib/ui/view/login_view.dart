import 'package:flutter/material.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLogin = true;
  late String title;
  late String actionButton;
  late String toggleButton;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool action) {
    setState(() {
      isLogin = action;
      if (isLogin) {
        title = 'Bem vindo';
        actionButton = 'Entrar';
        toggleButton = 'Criar conta';
      } else {
        title = 'Criar conta';
        actionButton = 'Cadastrar';
        toggleButton = 'Já tem conta? Entrar';
      }
    });
  }

  login() async {
    try {
      await context
          .read<AuthService>()
          .login(_emailController.text, _passwordController.text);
    } on AuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  register() async {
    try {
      await context
          .read<AuthService>()
          .register(_emailController.text, _passwordController.text);
    } on AuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      } else if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () {
                      if ((formKey.currentState as FormState).validate()) {
                        Provider.of<AuthService>(context, listen: false);
                        if (isLogin) {
                          login();
                        } else {
                          register();
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            actionButton,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setFormAction(!isLogin);
                  },
                  child: Text(
                    toggleButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
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
