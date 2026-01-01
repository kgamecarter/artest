import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/services.dart';
import 'object_overlay.dart';

class ARScannerPage extends StatefulWidget {
  const ARScannerPage({Key? key}) : super(key: key);

  @override
  State<ARScannerPage> createState() => _ARScannerPageState();
}

class _ARScannerPageState extends State<ARScannerPage> {
  ArCoreController? arCoreController;
  bool _isTargetVisible = false;

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. AR View Layer
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            type: ArCoreViewType.AUGMENTEDIMAGES,
            debug: true,
          ),

          // 2. HUD Layer (3D Object)
          if (_isTargetVisible)
            Positioned.fill(
              child: ObjectOverlay(
                modelPath: 'assets/cube.obj',
              ),
            ),

           // Instructions / Debug
          if (!_isTargetVisible)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.black54,
                  child: const Text(
                    "Scan the target image",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _loadImages();
  }

  Future<void> _loadImages() async {
    final ByteData bytes = await rootBundle.load('assets/target.jpg');
    final Uint8List list = bytes.buffer.asUint8List();

    arCoreController?.loadSingleAugmentedImage(
      bytes: list,
    );

    // Listen for Augmented Image tracking events
    arCoreController?.onTrackingImage = _handleOnTrackingImage;
  }

  void _handleOnTrackingImage(ArCoreAugmentedImage image) {
    // Determine visibility based on tracking method
    // ArCoreAugmentedImage has `trackingMethod` property.
    // TrackingMethod.FULL_TRACKING means it's visible/tracked.

    bool isVisible = (image.trackingMethod == TrackingMethod.FULL_TRACKING);

    if (_isTargetVisible != isVisible) {
      setState(() {
        _isTargetVisible = isVisible;
      });
    }
  }
}
