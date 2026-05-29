import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _visitorId = 'user_${Random().nextInt(999999)}';
  final List<_UiMessage> _messages = const [
    _UiMessage(fromUser: false, text: '¡Hola! Soy el soporte SafeCell 👋\n¿Buscas pantalla, batería, flex o quieres revisar un pedido?'),
  ].toList();
  bool _typing = false;

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _openWhatsApp() async {
    await launchUrl(Uri.parse(AppTheme.whatsapp), mode: LaunchMode.externalApplication);
  }

  Future<void> _send(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;
    _ctrl.clear();
    setState(() { _messages.add(_UiMessage(fromUser: true, text: value)); _typing = true; });
    _scrollDown();
    try {
      if (value.toLowerCase().contains('whatsapp') || value.toLowerCase().contains('asesor')) {
        setState(() { _typing = false; _messages.add(const _UiMessage(fromUser: false, text: 'Perfecto, te conecto con un asesor por WhatsApp.')); });
        await _openWhatsApp();
      } else {
        final reply = await ApiService.sendChatMessage(value, _visitorId);
        if (mounted) setState(() { _typing = false; _messages.add(_UiMessage(fromUser: false, text: reply)); });
      }
    } catch (_) {
      if (mounted) setState(() { _typing = false; _messages.add(const _UiMessage(fromUser: false, text: 'No pude conectar con el servidor. También puedes escribirnos por WhatsApp.')); });
    }
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgPage,
    appBar: AppBar(
      toolbarHeight: 68,
      title: const Text('Chat'),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        IconButton(onPressed: _openWhatsApp, icon: const Icon(Icons.more_vert_rounded)),
        const SizedBox(width: 8),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              _WhatsAppHero(onTap: _openWhatsApp),
              const SizedBox(height: 18),
              const _ChatTabs(),
              const SizedBox(height: 12),
              ..._messages.map((m) => _MessageBubble(message: m)),
              if (_typing) const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text('SafeCell está escribiendo...', style: TextStyle(color: AppTheme.grey2, fontSize: 12)),
              ),
              const SizedBox(height: 12),
              _QuickHelp(onTap: _openWhatsApp),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: const BoxDecoration(color: AppTheme.bgCard, border: Border(top: BorderSide(color: AppTheme.border))),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(child: TextField(
                controller: _ctrl,
                onSubmitted: _send,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  filled: true,
                  fillColor: AppTheme.bgPage,
                  prefixIcon: const Icon(Icons.attach_file_rounded, color: AppTheme.grey3, size: 20),
                  suffixIcon: const Icon(Icons.emoji_emotions_outlined, color: AppTheme.grey3, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
                ),
              )),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(width: 46, height: 46,
                  decoration: const BoxDecoration(color: AppTheme.orange, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
              ),
            ]),
          ),
        ),
      ],
    ),
  );
}

class _UiMessage {
  final bool fromUser;
  final String text;
  const _UiMessage({required this.fromUser, required this.text});
}

class _WhatsAppHero extends StatelessWidget {
  final VoidCallback onTap;
  const _WhatsAppHero({required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFFFEFE6), Color(0xFFFFF8F3)]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFFFD7C4)),
    ),
    child: Row(children: [
      Container(width: 58, height: 58, decoration: const BoxDecoration(color: AppTheme.orange, shape: BoxShape.circle),
        child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 30)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Escríbenos por WhatsApp', style: TextStyle(color: AppTheme.black, fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        const Text('Te respondemos rápido', style: TextStyle(color: AppTheme.grey2, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        GestureDetector(onTap: onTap, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(color: AppTheme.orange, borderRadius: BorderRadius.circular(999)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Abrir WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
            SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
          ]),
        )),
      ])),
      const Icon(Icons.chevron_right_rounded, color: AppTheme.grey1),
    ]),
  );
}

class _ChatTabs extends StatelessWidget {
  const _ChatTabs();
  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
    child: const Row(children: [
      Expanded(child: Center(child: Text('Conversaciones', style: TextStyle(color: AppTheme.orange, fontWeight: FontWeight.w900)))),
      Expanded(child: Center(child: Text('FAQs', style: TextStyle(color: AppTheme.grey2, fontWeight: FontWeight.w800)))),
    ]),
  );
}

class _MessageBubble extends StatelessWidget {
  final _UiMessage message;
  const _MessageBubble({required this.message});
  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .74),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.orange : AppTheme.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 5), bottomRight: Radius.circular(isUser ? 5 : 18)),
          border: isUser ? null : Border.all(color: AppTheme.border),
        ),
        child: Text(message.text, style: TextStyle(color: isUser ? Colors.white : AppTheme.black, fontSize: 13, height: 1.35, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _QuickHelp extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickHelp({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border)),
      child: const Row(children: [
        Icon(Icons.help_outline_rounded, color: AppTheme.grey2), SizedBox(width: 12),
        Expanded(child: Text('¿No encuentras tu pedido? Escríbenos y te ayudamos', style: TextStyle(fontWeight: FontWeight.w800))),
        Icon(Icons.chevron_right_rounded, color: AppTheme.grey3),
      ]),
    ),
  );
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        toolbarHeight: 68,
        title: const Text('Mi cuenta'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
          const SizedBox(width: 8),
        ],
      ),
      body: auth.isAuth ? _loggedIn(auth) : _authForms(),
    );
  }

  Widget _loggedIn(AuthProvider auth) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
    children: [
      _AccountHero(auth: auth), const SizedBox(height: 18),
      _LastOrderCard(token: auth.token), const SizedBox(height: 18),
      const Text('Mi cuenta', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10), _AccountMenu(onLogout: auth.logout),
    ],
  );

  Widget _authForms() => DefaultTabController(
    length: 2,
    child: Column(children: [
      const TabBar(indicatorColor: AppTheme.orange, labelColor: AppTheme.orange, unselectedLabelColor: AppTheme.grey3,
        tabs: [Tab(text: 'Iniciar sesión'), Tab(text: 'Registrarse')]),
      Expanded(child: TabBarView(children: [_LoginForm(), _RegisterForm()])),
    ]),
  );
}

