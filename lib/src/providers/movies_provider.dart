import 'dart:async';
import 'package:app_peliculas/src/helpers/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import 'package:app_peliculas/src/models/now_playing_response.dart';
import 'package:app_peliculas/src/models/now_playing_response.dart';
import 'package:app_peliculas/src/models/models.dart';
import 'package:app_peliculas/src/models/search_movies_response.dart';

class MoviesProvider extends ChangeNotifier {
  String _baseUrl = 'api.themoviedb.org';
  String _api = '3';
  Map<String, String> _queryParams = {
    'api_key': '15f125923a68d42c056286f68d673dd3',
    'language': 'es-MX',
  };

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(duration: Duration(milliseconds: 750));

  final StreamController<List<Movie>> _suggestionsStreamController =
      new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream =>
      this._suggestionsStreamController.stream;

  MoviesProvider() {
    print('MoviesProvider inicializado');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  getRequest(String endpoint, {String q = '', int page = 1}) async {
    try {
      print('solicitando datos');
      final apiEndpoint = '$_api/$endpoint';
      final requestQueryParams = {'page': '$page', ..._queryParams};
      if (q.isNotEmpty) {
        requestQueryParams['query'] = q;
      }

      final url = Uri.https(_baseUrl, apiEndpoint, requestQueryParams);

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
      final responseBody = await getRequest('movie/now_playing');
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
      _popularPage++;
      final responseBody = await getRequest('movie/popular');
      final popularResponse = PopularResponse.fromJson(responseBody);

      popularMovies = [...popularMovies, ...popularResponse.results];
      print(popularMovies);
      notifyListeners();
    } catch (e) {
      throw ErrorWidget.withDetails(message: e.toString());
    }
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) {
      return moviesCast[movieId]!;
    }

    final jsonData = await this.getRequest('movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      if (query.length < 3) {
        return [];
      }
      final response = await getRequest('search/movie', q: query);
      final searchMovieResponse = SearchMovieResponse.fromJson(response);

      return searchMovieResponse.movies;
    } catch (e) {
      throw ErrorWidget.withDetails(message: e.toString());
    }
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await this.searchMovies(value);
      this._suggestionsStreamController.add(results);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_$) => timer.cancel());
  }
}
