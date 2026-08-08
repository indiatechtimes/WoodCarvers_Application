import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../widgets/star_rating.dart';
import '../../../data/repositories/review_repository.dart';
import '../controllers/reviews_controller.dart';

class ReviewSection extends StatelessWidget {
  final ReviewsController controller;
  const ReviewSection({super.key, required this.controller});

  void _showLightbox(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Get.back(),
          child: InteractiveViewer(child: CachedNetworkImage(imageUrl: url)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Obx(() {
        final total = controller.total;
        final avg = controller.average;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REVIEWS',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What buyers are saying',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            if (total > 0)
              Row(
                children: [
                  StarRating(value: avg, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    avg.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    ' · $total review${total != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              )
            else
              const Text(
                'No reviews yet — a buyer will be the first to share their thoughts.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
            if (total > 0) ...[
              const SizedBox(height: 16),
              for (var s = 5; s >= 1; s--)
                _distributionRow(s, controller.distribution[s] ?? 0, total),
            ],
            const SizedBox(height: 28),
            const Text(
              'SHARE YOUR THOUGHTS',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (!auth.isLoggedIn) {
                return const Text(
                  'Sign in to leave a review.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                );
              }
              if (!controller.canReview.value) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Only buyers of this piece can post a review. Once your order is marked paid, this form will unlock.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                );
              }
              return _reviewForm(context);
            }),
            const SizedBox(height: 32),
            const Text(
              'ALL REVIEWS',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            if (controller.reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Reviews will appear here.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                ),
              )
            else
              for (final r in controller.reviews) _reviewItem(context, r, auth),
          ],
        );
      }),
    );
  }

  Widget _distributionRow(int star, int count, int total) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(
              '$star',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 5,
                backgroundColor: AppColors.muted,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => StarPicker(
            value: controller.formRating.value,
            onChanged: (v) => controller.formRating.value = v,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: controller.formTitle.value,
          onChanged: (v) => controller.formTitle.value = v,
          decoration: const InputDecoration(hintText: 'Title (optional)'),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: controller.formBody.value,
          onChanged: (v) => controller.formBody.value = v,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'How does it feel in your home?',
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < controller.formPhotos.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: controller.formPhotos[i].url,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => controller.removePhoto(i),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              if (controller.formPhotos.length < ReviewsController.maxPhotos)
                GestureDetector(
                  onTap: controller.uploading.value
                      ? null
                      : controller.addPhoto,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 18,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.uploading.value ? '…' : 'Add photo',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Up to 2 photos — help others see the piece in a real home.',
          style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 14),
        Obx(
          () => ElevatedButton(
            onPressed: controller.submitting.value ? null : controller.submit,
            child: Text(
              controller.submitting.value
                  ? 'Posting…'
                  : controller.alreadyReviewed.value
                  ? 'Update review'
                  : 'Post review',
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewItem(BuildContext context, ReviewModel r, AuthController auth) {
    final canDelete =
        auth.user.value != null &&
        (auth.user.value!.id == r.userId || auth.isAdmin);
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StarRating(value: r.rating.toDouble(), size: 14),
              if (r.verified) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 11,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'VERIFIED BUYER',
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 1,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (canDelete)
                GestureDetector(
                  onTap: () => _confirmDelete(context, r.id),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.mutedForeground,
                  ),
                ),
            ],
          ),
          if (r.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              r.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            r.body,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.foreground,
              height: 1.5,
            ),
          ),
          if (r.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final photo in r.photos)
                  GestureDetector(
                    onTap: () => _showLightbox(context, photo.url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: photo.url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '${r.userName} · ${r.createdAt != null ? DateFormat('d MMM y').format(r.createdAt!) : ''}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this review?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.delete(reviewId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
