import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../app/app_theme.dart';
import '../../../models/movie.dart';

class CustomPosterWidget extends StatelessWidget {
  final Movie movie;
  final double? width;
  final double? height;

  const CustomPosterWidget({
    super.key,
    required this.movie,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50), // Deep blue/grey
            Color(0xFF000000), // Black
          ],
        ),
        // Add subtle border if no fixed dimension is provided
        border: Border.all(
          color: AppTheme.surfaceLightColor.withValues(alpha: 0.5),
        ),
      ),
      child: Stack(
        children: [
          // Background icon to give texture
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.movie_creation_outlined,
              size: 150,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SizeTokens.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.textLarge,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 4),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeTokens.paddingSmall),
                if (movie.genre.isNotEmpty)
                  Text(
                    movie.genre
                        .split(',')
                        .take(2)
                        .join(', '), // Limit genres for space
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: SizeTokens.textSmall,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 4),
                if (movie.year.isNotEmpty)
                  Text(
                    movie.year,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: SizeTokens.textSmall,
                      letterSpacing: 1.2,
                    ),
                  ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
