import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'providers/providers.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_detail_cart_checkout.dart';
import 'screens/chat_account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const SafecellApp());
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    ShellRoute(
      builder: (context, state, child) => _Shell(child: child, location: state.fullPath ?? '/'),
      routes: [
        GoRoute(path: '/',        builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/catalog',
          builder: (_, state) => CatalogScreen(
            initialCategory: state.uri.queryParameters['cat']),
        ),
        GoRoute(path: '/chat',    builder: (_, __) => const ChatScreen()),
        GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
      ],
    ),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) => ProductDetailScreen(
        productSlug: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(path: '/cart',     builder: (_, __) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
  ],
);

class SafecellApp extends StatelessWidget {
  const SafecellApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
    ],
    child: MaterialApp.router(
      title: 'Safecell Venezuela',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    ),
  );
}

class _Shell extends StatelessWidget {
  final Widget child;
  final String location;
  const _Shell({required this.child, required this.location});

  int get _idx {
    if (location.startsWith('/catalog')) return 1;
    if (location.startsWith('/chat'))    return 2;
    if (location.startsWith('/account')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          backgroundColor: AppTheme.bgCard,
          selectedItemColor: AppTheme.orange,
          unselectedItemColor: AppTheme.grey3,
          elevation: 0,
          onTap: (i) {
            switch (i) {
              case 0: context.go('/');
              case 1: context.go('/catalog');
              case 2: context.go('/chat');
              case 3: context.go('/account');
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Catálogo',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: cart.count > 0
                ? Badge(label: Text('${cart.count}'), child: const Icon(Icons.person_outline))
                : const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: 'Cuenta',
            ),
          ],
        ),
      ),
    );
  }
}