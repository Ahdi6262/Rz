import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_the_add_hub/models/portfolio_item.dart';
import 'package:hex_the_add_hub/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final portfolioProvider = StateNotifierProvider<PortfolioNotifier, AsyncValue<List<PortfolioItem>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PortfolioNotifier(apiService);
});

final selectedPortfolioItemProvider = StateProvider<PortfolioItem?>((ref) => null);

class PortfolioNotifier extends StateNotifier<AsyncValue<List<PortfolioItem>>> {
  final ApiService _apiService;

  PortfolioNotifier(this._apiService) : super(const AsyncValue.loading()) {
    getProjects();
  }

  Future<void> getProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _apiService.getPortfolioItems();
      state = AsyncValue.data(projects);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<PortfolioItem> getProjectById(String id) async {
    try {
      return await _apiService.getPortfolioItemById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<PortfolioItem> createProject(CreatePortfolioItemRequest request) async {
    try {
      final newProject = await _apiService.createPortfolioItem(request);
      state = AsyncValue.data([...state.value!, newProject]);
      return newProject;
    } catch (e) {
      rethrow;
    }
  }

  Future<PortfolioItem> updateProject(String id, UpdatePortfolioItemRequest request) async {
    try {
      final updatedProject = await _apiService.updatePortfolioItem(id, request);
      state = AsyncValue.data(state.value!.map((project) {
        return project.id == id ? updatedProject : project;
      }).toList());
      return updatedProject;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _apiService.deletePortfolioItem(id);
      state = AsyncValue.data(state.value!.where((project) => project.id != id).toList());
    } catch (e) {
      rethrow;
    }
  }
}
