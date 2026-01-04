import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'hud_overlay.dart';

class ARScannerScreen extends StatefulWidget {
  const ARScannerScreen({super.key});

  @override
  State<ARScannerScreen> createState() => _ARScannerScreenState();
}

class _ARScannerScreenState extends State<ARScannerScreen> {
  ArCoreController? arCoreController;
  bool isTargetFound = false;
  DateTime? lastSeen;
  Timer? _checkTimer;
  String? debugStatus;

  @override
  void initState() {
    super.initState();
    _startKeepAliveCheck();
  }

  void _startKeepAliveCheck() {
    _checkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (lastSeen != null) {
        final diff = DateTime.now().difference(lastSeen!);
        if (diff.inMilliseconds > 1000) {
          if (isTargetFound) {
            setState(() {
              isTargetFound = false;
              debugStatus = "Target Lost (Timeout)";
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            type: ArCoreViewType.AUGMENTEDIMAGES,
            debug: true,
          ),
          HudOverlay(isVisible: isTargetFound),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                debugStatus ?? "Waiting for AR...",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          // Debug button for manual testing since we can't use real camera in sim
          // if (true) // Keeping it for user to test if needed, or I can remove later
          //   Positioned(
          //     top: 50,
          //     right: 20,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         setState(() {
          //           isTargetFound = !isTargetFound;
          //           lastSeen = DateTime.now(); // Reset timeout to avoid immediate hide if we were to rely on it
          //           debugStatus = isTargetFound ? "Manual: Found" : "Manual: Lost";
          //         });
          //       },
          //       child: const Text("Toggle HUD (Debug)"),
          //     ),
          //   ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    arCoreController?.onTrackingImage = _handleOnTrackingImage;
    loadAugmentedImagesDb(controller);
  }

  Future<void> loadAugmentedImagesDb(ArCoreController controller) async {
    try {
      final ByteData bytes = await rootBundle.load('assets/images/earth.jpg');
      final Uint8List list = bytes.buffer.asUint8List();

      controller.loadAugmentedImagesDatabase(
        bytes: list,
      );
      setState(() {
        debugStatus = "DB Loaded";
      });
    } catch (e) {
      setState(() {
        debugStatus = "Error loading DB: $e";
      });
    }
  }

  void _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    // This callback is called when an image is detected or tracked.
    if (augmentedImage.trackingMethod == TrackingMethod.FULL_TRACKING) {
      setState(() {
        isTargetFound = true;
        lastSeen = DateTime.now();
        debugStatus = "Tracking: ${augmentedImage.name} (Index: ${augmentedImage.index})";
      });
    }
  }
}
