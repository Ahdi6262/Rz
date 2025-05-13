import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/blog_post.dart';
import 'package:hex_the_add_hub/providers/auth_provider.dart';
import 'package:hex_the_add_hub/providers/blog_provider.dart';
import 'package:hex_the_add_hub/screens/blog/blog_post_screen.dart';
import 'package:hex_the_add_hub/widgets/blog_post_card.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blogPostsProvider.notifier).getPosts();
    });
  }
  
  Future<void> _refreshPosts() async {
    await ref.read(blogPostsProvider.notifier).getPosts();
  }
  
  void _viewPostDetails(BlogPost post) {
    ref.read(selectedBlogPostProvider.notifier).getPostById(post.id!);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlogPostScreen(postId: post.id!),
      ),
    );
  }
  
  void _createNewPost() {
    // Navigate to post creation screen (for admins)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BlogPostScreen(isEditing: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(blogPostsProvider);
    final currentUser = ref.watch(authProvider).value;
    final isAdmin = currentUser?.isAdmin ?? false;
    
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshPosts,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        AppStrings.blog,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        AppStrings.latestPosts,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: darkSecondaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            postsState.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: darkSecondaryTextColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noBlogPosts,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: darkSecondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isAdmin) ...[
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _createNewPost,
                              icon: const Icon(Icons.add),
                              label: const Text('Create Post'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = posts[index];
                        return FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: Duration(milliseconds: 100 * index),
                          child: BlogPostCard(
                            post: post,
                            onTap: () => _viewPostDetails(post),
                          ),
                        );
                      },
                      childCount: posts.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: Center(
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
                        onPressed: _refreshPosts,
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
      floatingActionButton: isAdmin ? FadeInRight(
        duration: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: _createNewPost,
          icon: const Icon(Icons.add),
          label: const Text('Create Post'),
        ),
      ) : null,
    );
  }
}
