import 'package:flutter/material.dart';
import 'package:bd_map/map.dart';
import 'package:touchable/touchable.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clickable Map of Bangladesh',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(
        title: 'Clickable Map of Bangladesh',
      ),
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
  // List<District> _pressedDistrict = [];
  List<District> districts = [];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < District.values.length; i++) {
      districts.add(District.values[i]);
    }
  }

  List<District> _selectedPath = [];
  @override
  Widget build(BuildContext context) {
    final double xScale = MediaQuery.of(context).size.width / MapSvgData.width;
    final double yScale =
        MediaQuery.of(context).size.height / MapSvgData.height;
    final double scale = xScale < yScale ? xScale : yScale;
    // scale each path to match canvas size
// calculate the scaled svg image width and height in order to get right offset
    double scaledSvgWidth = MapSvgData.width * scale;
    double scaledSvgHeight = MapSvgData.height * scale;
    // calculate offset to center the svg image
    double offsetX = (MediaQuery.of(context).size.width - scaledSvgWidth) / 2;
    double offsetY = (MediaQuery.of(context).size.height - scaledSvgHeight) / 2;
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
              child: CanvasTouchDetector(
                builder: (context) => CustomPaint(
                  painter: PathPainter(
                    context,
                    districts,
                    _selectedPath,
                    (path) {
                      setState(() {
                        if (_selectedPath.contains(path)) {
                          _selectedPath.remove(path);
                        } else {
                          _selectedPath.add(path);
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: Stack(
                children: _buildText(scale, offsetX, offsetY),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildText(scale, offsetX, offsetY) {
    List<Widget> widgets = [];
    for (int i = 0; i < districts.length; i++) {
      final Matrix4 matrix4 = textPosition[District.values[i]];
      if (textPosition[District.values[i]] != null) {
        matrix4.scaled(scale, scale);
      }

      widgets.add(
        Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Transform(
            transform: matrix4 == null ? Matrix4.zero() : matrix4,
            child: Text(
              districts[i].toString().replaceFirst('District.', ''),
              style: TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

class PathPainter extends CustomPainter {
  final List<District> _district;
  final List<District> curPaths;
  BuildContext context;
  Path path;
  PathPainter(this.context, this._district, this.curPaths, this.onPressed);
  final Function(District curPath) onPressed;
  @override
  void paint(Canvas canvas, Size size) {
    final double xScale = size.width / MapSvgData.width;
    final double yScale = size.height / MapSvgData.height;
    final double scale = xScale < yScale ? xScale : yScale;

    // scale each path to match canvas size
    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(scale, scale);

    // calculate the scaled svg image width and height in order to get right offset
    double scaledSvgWidth = MapSvgData.width * scale;
    double scaledSvgHeight = MapSvgData.height * scale;
    // calculate offset to center the svg image
    double offsetX = (size.width - scaledSvgWidth) / 2;
    double offsetY = (size.height - scaledSvgHeight) / 2;
    TouchyCanvas myCanvas = TouchyCanvas(context, canvas);
    _district.forEach((element) {
      path = getPathByDistrict(element);
      myCanvas.drawPath(
        path.transform(matrix4.storage).shift(
              Offset(offsetX, offsetY),
            ),
        Paint()
          ..style = PaintingStyle.fill
          ..color =
              curPaths.contains(element) ? Color(0xfff42a41) : Color(0xff006a4e)
          ..strokeWidth = 1,
        onTapDown: (_) {
          print(element);
          onPressed(element);
        },
      );
    });
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(PathPainter oldDelegate) => true;
}

class PathClipper extends CustomClipper<Path> {
  final District _district;
  PathClipper(this._district);

  @override
  Path getClip(Size size) {
    return getPathByDistrict(_district);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
