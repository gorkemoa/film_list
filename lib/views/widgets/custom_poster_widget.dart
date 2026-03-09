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
    // Detect if we are in a large view (detail) or small (grid/list)
    final bool isLarge = (height != null && height! > 200) || height == null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a1a),
            const Color(0xFF2d3436),
            const Color(0xFF000000),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Ambient light effect (circles)
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                movie.type == 'series' ? Icons.tv : Icons.movie_filter,
                size: isLarge ? 200 : 100,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),

            // Content
            Positioned.fill(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLarge
                          ? SizeTokens.paddingLarge * 2
                          : SizeTokens.paddingMedium,
                      vertical: SizeTokens.paddingMedium,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Spacer removed to help FittedBox center content cleanly
                        // Type badge if large
                        if (isLarge && movie.type != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              movie.type!.toUpperCase(),
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),

                        Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isLarge
                                ? SizeTokens.textTitle * 1.5
                                : SizeTokens.textLarge,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (isLarge) SizedBox(height: SizeTokens.paddingLarge),
                        if (!isLarge) SizedBox(height: SizeTokens.paddingSmall),

                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (movie.year.isNotEmpty)
                              _infoBadge(movie.year, Colors.white70),
                            if (movie.genre.isNotEmpty)
                              _infoBadge(
                                movie.genre.split(',').first,
                                AppTheme.primaryColor.withValues(alpha: 0.8),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
