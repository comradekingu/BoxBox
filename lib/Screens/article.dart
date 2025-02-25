/*
 *  This file is part of BoxBox (https://github.com/BrightDV/BoxBox).
 * 
 * BoxBox is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BoxBox is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BoxBox.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2022, BrightDV
 */

import 'package:boxbox/api/news.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:marquee/marquee.dart';

class ArticleScreen extends StatefulWidget {
  final String articleId;
  final String articleName;
  final bool isFromLink;

  const ArticleScreen(
    this.articleId,
    this.articleName,
    this.isFromLink,
  );

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  ValueNotifier<String> articleTitle = ValueNotifier('Loading...');

  void updateTitle(String title) {
    articleTitle.value = title;
  }

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: AppBar().preferredSize.height,
          width: AppBar().preferredSize.width,
          child: widget.isFromLink
              ? ValueListenableBuilder(
                  valueListenable: articleTitle,
                  builder: (context, value, widget) {
                    return Marquee(
                      text: value.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      pauseAfterRound: Duration(seconds: 1),
                      startAfter: Duration(seconds: 1),
                      velocity: 85,
                      blankSpace: 100,
                    );
                  },
                )
              : Marquee(
                  text: '${widget.articleName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  pauseAfterRound: Duration(seconds: 1),
                  startAfter: Duration(seconds: 1),
                  velocity: 85,
                  blankSpace: 100,
                ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: ArticleProvider(widget.articleId, updateTitle),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ArticleProvider extends StatelessWidget {
  Future<Article> getArticleData(
      String articleId, Function updateArticleTitle) async {
    Article article = await F1NewsFetcher().getArticleData(articleId);
    updateArticleTitle(article.articleName);
    return article;
  }

  final String articleId;
  final Function updateArticleTitle;
  ArticleProvider(this.articleId, this.updateArticleTitle);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Article>(
      future: getArticleData(this.articleId, updateArticleTitle),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? JoinArticlesParts(snapshot.data!)
            : LoadingIndicatorUtil();
      },
    );
  }
}
