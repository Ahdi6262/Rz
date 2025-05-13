import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/blog_post.dart';
import 'package:hex_the_add_hub/providers/blog_provider.dart';
import 'package:hex_the_add_hub/screens/blog/blog_post_screen.dart';
import 'package:intl/intl.dart';

class ManageBlogScreen extends ConsumerStatefulWidget {
  const ManageBlogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ManageBlogScreen> createState() => _ManageBlogScreenState();
}

class _ManageBlogScreenState extends ConsumerState<ManageBlogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blogPostsProvider.notifier).getPosts();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(blogPostsProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Actions row
          Row(
            children: [
              // Search bar
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search blog posts...',
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
              ),
              
              const SizedBox(width: 16),
              
              // Create post button
              ElevatedButton.icon(
                onPressed: () => _createNewPost(),
                icon: const Icon(Icons.add),
                label: const Text('Create Post'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Blog posts list
          Expanded(
            child: postsState.when(
              data: (posts) {
                // Filter posts based on search query
                final filteredPosts = _searchQuery.isEmpty
                  ? posts
                  : posts.where((post) =>
                      post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      post.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
                    ).toList();
                
                if (filteredPosts.isEmpty) {
                  return const Center(
                    child: Text('No blog posts found'),
                  );
                }
                
                return FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: post.published ? Colors.green : Colors.grey,
                            child: Icon(
                              Icons.article,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(post.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'By ${post.authorName} - ${DateFormat('MMM d, yyyy').format(post.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (post.tags.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: post.tags.map((tag) {
                                    return Chip(
                                      label: Text(
                                        tag,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      backgroundColor: primaryColor.withOpacity(0.2),
                                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: post.published 
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  post.published ? 'Published' : 'Draft',
                                  style: TextStyle(
                                    color: post.published ? Colors.green : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editPost(post),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: errorColor),
                                onPressed: () => _showDeletePostDialog(post),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () => _viewPost(post),
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
                      onPressed: () => ref.read(blogPostsProvider.notifier).getPosts(),
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
  
  void _createNewPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BlogPostScreen(isEditing: false),
      ),
    ).then((_) {
      // Refresh the posts list
      ref.read(blogPostsProvider.notifier).getPosts();
    });
  }
  
  void _viewPost(BlogPost post) {
    if (post.id != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlogPostScreen(postId: post.id!),
        ),
      ).then((_) {
        // Refresh the posts list
        ref.read(blogPostsProvider.notifier).getPosts();
      });
    }
  }
  
  void _editPost(BlogPost post) {
    if (post.id != null) {
      ref.read(selectedBlogPostProvider.notifier).getPostById(post.id!);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlogPostScreen(
            postId: post.id!,
            isEditing: true,
          ),
        ),
      ).then((_) {
        // Refresh the posts list
        ref.read(blogPostsProvider.notifier).getPosts();
      });
    }
  }
  
  void _showDeletePostDialog(BlogPost post) {
    if (post.id == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete "${post.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(blogPostsProvider.notifier).deletePost(post.id!);
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully')),
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
