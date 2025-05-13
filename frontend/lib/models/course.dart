import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool isFree;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.isFree,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Factory constructor for creating Course from JSON
  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  // Method for converting Course to JSON
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

@JsonSerializable()
class CourseSection {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseSection({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating CourseSection from JSON
  factory CourseSection.fromJson(Map<String, dynamic> json) => _$CourseSectionFromJson(json);

  // Method for converting CourseSection to JSON
  Map<String, dynamic> toJson() => _$CourseSectionToJson(this);
}

@JsonSerializable()
class CourseLesson {
  final String id;
  final String sectionId;
  final String title;
  final String? content;
  final String? videoUrl;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseLesson({
    required this.id,
    required this.sectionId,
    required this.title,
    this.content,
    this.videoUrl,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating CourseLesson from JSON
  factory CourseLesson.fromJson(Map<String, dynamic> json) => _$CourseLessonFromJson(json);

  // Method for converting CourseLesson to JSON
  Map<String, dynamic> toJson() => _$CourseLessonToJson(this);
}

@JsonSerializable()
class SectionWithLessons {
  final CourseSection section;
  final List<CourseLesson> lessons;

  SectionWithLessons({
    required this.section,
    required this.lessons,
  });

  // Factory constructor for creating SectionWithLessons from JSON
  factory SectionWithLessons.fromJson(Map<String, dynamic> json) => _$SectionWithLessonsFromJson(json);

  // Method for converting SectionWithLessons to JSON
  Map<String, dynamic> toJson() => _$SectionWithLessonsToJson(this);
}

@JsonSerializable()
class CourseWithSections {
  final Course course;
  final List<SectionWithLessons> sections;

  CourseWithSections({
    required this.course,
    required this.sections,
  });

  // Factory constructor for creating CourseWithSections from JSON
  factory CourseWithSections.fromJson(Map<String, dynamic> json) => _$CourseWithSectionsFromJson(json);

  // Method for converting CourseWithSections to JSON
  Map<String, dynamic> toJson() => _$CourseWithSectionsToJson(this);
}

@JsonSerializable()
class UserEnrollment {
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final DateTime? completedAt;

  UserEnrollment({
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    this.completedAt,
  });

  // Factory constructor for creating UserEnrollment from JSON
  factory UserEnrollment.fromJson(Map<String, dynamic> json) => _$UserEnrollmentFromJson(json);

  // Method for converting UserEnrollment to JSON
  Map<String, dynamic> toJson() => _$UserEnrollmentToJson(this);
}

@JsonSerializable()
class UserLessonProgress {
  final String userId;
  final String lessonId;
  final bool completed;
  final DateTime lastAccessed;

  UserLessonProgress({
    required this.userId,
    required this.lessonId,
    required this.completed,
    required this.lastAccessed,
  });

  // Factory constructor for creating UserLessonProgress from JSON
  factory UserLessonProgress.fromJson(Map<String, dynamic> json) => _$UserLessonProgressFromJson(json);

  // Method for converting UserLessonProgress to JSON
  Map<String, dynamic> toJson() => _$UserLessonProgressToJson(this);
}

@JsonSerializable()
class CreateCourseRequest {
  final String title;
  final String description;
  final double price;
  final bool isFree;

  CreateCourseRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.isFree,
  });

  // Factory constructor for creating CreateCourseRequest from JSON
  factory CreateCourseRequest.fromJson(Map<String, dynamic> json) => _$CreateCourseRequestFromJson(json);

  // Method for converting CreateCourseRequest to JSON
  Map<String, dynamic> toJson() => _$CreateCourseRequestToJson(this);
}

@JsonSerializable()
class UpdateCourseRequest {
  final String? title;
  final String? description;
  final double? price;
  final bool? isFree;

  UpdateCourseRequest({
    this.title,
    this.description,
    this.price,
    this.isFree,
  });

  // Factory constructor for creating UpdateCourseRequest from JSON
  factory UpdateCourseRequest.fromJson(Map<String, dynamic> json) => _$UpdateCourseRequestFromJson(json);

  // Method for converting UpdateCourseRequest to JSON
  Map<String, dynamic> toJson() => _$UpdateCourseRequestToJson(this);
}

@JsonSerializable()
class UpdateProgressRequest {
  final bool completed;

  UpdateProgressRequest({
    required this.completed,
  });

  // Factory constructor for creating UpdateProgressRequest from JSON
  factory UpdateProgressRequest.fromJson(Map<String, dynamic> json) => _$UpdateProgressRequestFromJson(json);

  // Method for converting UpdateProgressRequest to JSON
  Map<String, dynamic> toJson() => _$UpdateProgressRequestToJson(this);
}
