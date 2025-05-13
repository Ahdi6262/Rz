import 'package:dio/dio.dart';
import 'package:hex_the_add_hub/models/blog_post.dart';
import 'package:hex_the_add_hub/models/course.dart';
import 'package:hex_the_add_hub/models/portfolio_item.dart';
import 'package:hex_the_add_hub/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://0.0.0.0:8000/api';

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle refresh token or other error handling strategies here
          return handler.next(e);
        },
      ),
    );
  }

  // User endpoints
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('$_baseUrl/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('$_baseUrl/admin/users');
      return (response.data as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/admin/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('$_baseUrl/admin/users/$id', data: data);
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('$_baseUrl/admin/users/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Portfolio endpoints
  Future<List<PortfolioItem>> getPortfolioItems() async {
    try {
      final response = await _dio.get('$_baseUrl/portfolio');
      return (response.data as List).map((json) => PortfolioItem.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PortfolioItem> getPortfolioItemById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/portfolio/$id');
      return PortfolioItem.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PortfolioItem> createPortfolioItem(CreatePortfolioItemRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/portfolio',
        data: request.toJson(),
      );
      return PortfolioItem.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PortfolioItem> updatePortfolioItem(
      String id, UpdatePortfolioItemRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/portfolio/$id',
        data: request.toJson(),
      );
      return PortfolioItem.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePortfolioItem(String id) async {
    try {
      await _dio.delete('$_baseUrl/portfolio/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Course endpoints
  Future<List<Course>> getAllCourses() async {
    try {
      final response = await _dio.get('$_baseUrl/courses');
      return (response.data as List).map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CourseWithSections> getCourseById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/courses/$id');
      return CourseWithSections.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Course> createCourse(CreateCourseRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/courses',
        data: request.toJson(),
      );
      return Course.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Course> updateCourse(String id, UpdateCourseRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/courses/$id',
        data: request.toJson(),
      );
      return Course.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCourse(String id) async {
    try {
      await _dio.delete('$_baseUrl/courses/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> enrollInCourse(String courseId) async {
    try {
      await _dio.post('$_baseUrl/courses/enroll/$courseId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateLessonProgress(String lessonId, bool completed) async {
    try {
      await _dio.post(
        '$_baseUrl/courses/progress/$lessonId',
        data: {
          'completed': completed,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Blog endpoints
  Future<List<BlogPost>> getAllBlogPosts() async {
    try {
      final response = await _dio.get('$_baseUrl/blog');
      return (response.data as List).map((json) => BlogPost.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<BlogPost> getBlogPostById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/blog/$id');
      return BlogPost.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<BlogPost> createBlogPost(CreateBlogPostRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/blog',
        data: request.toJson(),
      );
      return BlogPost.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<BlogPost> updateBlogPost(String id, UpdateBlogPostRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/blog/$id',
        data: request.toJson(),
      );
      return BlogPost.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteBlogPost(String id) async {
    try {
      await _dio.delete('$_baseUrl/blog/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<BlogComment>> getComments(String postId) async {
    try {
      final response = await _dio.get('$_baseUrl/blog/$postId/comments');
      return (response.data as List).map((json) => BlogComment.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<BlogComment> addComment(String postId, String content) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/blog/$postId/comments',
        data: {
          'content': content,
        },
      );
      return BlogComment.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Admin endpoints
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await _dio.get('$_baseUrl/admin/stats');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;
        
        if (data is Map && data.containsKey('error')) {
          return Exception(data['error']);
        }
        
        switch (statusCode) {
          case 400:
            return Exception('Bad request');
          case 401:
            return Exception('Unauthorized');
          case 403:
            return Exception('Forbidden');
          case 404:
            return Exception('Not found');
          case 500:
            return Exception('Server error');
          default:
            return Exception('Network error: ${error.message}');
        }
      }
      return Exception('Network error: ${error.message}');
    }
    return Exception('Unknown error: $error');
  }
}
