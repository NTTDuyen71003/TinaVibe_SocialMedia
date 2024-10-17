import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/home/presentation/components/my_drawer.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/components/post_tile.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/cubits/post_states.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          //upload new post button
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadPostPage(),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: RefreshIndicator(
        onRefresh: fetchAllPosts, // triggers refresh when pulled down
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            if (state is PostsLoading && state is PostUploading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PostsLoaded) {
              final allPosts = state.posts;

              if (allPosts.isEmpty) {
                return const Center(
                  child: Text("No posts available"),
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
