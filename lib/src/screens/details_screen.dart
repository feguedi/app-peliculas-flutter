import 'package:flutter/material.dart';

import 'package:app_peliculas/src/models/models.dart';
import 'package:app_peliculas/src/widgets/widgets.dart';

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Movie movie = ModalRoute.of(context)!.settings.arguments as Movie;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _CustomAppBar(title: movie.title, backdrop: movie.fullBackDropPath),
          SliverList(
            delegate: SliverChildListDelegate([
              _PosterAndTitle(
                title: movie.title,
                poster: movie.fullMovieImg,
                originalTitle: movie.originalTitle,
                voteAverage: movie.voteAverage,
              ),
              _Overview(movie.overview),
              CastingCards(),
            ]),
          )
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final String title;
  final String backdrop;

  const _CustomAppBar({Key? key, required this.title, required this.backdrop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.indigo,
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.all(0),
        title: Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
          // color: Colors.black12,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black45,
                Colors.transparent,
              ],
            ),
          ),
          child: Text(
            title,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
        background: FadeInImage(
          placeholder: AssetImage('assets/loading.gif'),
          image: NetworkImage(backdrop),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PosterAndTitle extends StatelessWidget {
  final String title;
  final String originalTitle;
  final String poster;
  final double voteAverage;

  const _PosterAndTitle(
      {Key? key,
      required this.title,
      required this.poster,
      required this.originalTitle,
      required this.voteAverage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(
              width: size.width * 0.33,
              placeholder: AssetImage('assets/no-image.jpg'),
              image: NetworkImage(poster),
            ),
          ),
          SizedBox(width: 20),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.headline5,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  originalTitle,
                  style: textTheme.subtitle1,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [..._renderStars()]),
                    SizedBox(width: 5),
                    Text('$voteAverage', style: textTheme.caption),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Icon> _renderStars() {
    final List<Icon> _stars = [];
    final Icon _emptyStarIcon =
        Icon(Icons.star_outline, size: 15, color: Colors.grey);
    final Icon _halfStarIcon =
        Icon(Icons.star_half_outlined, size: 15, color: Colors.grey);
    final Icon _fullStarIcon =
        Icon(Icons.star_outlined, size: 15, color: Colors.grey);

    final double _decimal = voteAverage - voteAverage.toInt();

    for (int i = 1; i <= 10; i++) {
      if (i == voteAverage.toInt()) {
        if (_decimal >= 0.5) {
          _stars.add(_halfStarIcon);
        } else {
          _stars.add(_emptyStarIcon);
        }
      } else if (i < voteAverage.toInt()) {
        _stars.add(_fullStarIcon);
      } else if (i > voteAverage.toInt()) {
        _stars.add(_emptyStarIcon);
      }
    }

    return _stars;
  }
}

class _Overview extends StatelessWidget {
  final String str;

  const _Overview(this.str);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        str,
        textAlign: TextAlign.justify,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }
}
