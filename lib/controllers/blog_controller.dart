// ignore_for_file: public_member_api_docs, sort_constructors_first

import "dart:async";

import "package:amplify_api/amplify_api.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:example_project/controllers/comment_controller.dart";
import "package:example_project/models/ModelProvider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class Nullable<T> {
  const Nullable.value(this.value);
  final T? value;
}

class BlogState {
  final List<Blog?> blogs;
  final List<Post?> posts;
  final Nullable<Post?> selectedPost;
  final bool isLoading;
  final bool hasError;

  BlogState({
    required this.blogs,
    required this.posts,
    required this.selectedPost,
    required this.isLoading,
    required this.hasError,
  });

  BlogState copyWith({
    List<Blog?>? blogs,
    List<Post?>? posts,
    Nullable<Post?>? selectedPost,
    bool? isLoading,
    bool? hasError,
  }) {
    return BlogState(
      blogs: blogs ?? this.blogs,
      posts: posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

final blogNotifierProvider = NotifierProvider<BlogNotifier, BlogState>(
  BlogNotifier.new,
);

class BlogNotifier extends Notifier<BlogState> {
  @override
  BlogState build() {
    debugPrint("TodoNotifier initialized");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getBlogs();
    });

    return BlogState(
      blogs: [],
      posts: [],
      isLoading: false,
      hasError: false,
      selectedPost: const Nullable.value(null),
    );
  }

  Future<void> getBlogs() async {
    print("called get blogs");
    state = state.copyWith(isLoading: true);
    final request = ModelQueries.list(
      Blog.classType,
      // where: Blog.NAME.beginsWith("v"),
    );

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

  Future<void> createBlog(String? name) async {
    final request = ModelMutations.create(Blog(name: name!));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("create result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> deleteBlog(String? id) async {
    if (id == null) {
      return;
    }

    final request =
        ModelMutations.deleteById(Blog.classType, BlogModelIdentifier(id: id));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("delete result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> updateBlog(Blog blog) async {
    final request = ModelMutations.update(blog);
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("update result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> createPost(String? name, Blog? selectedBlog) async {
    final request =
        ModelMutations.create(Post(title: name!, blog: selectedBlog));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("create result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> getPosts(Blog? selectedBlog) async {
    state = state.copyWith(isLoading: true);

    final request = ModelQueries.list(
      Post.classType,
      where: QueryPredicateGroup(
        QueryPredicateGroupType.and,
        [
          Post.BLOG.eq(selectedBlog?.id),
        ],
      ),
    );
    final response = await Amplify.API.query(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("Get result: ${response.data?.items.length}");
      state = state.copyWith(posts: response.data!.items, isLoading: false);
    }
  }

  Future<void> getSelectedPost(String? postId) async {
    state = state.copyWith(
      isLoading: true,
      selectedPost: const Nullable.value(null),
    );

    final request = ModelQueries.list(
      Post.classType,
      where: Post.ID.eq(postId),
    );

    // Custom Document
    const customDocument =
        r"""query listPosts($filter: ModelPostFilterInput, $limit: Int, $nextToken: String) {
  listPosts(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      id
      title
      createdAt
      updatedAt
      blog {
        id
        name
        createdAt
        updatedAt
      }
      blogPostsId
      comments {
        items {
          content
          createdAt
          updatedAt
          id
        }
      }
    }
    nextToken
  }
}""";

    final customRequest = GraphQLRequest<PaginatedResult<Post>>(
      document: customDocument,
      apiName: request.apiName,
      authorizationMode: request.authorizationMode,
      variables: request.variables,
      headers: request.headers,
      decodePath: request.decodePath,
      modelType: request.modelType,
    );

    final response = await Amplify.API.query(request: customRequest).response;

    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("Get result: ${response.data?.items.length}");
      state = state.copyWith(
        selectedPost: Nullable.value(response.data!.items.first),
        isLoading: false,
      );

      unawaited(
        ref.read(commentNotifierProvider.notifier).getComments(postId),
      );
    }
  }
}
