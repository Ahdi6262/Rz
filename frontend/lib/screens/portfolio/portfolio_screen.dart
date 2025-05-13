import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/portfolio_item.dart';
import 'package:hex_the_add_hub/providers/portfolio_provider.dart';
import 'package:hex_the_add_hub/screens/portfolio/portfolio_item_screen.dart';
import 'package:hex_the_add_hub/widgets/portfolio_grid.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioProvider.notifier).getProjects();
    });
  }
  
  Future<void> _refreshProjects() async {
    await ref.read(portfolioProvider.notifier).getProjects();
  }
  
  void _addNewProject() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PortfolioItemScreen(isEditing: false),
      ),
    );
  }
  
  void _viewProjectDetails(PortfolioItem project) {
    ref.read(selectedPortfolioItemProvider.notifier).state = project;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PortfolioItemScreen(isEditing: true, item: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioProvider);
    
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshProjects,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  AppStrings.myProjects,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: portfolioState.when(
                  data: (projects) {
                    if (projects.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.work_off,
                              size: 64,
                              color: darkSecondaryTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.noProjects,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: darkSecondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _addNewProject,
                              icon: const Icon(Icons.add),
                              label: const Text(AppStrings.addProject),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: PortfolioGrid(
                        items: projects,
                        onItemTap: _viewProjectDetails,
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
                          onPressed: _refreshProjects,
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
        ),
      ),
      floatingActionButton: FadeInRight(
        duration: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: _addNewProject,
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.addProject),
        ),
      ),
    );
  }
}
