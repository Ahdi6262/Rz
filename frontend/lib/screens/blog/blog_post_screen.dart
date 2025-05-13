import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/blog_post.dart';
import 'package:hex_the_add_hub/providers/auth_provider.dart';
import 'package:hex_the_add_hub/providers/blog_provider.dart';

class BlogPostScreen extends ConsumerStatefulWidget {
  final String? postId;
  final bool isEditing;

  const BlogPostScreen({
    Key? key,
    this.postId,
    this.isEditing = true,
  }) : super(key: key);

  @override
  ConsumerState<BlogPostScreen> createState() => _BlogPostScreenState();
}

class _BlogPostScreenState extends ConsumerState<BlogPostScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _commentController = TextEditingController();
  
  bool _isPublished = true;
  bool _isLoading = false;
  bool _isSubmittingComment = false;
  bool _isViewMode = true;
  
  @override
  void initState() {
    super.initState();
    
    // If post ID is provided, fetch the post
    if (widget.postId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedBlogPostProvider.notifier).getPostById(widget.postId!);
        ref.read(blogCommentsProvider.notifier).getComments(widget.postId!);
      });
    } else {
      // Creating a new post
      _isViewMode = false;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _commentController.dispose();
    super.dispose();
  }
  
  void _setupEditMode(BlogPost post) {
    _titleController.text = post.title;
    _contentController.text = post.content;
    _tagsController.text = post.tags.join(', ');
    _isPublished = post.published;
  }
  
  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Parse comma-separated tags
        final tags = _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        
        if (widget.isEditing && widget.postId != null) {
          // Update existing post
          final request = UpdateBlogPostRequest(
            title: _titleController.text,
            content: _contentController.text,
            tags: tags,
            published: _isPublished,
          );
          
          await ref.read(blogPostsProvider.notifier).updatePost(widget.postId!, request);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post updated successfully')),
            );
            setState(() {
              _isViewMode = true;
            });
          }
        } else {
          // Create new post
          final request = CreateBlogPostRequest(
            title: _titleController.text,
            content: _contentController.text,
            tags: tags,
            published: _isPublished,
          );
          
          final newPost = await ref.read(blogPostsProvider.notifier).createPost(request);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post created successfully')),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
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
  
  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: errorColor),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await ref.read(blogPostsProvider.notifier).deletePost(postId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
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
  
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || widget.postId == null) {
      return;
    }
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    try {
      await ref.read(blogCommentsProvider.notifier).addComment(
        widget.postId!,
        _commentController.text.trim(),
      );
      
      if (mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.commentAdded)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPostState = ref.watch(selectedBlogPostProvider);
    final currentUser = ref.watch(authProvider).value;
    final isAdmin = currentUser?.isAdmin ?? false;
    
    // For new post creation
    if (widget.postId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create New Post'),
        ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildEditMode(),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _savePost,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                AppStrings.create,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: selectedPostState.when(
          data: (post) => Text(_isViewMode ? post?.title ?? 'Blog Post' : 'Edit Post'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Blog Post'),
        ),
        actions: selectedPostState.when(
          data: (post) => post != null && isAdmin ? [
            // Toggle between view and edit modes
            IconButton(
              icon: Icon(_isViewMode ? Icons.edit : Icons.visibility),
              onPressed: () {
                if (_isViewMode) {
                  // Switch to edit mode
                  _setupEditMode(post);
                }
                setState(() {
                  _isViewMode = !_isViewMode;
                });
              },
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : () => _deletePost(post.id!),
            ),
          ] : null,
          loading: () => null,
          error: (_, __) => null,
        ),
      ),
      body: selectedPostState.when(
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found'));
          }
          
          return _isViewMode
            ? _buildPostView(post)
            : _buildEditMode();
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
                onPressed: () => ref.read(selectedBlogPostProvider.notifier).getPostById(widget.postId!),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isViewMode
        ? null
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _savePost,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  AppStrings.update,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
    );
  }
  
  Widget _buildPostView(BlogPost post) {
    final commentsState = ref.watch(blogCommentsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured image
          if (post.featuredImage != null && post.featuredImage!.isNotEmpty)
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.featuredImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Title
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            child: Text(
              post.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Metadata (author, date)
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: Text(
              '${AppStrings.publishedOn} ${DateFormat('MMM d, yyyy').format(post.createdAt)} ${AppStrings.by} ${post.authorName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: darkSecondaryTextColor,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Tags
          if (post.tags.isNotEmpty)
            FadeInLeft(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: primaryColor.withOpacity(0.2),
                  );
                }).toList(),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Content
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 300),
            child: Text(
              post.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Comments section
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.comments,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Add comment form
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: AppStrings.writeComment,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: darkSurfaceColor,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmittingComment ? null : _submitComment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      child: _isSubmittingComment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppStrings.post),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Comments list
                commentsState.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            AppStrings.noComments,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: darkSecondaryTextColor,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            comment.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(comment.content),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d, yyyy • h:mm a').format(comment.createdAt),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: darkSecondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Error loading comments: $error',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: errorColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                prefixIcon: Icon(Icons.article),
                alignLabelWithHint: true,
              ),
              minLines: 10,
              maxLines: 20,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                prefixIcon: Icon(Icons.tag),
                hintText: 'Flutter, Dart, Web3, etc.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter at least one tag';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Publish checkbox
            Row(
              children: [
                Checkbox(
                  value: _isPublished,
                  onChanged: (value) {
                    setState(() {
                      _isPublished = value ?? false;
                    });
                  },
                ),
                const Text('Publish post'),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
