import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/data/repositories/user_repository.dart';
import 'package:projeto_flutter/domain/models/user.dart';
import 'package:projeto_flutter/data/services/auth_service.dart';
import 'package:projeto_flutter/ui/view/edit_account_view.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userRepo = context.read<UserRepository>();
    final profile = await userRepo.getUserProfile();
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data não informada';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<AuthService>().user;

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Conta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(firebaseUser.displayName ?? 'Nome não informado'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(firebaseUser.email ?? 'Email não informado'),
            ),
            const ListTile(
              leading: Icon(Icons.lock),
              title: Text('Senha'),
              subtitle: Text('********'),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: Text(_profile?.cpf ?? 'CPF não informado'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_formatDate(_profile?.birthDate)),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditAccountView()),
                );
                _loadUserProfile();
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar informações'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthService>().logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
