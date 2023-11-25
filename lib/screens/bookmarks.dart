import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarksScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
      ),
      body: FutureBuilder(
        future: _getBookmarks(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show a loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookmarks found.'));
          } else {
            // Data fetched successfully, build the ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var bookmark = snapshot.data![index];
                return GestureDetector(
                  onTap: () async {
                    String url = bookmark['url'];
                    print(url);
                    var urllaunchable = await canLaunchUrl(Uri.parse(url));
                    if (urllaunchable) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      print("URL can't be launched.");
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFEEEFF2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 130,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  bookmark['urlImage'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Positioned(
                              //     top: 0,
                              //     right: 0,
                              //     child: GestureDetector(
                              //       onTap: () async {
                              //         AuthMethods().bookmark(
                              //           url: article.url,
                              //           price: article.price,
                              //           store: article.store,
                              //           title: article.title,
                              //           urlImage: article.urlImage,
                              //         );

                              //         final snackBar = SnackBar(
                              //           /// need to set following properties for best effect of awesome_snackbar_content
                              //           elevation: 0,
                              //           behavior: SnackBarBehavior.floating,
                              //           backgroundColor: Colors.transparent,
                              //           content: AwesomeSnackbarContent(
                              //             title: 'Added',
                              //             message: 'Go to bookmarks section.',

                              //             /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                              //             contentType: ContentType.success,
                              //           ),
                              //         );

                              //         ScaffoldMessenger.of(context)
                              //           ..hideCurrentSnackBar()
                              //           ..showSnackBar(snackBar);
                              //       },
                              //       child: Container(
                              //           color: Colors.white,
                              //           child: Padding(
                              //             padding: const EdgeInsets.all(8.0),
                              //             child: Icon(Icons.bookmark),
                              //           )),
                              //     )),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  bookmark['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '\₹ ${bookmark['price'].toString()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    bookmark['store'] == 'flipkart'
                                        ? Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color(0xff26577C),
                                            ),
                                            child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    // vertical: 12.0,
                                                    // horizontal: 12,
                                                    ),
                                                child: Image(
                                                  image: AssetImage(
                                                    'assets/images/flipkart.png',
                                                  ),
                                                )
                                                // FaIcon(
                                                //   FontAwesomeIcons.chevronRight,
                                                //   color: Colors.white,
                                                //   size: 13,
                                                // ),
                                                ),
                                          )
                                        : Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color(0xff26577C),
                                            ),
                                            child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    // vertical: 12.0,
                                                    // horizontal: 12,
                                                    ),
                                                child: Image(
                                                  image: AssetImage(
                                                    'assets/images/amazon.png',
                                                  ),
                                                )
                                                // FaIcon(
                                                //   FontAwesomeIcons.chevronRight,
                                                //   color: Colors.white,
                                                //   size: 13,
                                                // ),
                                                ),
                                          )
                                  ],
                                ),
                              ]),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getBookmarks() async {
    var userUid = _auth.currentUser!.uid;

    var documentSnapshot =
        await _firestore.collection('bookmarks').doc(userUid).get();
    var data = documentSnapshot.data();

    if (data != null && data.containsKey('bookmarks')) {
      // 'bookmarks' array exists, return its contents
      return List<Map<String, dynamic>>.from(data['bookmarks']);
    } else {
      // 'bookmarks' array doesn't exist or is empty
      return [];
    }
  }
}
