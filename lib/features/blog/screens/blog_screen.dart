import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/post_model.dart';
import 'create_post_screen.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final posts = provider.posts;
    final isDeputy = provider.currentUser?.isDeputy ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Новости и публикации'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: isDeputy ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen())),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Новая публикация', style: TextStyle(color: Colors.white)),
      ) : null,
      body: posts.isEmpty
          ? const Center(child: Text('Публикаций нет', style: TextStyle(color: AppColors.textGrey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (ctx, i) => _PostCard(post: posts[i]),
            ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final dateStr = DateFormat('dd.MM.yyyy').format(post.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.backgroundBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue, radius: 18,
              child: Text(post.deputyName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.deputyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(dateStr, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ])),
            Icon(Icons.verified, color: AppColors.primaryBlue, size: 18),
          ]),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(post.content, style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5)),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, children: post.tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.backgroundBlue, borderRadius: BorderRadius.circular(10)),
                child: Text('#$t', style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue)),
              )).toList()),
            ],
          ]),
        ),
        // Actions
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Row(children: [
            GestureDetector(
              onTap: () => provider.likePost(post.id),
              child: Row(children: [
                const Icon(Icons.thumb_up_outlined, size: 18, color: AppColors.textGrey),
                const SizedBox(width: 4),
                Text('${post.likes}', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
              ]),
            ),
            const SizedBox(width: 16),
            Row(children: [
              const Icon(Icons.comment_outlined, size: 18, color: AppColors.textGrey),
              const SizedBox(width: 4),
              Text('${post.comments}', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
            ]),
            const Spacer(),
            IconButton(icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textGrey), onPressed: () {}),
          ]),
        ),
      ]),
    );
  }
}
