//import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../data/repositories/review_repository.dart';

class ReviewsController extends GetxController {
  final String productId;
  final double initialRating;
  final int initialCount;
  ReviewsController({required this.productId, this.initialRating = 0, this.initialCount = 0});

  final _repo = ReviewRepository();

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxMap<int, int> distribution = <int, int>{}.obs;
  final RxBool canReview = false.obs;
  final RxBool alreadyReviewed = false.obs;
  final RxBool loading = true.obs;

  // Form state
  final RxInt formRating = 5.obs;
  final RxString formTitle = ''.obs;
  final RxString formBody = ''.obs;
  final RxList<ReviewPhoto> formPhotos = <ReviewPhoto>[].obs;
  final RxBool uploading = false.obs;
  final RxBool submitting = false.obs;

  static const maxPhotos = 2;

  double get average {
    if (reviews.isEmpty) return initialRating;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  int get total => reviews.isNotEmpty ? reviews.length : (reviews.isEmpty && initialCount > 0 ? initialCount : 0);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final summary = await _repo.listReviews(productId);
      reviews.value = summary.reviews;
      distribution.value = summary.distribution;
      canReview.value = summary.canReview;
      alreadyReviewed.value = summary.alreadyReviewed;

      final auth = Get.find<AuthController>();
      final mine = auth.user.value != null
          ? summary.reviews.firstWhereOrNull((r) => r.userId == auth.user.value!.id)
          : null;
      if (mine != null) {
        formRating.value = mine.rating;
        formTitle.value = mine.title;
        formBody.value = mine.body;
        formPhotos.value = mine.photos;
      }
    } catch (_) {
      Get.snackbar('Error', 'Could not load reviews', snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  Future<void> addPhoto() async {
    if (formPhotos.length >= maxPhotos) {
      Get.snackbar('Limit reached', 'Max $maxPhotos photos per review', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    uploading.value = true;
    try {
      final photo = await _repo.uploadReviewPhoto(picked);
      formPhotos.add(photo);
    } catch (_) {
      Get.snackbar('Error', 'Upload failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      uploading.value = false;
    }
  }

  void removePhoto(int index) => formPhotos.removeAt(index);

  Future<void> submit() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.snackbar('Sign in required', 'Sign in to leave a review', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (formBody.value.trim().isEmpty) {
      Get.snackbar('Review required', 'Please write your review', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    submitting.value = true;
    try {
      await _repo.submitReview(
        productId,
        rating: formRating.value,
        title: formTitle.value,
        body: formBody.value,
        photos: formPhotos,
      );
      Get.snackbar(alreadyReviewed.value ? 'Review updated' : 'Review posted', '', snackPosition: SnackPosition.BOTTOM);
      await load();
    } catch (_) {
      Get.snackbar('Error', 'Could not post review', snackPosition: SnackPosition.BOTTOM);
    } finally {
      submitting.value = false;
    }
  }

  Future<void> delete(String reviewId) async {
    try {
      await _repo.deleteReview(reviewId);
      formTitle.value = '';
      formBody.value = '';
      formRating.value = 5;
      formPhotos.clear();
      Get.snackbar('Review deleted', '', snackPosition: SnackPosition.BOTTOM);
      await load();
    } catch (_) {
      Get.snackbar('Error', 'Could not delete review', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
