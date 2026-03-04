import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class SharedFunction {
  static Future<dynamic> generatePdf(
    ScreenshotController screenshotController,
  ) async {
    final pdf = pw.Document();

    // التقاط صورة للويدجت
    final Uint8List? capturedImage = await screenshotController.capture();
    if (capturedImage == null) {
      print("❌ لم يتم التقاط الصورة");
      return;
    }

    // تحويل الصورة إلى كائن من مكتبة image
    img.Image? image = img.decodeImage(capturedImage);
    if (image == null) {
      print("❌ فشل في تحليل الصورة");
      return;
    }

    // // تدوير 180 درجة
    // img.Image rotatedImage = img.copyRotate(image, angle: 180);

    // // عكس أفقيًا بعد التدوير
    // img.Image flippedImage = img.flipHorizontal(rotatedImage);

    // تحويل الصورة إلى صيغة PNG
    final Uint8List finalImage = Uint8List.fromList(img.encodePng(image));

    // إضافة الصورة إلى ملف PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(pw.MemoryImage(finalImage)));
        },
      ),
    );

    // طباعة أو معاينة PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  static Future<dynamic> generateScreenshot(
    ScreenshotController screenshotController,
  ) async {
    // التقاط صورة للويدجت
    final Uint8List? capturedImage = await screenshotController.capture();
    if (capturedImage == null) {
      print("❌ لم يتم التقاط الصورة");
      return;
    }

    // تحويل الصورة إلى كائن من مكتبة image
    img.Image? image = img.decodeImage(capturedImage);
    if (image == null) {
      print("❌ فشل في تحليل الصورة");
      return;
    }

    // // تدوير 180 درجة
    // img.Image rotatedImage = img.copyRotate(image, angle: 180);

    // // عكس أفقيًا بعد التدوير
    // img.Image flippedImage = img.flipHorizontal(rotatedImage);

    // تحويل الصورة إلى صيغة PNG
    final Uint8List finalImage = Uint8List.fromList(img.encodePng(image));

    // حفظ الصورة في المسار المؤقت
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/invoice_image.png';
    final file = File(filePath);
    await file.writeAsBytes(finalImage);

    // تحويل المسار إلى XFile
    final xFile = XFile(filePath);

    // مشاركة الصورة باستخدام shareXFiles
    await Share.shareXFiles([xFile], text: 'فاتورة شراء / فحص');
  }
}
