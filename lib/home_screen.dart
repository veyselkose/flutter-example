// ignore_for_file: public_member_api_docs

import "package:example_project/controllers/blog_controller.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/date_symbol_data_local.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _value;
  @override
  void initState() {
    initializeDateFormatting("tr_TR", null);
    initializeDateFormatting("en_US", null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              // Refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref.read(blogNotifierProvider.notifier).getBlogs();
                    },
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Consumer(
                  builder: (_, WidgetRef ref, __) {
                    final blogs = ref.watch(
                      blogNotifierProvider.select((value) => value.blogs),
                    );
                    return Row(
                      children: [
                        for (final blog in blogs)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: ChoiceChip(
                              label: Text(blog!.name),
                              selected: _value == blog.id,
                              onSelected: (bool selected) {
                                ref
                                    .read(blogNotifierProvider.notifier)
                                    .getPosts(blog);
                              },
                            ),
                          ),
                        const SizedBox(
                          width: 4,
                        ),
                        ActionChip(
                          label: const Icon(
                            Icons.tune_rounded,
                            size: 20,
                          ),
                          onPressed: () {
                            context.push("/blog-settings");
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    "Posts",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Consumer(
                    builder: (_, WidgetRef ref, __) {
                      final posts = ref.watch(
                        blogNotifierProvider.select((value) => value.posts),
                      );

                      if (posts.isEmpty) {
                        return const Center(
                          child: Text("No posts"),
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                context.push(
                                  "/post/${posts[index]?.id}",
                                );
                              },
                              title: Text(posts[index]?.title ?? ""),
                              subtitle: Text(posts[index]?.id ?? ""),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
