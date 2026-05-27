import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';

// ─── CHAT ─────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final _msgs   = <ChatMessage>[];
  bool  _typing = false;
  final _visitorId = 'user_${Random().nextInt(999999)}';

  @override
  void initState() {
    super.initState();
    _msgs.add(ChatMessage(
      sender: 'bot',
      text: '¡Hola! Bienvenido a Safecell 📱\n¿En qué puedo ayudarte hoy?',
      quickReplies: ['Ver catálogo', 'Estado de mi pedido', 'Hablar con asesor'],
    ));
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    setState(() { _msgs.add(ChatMessage(sender: 'user', text: text)); _typing = true; });
    _scrollDown();

    if (text.toLowerCase().contains('asesor') ||
        text.toLowerCase().contains('whatsapp') ||
        text.toLowerCase().contains('humano')) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() {
        _typing = false;
        _msgs.add(ChatMessage(
          sender: 'bot',
          text: 'Te conecto con un asesor por WhatsApp ahora mismo.',
          quickReplies: ['Abrir WhatsApp'],
        ));
      });
      _scrollDown();
      return;
    }

    try {
      final reply = await ApiService.sendChatMessage(text, _visitorId);
      if (mounted) setState(() {
        _typing = false;
        _msgs.add(ChatMessage(sender: 'bot', text: reply));
      });
    } catch (_) {
      if (mounted) setState(() {
        _typing = false;
        _msgs.add(ChatMessage(
          sender: 'bot',
          text: 'No pude conectar. ¿Quieres hablar con un asesor?',
          quickReplies: ['Hablar con asesor'],
        ));
      });
    }
    _scrollDown();
  }

  void _onQuickReply(String r) {
    if (r == 'Abrir WhatsApp' || r == 'Hablar con asesor') {
      launchUrl(Uri.parse(AppTheme.whatsapp), mode: LaunchMode.externalApplication);
      return;
    }
    _send(r);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.orangeLight,
            child: const Text('SC', style: TextStyle(
              color: AppTheme.orange, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Safecell Bot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text('En línea', style: TextStyle(color: AppTheme.success, fontSize: 11)),
            ],
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length + (_typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (_typing && i == _msgs.length) return _typingBubble();
              return _bubble(_msgs[i]);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          color: AppTheme.bgCard,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: _send,
                  style: const TextStyle(color: AppTheme.black),
                  decoration: InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    filled: true,
                    fillColor: AppTheme.bgPage,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 42, height: 42,
                  decoration: const BoxDecoration(color: AppTheme.orange, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bubble(ChatMessage m) {
    final isUser = m.sender == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.orange : AppTheme.bgCard,
              borderRadius: BorderRadius.only(
                topLeft:     const Radius.circular(16),
                topRight:    const Radius.circular(16),
                bottomLeft:  Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: isUser ? null : Border.all(color: AppTheme.border),
            ),
            child: Text(m.text, style: TextStyle(
              color: isUser ? Colors.white : AppTheme.black,
              height: 1.4, fontSize: 13)),
          ),
          if (m.quickReplies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: m.quickReplies.map((r) => GestureDetector(
                onTap: () => _onQuickReply(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.orange),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(r, style: const TextStyle(
                    color: AppTheme.orange, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _typingBubble() => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _Dot(delay: Duration(milliseconds: i * 180)),
        )),
      ),
    ),
  );
}

class _Dot extends StatefulWidget {
  final Duration delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _a = Tween(begin: 0.3, end: 1.0).animate(_c);
    Future.delayed(widget.delay, () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(
      width: 7, height: 7,
      decoration: const BoxDecoration(color: AppTheme.orange, shape: BoxShape.circle),
    ),
  );
}

// ─── ACCOUNT ──────────────────────────────────────────────────────
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: auth.isAuth ? _loggedIn(auth) : _authForms(),
    );
  }

  Widget _loggedIn(AuthProvider auth) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.bgCard,
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.orangeLight,
              child: Text(
                (auth.name ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: AppTheme.orange, fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.name ?? 'Usuario', style: const TextStyle(
                    color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(auth.email ?? '', style: const TextStyle(color: AppTheme.grey2, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.orangeLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Cliente ✓', style: TextStyle(
                color: AppTheme.orange, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.grey3, size: 20),
              onPressed: auth.logout,
            ),
          ],
        ),
      ),
      TabBar(
        controller: _tabs,
        indicatorColor: AppTheme.orange,
        labelColor: AppTheme.orange,
        unselectedLabelColor: AppTheme.grey3,
        indicatorWeight: 2,
        tabs: const [Tab(text: 'Mis pedidos'), Tab(text: 'Perfil')],
      ),
      Expanded(
        child: TabBarView(
          controller: _tabs,
          children: [
            _OrdersTab(token: auth.token!),
            _ProfileTab(auth: auth),
          ],
        ),
      ),
    ],
  );

  Widget _authForms() => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        const TabBar(
          indicatorColor: AppTheme.orange,
          labelColor: AppTheme.orange,
          unselectedLabelColor: AppTheme.grey3,
          tabs: [Tab(text: 'Iniciar sesión'), Tab(text: 'Registrarse')],
        ),
        Expanded(child: TabBarView(children: [_LoginForm(), _RegisterForm()])),
      ],
    ),
  );
}

