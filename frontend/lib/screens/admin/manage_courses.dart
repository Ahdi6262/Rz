import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/course.dart';
import 'package:hex_the_add_hub/providers/course_provider.dart';

class ManageCoursesScreen extends ConsumerStatefulWidget {
  const ManageCoursesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends ConsumerState<ManageCoursesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allCoursesProvider.notifier).getCourses();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final coursesState = ref.watch(allCoursesProvider);
    
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
                    hintText: 'Search courses...',
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
              
              // Create course button
              ElevatedButton.icon(
                onPressed: () => _showCreateCourseDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create Course'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Courses list
          Expanded(
            child: coursesState.when(
              data: (courses) {
                // Filter courses based on search query
                final filteredCourses = _searchQuery.isEmpty
                  ? courses
                  : courses.where((course) =>
                      course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      course.description.toLowerCase().contains(_searchQuery.toLowerCase())
                    ).toList();
                
                if (filteredCourses.isEmpty) {
                  return const Center(
                    child: Text('No courses found'),
                  );
                }
                
                return FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: ListView.builder(
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: course.isFree ? Colors.green : Colors.blue,
                            child: Icon(
                              Icons.school,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(course.title),
                          subtitle: Text(
                            course.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                                  color: course.isFree 
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  course.isFree 
                                    ? AppStrings.free
                                    : '\$${course.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: course.isFree ? Colors.green : Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditCourseDialog(course),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: errorColor),
                                onPressed: () => _showDeleteCourseDialog(course),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to a detailed course management screen
                            // This would be implemented in a real app
                          },
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
                      onPressed: () => ref.read(allCoursesProvider.notifier).getCourses(),
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
  
  void _showCreateCourseDialog() {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController(text: '0.00');
    bool _isFree = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _isFree,
                      onChanged: (value) {
                        setState(() {
                          _isFree = value ?? false;
                        });
                      },
                    ),
                    const Text('Free course'),
                  ],
                ),
                if (!_isFree) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price ($)',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and description are required')),
                  );
                  return;
                }
                
                try {
                  final price = _isFree ? 0.0 : double.tryParse(_priceController.text) ?? 0.0;
                  
                  final request = CreateCourseRequest(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    price: price,
                    isFree: _isFree,
                  );
                  
                  await ref.read(allCoursesProvider.notifier).createCourse(request);
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Course created successfully')),
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
              child: const Text(AppStrings.create),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditCourseDialog(Course course) {
    final _titleController = TextEditingController(text: course.title);
    final _descriptionController = TextEditingController(text: course.description);
    final _priceController = TextEditingController(text: course.price.toStringAsFixed(2));
    bool _isFree = course.isFree;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _isFree,
                      onChanged: (value) {
                        setState(() {
                          _isFree = value ?? false;
                        });
                      },
                    ),
                    const Text('Free course'),
                  ],
                ),
                if (!_isFree) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price ($)',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and description are required')),
                  );
                  return;
                }
                
                try {
                  final price = _isFree ? 0.0 : double.tryParse(_priceController.text) ?? 0.0;
                  
                  final request = UpdateCourseRequest(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    price: price,
                    isFree: _isFree,
                  );
                  
                  await ref.read(allCoursesProvider.notifier).updateCourse(course.id, request);
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Course updated successfully')),
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
              child: const Text(AppStrings.update),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDeleteCourseDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(allCoursesProvider.notifier).deleteCourse(course.id);
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Course deleted successfully')),
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
