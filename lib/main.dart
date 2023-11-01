import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:pricecompare/article.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Price Comparison',
      theme: ThemeData(
        fontFamily: 'Gabarito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Article> articles = [];
  @override
  void initState() {
    super.initState();
  }

  Future getFlipkartData() async {
    String term = search!.replaceAll(' ', '%');
    print('search word ${term}');
    final url = Uri.parse(
        'https://www.flipkart.com/search?q=${term}&otracker=search&otracker1=search&marketplace=FLIPKART&as-show=on&as=off');
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

    print('count: ${prices[0]}');

    setState(() {
      articles.addAll(List.generate(
        5,
        (index) => Article(
          url: 'urls[index]',
          title: titles[index],
          urlImage: images[index],
          price: double.parse(prices[index]),
          reviews: reviews[index],
        ),
      ));
    });
  }

  Future getAmazonData() async {
    String term = search!.replaceAll(' ', '+');
    print('search word ${term}');
    final url = Uri.parse('https://www.amazon.in/s?k=${term}&ref=nb_sb_noss_2');
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

    print('count: ${prices[0]}');

    setState(() {
      articles.addAll(List.generate(
        5,
        (index) => Article(
          url: urls[index],
          title: titles[index],
          urlImage: images[index],
          price: double.parse(prices[index]),
          reviews: reviews[index],
        ),
      ));
    });
  }

  TextEditingController searchword = TextEditingController();
  String? search;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
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
        body: Padding(
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
                      onSubmitted: (value) {
                        setState(() {
                          search = value;
                          getAmazonData();
                          getFlipkartData();
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ListTile(
                      leading: Image.network(
                        article.urlImage,
                        width: 50,
                        fit: BoxFit.fitHeight,
                      ),
                      title: Text(article.title),
                      // subtitle: Text(article.price.toString()),
                      subtitle: Text(article.price.toString()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}