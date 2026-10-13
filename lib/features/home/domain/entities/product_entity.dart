import '../../../../core/dummy_data.dart';
import 'category_entity.dart';

class ProductEntity extends Product {
  final int rawId;
  final CategoryEntity? category;
  final List<String> images;

  ProductEntity({
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
}