class _OrdersTab extends StatefulWidget {
  final String token;
  const _OrdersTab({required this.token});
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final orders = await ApiService.getMyOrders(widget.token);
    if (mounted) setState(() { _orders = orders; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppTheme.orange));
    if (_orders.isEmpty) return const Center(child: Text('No tienes pedidos aún',
      style: TextStyle(color: AppTheme.grey2)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (_, i) {
        final o = _orders[i];
        final statusColor = switch (o.status.toLowerCase()) {
          'completado' || 'entregado' => AppTheme.success,
          'cancelado'                 => AppTheme.error,
          'enviado'                   => AppTheme.orange,
          _                           => const Color(0xFFF59E0B),
        };
        final statusBg = statusColor.withOpacity(0.1);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido #${o.id}', style: const TextStyle(
                      color: AppTheme.black, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(o.createdAt.length > 10 ? o.createdAt.substring(0, 10) : o.createdAt,
                      style: const TextStyle(color: AppTheme.grey3, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(o.status, style: TextStyle(
                      color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 4),
                  Text('\$${o.total.toStringAsFixed(2)}', style: const TextStyle(
                    color: AppTheme.black, fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final AuthProvider auth;
  const _ProfileTab({required this.auth});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _tile('Nombre', auth.name ?? '-', Icons.person_outline),
        const SizedBox(height: 8),
        _tile('Email', auth.email ?? '-', Icons.email_outlined),
      ],
    ),
  );

  Widget _tile(String label, String val, IconData icon) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.orange, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.grey3, fontSize: 11)),
            Text(val, style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    ),
  );
}

class _LoginForm extends StatefulWidget {
  @override
  State<_LoginForm> createState() => _LoginFormState();
}
class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppTheme.black),
            decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _passCtrl, obscureText: _obscure,
            style: const TextStyle(color: AppTheme.black),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.grey3),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: auth.loading ? null : () async {
                final ok = await auth.login(_emailCtrl.text, _passCtrl.text);
                if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Credenciales incorrectas'),
                    backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating));
              },
              child: auth.loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Iniciar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}
class _RegisterFormState extends State<_RegisterForm> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(controller: _nameCtrl, style: const TextStyle(color: AppTheme.black),
            decoration: const InputDecoration(labelText: 'Nombre completo')),
          const SizedBox(height: 10),
          TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppTheme.black),
            decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 10),
          TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppTheme.black),
            decoration: const InputDecoration(labelText: 'Teléfono')),
          const SizedBox(height: 10),
          TextField(controller: _passCtrl, obscureText: _obscure,
            style: const TextStyle(color: AppTheme.black),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.grey3),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: auth.loading ? null : () async {
                final ok = await auth.register(
                  _nameCtrl.text, _emailCtrl.text, _passCtrl.text, _phoneCtrl.text);
                if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al registrarse.'),
                    backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating));
              },
              child: auth.loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Crear cuenta'),
            ),
          ),
        ],
      ),
    );
  }
}
