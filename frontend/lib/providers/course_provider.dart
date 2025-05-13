import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_the_add_hub/models/course.dart';
import 'package:hex_the_add_hub/services/api_service.dart';

final allCoursesProvider = StateNotifierProvider<CoursesNotifier, AsyncValue<List<Course>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CoursesNotifier(apiService);
});

final selectedCourseProvider = StateNotifierProvider<SelectedCourseNotifier, AsyncValue<CourseWithSections?>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SelectedCourseNotifier(apiService);
});

class CoursesNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final ApiService _apiService;

  CoursesNotifier(this._apiService) : super(const AsyncValue.loading()) {
    getCourses();
  }

  Future<void> getCourses() async {
    state = const AsyncValue.loading();
    try {
      final courses = await _apiService.getAllCourses();
      state = AsyncValue.data(courses);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<Course> createCourse(CreateCourseRequest request) async {
    try {
      final newCourse = await _apiService.createCourse(request);
      state = AsyncValue.data([...state.value!, newCourse]);
      return newCourse;
    } catch (e) {
      rethrow;
    }
  }

  Future<Course> updateCourse(String id, UpdateCourseRequest request) async {
    try {
      final updatedCourse = await _apiService.updateCourse(id, request);
      state = AsyncValue.data(state.value!.map((course) {
        return course.id == id ? updatedCourse : course;
      }).toList());
      return updatedCourse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCourse(String id) async {
    try {
      await _apiService.deleteCourse(id);
      state = AsyncValue.data(state.value!.where((course) => course.id != id).toList());
    } catch (e) {
      rethrow;
    }
  }
}

class SelectedCourseNotifier extends StateNotifier<AsyncValue<CourseWithSections?>> {
  final ApiService _apiService;

  SelectedCourseNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<void> getCourseById(String id) async {
    state = const AsyncValue.loading();
    try {
      final course = await _apiService.getCourseById(id);
      state = AsyncValue.data(course);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> enrollInCourse(String courseId) async {
    try {
      await _apiService.enrollInCourse(courseId);
      // After enrolling, refresh the course data
      await getCourseById(courseId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLessonProgress(String lessonId, bool completed) async {
    try {
      await _apiService.updateLessonProgress(lessonId, completed);
      // Optionally refresh course data if needed
    } catch (e) {
      rethrow;
    }
  }

  void clearSelectedCourse() {
    state = const AsyncValue.data(null);
  }
}
