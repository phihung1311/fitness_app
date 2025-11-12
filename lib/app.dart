import 'package:flutter/material.dart';

import 'presentation/modules/auth/screens/login_screen.dart';
import 'presentation/routes/app_router.dart';

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: LoginScreen.routeName,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
