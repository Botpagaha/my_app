import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.storageService,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedEmail = 'miftah@berdua.internal';
  final _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    await widget.storageService.login(_selectedEmail, _passwordController.text);
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onLoginSuccess();
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Bantuan Akun', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        content: const Text(
          'Aplikasi ini adalah ruang privat berdua khusus Miftah & Cinta. Pendaftaran akun publik dimatikan demi keamanan dan privasi kenangan berdua.\n\nJika lupa kata sandi atau butuh pembaruan akun, silakan hubungi Miftah langsung ❤️.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top romantic badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title & Subtitle
                Text(
                  'Berdua',
                  style: textTheme.displayMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ruang Privat Miftah & Cinta',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),

                // Account Selection Cards
                Text(
                  'PILIH AKUN MASUK',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildAccountCard(
                        name: 'Miftah',
                        email: 'miftah@berdua.internal',
                        initial: 'M',
                        isSelected: _selectedEmail == 'miftah@berdua.internal',
                        avatarColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAccountCard(
                        name: 'Cinta',
                        email: 'cinta@berdua.internal',
                        initial: 'C',
                        isSelected: _selectedEmail == 'cinta@berdua.internal',
                        avatarColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Password Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kata Sandi Privat',
                    style: textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kata sandi...',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.outline,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Remember Me
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (val) => setState(() => _rememberMe = val ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ingat sesi saya di HP ini (30 hari)',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Masuk ke Ruang Kita',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Help Button
                TextButton.icon(
                  onPressed: _showHelpDialog,
                  icon: const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.outline),
                  label: Text(
                    'Lupa kata sandi? Hubungi Miftah',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.outline,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required String name,
    required String email,
    required String initial,
    required bool isSelected,
    required Color avatarColor,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedEmail = email),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    right: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              email.split('@')[0],
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
