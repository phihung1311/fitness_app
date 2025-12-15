import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../user/screens/home_screen.dart';
import '../../user/screens/profile/onboarding_profile_screen.dart';
import '../../../../domain/usecases/profile/get_profile_metrics.dart';
import '../bloc/form_status.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _checkingOnboarding = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {

    context.read<LoginBloc>().add(
          LoginSubmitted(
            email: 'hung@test.com',
            password: '123456',
          ),
        );

    // final valid = _formKey.currentState?.validate() ?? false;
    // if (!valid) return;
    // context.read<LoginBloc>().add(
    //       LoginSubmitted(
    //         email: _emailController.text,
    //         password: _passwordController.text,
    //       ),
    //     );
  }

  Future<void> _navigateAfterLogin(BuildContext context) async {
    setState(() => _checkingOnboarding = true);
    try {
      final metrics = await injector<GetProfileMetrics>()();
      final needsOnboarding = _needsOnboarding(metrics);

      if (!mounted) return;
      if (needsOnboarding) {
        Navigator.of(context).pushReplacementNamed(OnboardingProfileScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(OnboardingProfileScreen.routeName);
      }
    } finally {
      if (mounted) {
        setState(() => _checkingOnboarding = false);
      }
    }
  }

  bool _needsOnboarding(metrics) {
    final hasBasic = (metrics.height ?? 0) > 0 && (metrics.weight ?? 0) > 0;
    final hasGoal = (metrics.weightGoal ?? 0) > 0 && (metrics.goalType ?? '').isNotEmpty;
    return !(hasBasic && hasGoal);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(injector()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Đăng nhập')),
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == FormStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            } else if (state.status == FormStatus.success) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar(); // optional: tránh spam
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đăng nhập thành công')),
              );

              _navigateAfterLogin(context);
            }
          },
          builder: (context, state) {
            final isLoading = state.status == FormStatus.loading || _checkingOnboarding;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Mật khẩu tối thiểu 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Đăng nhập'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(RegisterScreen.routeName);
                      },
                      child: const Text('Chưa có tài khoản? Đăng ký'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

