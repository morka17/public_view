import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morpheus/morpheus.dart';
import 'package:preferences/preferences.dart';
import 'package:share/share.dart';
import 'package:thepublictransport_app/backend/models/core/TripModel.dart';
import 'package:thepublictransport_app/backend/models/main/SuggestedLocation.dart';
import 'package:thepublictransport_app/backend/models/main/Trip.dart';
import 'package:thepublictransport_app/backend/service/core/CoreService.dart';
import 'package:thepublictransport_app/backend/service/shortener/ShortenerService.dart';
import 'package:thepublictransport_app/framework/language/GlobalTranslations.dart';
import 'package:thepublictransport_app/framework/theme/ThemeEngine.dart';
import 'package:thepublictransport_app/framework/time/DateParser.dart';
import 'package:thepublictransport_app/framework/time/DurationParser.dart';
import 'package:thepublictransport_app/framework/time/UnixTimeParser.dart';

import 'ResultDetailed.dart';

class Result extends StatefulWidget {

  final SuggestedLocation from_search;
  final SuggestedLocation to_search;
  final TimeOfDay time;
  final DateTime date;
  final bool barrier;
  final bool slowwalk;
  final bool fastroute;
  final String products;

  const Result({Key key, this.from_search, this.to_search, this.time, this.date, this.barrier, this.slowwalk, this.fastroute, this.products}) : super(key: key);


  @override
  _ResultState createState() => _ResultState(from_search, to_search, time, date, barrier, slowwalk, fastroute, products);
}

class _ResultState extends State<Result> {
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(36.0),
    topRight: Radius.circular(36.0),
  );

  final SuggestedLocation from_search;
  final SuggestedLocation to_search;
  final TimeOfDay time;
  final DateTime date;
  final bool barrier;
  final bool slowwalk;
  final bool fastroute;
  final String products;

  _ResultState(this.from_search, this.to_search, this.time, this.date, this.barrier, this.slowwalk, this.fastroute, this.products);

  var theme = ThemeEngine.getCurrentTheme();

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: theme.backgroundColor,
      statusBarColor: Colors.transparent, // status bar color
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.status == "light" ? Colors.black : theme.cardColor,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
              heroTag: "HEROOOO",
              onPressed: () {
                Navigator.of(context).pop();
              },
              backgroundColor: theme.floatingActionButtonColor,
              child: Icon(Icons.arrow_back, color: theme.floatingActionButtonIconColor),
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "NOHERO",
            onPressed: () async {
              var prepared = 'https://thepublictransport.de/share?fromName='
                  + from_search.location.name + (from_search.location.place != null ? ", " + from_search.location.place : "") +
                  '&fromID=' + from_search.location.id +
                  '&toName=' + to_search.location.name + (to_search.location.place != null ? ", " + to_search.location.place : "") +
                  '&toID=' + to_search.location.id +
                  '&date=' + date.toString() +
                  '&time=' + time.hour.toString() + ":" + time.minute.toString().padLeft(2, '0') +
                  '&barrier=' + barrier.toString() +
                  '&slowwalk=' + slowwalk.toString() +
                  '&fastroute=' + fastroute.toString() +
                  '&source=' + PrefService.getString('public_transport_data') +
                  '&products=' + products;

              var shortened = await ShortenerService.createLink(Uri.encodeFull(prepared).toString());

              Share.share(shortened);
            },
            backgroundColor: theme.floatingActionButtonColor,
            child: Icon(Icons.share, color: theme.floatingActionButtonIconColor),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: theme.status == "light" ? Colors.black : theme.cardColor,
            ),
            height: MediaQuery.of(context).padding.top + MediaQuery.of(context).size.height * 0.34,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    allTranslations.text('RESULT.TITLE'),
                    style: TextStyle(
                      fontFamily: 'NunitoSansBold',
                      fontSize: 40,
                      color: Colors.white
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              from_search.location.name + (from_search.location.place != null ? ", " + from_search.location.place : ""),
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                            Text(
                              to_search.location.name + (to_search.location.place != null ? ", " + to_search.location.place : ""),
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              time.hour.toString() + ":" + time.minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                            Text(
                              date.day.toString().padLeft(2, '0') + "." + date.month.toString().padLeft(2, '0') + "." + date.year.toString().padLeft(4, '0'),
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: FutureBuilder(
                future: getTrips(),
                builder: (BuildContext context, AsyncSnapshot<TripModel> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return ClipRRect(
                        borderRadius: radius,
                        child: Container(
                          height: double.infinity,
                          color: theme.backgroundColor,
                          child: Center(
                            child: SizedBox(
                              width: 500,
                              height: 500,
                              child: FlareActor(
                                'anim/cloud_loading.flr',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                                animation: 'Sync',
                              ),
                            ),
                          ),
                        ),
                      );
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Text(snapshot.error);
                      } else {
                        if (snapshot.data.trips == null) {
                          return ClipRRect(
                            borderRadius: radius,
                            child: Container(
                              color: theme.backgroundColor,
                              child: Center(
                                child: Text(allTranslations.text('RESULT.FAILED'), style: TextStyle(color: theme.subtitleColor)),
                              ),
                            ),
                          );
                        }
                        return ClipRRect(
                          borderRadius: radius,
                          child: Container(
                            color: theme.backgroundColor,
                            child: ListView.builder(
                                itemCount: snapshot.data.trips.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return createCard(snapshot.data.trips[index]);
                                }
                            ),
                          ),
                        );
                      }
                  }
                  return null;
                }
            ),
          )
        ],
      ),
    );
  }

  Widget createCard(Trip trip) {
    final _parentKey = GlobalKey();
    var begin = UnixTimeParser.parse(trip.firstDepartureTime);
    var end = UnixTimeParser.parse(trip.lastArrivalTime);
    var difference = DurationParser.parse(end.difference(begin));
    var travels = [];
    var counter = 0;

    for (var i in trip.legs) {
      if (i.line == null)
        continue;

      travels.add(i.line.name.replaceAll(new RegExp("[^A-Za-z]+"), ""));
      counter++;
    }


    return Card(
      key: _parentKey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0)
      ),
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MorpheusPageRoute(parentKey: _parentKey, builder: (context) => ResultDetailed(trip: trip)));
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    begin.hour.toString().padLeft(2, '0') + ":" + begin.minute.toString().padLeft(2, '0'),
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NunitoSansBold',
                        color: theme.textColor
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    end.hour.toString().padLeft(2, '0') + ":" + end.minute.toString().padLeft(2, '0'),
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NunitoSansBold',
                        color: theme.textColor
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    difference,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NunitoSansBold',
                        color: theme.textColor
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    counter.toString(),
                    style: TextStyle(
                      fontSize: 15,
                        color: theme.textColor
                    ),
                  ),
                ],
              ),
              Divider(
                height: 2.0,
              ),
              Text(
                travels.join(" - "),
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'NunitoSansBold',
                    color: theme.textColor
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<TripModel> getTrips() async {
    String barrier_mode = barrier == true ? "BARRIER_FREE" : "NEUTRAL";
    String slowwalk_mode = slowwalk == true ? "SLOW" : "NORMAL";
    String fastroute_mode = fastroute == true ? "LEAST_DURATION" : "LEAST_CHANGES";

    return CoreService.getTripById(
        from_search.location.id,
        to_search.location.id,
        DateParser.getTPTDate(date, time),
        barrier_mode,
        fastroute_mode,
        slowwalk_mode,
        PrefService.getString('public_transport_data'),
        products
    );
  }
}
