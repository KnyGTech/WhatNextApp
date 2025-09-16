import 'package:flutter/material.dart';


class ImageBanner extends StatelessWidget {
  final String path;
  final double? size;

  const ImageBanner(this.path, {super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.network(path,
        width: size ?? 130,
        loadingBuilder: ((context, child, loadingProgress) =>
            loadingProgress == null
                ? child
                : Image.asset('assets/images/ikon_placeholder.png')),
        errorBuilder: ((context, error, stackTrace) =>
            Image.asset('assets/images/ikon_placeholder.png')));
  }
}
