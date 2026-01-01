import 'package:flutter/material.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

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
    scale: 3.0, // Initial scale
    // We can set translation if needed, but HUD usually centers the object
  );

  late Future<List<Model3D<Model3D<dynamic>>>> _modelFuture;

  // Variables for gesture handling
  double _baseScale = 1.0;
  double _lastScale = 1.0;

  double _baseRotationX = 0.0;
  double _baseRotationY = 0.0;

  @override
  void initState() {
    super.initState();
    _modelFuture = _loadModel();
  }

  Future<List<Model3D<Model3D<dynamic>>>> _loadModel() async {
    // DiTreDi loads from assets using ObjParser.loadFromResources
    // Note: widget.modelPath is 'assets/cube.obj'.
    // ObjParser expects the path relative to assets root usually?
    // Let's check documentation or assume standard flutter asset loading.
    // ObjParser().loadFromResources("assets/cube.obj") should work if added to pubspec.
    return ObjParser().loadFromResources(widget.modelPath);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _controller.scale;
        _baseRotationX = _controller.rotationX;
        _baseRotationY = _controller.rotationY;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Scale (Zoom)
          // details.scale starts at 1.0 each gesture.
          if (details.pointerCount == 2) {
             double newScale = _baseScale * details.scale;
             _controller.update(scale: newScale.clamp(0.5, 10.0));
          }

          // Rotation (Pan)
          // details.focalPointDelta is movement since last update.
          // BUT simpler to use details.rotation if using rotation gesture? No, user said "Single finger rotate".
          // Single finger 'scale' gesture usually has scale=1.0.

          if (details.pointerCount == 1) {
             // We can use focalPointDelta for rotation
             // We need to accumulate? No, onScaleUpdate gives delta since start?
             // No, focalPointDelta is since last event.
             // But we want absolute rotation based on drag?

             // To be robust:
             // RotationX += deltaY
             // RotationY += deltaX

             // Since we don't have total delta easily in `details` without tracking,
             // let's use the delta approach on the controller.

             // Actually, `details.focalPointDelta` is reliable.

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
            return const Center(child: CircularProgressIndicator()); // Or transparent
          }
          return DiTreDi(
            figures: snapshot.data!,
            controller: _controller,
            // Configure DiTreDi to be transparent if possible?
            // DiTreDi uses CustomPainter. background is transparent by default if not filled.
            // But we need to check if `config` sets a color.
            config: const DiTreDiConfig(
              supportZ: true,
            ),
          );
        },
      ),
    );
  }
}
