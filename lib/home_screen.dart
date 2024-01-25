import 'package:example_project/controllers/blog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _value;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildListDelegate([
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var blog in ref.watch(blogNotifierProvider).blogs)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ChoiceChip(
                        label: Text(blog!.name),
                        selected: _value == blog.id,
                        onSelected: (bool selected) {
                          setState(() {
                            _value = selected ? blog.id : null;
                          });
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
                        context.push('/blog-settings');
                      }),
                ],
              ),
            ),
          ])),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              Text(
                'Posts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton(
                  onPressed: () {
                    print(ref.read(blogNotifierProvider).blogs);
                  },
                  child: const Text("göster")),
              ElevatedButton(
                  onPressed: () {
                    ref.read(blogNotifierProvider.notifier).createPost(
                          "test post",
                          ref.read(blogNotifierProvider).blogs[0],
                        );
                  },
                  child: const Text('Create Post'))
            ])),
          ),
        ],
      ),
    );
  }
}
