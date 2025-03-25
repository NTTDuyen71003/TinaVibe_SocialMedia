import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/components/post_tile.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/en.dart';
import 'package:flutter_firebase_mxh_tinavibe/translations/vi.dart';
import 'package:get/get.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  //post cubit
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  Future<void> fetchAllPosts() async {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  String translate(String key) {
    final locale = Get.locale?.languageCode; // Get current locale
    if (locale == 'vi') {
      return vi[key] ?? key; // Return Vietnamese translation if available
    } else {
      return en[key] ?? key; // Return English translation if available
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Bảng tin"),
      //   actions: [
      //     // Upload new post button
      //     IconButton(
      //       onPressed: () => Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => const UploadPostPage(),
      //         ),
      //       ),
      //       icon: const Icon(Icons.add),
      //     ),
      //   ],
      // ),
      body: RefreshIndicator(
        onRefresh: fetchAllPosts, // triggers refresh when pulled down
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            if (state is PostsLoading && state is PostUploading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PostsLoaded) {
              final allPosts = state.posts;

              if (allPosts.isEmpty) {
                return Center(
                  child: Text(translate('post_valid')),
                );
              }

              return ListView.builder(
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  //get individual post
                  final post = allPosts[index];
                  //image
                  return PostTile(
                    post: post,
                    onDeletePressed: () => deletePost(post.id),
                  );
                },
              );
            } else if (state is PostsError) {
              return Center(child: Text(state.message));
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
