import 'dart:async';
import 'dart:ffi';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:memeapp/models/cart_card_model.dart';
import 'package:memeapp/providers/cart_counter_provider.dart';
import 'package:memeapp/providers/meme_cart_provider.dart';
import 'package:memeapp/screens/cart_page.dart';
import 'package:memeapp/screens/preview_download.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memeapp/models/memes_model.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
//fileName : fintechdashboardclone

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
      backgroundColor: const Color(0xffEFE9FF),
      appBar: AppBar(
        title: const Text(
          "Memes App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0, top: 5.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                    icon: const Icon(
                      Icons.filter_list_rounded,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                    onPressed: () {

                      /*Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CartPage()));
                      */

                    }),
              /*  Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.orange,
                      maxRadius: 10,
                    ),
                    Text("$cartCounter"),
                  ],
                ),*/
              ],
            ),
          )
        ],
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
                          elevation: 10,
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
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0) ,topRight:  Radius.circular(8.0)),
                                      child: SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: Image.network(memeImageUrl , width: double.infinity,height: double.infinity,fit: BoxFit.fill,)

                                      )),
                                  const SizedBox(height: 5),
                                 Row(children: [
                                   IconButton(onPressed: (){
                                     shareAtIndex(index!, context);
                                   }, icon: const Icon(Icons.share)),
                                   IconButton(onPressed: (){

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
  void shareAtIndex(int index, BuildContext context) async {
    final directory_ = await getApplicationDocumentsDirectory();
    // final directory = await getExternalStorageDirectory().path;
    print("\n---> Directory Path :\n${directory_}");
    Share.share('check out my website https://example.com');
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
  void downloadAtIndex(int index) {

  }
}
