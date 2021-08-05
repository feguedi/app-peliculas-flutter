import 'dart:convert';

import 'package:app_peliculas/src/models/models.dart';

class SearchMovieResponse {
  SearchMovieResponse({
    required this.page,
    required this.movies,
    required this.totalPages,
    required this.totalResults,
  });

  int page;
  List<Movie> movies;
  int totalPages;
  int totalResults;

  factory SearchMovieResponse.fromJson(String str) =>
      SearchMovieResponse.fromMap(json.decode(str));

  factory SearchMovieResponse.fromMap(Map<String, dynamic> json) =>
      SearchMovieResponse(
        page: json['page'],
        movies: List<Movie>.from(json['results'].map((x) => Movie.fromMap(x))),
        totalPages: json['total_pages'],
        totalResults: json['total_results'],
      );
}
