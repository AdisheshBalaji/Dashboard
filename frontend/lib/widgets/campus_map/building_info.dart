import 'package:dashbaord/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class BlockDetailsModal {
  static void show(
    BuildContext context, {
    required String blockName,
    required String description,
    required List<String> tags,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? imageUrls,
    String? primaryTag,
    String? mapLink,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => _BlockDetailsContent(
        blockName: blockName,
        description: description,
        tags: tags,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        primaryTag: primaryTag,
        mapLink: mapLink,
      ),
    );
  }
}

class _BlockDetailsContent extends StatelessWidget {
  final String blockName;
  final String description;
  final List<String> tags;
  final String? mapLink;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String>? imageUrls;
  final String? primaryTag;

  const _BlockDetailsContent({
    required this.blockName,
    required this.description,
    required this.tags,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.imageUrls,
    this.primaryTag,
    this.mapLink,
  });

  Future<void> _openGoogleMaps() async {
    if (latitude != null && longitude != null) {
      final url = Uri.parse(mapLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  List<String> get _allImages {
    final images = <String>[];
    if (imageUrl != null) images.add(imageUrl!);
    if (imageUrls != null) images.addAll(imageUrls!);
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: context.customColors.customContainerColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_allImages.isNotEmpty) ...[
                    _buildImageSection(),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    blockName,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                      height: 1.5,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (tags.isNotEmpty || primaryTag != null) ...[
                    Text(
                      'Tags',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.customColors.customTextColor
                            .withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTagsSection(context),
                    const SizedBox(height: 24),
                  ],
                  if (mapLink != null) ...[
                    const SizedBox(height: 16),
                    _buildMapButton(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (_allImages.length == 1) {
      return _buildSingleImage(_allImages.first);
    } else {
      return _buildImageCarousel();
    }
  }

  Widget _buildSingleImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image_rounded,
                size: 48,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: _allImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                _allImages[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    final allTags = <String>[];

    if (primaryTag != null) {
      allTags.add(primaryTag!);
    }

    for (final tag in tags) {
      if (tag != primaryTag) {
        allTags.add(tag);
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: allTags.map((tag) {
        final isPrimary = tag == primaryTag;
        return _buildTag(tag, context, isPrimary: isPrimary);
      }).toList(),
    );
  }

  Widget _buildTag(String tag, BuildContext context, {bool isPrimary = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: isPrimary ? 16 : 12,
        vertical: isPrimary ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: isPrimary
            ? context.customColors.customAccentColor
            : context.customColors.customAccentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(isPrimary ? 24 : 20),
        border: isPrimary
            ? null
            : Border.all(
                color: context.customColors.customAccentColor.withOpacity(0.2),
                width: 1,
              ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color:
                      context.customColors.customAccentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPrimary) ...[
            Icon(
              Icons.star_rounded,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            tag,
            style: GoogleFonts.inter(
              fontSize: isPrimary ? 13 : 12,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              color: isPrimary
                  ? Colors.white
                  : context.customColors.customAccentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.customColors.customAccentColor.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.customColors.customAccentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _openGoogleMaps,
        icon: const Icon(Icons.map_outlined, size: 20),
        label: Text(
          'View on Google Maps',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
