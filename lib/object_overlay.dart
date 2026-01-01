import 'package:flutter/material.dart';
import 'package:ditredi/ditredi.dart';

class ObjectOverlay extends StatefulWidget {
  final String modelPath;

  const ObjectOverlay({Key? key, required this.modelPath}) : super(key: key);

  @override
  State<ObjectOverlay> createState() => _ObjectOverlayState();
}

class _ObjectOverlayState extends State<ObjectOverlay> {
  // Controller for DiTreDi
  final _controller = DiTreDiController(
    rotationX: 0,
    rotationY: 0,
    rotationZ: 0,
    userScale: 3.0, // Initial user scale
    minUserScale: 0.1,
    maxUserScale: 20.0,
  );

  late Future<List<Model3D<Model3D<dynamic>>>> _modelFuture;

  // Variables for gesture handling
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _modelFuture = _loadModel();
  }

  Future<List<Model3D<Model3D<dynamic>>>> _loadModel() async {
    return ObjParser().loadFromResources(widget.modelPath);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _controller.userScale;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Scale (Zoom)
          if (details.pointerCount == 2) {
             double newScale = _baseScale * details.scale;
             _controller.update(userScale: newScale);
          }

          // Rotation (Pan)
          if (details.pointerCount == 1) {
             _controller.update(
               rotationY: _controller.rotationY + details.focalPointDelta.dx * 0.01,
               rotationX: _controller.rotationX + details.focalPointDelta.dy * 0.01,
             );
          }
        });
      },
      child: FutureBuilder<List<Model3D<Model3D<dynamic>>>>(
        future: _modelFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return DiTreDi(
            figures: snapshot.data!,
            controller: _controller,
            config: const DiTreDiConfig(),
          );
        },
      ),
    );
  }
}
