import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/user.dart';
import 'package:hex_the_add_hub/providers/auth_provider.dart';
import 'package:hex_the_add_hub/services/solana_service.dart';
import 'package:hex_the_add_hub/widgets/custom_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isRegistering = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        if (_isRegistering) {
          await ref.read(authProvider.notifier).register(
            _emailController.text,
            _passwordController.text,
            _fullNameController.text,
          );
        } else {
          await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(authProvider.notifier).loginWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithWallet() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final solanaService = SolanaService();
      final walletResult = await solanaService.connectWallet();
      
      if (walletResult != null) {
        // Create a message to sign
        final message = 'Sign this message to log in to HEX THE ADD HUB: ${DateTime.now().millisecondsSinceEpoch}';
        
        // Request signature
        final signatureResult = await solanaService.signMessage(walletResult.publicKey, message);
        
        if (signatureResult != null) {
          // Create login request
          final request = Web3LoginRequest(
            walletAddress: walletResult.publicKey,
            message: message,
            signature: signatureResult,
          );
          
          // Login with wallet
          await ref.read(authProvider.notifier).loginWithWallet(request);
        } else {
          throw Exception('Failed to sign message');
        }
      } else {
        throw Exception('Failed to connect wallet');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and App Name
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.hexagon_outlined,
                          size: 80,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.appName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                  
                  // Login/Register Form
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Form title
                          Text(
                            _isRegistering ? AppStrings.register : AppStrings.login,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Full name field (only for registration)
                          if (_isRegistering) ...[
                            TextFormField(
                              controller: _fullNameController,
                              decoration: const InputDecoration(
                                labelText: AppStrings.fullName,
                                prefixIcon: Icon(Icons.person),
                              ),
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.fullNameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.email,
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.emailRequired;
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return AppStrings.emailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.password,
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.passwordRequired;
                              }
                              if (_isRegistering && value.length < 6) {
                                return AppStrings.passwordTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Login/Register button
                          CustomButton(
                            onPressed: _isLoading ? null : _submit,
                            text: _isRegistering ? AppStrings.signUp : AppStrings.signIn,
                            isLoading: _isLoading,
                          ),
                          
                          // Toggle between login and register
                          TextButton(
                            onPressed: _isLoading ? null : _toggleMode,
                            child: Text(
                              _isRegistering 
                                ? AppStrings.alreadyHaveAccount
                                : AppStrings.dontHaveAccount,
                            ),
                          ),
                          
                          // Or divider
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white54)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    AppStrings.orContinueWith,
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.white54)),
                              ],
                            ),
                          ),
                          
                          // Social and wallet login options
                          Row(
                            children: [
                              // Google login
                              Expanded(
                                child: CustomButton(
                                  onPressed: _isLoading ? null : _loginWithGoogle,
                                  text: AppStrings.loginWithGoogle,
                                  icon: const Icon(Icons.g_mobiledata, size: 24),
                                  color: Colors.white,
                                  textColor: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Wallet login
                              Expanded(
                                child: CustomButton(
                                  onPressed: _isLoading ? null : _loginWithWallet,
                                  text: AppStrings.loginWithWallet,
                                  icon: const Icon(Icons.account_balance_wallet, size: 20),
                                  color: const Color(0xFF9945FF), // Solana purple
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
