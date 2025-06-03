import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fmp_supplier_app/core/config/mapbox_config.dart';
import 'package:fmp_supplier_app/features/parties/domain/entities/party_entity.dart';

class PartyModel extends PartyEntity {
  const PartyModel({
    required String id,
    required String name,
    required String description,
    required String venue,
    required String genre,
    required double latitude,
    required double longitude,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String imageUrl,
    required String logoUrl,
    required double rating,
    required int reviewCount,
    required String priceCategory,
    required List<String> tags,
    required String ownerId,
    bool isFeatured = false,
  }) : super(
         id: id,
         name: name,
         description: description,
         venue: venue,
         genre: genre,
         latitude: latitude,
         longitude: longitude,
         date: date,
         startTime: startTime,
         endTime: endTime,
         imageUrl: imageUrl,
         logoUrl: logoUrl,
         rating: rating,
         reviewCount: reviewCount,
         priceCategory: priceCategory,
         tags: tags,
         isFeatured: isFeatured,
         ownerId: ownerId,
       );

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      venue: json['venue'] ?? '',
      genre: json['genre'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      priceCategory: json['priceCategory'] ?? '€',
      tags: List<String>.from(json['tags'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
      ownerId: json['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'venue': venue,
      'genre': genre,
      'latitude': latitude,
      'longitude': longitude,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'priceCategory': priceCategory,
      'tags': tags,
      'isFeatured': isFeatured,
      'ownerId': ownerId,
    };
  }

  factory PartyModel.empty({required String ownerId}) {
    return PartyModel(
      id: '',
      name: '',
      description: '',
      venue: '',
      genre: '',
      latitude: MapboxConfig.initialLatitude,
      longitude: MapboxConfig.initialLongitude,
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: '22:00',
      endTime: '04:00',
      imageUrl: '',
      logoUrl: '',
      rating: 0.0,
      reviewCount: 0,
      priceCategory: '€',
      tags: [],
      ownerId: ownerId,
    );
  }
}
