// Copyright (c) 2021 Sazzad Shopno
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:math';

import 'package:bd_map/widget/map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' hide SelectionChangedCallback;
import 'package:bd_map/widget/map_controller.dart';
import 'package:touchable/touchable.dart';

/// Bangladesh Map that supports tapping to select districts.
///

class BangladeshMap extends StatefulWidget {
  /// Default width of the map.
  final double mapWidth;

  /// Default height of the map.
  final double mapHeight;

  /// Default district text color
  final Color textColor;

  /// Default selected district color
  final Color selectedColor;

  /// Default non-selected district color
  final Color defaultColor;

  ///
  /// The [mapController] provides information that can be used to update the
  /// UI to indicate whether there are selected items and how many are selected,
  /// besides allowing to directly update the selected items.

  ///
  final BangladeshMapController mapController;
  final BuildContext context;
  BangladeshMap({
    Key key,
    @required this.context,
    @required this.mapController,
    this.mapWidth = 300,
    this.mapHeight = 500,
    @required this.textColor,
    @required this.selectedColor,
    @required this.defaultColor,
  }) : super(key: key);

  /// Controller of the map.
  ///
  /// Provides information that can be used to update the UI to indicate whether
  /// there are selected items and how many are selected.
  ///
  /// Also allows to directly update the selected items.
  ///
  /// This controller may not be used after [BangladeshMapState] disposes,
  /// since [BangladeshMapController.dispose] will get called and the
  /// listeners are going to be cleaned up.

  @override
  _BangladeshMapState createState() => _BangladeshMapState();
}

class _BangladeshMapState extends State<BangladeshMap> {
  BangladeshMapController get _mapController => widget.mapController;

  /// All 64 districts
  List<District> districts = [];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < District.values.length; i++) {
      districts.add(District.values[i]);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double xScale =
        min(widget.mapWidth, MediaQuery.of(widget.context).size.width) /
            MapSvgData.width;
    final double yScale =
        min(widget.mapHeight, MediaQuery.of(widget.context).size.height) /
            MapSvgData.height;
    final double scale = xScale < yScale ? xScale : yScale;
    double scaledSvgWidth = MapSvgData.width * scale;
    double scaledSvgHeight = MapSvgData.height * scale;

    // calculate offset to center the svg image
    double offsetX =
        (MediaQuery.of(widget.context).size.width - scaledSvgWidth) / 2;
    double offsetY =
        (MediaQuery.of(widget.context).size.height - scaledSvgHeight) / 2;
    return InteractiveViewer(
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
                    _mapController.value.selectedDistricts,
                    Offset(offsetX, offsetY),
                    scale,
                    (path) {
                      _mapController.add(path);
                    },
                    widget.textColor,
                    widget.selectedColor,
                    widget.defaultColor,
                  ),
                ),
              ),
            ),
            CustomPaint(
              painter: PathPainter(
                context,
                [District.Text],
                _mapController.value.selectedDistricts,
                Offset(offsetX, offsetY),
                scale,
                (path) {},
                widget.textColor,
                widget.selectedColor,
                widget.defaultColor,
              ),
            ),
          ],
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
  final Color textColor, selectedColor, defaultColor;
  PathPainter(
      this.context,
      this._district,
      this.curPaths,
      this.offset,
      this.scale,
      this.onPressed,
      this.textColor,
      this.selectedColor,
      this.defaultColor);
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
