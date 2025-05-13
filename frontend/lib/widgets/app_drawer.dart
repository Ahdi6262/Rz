import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Drawer(
      child: Container(
        color: darkSurfaceColor,
        child: authState.when(
          data: (user) {
            if (user == null) {
              return const Center(
                child: Text('Not logged in'),
              );
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: primaryColor,
                  ),
                  accountName: Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  accountEmail: Text(user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 24.0,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: AppStrings.home,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigate to home if not already there
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.work,
                  title: AppStrings.portfolio,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigate to portfolio
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.school,
                  title: AppStrings.courses,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigate to courses
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.article,
                  title: AppStrings.blog,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigate to blog
                  },
                ),
                if (user.isAdmin)
                  _buildDrawerItem(
                    context,
                    icon: Icons.admin_panel_settings,
                    title: AppStrings.admin,
                    onTap: () {
                      Navigator.of(context).pop();
                      // Navigate to admin
                    },
                  ),
                const Divider(color: darkDividerColor),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: AppStrings.profile,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigate to profile
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: AppStrings.settings,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Navigate to settings
                  },
                ),
                const Divider(color: darkDividerColor),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: AppStrings.logout,
                  onTap: () async {
                    Navigator.of(context).pop();
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(AppStrings.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(AppStrings.logout),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      await ref.read(authProvider.notifier).logout();
                    }
                  },
                ),
                if (user.web3Wallet != null) ...[
                  const Divider(color: darkDividerColor),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connected Wallet',
                          style: TextStyle(
                            fontSize: 12,
                            color: darkSecondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user.web3Wallet!.substring(0, 6)}...${user.web3Wallet!.substring(user.web3Wallet!.length - 4)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: darkTextColor,
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}
