import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/personal_information_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/search_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/university_detail_screen.dart';
import 'models/university.dart';
import 'models/user_profile.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UniGuideApp());
}

class UniGuideApp extends StatelessWidget {
  const UniGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniGuide Cambodia',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const UniGuideScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B5E),
          primary: const Color(0xFF0D3B5E),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/saved': (context) => const SavedScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/personal-information': (context) => const PersonalInformationScreen(),
        '/privacy-security': (context) => const PrivacySecurityScreen(),
        '/terms': (context) => const TermsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/university-details') {
          final university = settings.arguments as University;
          return MaterialPageRoute(
            builder: (_) => UniversityDetailScreen(university: university),
          );
        }

        if (settings.name == '/edit-profile') {
          final profile = settings.arguments as UserProfile;
          return MaterialPageRoute(
            builder: (_) => EditProfileScreen(profile: profile),
          );
        }

        return null;
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FA),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const HomeScreen();
        }

        return const OnboardingScreen();
      },
    );
  }
}

class UniGuideScrollBehavior extends MaterialScrollBehavior {
  const UniGuideScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
