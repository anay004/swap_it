import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String? email;
  final String? name;
  final String? price;
  final String? description;
  final String? productImage;
  final int? likes;
  final DateTime? dateCreated;
  final List<String> likedBy;
  final List<String>? comments;
  final List<String>? commentBy;

  PostModel({
    this.email,
    this.name,
    this.price,
    this.description,
    this.productImage,
    this.likes = 0,
    this.dateCreated,
    this.likedBy = const [],
    this.comments = const [],
    this.commentBy = const [],
  });

  factory PostModel.fromjson(Map<String, dynamic> json) {
    return PostModel(
      email: json['email'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      productImage: json['productImage'],
      likes: json['likes'] ?? 0,
      dateCreated: (json['dateCreated'] as Timestamp?)?.toDate(),
      likedBy: List<String>.from(json['likedBy'] ?? []),
      comments: List<String>.from(json['comments'] ?? []),
      commentBy: List<String>.from(json['commentBy'] ?? []),
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'email': email,
      'name': name,
      'price': price,
      'description': description,
      'productImage': productImage,
      'likes': likes,
      'dateCreated': dateCreated ?? FieldValue.serverTimestamp(),
      'likedBy': likedBy,
      'comments': comments,
      'commentBy': commentBy,
    };
  }

  // Add copyWith method
  PostModel copyWith({
    String? email,
    String? name,
    String? price,
    String? description,
    String? productImage,
    int? likes,
    DateTime? dateCreated,
    List<String>? likedBy,
    List<String>? comments,
    List<String>? commentBy,
  }) {
    return PostModel(
      email: email ?? this.email,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      productImage: productImage ?? this.productImage,
      likes: likes ?? this.likes,
      dateCreated: dateCreated ?? this.dateCreated,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
      commentBy: commentBy ?? this.commentBy,
    );
  }
}
