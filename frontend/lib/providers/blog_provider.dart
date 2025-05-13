import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_the_add_hub/models/blog_post.dart';
import 'package:hex_the_add_hub/services/api_service.dart';

final blogPostsProvider = StateNotifierProvider<BlogPostsNotifier, AsyncValue<List<BlogPost>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BlogPostsNotifier(apiService);
});

final selectedBlogPostProvider = StateNotifierProvider<SelectedBlogPostNotifier, AsyncValue<BlogPost?>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SelectedBlogPostNotifier(apiService);
});

final blogCommentsProvider = StateNotifierProvider<BlogCommentsNotifier, AsyncValue<List<BlogComment>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final selectedPost = ref.watch(selectedBlogPostProvider);
  
  final notifier = BlogCommentsNotifier(apiService);
  
  // Load comments when a post is selected
  if (selectedPost.value != null && selectedPost.value!.id != null) {
    notifier.getComments(selectedPost.value!.id!);
  }
  
  return notifier;
});

class BlogPostsNotifier extends StateNotifier<AsyncValue<List<BlogPost>>> {
  final ApiService _apiService;

  BlogPostsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    getPosts();
  }

  Future<void> getPosts() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _apiService.getAllBlogPosts();
      state = AsyncValue.data(posts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<BlogPost> createPost(CreateBlogPostRequest request) async {
    try {
      final newPost = await _apiService.createBlogPost(request);
      state = AsyncValue.data([...state.value!, newPost]);
      return newPost;
    } catch (e) {
      rethrow;
    }
  }

  Future<BlogPost> updatePost(String id, UpdateBlogPostRequest request) async {
    try {
      final updatedPost = await _apiService.updateBlogPost(id, request);
      state = AsyncValue.data(state.value!.map((post) {
        return post.id == id ? updatedPost : post;
      }).toList());
      return updatedPost;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await _apiService.deleteBlogPost(id);
      state = AsyncValue.data(state.value!.where((post) => post.id != id).toList());
    } catch (e) {
      rethrow;
    }
  }
}

class SelectedBlogPostNotifier extends StateNotifier<AsyncValue<BlogPost?>> {
  final ApiService _apiService;

  SelectedBlogPostNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<void> getPostById(String id) async {
    state = const AsyncValue.loading();
    try {
      final post = await _apiService.getBlogPostById(id);
      state = AsyncValue.data(post);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearSelectedPost() {
    state = const AsyncValue.data(null);
  }
}

class BlogCommentsNotifier extends StateNotifier<AsyncValue<List<BlogComment>>> {
  final ApiService _apiService;

  BlogCommentsNotifier(this._apiService) : super(const AsyncValue.data([]));

  Future<void> getComments(String postId) async {
    state = const AsyncValue.loading();
    try {
      final comments = await _apiService.getComments(postId);
      state = AsyncValue.data(comments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<BlogComment> addComment(String postId, String content) async {
    try {
      final newComment = await _apiService.addComment(postId, content);
      state = AsyncValue.data([...state.value!, newComment]);
      return newComment;
    } catch (e) {
      rethrow;
    }
  }

  void clearComments() {
    state = const AsyncValue.data([]);
  }
}
