import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HeroImageViewer extends StatelessWidget {
  final String imageURL;
  final String heroTag;
  const HeroImageViewer(
      {super.key, required this.imageURL, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(220, 0, 0, 0),
        title: const Text(
          "image",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Center(
          child: InteractiveViewer(
            child: Image(
              image: CachedNetworkImageProvider(imageURL),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
