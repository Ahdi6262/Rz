import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/providers/auth_provider.dart';
import 'package:hex_the_add_hub/screens/admin/admin_dashboard.dart';
import 'package:hex_the_add_hub/screens/blog/blog_screen.dart';
import 'package:hex_the_add_hub/screens/courses/courses_screen.dart';
import 'package:hex_the_add_hub/screens/portfolio/portfolio_screen.dart';
import 'package:hex_the_add_hub/widgets/app_drawer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: normalAnimationDuration,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDashboardContent() {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInLeft(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  '${AppStrings.welcome}, ${user.fullName}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInLeft(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'What would you like to do today?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: darkSecondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                title: AppStrings.portfolio,
                icon: Icons.work,
                color: Colors.blue,
                index: 1,
              ),
              _buildDashboardCard(
                title: AppStrings.courses,
                icon: Icons.school,
                color: Colors.green,
                index: 2,
              ),
              _buildDashboardCard(
                title: AppStrings.blog,
                icon: Icons.article,
                color: Colors.orange,
                index: 3,
              ),
              if (user.isAdmin)
                _buildDashboardCard(
                  title: AppStrings.admin,
                  icon: Icons.admin_panel_settings,
                  color: Colors.purple,
                  index: 4,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: Duration(milliseconds: 300 + (index * 100)),
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.7),
                  color.withOpacity(0.9),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final List<Widget> pages = [
      _buildDashboardContent(),
      const PortfolioScreen(),
      const CoursesScreen(),
      const BlogScreen(),
      if (user?.isAdmin == true) const AdminDashboard(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 
          ? AppStrings.home 
          : _selectedIndex == 1 
            ? AppStrings.portfolio 
            : _selectedIndex == 2 
              ? AppStrings.courses 
              : _selectedIndex == 3 
                ? AppStrings.blog 
                : AppStrings.admin),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Implement notifications
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          const NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: AppStrings.portfolio,
          ),
          const NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: AppStrings.courses,
          ),
          const NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: AppStrings.blog,
          ),
          if (user?.isAdmin == true)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: AppStrings.admin,
            ),
        ],
      ),
    );
  }
}