class _AccountHero extends StatelessWidget {
  final AuthProvider auth;
  const _AccountHero({required this.auth});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(26), boxShadow: [AppTheme.softShadow(.13)]),
    child: Column(children: [
      Row(children: [
        Container(width: 76, height: 76, decoration: BoxDecoration(color: AppTheme.black, shape: BoxShape.circle, border: Border.all(color: AppTheme.orange, width: 1.4)),
          child: Center(child: Text((auth.name ?? 'SC').isNotEmpty ? (auth.name ?? 'SC')[0].toUpperCase() : 'SC',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(auth.name ?? 'Cliente SafeCell', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4), Text(auth.email ?? '', style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 12)),
          const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.orange.withOpacity(.16), borderRadius: BorderRadius.circular(999)),
            child: const Text('Cliente verificado', style: TextStyle(color: AppTheme.orange, fontSize: 11, fontWeight: FontWeight.w900))),
        ])),
      ]),
      const SizedBox(height: 18),
      Row(children: const [Expanded(child: _Stat(label: 'Pedidos', value: '12')), Expanded(child: _Stat(label: 'Favoritos', value: '5')), Expanded(child: _Stat(label: 'Direcciones', value: '3'))]),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final String label; final String value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3), Text(label, style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 11, fontWeight: FontWeight.w600)),
  ]);
}

class _LastOrderCard extends StatefulWidget {
  final String? token;
  const _LastOrderCard({required this.token});
  @override
  State<_LastOrderCard> createState() => _LastOrderCardState();
}
class _LastOrderCardState extends State<_LastOrderCard> {
  Order? _last; bool _loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    if (widget.token == null) { setState(() => _loading = false); return; }
    try { final orders = await ApiService.getMyOrders(widget.token!); if (mounted) setState(() { _last = orders.isNotEmpty ? orders.first : null; _loading = false; }); }
    catch (_) { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppTheme.orange));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppTheme.border), boxShadow: [AppTheme.cardShadow(.035)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Expanded(child: Text('Mi último pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))), Text('Ver todos', style: TextStyle(color: AppTheme.orange, fontWeight: FontWeight.w900, fontSize: 12))]),
        const SizedBox(height: 14),
        if (_last == null) const Text('Todavía no tienes pedidos registrados.', style: TextStyle(color: AppTheme.grey2))
        else Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(color: AppTheme.bgPage, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.orange)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pedido #${_last!.id}', style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(_last!.status, style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w800, fontSize: 12))])),
          Text('\$${_last!.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        ]),
      ]),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  final VoidCallback onLogout;
  const _AccountMenu({required this.onLogout});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppTheme.border)),
    child: Column(children: [
      _menuTile(Icons.shopping_bag_outlined, 'Mis pedidos'), _menuTile(Icons.favorite_border_rounded, 'Mis favoritos'),
      _menuTile(Icons.location_on_outlined, 'Direcciones'), _menuTile(Icons.credit_card_rounded, 'Métodos de pago'),
      _menuTile(Icons.support_agent_rounded, 'Soporte y ayuda'), _menuTile(Icons.logout_rounded, 'Cerrar sesión', color: AppTheme.error, onTap: onLogout),
    ]),
  );
  Widget _menuTile(IconData icon, String title, {Color color = AppTheme.black, VoidCallback? onTap}) => ListTile(
    onTap: onTap, leading: Icon(icon, color: color, size: 21),
    title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.grey3));
}

class _LoginForm extends StatefulWidget { @override State<_LoginForm> createState() => _LoginFormState(); }
class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl = TextEditingController(); final _passCtrl = TextEditingController(); bool _obscure = true;
  @override void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const SizedBox(height: 20), TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
      const SizedBox(height: 12), TextField(controller: _passCtrl, obscureText: _obscure, decoration: InputDecoration(labelText: 'Contraseña', suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.grey3), onPressed: () => setState(() => _obscure = !_obscure)))),
      const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: auth.loading ? null : () async { final ok = await auth.login(_emailCtrl.text, _passCtrl.text); if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciales incorrectas'), backgroundColor: AppTheme.error)); }, child: auth.loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Iniciar sesión'))),
    ]));
  }
}
class _RegisterForm extends StatefulWidget { @override State<_RegisterForm> createState() => _RegisterFormState(); }
class _RegisterFormState extends State<_RegisterForm> {
  final _nameCtrl = TextEditingController(); final _emailCtrl = TextEditingController(); final _passCtrl = TextEditingController(); final _phoneCtrl = TextEditingController(); bool _obscure = true;
  @override void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const SizedBox(height: 20), TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
      const SizedBox(height: 10), TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
      const SizedBox(height: 10), TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono')),
      const SizedBox(height: 10), TextField(controller: _passCtrl, obscureText: _obscure, decoration: InputDecoration(labelText: 'Contraseña', suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.grey3), onPressed: () => setState(() => _obscure = !_obscure)))),
      const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: auth.loading ? null : () async { final ok = await auth.register(_nameCtrl.text, _emailCtrl.text, _passCtrl.text, _phoneCtrl.text); if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al registrarse.'), backgroundColor: AppTheme.error)); }, child: auth.loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Crear cuenta'))),
    ]));
  }
}
