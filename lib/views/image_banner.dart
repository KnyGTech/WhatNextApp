import 'package:flutter/material.dart';

class ImageBanner extends StatelessWidget {
  final String path;

  const ImageBanner(this.path, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(path,
        width: 130,
        loadingBuilder: ((context, child, loadingProgress) =>
            loadingProgress == null
                ? child
                : Image.asset('assets/images/ikon_placeholder.png')),
        errorBuilder: ((context, error, stackTrace) =>
            Image.asset('assets/images/ikon_placeholder.png')));
  }
}
