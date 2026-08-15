// import 'dart:io';
// import 'package:dio/dio.dart';
// import '../providers/api_provider.dart';

// class ReviewPhoto {
//   final String url;
//   final String publicId;
//   ReviewPhoto({required this.url, required this.publicId});

//   factory ReviewPhoto.fromJson(Map<String, dynamic> json) =>
//       ReviewPhoto(url: json['url'] ?? '', publicId: json['publicId'] ?? '');

//   Map<String, dynamic> toJson() => {'url': url, 'publicId': publicId};
// }

// class ReviewModel {
//   final String id;
//   final String userId;
//   final String userName;
//   final int rating;
//   final String title;
//   final String body;
//   final List<ReviewPhoto> photos;
//   final bool verified;
//   final DateTime? createdAt;

//   ReviewModel({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     required this.rating,
//     this.title = '',
//     required this.body,
//     this.photos = const [],
//     this.verified = false,
//     this.createdAt,
//   });

//   factory ReviewModel.fromJson(Map<String, dynamic> json) {
//     return ReviewModel(
//       id: json['_id'] ?? '',
//       userId: json['user'] ?? '',
//       userName: json['userName'] ?? '',
//       rating: json['rating'] ?? 5,
//       title: json['title'] ?? '',
//       body: json['body'] ?? '',
//       photos: (json['photos'] as List? ?? []).map((p) => ReviewPhoto.fromJson(p)).toList(),
//       verified: json['verified'] ?? false,
//       createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
//     );
//   }
// }

// class ReviewSummary {
//   final List<ReviewModel> reviews;
//   final Map<int, int> distribution;
//   final bool canReview;
//   final bool alreadyReviewed;

//   ReviewSummary({
//     required this.reviews,
//     required this.distribution,
//     required this.canReview,
//     required this.alreadyReviewed,
//   });
// }

// class ReviewRepository {
//   final _api = ApiProvider().dio;

//   Future<ReviewSummary> listReviews(String productId) async {
//     final res = await _api.get('/products/$productId/reviews');
//     final dist = <int, int>{};
//     final rawDist = res.data['distribution'] as Map? ?? {};
//     for (var i = 1; i <= 5; i++) {
//       dist[i] = rawDist['$i'] ?? rawDist[i] ?? 0;
//     }
//     return ReviewSummary(
//       reviews: (res.data['reviews'] as List? ?? []).map((r) => ReviewModel.fromJson(r)).toList(),
//       distribution: dist,
//       canReview: res.data['canReview'] == true,
//       alreadyReviewed: res.data['alreadyReviewed'] == true,
//     );
//   }

//   Future<void> submitReview(
//     String productId, {
//     required int rating,
//     String title = '',
//     required String body,
//     List<ReviewPhoto> photos = const [],
//   }) async {
//     await _api.post('/products/$productId/reviews', data: {
//       'rating': rating,
//       'title': title,
//       'body': body,
//       'photos': photos.map((p) => p.toJson()).toList(),
//     });
//   }

//   Future<void> deleteReview(String reviewId) async {
//     await _api.delete('/reviews/$reviewId');
//   }

//   Future<ReviewPhoto> uploadReviewPhoto(File file) async {
//     final formData = FormData.fromMap({
//       'file': await MultipartFile.fromFile(file.path),
//     });
//     final res = await _api.post('/media/upload/review', data: formData);
//     final media = res.data['media'];
//     return ReviewPhoto(url: media['url'], publicId: media['publicId']);
//   }
// }

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/api_provider.dart';

class ReviewPhoto {
  final String url;
  final String publicId;
  ReviewPhoto({required this.url, required this.publicId});

  factory ReviewPhoto.fromJson(Map<String, dynamic> json) =>
      ReviewPhoto(url: json['url'] ?? '', publicId: json['publicId'] ?? '');

  Map<String, dynamic> toJson() => {'url': url, 'publicId': publicId};
}

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String title;
  final String body;
  final List<ReviewPhoto> photos;
  final bool verified;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.title = '',
    required this.body,
    this.photos = const [],
    this.verified = false,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      userName: json['userName'] ?? '',
      rating: json['rating'] ?? 5,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      photos: (json['photos'] as List? ?? [])
          .map((p) => ReviewPhoto.fromJson(p))
          .toList(),
      verified: json['verified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

class ReviewSummary {
  final List<ReviewModel> reviews;
  final Map<int, int> distribution;
  final bool canReview;
  final bool alreadyReviewed;

  ReviewSummary({
    required this.reviews,
    required this.distribution,
    required this.canReview,
    required this.alreadyReviewed,
  });
}

class ReviewRepository {
  final _api = ApiProvider().dio;

  Future<ReviewSummary> listReviews(String productId) async {
    final res = await _api.get('/products/$productId/reviews');
    final dist = <int, int>{};
    final rawDist = res.data['distribution'] as Map? ?? {};
    for (var i = 1; i <= 5; i++) {
      dist[i] = rawDist['$i'] ?? rawDist[i] ?? 0;
    }
    return ReviewSummary(
      reviews: (res.data['reviews'] as List? ?? [])
          .map((r) => ReviewModel.fromJson(r))
          .toList(),
      distribution: dist,
      canReview: res.data['canReview'] == true,
      alreadyReviewed: res.data['alreadyReviewed'] == true,
    );
  }

  Future<void> submitReview(
    String productId, {
    required int rating,
    String title = '',
    required String body,
    List<ReviewPhoto> photos = const [],
  }) async {
    await _api.post(
      '/products/$productId/reviews',
      data: {
        'rating': rating,
        'title': title,
        'body': body,
        'photos': photos.map((p) => p.toJson()).toList(),
      },
    );
  }

  Future<void> deleteReview(String reviewId) async {
    await _api.delete('/reviews/$reviewId');
  }

  Future<ReviewPhoto> uploadReviewPhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
    });
    final res = await _api.post('/media/upload/review', data: formData);
    final media = res.data['media'];
    return ReviewPhoto(url: media['url'], publicId: media['publicId']);
  }
}
