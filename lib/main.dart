import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/madgwik.dart';
import 'package:sensors_plus/sensors_plus.dart';

//import 'snake.dart';

void main() {
  runApp(MyApp());
}

double x = 10;
double y = 10;
MadgwickAHRS madgwickAHRS = MadgwickAHRS(1);

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff638965)
      ..style = PaintingStyle.fill;
    //a rectangle
    canvas.drawRect(Offset(x*10, y*10) & Size(100, 100), paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];



  @override
  Widget build(BuildContext context) {
    // final accelerometer =
    //     _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    // final gyroscope =
    //     _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    // final userAccelerometer = _userAccelerometerValues
    //     ?.map((double v) => v.toStringAsFixed(1))
    //     .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.black38),
              ),
              child: SizedBox(
                height: _snakeRows * _snakeCellSize,
                width: _snakeColumns * _snakeCellSize,
                child: CustomPaint(
                  painter: OpenPainter(),
                ),
                // child: Snake(
                //   rows: _snakeRows,
                //   columns: _snakeColumns,
                //   cellSize: _snakeCellSize,
                // ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
               // Text('Accelerometer: $accelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
             //   Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
              //  Text('Gyroscope: $gyroscope'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    madgwickAHRS.withData(2, 1);
    // _streamSubscriptions.add(
    //   accelerometerEvents.listen(
    //     (AccelerometerEvent event) {
    //       setState(() {
    //         //print("--------Accelerometr-$event");
    //         // print("--------Accelerometr- X=" + event.x.toString());
    //         // print("--------Accelerometr- Y=" + event.y.toString());
    //         // print("--------Accelerometr- Z=" + event.z.toString());
    //         _accelerometerValues = <double>[event.x, event.y, event.z];
    //       });
    //     },
    //   ),
    // );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {

            gX=event.x;
            gY=event.y;
            gZ=event.z;
           // print("--------Gyro-$event");
           //  if (_accelerometerValues[0] != null) {
           //    print("--------Accelerometr :" +
           //        _accelerometerValues[0].toString());
           //    _gyroscopeValues = <double>[event.x, event.y, event.z];
           //   var res= madgwickAHRS.updateGyroAccel(
           //        event.x,
           //        event.y,
           //        event.z,
           //        _accelerometerValues[0],
           //        _accelerometerValues[1],
           //        _accelerometerValues[2]);
           //    print("--------res=$res");
           //    print("--------last xY=$x");
           //    x=madgwickAHRS.getQuaternion()[0];
           //    y=madgwickAHRS.getQuaternion()[1];
           //    print("--------new xY=$x");
           //  }
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            // event.
            // print("--------AccelerometrUser-$event");
            // print("--------AccelerometrUser- X=" + event.x.toString());
            // print("--------AccelerometrUser- Y=" + event.y.toString());
            // print("--------AccelerometrUser- Z=" + event.z.toString());
            _userAccelerometerValues = <double>[event.x, event.y, event.z];

            if (_userAccelerometerValues[0] != null) {
              print("--------Accelerometr :" +
                  _userAccelerometerValues[0].toString());
              _gyroscopeValues = <double>[event.x, event.y, event.z];
              var res= madgwickAHRS.updateGyroAccel(
                  gX,
                  gY,
                  gZ,
                  _userAccelerometerValues[0],
                  _userAccelerometerValues[1],
                  _userAccelerometerValues[2]);
              print("--------res=$res");
              print("--------last x=$x");
              x=madgwickAHRS.getQuaternion()[0];
              y=madgwickAHRS.getQuaternion()[2];
              print("--------new x=$x");
            }
          });
        },
      ),
    );
  }
}
double gX,gY,gZ,aX,aY,aZ;
