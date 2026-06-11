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
            initialBrand: state.uri.queryParameters['brand'],
          ),
        ),
        GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
        GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
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
          ChangeNotifierProvider(create: (_) => FavoritesProvider()..init()),
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
    if (location.startsWith('/favorites')) return 3;
    if (location.startsWith('/account')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final favs = context.watch<FavoritesProvider>();

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
                case 0: context.go('/'); break;
                case 1: context.go('/catalog'); break;
                case 2: context.go('/chat'); break;
                case 3: context.go('/favorites'); break;
                case 4: context.go('/account'); break;
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
              BottomNavigationBarItem(
                icon: favs.count > 0
                    ? Badge(
                        backgroundColor: AppTheme.orange,
                        label: Text('${favs.count}'),
                        child: const Icon(Icons.favorite_border_rounded),
                      )
                    : const Icon(Icons.favorite_border_rounded),
                activeIcon: const Icon(Icons.favorite_rounded),
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

// ─────────────────────────────────────────────────────────────
// FAVORITES SCREEN
// ─────────────────────────────────────────────────────────────

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPage,
        title: const Text(
          'Favoritos',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (favs.count > 0)
            TextButton(
              onPressed: () async {
                for (final p in favs.items.toList()) {
                  await favs.remove(p.id);
                }
              },
              child: const Text(
                'Limpiar',
                style: TextStyle(color: AppTheme.grey2),
              ),
            ),
        ],
      ),
      body: favs.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 72,
                    color: AppTheme.grey3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes favoritos aún',
                    style: TextStyle(
                      color: AppTheme.grey2,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Guarda productos para verlos aquí',
                    style: TextStyle(
                      color: AppTheme.grey3,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/catalog'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Ver catálogo',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: favs.items.length,
              itemBuilder: (_, i) {
                final p = favs.items[i];
                final hasImage = p.imageUrl != null &&
                    p.imageUrl!.trim().isNotEmpty &&
                    !p.imageUrl!.toLowerCase().endsWith('.svg');

                return GestureDetector(
                  onTap: () => context.push('/product/${p.slug}'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [AppTheme.cardShadow(.04)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Center(
                                child: hasImage
                                    ? Image.network(
                                        p.imageUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.phone_android_rounded,
                                          color: AppTheme.grey3,
                                          size: 58,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.phone_android_rounded,
                                        color: AppTheme.grey3,
                                        size: 58,
                                      ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => favs.toggle(p),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppTheme.orange.withOpacity(.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite_rounded,
                                      color: AppTheme.orange,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.black,
                            fontSize: 12.5,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '\$${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<CartProvider>().add(p);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${p.name} agregado'),
                                    backgroundColor: AppTheme.black,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}