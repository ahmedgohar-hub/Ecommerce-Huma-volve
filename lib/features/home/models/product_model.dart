import 'package:flutter/material.dart';
import '../../../core/dummy_data.dart';
import 'category_model.dart';

class ProductModel extends Product {
  final int rawId;
  final CategoryModel? category;
  final List<String> images;

  ProductModel({
    required this.rawId,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.colors,
    required super.sizes,
    this.category,
    this.images = const [],
  }) : super(id: rawId.toString());

  static String cleanUrl(dynamic input) {
    if (input == null) return '';
    String raw = input.toString().trim();
    raw = raw.replaceAll('[', '').replaceAll(']', '');
    raw = raw.replaceAll('"', '').replaceAll("'", '');
    raw = raw.replaceAll(r'\', '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    return '';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> cleanedImages = [];
    if (rawImages is List) {
      for (final img in rawImages) {
        final cleaned = cleanUrl(img);
        if (cleaned.isNotEmpty) {
          cleanedImages.add(cleaned);
        }
      }
    }

    const defaultFallbackUrl =
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600';
    final primaryImageUrl = cleanedImages.isNotEmpty
        ? cleanedImages.first
        : defaultFallbackUrl;

    CategoryModel? cat;
    if (json['category'] is Map<String, dynamic>) {
      cat = CategoryModel.fromJson(json['category'] as Map<String, dynamic>);
    }

    final num? priceNum = json['price'] as num?;
    final double parsedPrice = priceNum?.toDouble() ?? 0.0;

    return ProductModel(
      rawId: json['id'] as int? ?? 0,
      name: json['title'] as String? ?? 'Product',
      description: json['description'] as String? ?? 'No description available.',
      price: parsedPrice,
      imageUrl: primaryImageUrl,
      category: cat,
      images: cleanedImages.isNotEmpty ? cleanedImages : [defaultFallbackUrl],
      colors: const [
        Color(0xFF2B2D42),
        Color(0xFF8D99AE),
        Color(0xFFD90429),
        Color(0xFFEF233C),
      ],
      sizes: const ['S', 'M', 'L', 'XL'],
    );
  }
}
