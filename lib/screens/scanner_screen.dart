import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/scan_provider.dart';
import '../services/user_provider.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;
  late AnimationController _lineCtrl;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _lineAnim = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    setState(() => _scanned = true);
    await _controller.stop();

    if (!mounted) return;
    final scanProvider = context.read<ScanProvider>();
    await scanProvider.scanBarcode(barcode);

    if (!mounted) return;
    final product = scanProvider.product;

    if (product != null) {
      context.read<UserProvider>().addToHistory(product);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultScreen(product: product)),
      );
    } else {
      _showNotFound(barcode);
    }
  }

  void _showNotFound(String barcode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Product Not Found', style: GoogleFonts.dmSerifDisplay(color: AppColors.navy)),
        content: Text('Barcode $barcode was not found in the Open Food Facts database.', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() => _scanned = false); _controller.start(); }, child: const Text('Try Again')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay
          _ScanOverlay(lineAnimation: _lineAnim),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                  ),
                  Text('Scan Barcode', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
                  IconButton(
                    onPressed: () => _controller.toggleTorch(),
                    icon: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
          ),

          // Bottom hint
          Positioned(
            bottom: 60,
            left: 0, right: 0,
            child: Text(
              'Point at any food barcode',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
            ),
          ),

          // Loading overlay
          if (_scanned)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: AppColors.green)),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  final Animation<double> lineAnimation;
  const _ScanOverlay({required this.lineAnimation});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(lineAnimation),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Animation<double> anim;
  _OverlayPainter(this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    const cutoutW = 240.0;
    const cutoutH = 180.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: cutoutW, height: cutoutH);

    // Dim overlay
    final dimPaint = Paint()..color = Colors.black.withOpacity(0.65);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, dimPaint);

    // Corner guides
    const cornerLen = 24.0;
    const cornerThick = 3.0;
    final greenPaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = cornerThick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      [rect.topLeft, Offset(rect.left + cornerLen, rect.top), Offset(rect.left, rect.top + cornerLen)],
      [rect.topRight, Offset(rect.right - cornerLen, rect.top), Offset(rect.right, rect.top + cornerLen)],
      [rect.bottomLeft, Offset(rect.left + cornerLen, rect.bottom), Offset(rect.left, rect.bottom - cornerLen)],
      [rect.bottomRight, Offset(rect.right - cornerLen, rect.bottom), Offset(rect.right, rect.bottom - cornerLen)],
    ];

    for (final c in corners) {
      final p = Path()
        ..moveTo(c[1].dx, c[1].dy)
        ..lineTo(c[0].dx, c[0].dy)
        ..lineTo(c[2].dx, c[2].dy);
      canvas.drawPath(p, greenPaint);
    }

    // Animated scan line
    final lineY = rect.top + (rect.height * anim.value);
    final linePaint = Paint()
      ..shader = LinearGradient(colors: [Colors.transparent, AppColors.amber, Colors.transparent])
          .createShader(Rect.fromLTWH(rect.left, lineY, cutoutW, 2));
    canvas.drawRect(Rect.fromLTWH(rect.left, lineY, cutoutW, 2), linePaint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => true;
}
