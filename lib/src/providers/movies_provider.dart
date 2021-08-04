import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import 'package:app_peliculas/src/models/now_playing_response.dart';
import 'package:app_peliculas/src/models/now_playing_response.dart';
import 'package:app_peliculas/src/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  String _baseUrl = 'api.themoviedb.org';
  String _api = '3/movie';
  Map<String, String> _queryParams = {
    'api_key': '15f125923a68d42c056286f68d673dd3',
    'language': 'es-MX',
    'page': '1',
  };

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  MoviesProvider() {
    print('MoviesProvider inicializado');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  getRequest(String endpoint) async {
    try {
      final apiEndpoint = '$_api/$endpoint';
      final url = Uri.https(_baseUrl, apiEndpoint, _queryParams);
      print('url: ${url.toString()}');
      final response = await http.get(url);
      final statusCode = response.statusCode;
      final body = response.body;

      if (statusCode != 200) {
        throw new ErrorWidget.withDetails(
          message: 'Codigo de estado: $statusCode',
        );
      } else if (statusCode == 404) {
        return '{}';
      }

      return body;
    } catch (e) {
      throw ErrorWidget.withDetails(message: e.toString());
    }
  }

  getOnDisplayMovies() async {
    try {
      final responseBody = await getRequest('now_playing');
      final nowPlayingResponse = NowPlayingResponse.fromJson(responseBody);
      print(nowPlayingResponse.results[0].title);

      onDisplayMovies = nowPlayingResponse.results;

      notifyListeners();
    } catch (e) {
      print(e);
      throw ErrorWidget.withDetails(message: e.toString());
    }
  }

  getPopularMovies() async {
    try {
      final responseBody = await getRequest('popular');
      final popularResponse = PopularResponse.fromJson(responseBody);

      popularMovies = [...popularMovies, ...popularResponse.results];
      print(popularMovies);
      notifyListeners();
    } catch (e) {
      throw ErrorWidget.withDetails(message: e.toString());
    }
  }
}
