import 'package:flutter/material.dart';
import 'package:flutter_app/api/private/cart_api_service.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/cart_provider.dart';
import 'package:flutter_app/providers/listing_provider.dart';
import 'package:flutter_app/screens/home/home_page.dart';
import 'package:flutter_app/screens/payment/payment_cancel_page.dart';
import 'package:flutter_app/screens/payment/payment_polling_page.dart';
import 'package:flutter_app/screens/payment/payment_success_page.dart';
import 'package:flutter_app/screens/profile/profile_page.dart';
import 'package:flutter_app/screens/seller/seller_dashboard_page.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/listing_service.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
// import 'package:uni_links/uni_links.dart';
import 'screens/auth/login_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => TokenService()),
        Provider(
          create: (context) => AuthService(context.read<TokenService>()),
        ),
        Provider(
          create: (context) => CartApiService(context.read<TokenService>()),
        ),
        Provider(
          create: (context) => ListingService(context.read<TokenService>()),
        ),
        Provider(
          create: (context) => CartApiService(context.read<TokenService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<TokenService>(),
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ListingProvider()),

        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (context) => CartProvider(
            context.read<AuthProvider>(),
            context.read<CartApiService>(),
          ),
          update: (context, auth, previousCart) {
            if (previousCart == null)
              return CartProvider(auth, context.read<CartApiService>());

            previousCart.update(auth);

            if (auth.isLoggedIn &&
                previousCart.cart == null &&
                !previousCart.isLoading) {
              previousCart.fetchCart();
            } else if (!auth.isLoggedIn && previousCart.cart != null) {
              previousCart.clearCart();
            }

            return previousCart;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize deep link listeners when the app starts
    // _initUniLinks();
  }

  void _handleDeepLink(String deepLink) {
    final uri = Uri.parse(deepLink);
    final nav = navigatorKey.currentState;

    if (uri.scheme == 'phsakhmer') {
      if (uri.pathSegments.contains('checkout') && nav != null) {
        final sessionId = uri.queryParameters['session_id'];

        if (sessionId != null) {
          nav.pushNamedAndRemoveUntil(
            '/payment_polling',
            (route) => false,
            arguments: sessionId,
          );
        }
      }
    }
  }

  // Set up uni_links listeners
  // Future<void> _initUniLinks() async {
  //   try {
  //     final initialLink = await getInitialLink();
  //     if (initialLink != null) {
  //       _handleDeepLink(initialLink);
  //     }
  //   } catch (e) {
  //     print("Failed to get initial link: $e");
  //   }

  //   getUriLinksStream().listen(
  //     (Uri? uri) {
  //       if (uri != null) {
  //         _handleDeepLink(uri.toString());
  //       }
  //     },
  //     onError: (err) {
  //       print("Deep link stream error: $err");
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phsa Khmer',
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      home: HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/seller_dashboard': (context) => const SellerDashboardPage(),

        '/payment_cancel': (context) => const PaymentCancelPage(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);
        if (settings.name!.startsWith('/checkout/status')) {
          final sessionId = uri.queryParameters['session_id'];

          if (sessionId != null) {
            return MaterialPageRoute(
              builder: (context) => PaymentPollingPage(sessionId: sessionId),
            );
          }
        }
        if (settings.name == '/payment_polling') {
          final sessionId = settings.arguments as String?;
          if (sessionId != null) {
            return MaterialPageRoute(
              builder: (context) => PaymentPollingPage(sessionId: sessionId),
            );
          }
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenService().isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If logged in, go to Home Page
        if (snapshot.data == true) {
          // You might want to navigate to ProfilePage for testing token use
          return const ProfilePage(); // Use ProfilePage or HomePage
        } else {
          // If not logged in, go to Login Page
          return const LoginPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
