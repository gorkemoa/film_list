import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../app/translations.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../app/app_theme.dart';
import '../../../models/movie.dart';
import '../../../services/movie_cache_service.dart';
import '../../../viewmodels/home_view_model.dart';
import '../../../core/utils/logger.dart';

class CustomAddMovieView extends StatefulWidget {
  const CustomAddMovieView({super.key});

  @override
  State<CustomAddMovieView> createState() => _CustomAddMovieViewState();
}

class _CustomAddMovieViewState extends State<CustomAddMovieView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _genreController = TextEditingController();
  String _selectedType = 'movie'; // Default

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  void _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      try {
        final movie = Movie(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          year: _yearController.text.trim(),
          genre: _genreController.text.trim(),
          type: _selectedType,
          isWatched: false,
          watchCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await MovieCacheService().saveMovie(movie);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${movie.title} ${Translations.tr('saveCustom')}!'),
            ),
          );
          // Refresh home view model so it appears in the lists
          context.read<HomeViewModel>().init();
          Navigator.pop(context); // Close dialog or page
        }
      } catch (e, st) {
        Logger.error('Failed to save custom movie', e, st);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.tr('customAddTitle'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeTokens.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: Translations.tr('title'),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return Translations.tr('requiredField');
                  }
                  return null;
                },
              ),
              SizedBox(height: SizeTokens.paddingMedium),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: Translations.tr('type'),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'movie',
                    child: Text(Translations.tr('movie')),
                  ),
                  DropdownMenuItem(
                    value: 'series',
                    child: Text(Translations.tr('tv_show')),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              SizedBox(height: SizeTokens.paddingMedium),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: Translations.tr('year'),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return Translations.tr('requiredField');
                  }
                  return null;
                },
              ),
              SizedBox(height: SizeTokens.paddingMedium),
              TextFormField(
                controller: _genreController,
                decoration: InputDecoration(
                  labelText: Translations.tr('genre'),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return Translations.tr('requiredField');
                  }
                  return null;
                },
              ),
              SizedBox(height: SizeTokens.paddingXLarge),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeTokens.paddingMedium,
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveMovie,
                child: Text(
                  Translations.tr('saveCustom'),
                  style: TextStyle(
                    fontSize: SizeTokens.textLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
