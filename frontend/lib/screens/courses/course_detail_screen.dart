import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/course.dart';
import 'package:hex_the_add_hub/providers/course_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _selectedLessonId;
  CourseLesson? _selectedLesson;
  bool _isEnrolling = false;
  bool _isUpdatingProgress = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedCourseProvider.notifier).getCourseById(widget.courseId);
    });
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
  
  void _initializeVideo(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) {
      _disposeVideo();
      return;
    }
    
    // Dispose previous controllers if they exist
    _disposeVideo();
    
    // Initialize new controllers
    _videoController = VideoPlayerController.network(videoUrl);
    _videoController!.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  void _disposeVideo() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }
  
  void _selectLesson(CourseLesson lesson) {
    setState(() {
      _selectedLessonId = lesson.id;
      _selectedLesson = lesson;
    });
    
    // Initialize video if the lesson has a video
    _initializeVideo(lesson.videoUrl);
  }
  
  Future<void> _enrollInCourse() async {
    setState(() {
      _isEnrolling = true;
    });
    
    try {
      await ref.read(selectedCourseProvider.notifier).enrollInCourse(widget.courseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.enrolled_success)),
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
          _isEnrolling = false;
        });
      }
    }
  }
  
  Future<void> _markLessonAsComplete(bool completed) async {
    if (_selectedLessonId == null) return;
    
    setState(() {
      _isUpdatingProgress = true;
    });
    
    try {
      await ref.read(selectedCourseProvider.notifier).updateLessonProgress(
        _selectedLessonId!,
        completed,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.progressUpdated)),
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
          _isUpdatingProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(selectedCourseProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: courseState.when(
          data: (courseWithSections) => Text(courseWithSections?.course.title ?? 'Course Details'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Course Details'),
        ),
      ),
      body: courseState.when(
        data: (courseWithSections) {
          if (courseWithSections == null) {
            return const Center(child: Text('Course not found'));
          }
          
          return _buildCourseContent(courseWithSections);
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
                onPressed: () => ref.read(selectedCourseProvider.notifier).getCourseById(widget.courseId),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCourseContent(CourseWithSections courseWithSections) {
    final course = courseWithSections.course;
    final sections = courseWithSections.sections;
    
    return Column(
      children: [
        // Course header
        _buildCourseHeader(course),
        
        // Course content - Sections and lessons
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course sections and lessons sidebar
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: darkSurfaceColor,
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: sections.length,
                  itemBuilder: (context, sectionIndex) {
                    final section = sections[sectionIndex].section;
                    final lessons = sections[sectionIndex].lessons;
                    
                    return FadeInLeft(
                      duration: const Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 100 * sectionIndex),
                      child: ExpansionTile(
                        title: Text(
                          section.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${lessons.length} ${AppStrings.lessons}'),
                        initiallyExpanded: sectionIndex == 0,
                        children: lessons.map((lesson) {
                          final isSelected = _selectedLessonId == lesson.id;
                          
                          return ListTile(
                            title: Text(lesson.title),
                            leading: Icon(
                              lesson.videoUrl != null
                                  ? Icons.play_circle_outline
                                  : Icons.article_outlined,
                              color: isSelected ? primaryColor : null,
                            ),
                            selected: isSelected,
                            selectedTileColor: primaryColor.withOpacity(0.1),
                            onTap: () => _selectLesson(lesson),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              
              // Lesson content
              Expanded(
                child: _selectedLesson != null
                    ? _buildLessonContent()
                    : _buildEmptyLessonState(),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCourseHeader(Course course) {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: darkSurfaceColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isEnrolling ? null : _enrollInCourse,
                  child: _isEnrolling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.enroll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    course.isFree ? AppStrings.free : '${AppStrings.coursePrice}: \$${course.price.toStringAsFixed(2)}',
                  ),
                  backgroundColor: course.isFree ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${course.createdAt.year}-${course.createdAt.month.toString().padLeft(2, '0')}-${course.createdAt.day.toString().padLeft(2, '0')}'),
                  backgroundColor: Colors.grey.withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLessonContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson title
          FadeInRight(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _selectedLesson!.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Video player (if available)
          if (_selectedLesson!.videoUrl != null && _chewieController != null)
            FadeInRight(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Chewie(controller: _chewieController!),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Lesson content
          if (_selectedLesson!.content != null && _selectedLesson!.content!.isNotEmpty)
            Expanded(
              child: FadeInRight(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: SingleChildScrollView(
                  child: Text(_selectedLesson!.content!),
                ),
              ),
            ),
          
          // Mark as complete button
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton.icon(
                onPressed: _isUpdatingProgress
                    ? null
                    : () => _markLessonAsComplete(true),
                icon: _isUpdatingProgress
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: const Text(AppStrings.markAsComplete),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyLessonState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.menu_book,
            size: 64,
            color: darkSecondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a lesson to start learning',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: darkSecondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
