import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/screens/admin/manage_users.dart';
import 'package:hex_the_add_hub/screens/admin/manage_courses.dart';
import 'package:hex_the_add_hub/screens/admin/manage_blog.dart';
import 'package:hex_the_add_hub/services/api_service.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final stats = await apiService.getAdminStats();
  return stats;
});

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(adminStatsProvider);
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: AppBar(
            title: const Text(AppStrings.adminDashboard),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: AppStrings.manageUsers),
                Tab(text: AppStrings.manageCourses),
                Tab(text: AppStrings.manageBlog),
              ],
              indicatorColor: activeTabColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: activeTabColor,
              unselectedLabelColor: darkSecondaryTextColor,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Overview tab
            _buildOverviewTab(context, statsState),
            
            // Users tab
            const ManageUsersScreen(),
            
            // Courses tab
            const ManageCoursesScreen(),
            
            // Blog tab
            const ManageBlogScreen(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewTab(BuildContext context, AsyncValue<Map<String, dynamic>> statsState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Text(
              AppStrings.statistics,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: statsState.when(
              data: (stats) {
                return FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        context,
                        Icons.people,
                        AppStrings.totalUsers,
                        stats['user_count'].toString(),
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        Icons.school,
                        AppStrings.totalCourses,
                        stats['course_count'].toString(),
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        Icons.how_to_reg,
                        AppStrings.totalEnrollments,
                        stats['enrollment_count'].toString(),
                        Colors.orange,
                      ),
                      _buildStatCard(
                        context,
                        Icons.work,
                        AppStrings.totalProjects,
                        stats['portfolio_count'].toString(),
                        Colors.purple,
                      ),
                      _buildStatCard(
                        context,
                        Icons.article,
                        AppStrings.totalBlogPosts,
                        stats['blog_post_count'].toString(),
                        Colors.red,
                      ),
                      _buildStatCard(
                        context,
                        Icons.comment,
                        AppStrings.totalComments,
                        stats['comment_count'].toString(),
                        Colors.teal,
                      ),
                    ],
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
                    Consumer(
                      builder: (context, ref, _) => ElevatedButton.icon(
                        onPressed: () => ref.refresh(adminStatsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
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
  
  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
