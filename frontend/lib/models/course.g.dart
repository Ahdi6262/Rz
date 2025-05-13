// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      isFree: json['isFree'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'isFree': instance.isFree,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };

CourseSection _$CourseSectionFromJson(Map<String, dynamic> json) =>
    CourseSection(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CourseSectionToJson(CourseSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'title': instance.title,
      'description': instance.description,
      'position': instance.position,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CourseLesson _$CourseLessonFromJson(Map<String, dynamic> json) => CourseLesson(
      id: json['id'] as String,
      sectionId: json['sectionId'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      videoUrl: json['videoUrl'] as String?,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CourseLessonToJson(CourseLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sectionId': instance.sectionId,
      'title': instance.title,
      'content': instance.content,
      'videoUrl': instance.videoUrl,
      'position': instance.position,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SectionWithLessons _$SectionWithLessonsFromJson(Map<String, dynamic> json) =>
    SectionWithLessons(
      section:
          CourseSection.fromJson(json['section'] as Map<String, dynamic>),
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => CourseLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SectionWithLessonsToJson(SectionWithLessons instance) =>
    <String, dynamic>{
      'section': instance.section,
      'lessons': instance.lessons,
    };

CourseWithSections _$CourseWithSectionsFromJson(Map<String, dynamic> json) =>
    CourseWithSections(
      course: Course.fromJson(json['course'] as Map<String, dynamic>),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => SectionWithLessons.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseWithSectionsToJson(CourseWithSections instance) =>
    <String, dynamic>{
      'course': instance.course,
      'sections': instance.sections,
    };

UserEnrollment _$UserEnrollmentFromJson(Map<String, dynamic> json) =>
    UserEnrollment(
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$UserEnrollmentToJson(UserEnrollment instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'courseId': instance.courseId,
      'enrolledAt': instance.enrolledAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

UserLessonProgress _$UserLessonProgressFromJson(Map<String, dynamic> json) =>
    UserLessonProgress(
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      completed: json['completed'] as bool,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
    );

Map<String, dynamic> _$UserLessonProgressToJson(UserLessonProgress instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'lessonId': instance.lessonId,
      'completed': instance.completed,
      'lastAccessed': instance.lastAccessed.toIso8601String(),
    };

CreateCourseRequest _$CreateCourseRequestFromJson(Map<String, dynamic> json) =>
    CreateCourseRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      isFree: json['isFree'] as bool,
    );

Map<String, dynamic> _$CreateCourseRequestToJson(
        CreateCourseRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'isFree': instance.isFree,
    };

UpdateCourseRequest _$UpdateCourseRequestFromJson(Map<String, dynamic> json) =>
    UpdateCourseRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      isFree: json['isFree'] as bool?,
    );

Map<String, dynamic> _$UpdateCourseRequestToJson(
        UpdateCourseRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'isFree': instance.isFree,
    };

UpdateProgressRequest _$UpdateProgressRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProgressRequest(
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$UpdateProgressRequestToJson(
        UpdateProgressRequest instance) =>
    <String, dynamic>{
      'completed': instance.completed,
    };