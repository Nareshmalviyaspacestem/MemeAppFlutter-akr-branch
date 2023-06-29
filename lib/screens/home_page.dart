import 'dart:async';
// import 'dart:ffi';
// import 'dart:html';
import 'dart:io';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:memeapp/models/cart_card_model.dart';
import 'package:memeapp/providers/cart_counter_provider.dart';
import 'package:memeapp/providers/meme_cart_provider.dart';
// import 'package:memeapp/screens/cart_page.dart';
// import 'package:memeapp/screens/preview_download.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memeapp/models/memes_model.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
//fileName : fintechdashboardclone
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<MemesModel> getMemesApi() async {
  final response =
      await http.get(Uri.parse("https://api.imgflip.com/get_memes"));
  var data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return MemesModel.fromJson(data);
  } else {
    return MemesModel.fromJson(data);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<MemesModel> memes;

  @override
  void initState() {
    super.initState();
    memes = getMemesApi();
  }

  @override
  Widget build(BuildContext context) {
    var memeCartProvider =
        Provider.of<MemeCartProvider>(context, listen: false);
    int cartCounter = context.watch<CartCounterProvider>().getCartCount;

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Image.asset(
                'assets/images/logo1.png',
               color: Colors.white,
                width: 150,
                height: 40,
              ),
            ),
          ),
          backgroundColor: Color(0xffA375AD),
        ),
      ),
      body: FutureBuilder<MemesModel>(
        future: memes,
        builder: (context, snapshot) {
          return Scrollbar(
            radius: const Radius.circular(10),
            thumbVisibility: true,
            thickness: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: DynamicHeightGridView(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  itemCount:
                      //nullcheck operator
                      snapshot.hasData ? snapshot.data!.data!.memes!.length : 1,
                  builder: (context, index) {
                    if (snapshot.hasData) {
                      String memeId =
                          snapshot.data!.data!.memes![index].id.toString();
                      String memeName =
                          snapshot.data!.data!.memes![index].name.toString();
                      String memeImageUrl =
                          snapshot.data!.data!.memes![index].url.toString();

                      CartCardModel addCartItem = CartCardModel(
                          id: memeId,
                          nameCart: memeName,
                          imageUrlCart: memeImageUrl);
                      return Card(
                          elevation: 0.5,
                          child: SizedBox(
                            child: Column(
                                // mainAxisSize: MainAxisSize.max
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Text(
                                  //     "memes type : ${snapshot.data!.data!.memes.runtimeType}"),
                                 /* Text(
                                      "${snapshot.data!.data!.memes![index].name}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 5),*/
                                  ClipRRect(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0) ,topRight:  Radius.circular(5.0)),
                                      child: SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: Image.network(memeImageUrl , width: double.infinity,height: double.infinity,fit: BoxFit.fill,)

                                      )),
                                  const SizedBox(height: 5),
                                 Row(children: [
                                   IconButton(onPressed: (){
                                     String memeImageUrl =
                                     snapshot.data!.data!.memes![index].url.toString();
                                     shareAtIndex(memeImageUrl , context);
                                   }, icon: const Icon(Icons.share)),
                                   IconButton(onPressed: (){
                                     requestStoragePermissions(memeImageUrl , context);
                                    // downloadAtIndex(memeImageUrl , context);
                                   }, icon: const Icon(Icons.download))

                                 ],)

                                 /* ElevatedButton(
                                      onPressed: memeCartProvider
                                              .getMemesIdList!
                                              .contains(memeId)
                                          ? () {}
                                          : () {
                                              // if (memeCartProvider
                                              //     .getMemesIdList!
                                              //     .contains(memeId)) {
                                              //   // print(
                                              //   //     ".....memeid : ............................${memeId}");
                                              //   ScaffoldMessenger.of(context)
                                              //       .showSnackBar(const SnackBar(
                                              //           duration: Duration(
                                              //               milliseconds: 300),
                                              //           content: Text(
                                              //               "Already in cart")));
                                              //   //ignore:avoid_print
                                              //   print(
                                              //       ".............memesIdList duplicate: ${memeCartProvider.getMemesIdList.toString()}");
                                              // }
                                              // else {
                                              memeCartProvider.getMemesIdList!
                                                  .add(memeId);
                                              memeCartProvider
                                                  .addItem(addCartItem);
                                              context
                                                  .read<CartCounterProvider>()
                                                  .increment();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 800),
                                                content:
                                                    const Text("Added to Cart"),
                                                action: SnackBarAction(
                                                    label: "View Cart",
                                                    textColor: Colors.white,
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const CartPage()));
                                                    }),
                                              ));
                                              //ignore:avoid_print
                                              print(
                                                  ".............memesIdList add: ${memeCartProvider.getMemesIdList.toString()}");
                                            }
                                      // }
                                      ,
                                      style: ElevatedButton.styleFrom(
                                          primary: memeCartProvider
                                                  .getMemesIdList!
                                                  .contains(memeId)
                                              ? Colors.black.withOpacity(0.3)
                                              : Colors.black),
                                      child: Text(
                                        "Get This Meme",
                                        style: TextStyle(
                                            color: memeCartProvider
                                                    .getMemesIdList!
                                                    .contains(memeId)
                                                ? Colors.white.withOpacity(0.5)
                                                : Colors.white),
                                      )),
                                  PreviewDownload(imageUrl: memeImageUrl)*/
                                ]),
                          ));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error Occured : ${snapshot.error}"),
                      );
                    } else {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.teal,
                      ));
                    }
                  }),
            ),
          );
        },
      ),
    );
  }

  //todo: Share Function
  void shareAtIndex(String memeImageUrl, BuildContext context) async {
    //final directory_ = await getApplicationDocumentsDirectory();
    //final directory = await getExternalStorageDirectory().path;
    //print("\n---> Directory Path :\n${directory_}");

    final uri = Uri.parse(memeImageUrl);
    final response = await http.get(uri);
    final bytes  = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);
    Share.shareFiles([path], text: '');

    // ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // Uint8List pngBytes = byteData.buffer.asUint8List();
    // File imgFile = new File('$directory/screenshot.png');
    // imgFile.writeAsBytes(pngBytes);
    // final RenderBox box = context.findRenderObject();
    // Share.shareFile(File('$directory/screenshot.png'),
    // subject: 'Share ScreenShot',
    // text: 'Hello, check your share files!',
    // sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
    // );
  }

  //todo: Download Function
  Future<void> downloadAtIndex(String url, BuildContext context) async {

    var response = await http.get(Uri.parse(url));
    String imagePath = "";
    if (Platform.isIOS) {
      // Code specific to iOS
      var directory = await getApplicationDocumentsDirectory();
      if (directory != null) {
        imagePath = '${directory.path}/image132123.jpg';
      }else { return; }
      print('Running on iOS');
    } else if (Platform.isAndroid) {
      // Code specific to Android
      var directory = await getExternalStorageDirectory();
      if (directory != null) {
        imagePath = '${directory.path}/image132123.jpg';
      }else { return; }
      print('Running on Android');
    } else {
      // Code for other platforms
      print('Running on a platform other than iOS and Android');
    }
    //var directory = await getExternalStorageDirectory();
    // var dir = await get
    // var imagePath;
    // if (directory != null) {
    //   imagePath = '${directory.path}/image132123.jpg';
    //
    //
    //
    //   // Show a message or perform any other actions after the image is downloaded and saved
    // } else {
    //   // Handle the case where directory is null
    //   // Display an error message or take appropriate action
    //   final snackBar = SnackBar(
    //     content: Text('Error'),
    //     duration: Duration(seconds: 3),
    //     action: SnackBarAction(
    //       label: 'Close',
    //       onPressed: () {
    //         // Perform some action when the SnackBar action is pressed
    //       },
    //     ),
    //   );
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   return;
    // }
    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(response.bodyBytes);
    await GallerySaver.saveImage(imagePath);

    File imageFile2 = File(imagePath);
    await imageFile2.writeAsBytes(response.bodyBytes);

    final snackBar = SnackBar(
      content: Text('Downloaded'),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Perform some action when the SnackBar action is pressed
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> requestStoragePermissions(String url, BuildContext context) async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted, proceed with file operations
      downloadAtIndex(url , context);
    } else if (status.isDenied) {
      // Permission denied
      // Optionally, show an explanation to the user and ask again
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied
      // Open app settings for the user to manually grant permission
      openAppSettings();
    }
  }
}
