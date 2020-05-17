import 'package:flutter/material.dart';
import 'package:playstack/screens/GenresSongs.dart';
import 'package:playstack/shared/common.dart';

import 'Home.dart';

var blueColor = Color(0xFF090e42);
var pinkColor = Color(0xFFff6b80);

var flume = 'https://i.scdn.co/image/8d84f7b313ca9bafcefcf37d4e59a8265c7d3fff';
var martinGarrix =
    'https://c1.staticflickr.com/2/1841/44200429922_d0cbbf22ba_b.jpg';
var rosieLowe =
    'https://i.scdn.co/image/db8382f6c33134111a26d4bf5a482a1caa5f151c';

Widget genres() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 15.0),
        Text(
          'Géneros',
          style: TextStyle(fontFamily: 'Circular', fontSize: 22.0),
        ),
        SizedBox(height: 16.0),
        Row(
          children: <Widget>[
            ItemCard('assets/images/RapGenre.png', 'Rap'),
            SizedBox(
              width: 16.0,
            ),
            ItemCard('assets/images/LatinGenre.png', 'Latin'),
          ],
        ),
        SizedBox(
          height: 32.0,
        ),
        Row(
          children: <Widget>[
            ItemCard('assets/images/PopGenre.png', 'Pop'),
            SizedBox(
              width: 16.0,
            ),
            ItemCard('assets/images/TechnoGenre.png', 'Techno'),
          ],
        ),
        SizedBox(
          height: 32.0,
        ),
      ],
    ),
  );
}

class ItemCard extends StatelessWidget {
  final image;
  final title;
  ItemCard(this.image, this.title);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 120.0,
            child: Stack(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      height: 140.0,
                      width: double.infinity,
                    )),
                Container(
                  height: 120,
                  width: double.infinity,
                  child: FlatButton(
                    color: Colors.transparent,
                    onPressed: () {
                      print('TITULO: $title');
                      currentGenre = title;
                      currentGenreImage = image;
                      homeIndex.value = 3;
                    },
                    child: null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          )
        ],
      ),
    );
  }
}

class DetailedScreen extends StatelessWidget {
  final title;
  final artist;
  final image;
  DetailedScreen(this.title, this.artist, this.image);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueColor,
      body: Column(
        children: <Widget>[
          Container(
            height: 500.0,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(image), fit: BoxFit.cover)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [blueColor.withOpacity(0.4), blueColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 52.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50.0)),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'PLAYLIST',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                              ),
                              Text('Best Vibes of the Week',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Icon(
                            Icons.playlist_add,
                            color: Colors.white,
                          )
                        ],
                      ),
                      Spacer(),
                      Text(title,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0)),
                      SizedBox(
                        height: 6.0,
                      ),
                      Text(
                        artist,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 18.0),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 42.0),
          Slider(
            onChanged: (double value) {},
            value: 0.2,
            activeColor: pinkColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '2:10',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                Text('-03:56',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)))
              ],
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.fast_rewind,
                color: Colors.white54,
                size: 42.0,
              ),
              SizedBox(width: 32.0),
              Container(
                  decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(50.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.play_arrow,
                      size: 58.0,
                      color: Colors.white,
                    ),
                  )),
              SizedBox(width: 32.0),
              Icon(
                Icons.fast_forward,
                color: Colors.white54,
                size: 42.0,
              )
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(
                Icons.bookmark_border,
                color: pinkColor,
              ),
              Icon(
                Icons.shuffle,
                color: pinkColor,
              ),
              Icon(
                Icons.repeat,
                color: pinkColor,
              ),
            ],
          ),
          SizedBox(height: 58.0),
        ],
      ),
    );
  }
}

Widget lists() {
  Column(
    children: <Widget>[
      Container(
        height: 250.0,
        child: Column(
          children: <Widget>[
            Text(
              'Recommendation',
              style: TextStyle(
                color: Colors.white.withOpacity(1.0),
                fontSize: 23.0,
                fontFamily: 'Circular',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
            ),
            Container(
              height: 165.0,
              child: ListView.builder(
                itemCount: imageurl.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      SizedBox(
                        height: 130.0,
                        width: 140.0,
                        child: Image.asset(
                          imageurl[index],
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      Text(
                        artists[index],
                        style: TextStyle(
                          color: Colors.white.withOpacity(1.0),
                          fontFamily: 'Circular',
                          fontSize: 10.0,
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      )
    ],
  );
}
