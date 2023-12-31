import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pricecompare/article.dart';
import 'package:http/http.dart' as http;

import 'package:html/dom.dart' as dom;
import 'package:pricecompare/components/auth_methods.dart';
import 'package:pricecompare/screens/bookmarks.dart';
import 'package:pricecompare/screens/profile.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Article> articles = [];
  List<Article> filtered = [];

  @override
  void initState() {
    super.initState();
  }

  Future getFlipkartData() async {
    List<String> terms = search!.split(' ');
    List<String> copy = search!.split(' ');
    int i = 0;
    for (String x in terms) {
      try {
        if (int.parse(x) > 0) {
          terms[i] = '20$x';
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      i += 1;
    }
    String concatenatedString = terms.join(' ');
    String term = concatenatedString.replaceAll(' ', '%');
    final url = Uri.parse(
        'https://www.flipkart.com/search?q=$term&otracker=search&otracker1=search&marketplace=FLIPKART&as-show=on&as=off');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final titles = html
        .querySelectorAll('div._3pLy-c.row > div.col.col-7-12 > div._4rR01T')
        .map((e) => e.innerHtml.trim())
        .toList();

    final urls = html
        .querySelectorAll(
            'div._1YokD2._2GoDe3 > div:nth-child(2) > div:nth-child(3) > div > div > div > a')
        .map((e) => "https://www.amazon.in/${e.attributes['href']}")
        .toList();

    final images = html
        .querySelectorAll('div._2QcLo- > div > div > img')
        .map((e) => e.attributes['src']!)
        .toList();

    final prices = html
        .querySelectorAll('div._25b18c > div._30jeq3._1_WHN1')
        .map((e) => e.innerHtml
            .trim()
            .toString()
            .replaceAll(',', '')
            .replaceAll('₹', ''))
        .toList();

    final reviews = html
        .querySelectorAll(
            'div.gUuXy- > span._2_R_DZ > span > span:nth-child(1)')
        .map((e) => e.innerHtml.trim())
        .toList();

    double avg = 0;
    for (int i = 0; i < 5; i++) {
      avg += double.parse(prices[i]);
    }

    avg = avg / 5;

    List<Article> temp = [];

    for (int i = 0; i < 5; i++) {
      if (double.parse(prices[i]) > (avg / 2) &&
          double.parse(prices[i]) < (avg * 1.5)) {
        temp.add(
          Article(
            url: 'urls[i]',
            title: titles[i],
            store: 'flipkart',
            urlImage: images[i],
            price: double.parse(prices[i]),
            reviews: reviews[i],
          ),
        );
      }
    }

    for (int i = 0; i < temp.length; i++) {
      bool exist = true;
      copy.every(
        (searchTerm) {
          if (temp[i].title.split(' ').contains(searchTerm)) {
            exist = true;
          } else {
            exist = false;
          }
          return true;
        },
      );
      if (exist) {
        print('${temp[i].title} is added');
        filtered.add(temp[i]);
      }
    }

    print(filtered.length);
    setState(() {});
  }

  Future getAmazonData() async {
    List<String> copy = search!.split(' ');

    String term = search!.replaceAll(' ', '+');
    final url = Uri.parse('https://www.amazon.in/s?k=$term&ref=nb_sb_noss_2');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final titles = html
        .querySelectorAll(
            'div.a-section.a-spacing-none.puis-padding-right-small.s-title-instructions-style > h2 > a > span')
        .map((e) => e.innerHtml.trim())
        .toList();

    final urls = html
        .querySelectorAll(
            'div.a-section.a-spacing-none.puis-padding-right-small.s-title-instructions-style > h2 > a')
        .map((e) => "https://www.amazon.in/${e.attributes['href']}")
        .toList();

    final images = html
        .querySelectorAll('div > span > a > div > img')
        .map((e) => e.attributes['src']!)
        .toList();

    final prices = html
        .querySelectorAll('span.a-price-whole')
        .map((e) => e.innerHtml.trim().toString().replaceAll(',', ''))
        .toList();

    final reviews = html
        .querySelectorAll('span.a-size-base.s-underline-text')
        .map((e) => e.innerHtml.trim())
        .toList();

    double avg = 0;
    for (int i = 0; i < 5; i++) {
      avg += double.parse(prices[i]);
    }

    avg = avg / 5;
    List<Article> temp = [];
    for (int i = 0; i < 5; i++) {
      if (double.parse(prices[i]) > (avg / 2) &&
          double.parse(prices[i]) < (avg * 1.5)) {
        temp.add(
          Article(
            url: urls[i],
            title: titles[i],
            store: 'amazon',
            urlImage: images[i],
            price: double.parse(prices[i]),
            reviews: reviews[i],
          ),
        );
      }
    }
    for (int i = 0; i < temp.length; i++) {
      bool exist = true;
      copy.every(
        (searchTerm) {
          if (temp[i].title.split(' ').contains(searchTerm)) {
            exist = true;
          } else {
            exist = false;
          }
          return true;
        },
      );
      if (exist) {
        print('${temp[i].title} is added');
        filtered.add(temp[i]);
      }
    }

    setState(() {});
  }

  TextEditingController searchword = TextEditingController();
  String? search;
  bool isLoading = false;
  int Pageindex = 0;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    List<dynamic> widgetTabs = [
      SearchPage(width, height, context),
      BookmarksScreen(),
      UserProfile(),
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: width * 0.8,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.08,
                ),
              ),
            ],
          ),
        ),
      ),
      body: widgetTabs[Pageindex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            padding: EdgeInsets.all(16),
            activeColor: Colors.white,
            gap: 8,
            onTabChange: (value) {
              setState(() {
                Pageindex = value;
              });
            },
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.bookmark,
                text: 'Bookmarks',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Center ProfilePage() => Center(
        child: Text('Profile page'),
      );

  Center Bookmarks() => Center(child: Text('Bookmarks'));

  Padding SearchPage(double width, double height, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: width * 0.8,
                child: TextField(
                  controller: searchword,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    hintText: 'Enter a search item',
                  ),
                  onSubmitted: (value) async {
                    filtered.clear();
                    setState(() {
                      isLoading = true;
                      search = value;
                      articles.clear();
                    });
                    await getAmazonData();
                    await getFlipkartData();
                    articles.sort(
                      (a, b) => a.price.compareTo(b.price),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  height: height * 0.08,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4edb86),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Align(
                    alignment: Alignment.center,
                    child: FaIcon(
                      FontAwesomeIcons.searchengin,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                    ((MediaQuery.of(context).size.height * 0.75)),
              ),
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final article = filtered[index];
                return GestureDetector(
                  onTap: () async {
                    String url = article.url;
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
                                  article.urlImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      AuthMethods().bookmark(
                                        url: article.url,
                                        price: article.price,
                                        store: article.store,
                                        title: article.title,
                                        urlImage: article.urlImage,
                                      );

                                      final snackBar = SnackBar(
                                        /// need to set following properties for best effect of awesome_snackbar_content
                                        elevation: 0,
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        content: AwesomeSnackbarContent(
                                          title: 'Added',
                                          message: 'Go to bookmarks section.',

                                          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                          contentType: ContentType.success,
                                        ),
                                      );

                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(snackBar);
                                    },
                                    child: Container(
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.bookmark),
                                        )),
                                  )),
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
                                  article.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '\₹ ${article.price.toString()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    article.store == 'flipkart'
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
            ),
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(),
        ],
      ),
    );
  }
}
