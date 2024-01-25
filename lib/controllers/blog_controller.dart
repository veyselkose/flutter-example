// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:example_project/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class BlogState {
  final List<Blog?> blogs;
  final bool isLoading;
  final bool hasError;
  BlogState({
    required this.blogs,
    required this.isLoading,
    required this.hasError,
  });

  BlogState copyWith({
    List<Blog?>? blogs,
    bool? isLoading,
    bool? hasError,
  }) {
    return BlogState(
      blogs: blogs ?? this.blogs,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  String toString() =>
      'BlogState(blogs: $blogs, isLoading: $isLoading, hasError: $hasError)';
}

final blogNotifierProvider =
    StateNotifierProvider<BlogNotifier, BlogState>((final ref) {
  return BlogNotifier();
});

class BlogNotifier extends StateNotifier<BlogState> {
  BlogNotifier()
      : super(
          BlogState(
            blogs: [],
            isLoading: false,
            hasError: false,
          ),
        ) {
    debugPrint("TodoNotifier initialized");
    getBlogs();
  }

  // Future getBlogs() async {
  //   state = state.copyWith(isLoading: true);
  //   final request = ModelQueries.list(Blog.classType);
  //   final response = await Amplify.API.query(request: request).response;
  //   if (response.hasErrors) {
  //     debugPrint(response.errors.toString());
  //     state = state.copyWith(isLoading: true);
  //   } else {
  //     if (response.data != null) {
  //       state = state.copyWith(
  //         blogs: response.data!.items,
  //         isLoading: false,
  //       );
  //     }
  //   }
  // }
  Future getBlogs() async {
    state = state.copyWith(isLoading: true);
    final request = ModelQueries.list(Blog.classType);

    print(request.document);

    final response = await Amplify.API.query(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
      state = state.copyWith(isLoading: true);
    } else {
      if (response.data != null) {
        state = state.copyWith(
          blogs: response.data!.items,
          isLoading: false,
        );
      }
    }
  }

  Future createBlog(String? name) async {
    final request = ModelMutations.create(Blog(name: name!));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint('Create result: $response');
      await getBlogs();
    }
  }

  Future deleteBlog(id) async {
    final request =
        ModelMutations.deleteById(Blog.classType, BlogModelIdentifier(id: id));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint('Delete result: $response');
      await getBlogs();
    }
  }

  Future updateBlog(Blog blog) async {
    final request = ModelMutations.update(blog);
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint('Update result: $response');
      await getBlogs();
    }
  }

  Future createPost(String? name, Blog? selectedBlog) async {
    final request =
        ModelMutations.create(Post(title: name!, blog: selectedBlog));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint('Create result: $response');
      await getBlogs();
    }
  }
}
