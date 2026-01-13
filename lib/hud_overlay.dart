import 'package:flutter/material.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class HudOverlay extends StatefulWidget {
  final bool isVisible;

  const HudOverlay({super.key, required this.isVisible});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  final _controller = DiTreDiController(
    rotationX: 0,
    rotationY: 0,
    rotationZ: 0,
  );

  double _scale = 1.0;
  double _baseScale = 1.0;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: GestureDetector(
          onScaleStart: (details) {
            _baseScale = _scale;
          },
          onScaleUpdate: (details) {
            setState(() {
              // Handle Scaling (Pinch)
              _scale = (_baseScale * details.scale).clamp(0.5, 5.0);

              // Handle Rotation (Pan with single finger or two fingers)
              // We add the delta to the current rotation
              // Dividing by 100 to make it less sensitive
              _controller.rotationY += details.focalPointDelta.dx / 100;
              _controller.rotationX += details.focalPointDelta.dy / 100;
            });
          },
          child: DiTreDi(
            figures: [
              Cube3D(2, vector.Vector3(0, 0, 0)),
            ],
            controller: _controller,
            config: DiTreDiConfig(
              supportZIndex: true,
              perspective: true,
            ),
            // We apply scale via the Transform widget wrapping the DiTreDi or by scaling the model?
            // DiTreDi doesn't have a global scale in controller easily,
            // but we can scale the figures or wrap in Transform.
            // Let's just create the Cube with size * scale.
          ).copyWith(figures: [
             Cube3D(2 * _scale, vector.Vector3(0, 0, 0)),
          ]),
        ),
      ),
    );
  }
}

extension CopyWithExtension on DiTreDi {
  DiTreDi copyWith({
    List<Model3D>? figures,
    DiTreDiController? controller,
    DiTreDiConfig? config,
  }) {
    return DiTreDi(
      figures: figures ?? this.figures,
      controller: controller ?? this.controller,
      config: config ?? this.config,
    );
  }
}
