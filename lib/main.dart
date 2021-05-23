import 'package:flutter/material.dart';
import 'package:bd_map/map.dart';
import 'package:touchable/touchable.dart';

void main() => runApp(
      MyApp(),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clickable Map of Bangladesh',
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
  List<District> districts = [];
  List<District> _selectedPath = [];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < District.values.length; i++) {
      districts.add(District.values[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double xScale = MediaQuery.of(context).size.width / MapSvgData.width;
    final double yScale =
        MediaQuery.of(context).size.height / MapSvgData.height;
    final double scale = xScale < yScale ? xScale : yScale;
    double scaledSvgWidth = MapSvgData.width * scale;
    double scaledSvgHeight = MapSvgData.height * scale;
    // calculate offset to center the svg image
    double offsetX = (MediaQuery.of(context).size.width - scaledSvgWidth) / 2;
    double offsetY = (MediaQuery.of(context).size.height - scaledSvgHeight) / 2;

    return Scaffold(
      body: InteractiveViewer(
        minScale: 0.1,
        maxScale: 5,
        child: Center(
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
                      Offset(offsetX, offsetY),
                      scale,
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
              CustomPaint(
                painter: PathPainter(
                  context,
                  [District.Text],
                  _selectedPath,
                  Offset(offsetX, offsetY),
                  scale,
                  (path) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<District> _district;
  final List<District> curPaths;
  final Offset offset;
  final double scale;
  BuildContext context;
  // Change color according to your need
  final Color textColor = Colors.yellow,
      selectedColor = Color(0xfff42a41),
      defaultColor = Color(0xff006a4e);

  PathPainter(this.context, this._district, this.curPaths, this.offset,
      this.scale, this.onPressed);
  final Function(District curPath) onPressed;
  @override
  void paint(Canvas canvas, Size size) {
    // scale each path to match canvas size
    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(scale, scale);
    TouchyCanvas myCanvas = TouchyCanvas(context, canvas);
    _district.forEach((element) {
      Path path = getPathByDistrict(element);
      if (element == District.Text) {
        myCanvas.drawPath(
          path.transform(matrix4.storage).shift(
                offset,
              ),
          Paint()
            ..style = PaintingStyle.fill
            ..color = textColor
            ..strokeWidth = 1,
        );
      } else {
        myCanvas.drawPath(
          path.transform(matrix4.storage).shift(
                offset,
              ),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = curPaths.contains(element) ? defaultColor : selectedColor
            ..strokeWidth = 2,
          onTapDown: (_) {
            print(element);
            onPressed(element);
          },
        );
        myCanvas.drawPath(
          path.transform(matrix4.storage).shift(
                offset,
              ),
          Paint()
            ..style = PaintingStyle.fill
            ..color = curPaths.contains(element) ? selectedColor : defaultColor,
          onTapDown: (_) {
            onPressed(element);
          },
        );
      }
    });
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(PathPainter oldDelegate) => false;
}
