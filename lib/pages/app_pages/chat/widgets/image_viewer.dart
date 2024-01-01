import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String imageURL;
  const ImageViewer({super.key, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7.5)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CachedNetworkImage(
          fadeInCurve: Curves.linear,
          imageUrl: imageURL,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
