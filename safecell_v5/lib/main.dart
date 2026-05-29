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
    systemNavigationBarColor: AppTheme.bgCard,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const SafecellApp());
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    ShellRoute(
      builder: (context, state, child) => _Shell(
        child: child,
        location: state.uri.path,
      ),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/catalog',
          builder: (_, state) => CatalogScreen(
            initialCategory: state.uri.queryParameters['cat'],
          ),
        ),
        GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
        GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
      ],
    ),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) => ProductDetailScreen(
        productSlug: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
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
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/account')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.border),
            boxShadow: [AppTheme.softShadow(.08)],
          ),
          child: BottomNavigationBar(
            currentIndex: _idx,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.orange,
            unselectedItemColor: AppTheme.grey3,
            elevation: 0,
            onTap: (i) {
              switch (i) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/catalog');
                  break;
                case 2:
                  context.go('/chat');
                  break;
                case 3:
                  context.go('/catalog');
                  break;
                case 4:
                  context.go('/account');
                  break;
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Inicio',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Catálogo',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: cart.count > 0
                    ? Badge(
                        backgroundColor: AppTheme.orange,
                        label: Text('${cart.count}'),
                        child: const Icon(Icons.person_outline_rounded),
                      )
                    : const Icon(Icons.person_outline_rounded),
                activeIcon: const Icon(Icons.person_rounded),
                label: 'Cuenta',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
