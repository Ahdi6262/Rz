import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/course.dart';
import 'package:hex_the_add_hub/providers/auth_provider.dart';
import 'package:hex_the_add_hub/providers/course_provider.dart';
import 'package:hex_the_add_hub/screens/courses/course_detail_screen.dart';
import 'package:hex_the_add_hub/widgets/course_card.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allCoursesProvider.notifier).getCourses();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshCourses() async {
    await ref.read(allCoursesProvider.notifier).getCourses();
  }
  
  void _openCourseDetails(Course course) {
    ref.read(selectedCourseProvider.notifier).getCourseById(course.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseId: course.id),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final coursesState = ref.watch(allCoursesProvider);
    final currentUser = ref.watch(authProvider).value;
    final isAdmin = currentUser?.isAdmin ?? false;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        AppStrings.courses,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: AppStrings.allCourses),
                    Tab(text: AppStrings.enrolledCourses),
                  ],
                  indicatorColor: activeTabColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: activeTabColor,
                  unselectedLabelColor: darkSecondaryTextColor,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // All courses tab
            RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refreshCourses,
              child: coursesState.when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: darkSecondaryTextColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noCourses,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: darkSecondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isAdmin) ...[
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to course creation screen (for admins)
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Course'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  
                  return FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return CourseCard(
                          course: course,
                          onTap: () => _openCourseDetails(course),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
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
                        onPressed: _refreshCourses,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Enrolled courses tab (to be implemented)
            const Center(
              child: Text(AppStrings.noEnrolledCourses),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin ? FadeInRight(
        duration: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Navigate to course creation screen (for admins)
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Course'),
        ),
      ) : null,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: darkBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
