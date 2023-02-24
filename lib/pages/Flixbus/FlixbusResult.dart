import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:morpheus/morpheus.dart';
import 'package:thepublictransport_app/backend/models/core/FlixbusJourneyModel.dart';
import 'package:thepublictransport_app/backend/models/flixbus/Message.dart';
import 'package:thepublictransport_app/backend/models/flixbus/QueryResult.dart';
import 'package:thepublictransport_app/backend/service/flixbus/FlixbusService.dart';
import 'package:thepublictransport_app/framework/language/GlobalTranslations.dart';
import 'package:thepublictransport_app/framework/theme/ThemeEngine.dart';
import 'package:thepublictransport_app/framework/time/DateParser.dart';
import 'package:thepublictransport_app/framework/time/DurationParser.dart';

import 'FlixbusResultDetailed.dart';

class FlixbusResult extends StatefulWidget {

  final QueryResult from_search;
  final QueryResult to_search;
  final TimeOfDay time;
  final DateTime date;

  const FlixbusResult({Key key, this.from_search, this.to_search, this.time, this.date}) : super(key: key);


  @override
  _FlixbusResultState createState() => _FlixbusResultState(from_search, to_search, time, date);
}

class _FlixbusResultState extends State<FlixbusResult> {
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(36.0),
    topRight: Radius.circular(36.0),
  );

  final QueryResult from_search;
  final QueryResult to_search;
  final TimeOfDay time;
  final DateTime date;

  _FlixbusResultState(this.from_search, this.to_search, this.time, this.date);

  var theme = ThemeEngine.getCurrentTheme();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      floatingActionButton: FloatingActionButton(
          heroTag: "HEROOOO",
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: theme.floatingActionButtonColor,
          child: Icon(Icons.arrow_back, color: theme.floatingActionButtonIconColor),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.lightGreen,
            ),
            height: MediaQuery.of(context).padding.top + MediaQuery.of(context).size.height * 0.34,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    allTranslations.text('FLIXBUS.TITLE'),
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
                              from_search.name,
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                            Text(
                              to_search.name,
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
                future: getJourney(),
                builder: (BuildContext context, AsyncSnapshot<FlixbusJourneyModel> snapshot) {
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
                        if (snapshot.data == null) {
                          return ClipRRect(
                            borderRadius: radius,
                            child: Container(
                              color: theme.backgroundColor,
                              child: Center(
                                child: Text(allTranslations.text('FLIXBUS.RESULT.FAILED'), style: TextStyle(color: theme.subtitleColor)),
                              ),
                            ),
                          );
                        }
                        return ClipRRect(
                          borderRadius: radius,
                          child: Container(
                            height: double.infinity,
                            color: theme.backgroundColor,
                            child: ListView.builder(
                                itemCount: snapshot.data.message.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return createCard(snapshot.data.message[index]);
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

  Widget createCard(Message message) {
    var begin = message.legs.first.departure;
    var end = message.legs.last.arrival;
    var difference = DurationParser.parse(end.difference(begin));
    final _parentKey = GlobalKey();


    return Card(
      key: _parentKey,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0)
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MorpheusPageRoute(parentKey: _parentKey, builder: (context) => FlixbusResultDetailed(trip: message)));
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
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
                        message.legs.length.toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: theme.textColor
                        ),
                      ),
                    ],
                  ),
                  Text(
                    message.price.amount != null ? (message.price.amount.toString() + " " + message.price.currency.toString()) : "Kein Preis angegeben",
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NunitoSansBold',
                        color: message.price.amount != null ? expensiveColor(message.price.amount) : Colors.red
                    ),
                  )
                ],
              ),
              Divider(
                height: 2.0,
              ),
              Row(
                children: <Widget>[
                  Text(
                    allTranslations.text('FLIXBUS.RESULT.START'),
                    style: TextStyle(
                        fontSize: 15,
                        color: theme.textColor
                    ),
                  ),
                  Text(
                    message.legs.first.origin.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NunitoSansBold',
                        color: theme.textColor
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    allTranslations.text('FLIXBUS.RESULT.END'),
                    style: TextStyle(
                        fontSize: 15,
                        color: theme.textColor
                    ),
                  ),
                  Text(
                    message.legs.last.destination.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NunitoSansBold',
                        color: theme.textColor
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Color expensiveColor(double amount) {
    if (amount > 41)
      return Colors.red;

    return Colors.green;
  }

  Future<FlixbusJourneyModel> getJourney() async {
    var result = await FlixbusService.getJourney(from_search.id, from_search.type, to_search.id, to_search.type, DateParser.getRFCDate(date, time));

    return result;
  }
}
