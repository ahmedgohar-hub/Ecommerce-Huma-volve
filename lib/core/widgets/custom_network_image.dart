import 'package:flutter/material.dart';
import '../theme.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  bool get _isValidUrl {
    final trimmed = imageUrl.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    Widget imageContent;

    if (!_isValidUrl) {
      imageContent = errorWidget ?? _buildDefaultError();
    } else {
      imageContent = Image.network(
        imageUrl.trim(),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey.shade100,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppTheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 28,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
