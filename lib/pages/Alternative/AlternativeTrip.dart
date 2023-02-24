import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thepublictransport_app/backend/models/main/Trip.dart';
import 'package:thepublictransport_app/framework/theme/ThemeEngine.dart';
import 'package:thepublictransport_app/framework/time/UnixTimeParser.dart';
import 'package:thepublictransport_app/pages/Alternative/AlternativeFlixbus.dart';
import 'package:thepublictransport_app/pages/Alternative/AlternativeSparpreis.dart';

class AlternativeTrip extends StatefulWidget {
  final Trip trip;

  const AlternativeTrip({Key key, this.trip}) : super(key: key);

  @override
  _AlternativeTripState createState() => _AlternativeTripState(trip);
}

class _AlternativeTripState extends State<AlternativeTrip> {
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(36.0),
    topRight: Radius.circular(36.0),
  );

  final Trip trip;

  _AlternativeTripState(this.trip);

  PageController _pageController = new PageController();
  int _selectedIndex = 0;

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
    var time = UnixTimeParser.parse(trip.firstDepartureTime);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.blueAccent,
      floatingActionButton: FloatingActionButton(
        heroTag: "HEROOOO2",
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: theme.floatingActionButtonColor,
        child: Icon(Icons.arrow_back, color: theme.floatingActionButtonIconColor),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: 75,
          color: theme.backgroundColor,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                iconSize: 30.0,
                padding: EdgeInsets.only(left: 28.0),
                icon: Icon(Icons.train, color: _selectedIndex == 0 ? Colors.red : Colors.grey),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                    _pageController.animateToPage(0,
                        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                  });
                },
              ),
              IconButton(
                iconSize: 30.0,
                padding: EdgeInsets.only(right: 28.0),
                icon: Icon(Icons.directions_bus, color: _selectedIndex == 1 ? Colors.lightGreen : Colors.grey),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                    _pageController.animateToPage(1,
                        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent
            ),
            height: MediaQuery.of(context).padding.top + MediaQuery.of(context).size.height * 0.34,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Günstige Alternative",
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
                              trip.from.name + (trip.from.place != null ? ", " + trip.from.place : ""),
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                            Text(
                              trip.to.name + (trip.to.place != null ? ", " + trip.to.place : ""),
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
                              time.day.toString().padLeft(2, '0') + "." + time.month.toString().padLeft(2, '0') + "." + time.year.toString().padLeft(4, '0'),
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
            child: ClipRRect(
              borderRadius: radius,
              child: Container(
                height: double.infinity,
                color: theme.backgroundColor,
                child: PageView(
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  controller: _pageController,
                  children: <Widget>[
                    AlternativeSparpreis(fromID: trip.from.id, toID: trip.to.id, dateTime: time),
                    AlternativeFlixbus(fromID: trip.from.id, toID: trip.to.id, dateTime: time),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
