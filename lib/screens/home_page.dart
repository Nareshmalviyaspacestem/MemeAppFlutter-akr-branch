import 'dart:async';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:memeapp/models/cart_card_model.dart';
import 'package:memeapp/providers/cart_counter_provider.dart';
import 'package:memeapp/providers/meme_cart_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memeapp/models/memes_model.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
      appBar: AppBar(
        backgroundColor: const Color(0xffA375AD),
        title: Image.asset(
          'assets/images/logo1.png',
          color: Colors.white,
          width: 130,
          height: 40,
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
              child: prepareGridView(context, snapshot),
            ),
          );
        },
      ),
    );
  }

  //todo: Prepare GridView
  GridView prepareGridView(BuildContext context, AsyncSnapshot<MemesModel> snapshot) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: snapshot.hasData ? snapshot.data!.data!.memes!.length : 1,
      itemBuilder: (context, index) {
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
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: SizedBox(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: [
                      SizedBox(
                          width: double.infinity,
                          child: Image.network(memeImageUrl , width: double.infinity,height: double.infinity,fit: BoxFit.cover,)

                      ),
                      GradientView(
                        colors: const [Colors.transparent, Color(0xffA375AD)],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(onPressed: (){
                              String memeImageUrl =
                              snapshot.data!.data!.memes![index].url.toString();
                              shareAtIndex(memeImageUrl , context);
                            }, icon: const Icon(Icons.share,color: Colors.white,)),
                            IconButton(onPressed: (){
                              requestStoragePermissions(memeImageUrl , context);
                            }, icon: const Icon(Icons.download,color: Colors.white,))

                          ],),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
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
      },
    );
  }

  //todo: Share Function
  void shareAtIndex(String memeImageUrl, BuildContext context) async {
    final uri = Uri.parse(memeImageUrl);
    final response = await http.get(uri);
    final bytes  = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);
    Share.shareFiles([path], text: '');
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
    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(response.bodyBytes);
    await GallerySaver.saveImage(imagePath);

    File imageFile2 = File(imagePath);
    await imageFile2.writeAsBytes(response.bodyBytes);

    final snackBar = SnackBar(
      content: const Text('Downloaded'),
      duration: const Duration(seconds: 3),
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


class GradientView extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  const GradientView({required this.colors, required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}


/*
PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Image.asset(
                'assets/images/logo1.png',
               color: Colors.white,
                width: 150,
                height: 40,
              ),
            ),
          ),
          backgroundColor: const Color(0xffA375AD),
        ),
      ),
 */