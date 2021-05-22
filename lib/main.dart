import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IPV Form Editor',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'IPV Form Editor'),
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
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final pan = TextEditingController();
  final _picker = ImagePicker();
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('dd-MM-yyyy');
  final String formatted = formatter.format(now);
  File photoImage, signImage;
  PickedFile pickedFile;

  Future chooseFile(String s) async {
    pickedFile =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    s == "1"
        ? photoImage = File(pickedFile.path)
        : signImage = File(pickedFile.path);
  }

  Future createPDF() async {
    final PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData());
    final PdfPage page = document.pages[0];
    page.graphics.drawString(
        pan.text.toUpperCase(), PdfStandardFont(PdfFontFamily.timesRoman, 12),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: const Rect.fromLTWH(88, 140, 150, 20));
    page.graphics.drawString(
        name.text.toUpperCase(), PdfStandardFont(PdfFontFamily.timesRoman, 12),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: const Rect.fromLTWH(177, 180, 150, 20));
    page.graphics.drawString(
        name.text.toUpperCase(), PdfStandardFont(PdfFontFamily.timesRoman, 12),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: const Rect.fromLTWH(177, 592, 150, 20));
    page.graphics.drawString(
        formatted, PdfStandardFont(PdfFontFamily.timesRoman, 12),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: const Rect.fromLTWH(150, 222, 150, 20));
    final Uint8List photoData = photoImage.readAsBytesSync();
    final Uint8List signData = signImage.readAsBytesSync();
    final PdfBitmap photo = PdfBitmap(photoData);
    final PdfBitmap sign = PdfBitmap(signData);
    page.graphics.drawImage(photo, const Rect.fromLTWH(440, 90, 130, 130));
    page.graphics.drawImage(sign, const Rect.fromLTWH(220, 648, 80, 25));
    final List<int> bytes = document.save();
    await saveAndLaunchFile(bytes, '${name.text.split(" ")[0]} IPV.pdf');
    document.dispose();
  }

  Future<List<int>> _readDocumentData() async {
    final ByteData data = await rootBundle.load('assets/test.pdf');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    String path = "/storage/emulated/0/Download";
    File('$path/$fileName').writeAsBytes(bytes, flush: true);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PDF Created!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('PDF file stored in Downloads'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            SizedBox(height: 40),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.blue,
                size: 40,
              ),
              title: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                controller: name,
                decoration: InputDecoration(
                  hintText: "Full Name",
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              leading: const Icon(
                Icons.payment,
                color: Colors.blue,
                size: 40,
              ),
              title: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                controller: pan,
                decoration: InputDecoration(
                  hintText: "PAN",
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Text('Passport Photo:'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: Text(
                  'Browse File',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  chooseFile("1");
                },
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Text('Signature:'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: Text(
                  'Browse File',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  chooseFile("0");
                },
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: Text(
                  'Create PDF',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  createPDF();
                  _showMyDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
