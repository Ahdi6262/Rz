import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hex_the_add_hub/constants/strings.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/portfolio_item.dart';
import 'package:hex_the_add_hub/providers/portfolio_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioItemScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  final PortfolioItem? item;

  const PortfolioItemScreen({
    Key? key,
    required this.isEditing,
    this.item,
  }) : super(key: key);

  @override
  ConsumerState<PortfolioItemScreen> createState() => _PortfolioItemScreenState();
}

class _PortfolioItemScreenState extends ConsumerState<PortfolioItemScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _technologiesController = TextEditingController();
  
  List<String> _technologies = [];
  List<String> _imageUrls = [];
  
  bool _isLoading = false;
  bool _isViewMode = false;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.item != null) {
      // Set view mode initially for editing existing items
      _isViewMode = true;
      
      // Initialize controllers with existing data
      _titleController.text = widget.item!.title;
      _descriptionController.text = widget.item!.description;
      _projectUrlController.text = widget.item!.projectUrl ?? '';
      _githubUrlController.text = widget.item!.githubUrl ?? '';
      _technologies = List<String>.from(widget.item!.technologies);
      _imageUrls = List<String>.from(widget.item!.imageUrls);
      
      // Join technologies for the text field
      _technologiesController.text = _technologies.join(', ');
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectUrlController.dispose();
    _githubUrlController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }
  
  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Parse comma-separated technologies
        _technologies = _technologiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        
        if (widget.isEditing && widget.item != null) {
          // Update existing project
          final request = UpdatePortfolioItemRequest(
            title: _titleController.text,
            description: _descriptionController.text,
            technologies: _technologies,
            imageUrls: _imageUrls,
            projectUrl: _projectUrlController.text.isEmpty ? null : _projectUrlController.text,
            githubUrl: _githubUrlController.text.isEmpty ? null : _githubUrlController.text,
          );
          
          await ref.read(portfolioProvider.notifier).updateProject(widget.item!.id!, request);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.projectSaved)),
            );
            setState(() {
              _isViewMode = true;
            });
          }
        } else {
          // Create new project
          final request = CreatePortfolioItemRequest(
            title: _titleController.text,
            description: _descriptionController.text,
            technologies: _technologies,
            imageUrls: _imageUrls,
            projectUrl: _projectUrlController.text.isEmpty ? null : _projectUrlController.text,
            githubUrl: _githubUrlController.text.isEmpty ? null : _githubUrlController.text,
          );
          
          final newProject = await ref.read(portfolioProvider.notifier).createProject(request);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.projectSaved)),
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
  
  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project? This action cannot be undone.'),
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
    
    if (confirmed == true && widget.item != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await ref.read(portfolioProvider.notifier).deleteProject(widget.item!.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.projectDeleted)),
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
  
  Future<void> _addImage() async {
    // In a real app, you would use image_picker to select an image
    // For this sample, we'll just add a placeholder URL
    setState(() {
      _imageUrls.add('https://via.placeholder.com/300');
    });
  }
  
  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }
  
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isViewMode 
          ? widget.item?.title ?? '' 
          : widget.isEditing 
            ? AppStrings.editProject 
            : AppStrings.addProject),
        actions: widget.isEditing && widget.item != null
          ? [
              // Toggle between view and edit modes
              IconButton(
                icon: Icon(_isViewMode ? Icons.edit : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _isViewMode = !_isViewMode;
                  });
                },
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _isLoading ? null : _deleteProject,
              ),
            ]
          : null,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _isViewMode && widget.item != null
          ? _buildViewMode()
          : _buildEditMode(),
      bottomNavigationBar: _isViewMode || _isLoading
        ? null
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveProject,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  widget.isEditing ? AppStrings.update : AppStrings.save,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
    );
  }
  
  Widget _buildViewMode() {
    final item = widget.item!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Images
          if (item.imageUrls.isNotEmpty)
            SizedBox(
              height: 200,
              child: FadeInRight(
                duration: const Duration(milliseconds: 500),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrls[index],
                          height: 200,
                          width: 280,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: 280,
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
                    );
                  },
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Title
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 100),
            child: Text(
              item.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Technologies
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.technologies,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.technologies.map((tech) {
                    return Chip(
                      label: Text(tech),
                      backgroundColor: primaryColor.withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Links
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.projectUrl != null && item.projectUrl!.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link),
                    title: const Text('Project URL'),
                    subtitle: Text(item.projectUrl!),
                    onTap: () => _launchUrl(item.projectUrl!),
                  ),
                
                if (item.githubUrl != null && item.githubUrl!.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.code),
                    title: const Text('GitHub URL'),
                    subtitle: Text(item.githubUrl!),
                    onTap: () => _launchUrl(item.githubUrl!),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Created & Updated
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Created: ${item.createdAt.toLocal().toString().split('.')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 450),
            child: Text(
              'Updated: ${item.updatedAt.toLocal().toString().split('.')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
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
                labelText: AppStrings.projectTitle,
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
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.projectDescription,
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Technologies
            TextFormField(
              controller: _technologiesController,
              decoration: const InputDecoration(
                labelText: AppStrings.technologies,
                prefixIcon: Icon(Icons.code),
                hintText: 'Flutter, Dart, Firebase, etc.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter at least one technology';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Project URL
            TextFormField(
              controller: _projectUrlController,
              decoration: const InputDecoration(
                labelText: AppStrings.projectUrl,
                prefixIcon: Icon(Icons.link),
                hintText: 'https://example.com',
              ),
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 16),
            
            // GitHub URL
            TextFormField(
              controller: _githubUrlController,
              decoration: const InputDecoration(
                labelText: AppStrings.githubUrl,
                prefixIcon: Icon(Icons.code),
                hintText: 'https://github.com/username/repo',
              ),
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 24),
            
            // Images
            Text(
              AppStrings.addImages,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Image preview grid
            if (_imageUrls.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            
            const SizedBox(height: 16),
            
            // Add image button
            Center(
              child: ElevatedButton.icon(
                onPressed: _addImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text(AppStrings.addImages),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
