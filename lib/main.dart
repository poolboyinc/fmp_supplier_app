import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:fmp_supplier_app/core/config/mapbox_config.dart';
import 'package:fmp_supplier_app/core/config/theme.dart';
import 'package:fmp_supplier_app/core/services/service_locator.dart' as di;
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fmp_supplier_app/features/auth/presentation/pages/login_page.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_bloc.dart';
import 'package:fmp_supplier_app/features/parties/presentation/pages/create_party_page.dart';
import 'package:fmp_supplier_app/features/parties/presentation/pages/parties_page.dart';
import 'package:fmp_supplier_app/features/parties/presentation/pages/party_details_page.dart';
import 'package:fmp_supplier_app/features/splash/splash_page.dart';

void main() async {
  runApp(const LoadingApp());

  try {
    // Initialize the app
    await initializeApp();
    // If initialization is successful, run the main app
    runApp(const MyApp());
  } catch (error) {
    // If initialization fails, show an error screen
    print('INITIALIZATION ERROR: $error');
    runApp(ErrorApp(error: error.toString()));
  }
}

Future<void> initializeApp() async {
  try {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    print("Loading environment variables...");
    await dotenv.load(fileName: '.env');

    print("Setting Mapbox token...");
    final token = MapboxConfig.accessToken;
    print("Token loaded, length: ${token.length}");
    MapboxOptions.setAccessToken(token);
    print("Mapbox token set successfully");

    print("Initializing Firebase...");
    await Firebase.initializeApp();

    print("Initializing dependencies...");
    await di.init();

    print("App initialization completed successfully!");
  } catch (e) {
    print("CRITICAL INITIALIZATION ERROR: $e");
    throw Exception("Failed to initialize: $e");
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: AppTheme.primaryPurple),
              SizedBox(height: 24),
              Text(
                'Starting app...',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, this.error = "Unknown error"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<PartyBloc>(create: (_) => di.sl<PartyBloc>()),
        BlocProvider<BookingBloc>(create: (_) => di.sl<BookingBloc>()),
      ],
      child: MaterialApp(
        title: 'FMP Supplier',
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthInitial || state is AuthLoading) {
              return const SplashPage();
            } else if (state is Authenticated) {
              return const SupplierHomePage();
            } else {
              return const LoginPage();
            }
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/parties': (context) => const PartiesPage(),
          '/bookings': (context) => const BookingsPage(),
          '/create-party': (context) => const CreatePartyPage(),
          '/edit-party':
              (context) => CreatePartyPage(
                partyId: ModalRoute.of(context)?.settings.arguments as String?,
              ),
          '/party-details':
              (context) => PartyDetailsPage(
                partyId: ModalRoute.of(context)?.settings.arguments as String,
              ),
        },
      ),
    );
  }
}

class SupplierHomePage extends StatefulWidget {
  const SupplierHomePage({Key? key}) : super(key: key);

  @override
  State<SupplierHomePage> createState() => _SupplierHomePageState();
}

class _SupplierHomePageState extends State<SupplierHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const PartiesPage(), const BookingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppTheme.primaryDark,
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: AppTheme.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Parties'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }
}
