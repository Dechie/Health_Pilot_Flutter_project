import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Raster image with a themed placeholder when the asset is missing or invalid.
class SafeRasterAsset extends StatelessWidget {
  const SafeRasterAsset(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.borderRadius,
  });

  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget image = Image.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => _Placeholder(
        width: width,
        height: height,
        color: cs.primaryContainer,
        iconColor: cs.onPrimaryContainer,
      ),
    );
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

/// SVG asset with a themed placeholder when the bundle cannot load the file.
class SafeSvgAsset extends StatefulWidget {
  const SafeSvgAsset(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
  });

  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Color? color;

  @override
  State<SafeSvgAsset> createState() => _SafeSvgAssetState();
}

class _SafeSvgAssetState extends State<SafeSvgAsset> {
  late final Future<bool> _exists;

  @override
  void initState() {
    super.initState();
    _exists = rootBundle
        .load(widget.assetName)
        .then((_) => true)
        .catchError((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<bool>(
      future: _exists,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _Placeholder(
            width: widget.width,
            height: widget.height,
            color: cs.surfaceContainerHighest,
            iconColor: cs.onSurfaceVariant,
          );
        }
        if (snapshot.data != true) {
          return _Placeholder(
            width: widget.width,
            height: widget.height,
            color: cs.primaryContainer,
            iconColor: cs.onPrimaryContainer,
          );
        }
        return SvgPicture.asset(
          widget.assetName,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
          colorFilter: widget.color == null
              ? null
              : ColorFilter.mode(widget.color!, BlendMode.srcIn),
        );
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.color,
    required this.iconColor,
    this.width,
    this.height,
  });

  final Color color;
  final Color iconColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: color,
      child: Icon(
        Icons.hide_image_outlined,
        color: iconColor,
        size: 28,
      ),
    );
  }
}
