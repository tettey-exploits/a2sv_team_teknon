import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmnets/themes/light_mode.dart';
import 'package:flutter/material.dart';

/// Generates a profile image based on either a network URL or a local file.
///
/// If `image` is `null`, it generates the profile image based on `imageUrl`.
/// If `imageUrl` is `null` or an empty string, it loads a default profile image.
/// If `imageUrl` is provided, it loads the image from the network with caching.
/// If there's an error loading the network image, it falls back to the default profile image.
///
/// If `image` is provided, it loads the image from the local file.

Widget profileWidget({String? imageUrl, File? image}) {
  if (image == null) {
    if (imageUrl == null || imageUrl == "") {
      return Image.asset(
        'assets/app_images/no_profile.png',
        fit: BoxFit.cover,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return const CircularProgressIndicator(
            color: tabColor,
          );
        },
        errorWidget: (context, url, error) => Image.asset(
          'assets/app_images/no_profile.png',
          fit: BoxFit.cover,
        ),
      );
    }
  } else {
    return Image.file(
      image,
      fit: BoxFit.cover,
    );
  }
}

Widget kwameGeminiProfileWidget({String? imageUrl, File? image}) {
  if (image == null) {
    if (imageUrl == null || imageUrl == "") {
      return Image.asset(
        'assets/app_images/farmer_image.png',
        fit: BoxFit.cover,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return const CircularProgressIndicator(
            color: tabColor,
          );
        },
        errorWidget: (context, url, error) => Image.asset(
          'assets/app_images/kwame_ai_profile.png',
          fit: BoxFit.cover,
        ),
      );
    }
  } else {
    return Image.file(
      image,
      fit: BoxFit.cover,
    );
  }
}
