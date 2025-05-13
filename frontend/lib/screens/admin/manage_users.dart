import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/user.dart';
import 'package:hex_the_add_hub/services/api_service.dart';

final usersProvider = FutureProvider<List<User>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final users = await apiService.getAllUsers();
  return users;
});

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: darkSurfaceColor,
              suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Users list
          Expanded(
            child: usersState.when(
              data: (users) {
                // Filter users based on search query
                final filteredUsers = _searchQuery.isEmpty
                  ? users
                  : users.where((user) =>
                      user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (user.web3Wallet != null && user.web3Wallet!.toLowerCase().contains(_searchQuery.toLowerCase()))
                    ).toList();
                
                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }
                
                return FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor,
                            child: Text(
                              user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(user.fullName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email),
                              if (user.web3Wallet != null)
                                Text(
                                  'Wallet: ${user.web3Wallet!.substring(0, 6)}...${user.web3Wallet!.substring(user.web3Wallet!.length - 4)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user.isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditUserDialog(user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: errorColor),
                                onPressed: () => _showDeleteUserDialog(user),
                              ),
                            ],
                          ),
                          isThreeLine: user.web3Wallet != null,
                          onTap: () => _showUserDetails(user),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: errorColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => ref.refresh(usersProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Full Name'),
              subtitle: Text(user.fullName),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(user.email),
              contentPadding: EdgeInsets.zero,
            ),
            if (user.web3Wallet != null)
              ListTile(
                title: const Text('Wallet Address'),
                subtitle: Text(user.web3Wallet!),
                contentPadding: EdgeInsets.zero,
              ),
            ListTile(
              title: const Text('Role'),
              subtitle: Text(user.isAdmin ? 'Admin' : 'User'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Created At'),
              subtitle: Text(user.createdAt.toString()),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Updated At'),
              subtitle: Text(user.updatedAt.toString()),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditUserDialog(user);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
  
  void _showEditUserDialog(User user) {
    final _nameController = TextEditingController(text: user.fullName);
    final _emailController = TextEditingController(text: user.email);
    final _walletController = TextEditingController(text: user.web3Wallet ?? '');
    bool _isAdmin = user.isAdmin;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _walletController,
                decoration: const InputDecoration(
                  labelText: 'Wallet Address (optional)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isAdmin,
                    onChanged: (value) {
                      setState(() {
                        _isAdmin = value ?? false;
                      });
                    },
                  ),
                  const Text('Admin'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedUser = await ref.read(apiServiceProvider).updateUser(
                    user.id,
                    {
                      'full_name': _nameController.text,
                      'email': _emailController.text,
                      'web3_wallet': _walletController.text.isEmpty ? null : _walletController.text,
                      'is_admin': _isAdmin,
                    },
                  );
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ref.refresh(usersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User updated successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(apiServiceProvider).deleteUser(user.id);
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ref.refresh(usersProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
