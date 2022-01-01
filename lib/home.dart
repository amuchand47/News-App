import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart';
import 'package:khul/model.dart';

class Home extends StatefulWidget {
  const Home({key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController searchController = new TextEditingController();

  List<NewsQueryModel> newsModelList = <NewsQueryModel>[];
  List<NewsQueryModel> newsModelListCarousel = <NewsQueryModel>[];

  List<String> navBarItem = ["world", "finance", "health", "sport", "gadget"];

  bool isLoading = true;

  // getting data from api by query
  getNewsByQuery(String query) async {

    String url = "https://newsapi.org/v2/everything?q=$query&from=2021-12-01&sortBy=publishedAt&apiKey=cad510c1cfc448b4b5ca122567ac0125";

    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);

    setState(() {

      if(newsModelList.isNotEmpty)
      newsModelList.clear();

      data["articles"].forEach((element) {
        NewsQueryModel newsQueryModel = new NewsQueryModel();
        newsQueryModel = NewsQueryModel.fromMap(element);
        newsModelList.add(newsQueryModel);

        setState(() {
          isLoading = false;
        });

      });
    });

  }

  // getting indian news data from api
  getNewsOfIndia() async {

    String url = "https://newsapi.org/v2/top-headlines?country=in&apiKey=cad510c1cfc448b4b5ca122567ac0125";

    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);

    setState(() {
      data["articles"].forEach((element) {
        NewsQueryModel newsQueryModel = new NewsQueryModel();
          newsQueryModel = NewsQueryModel.fromMap(element);
          newsModelListCarousel.add(newsQueryModel);
        setState(() {
          isLoading = false;
        });

      });
      newsModelList.forEach((news) {
        if(news.newsUrl==null){
          print(news.newsHead);
        }
      });

    });

  }

  //
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsOfIndia();
    getNewsByQuery("omicron");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("INDIAN NEWS"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(

        child: Column(

          children: [

            // search container
            Container(
              //Search Wala Container

              padding: EdgeInsets.symmetric(horizontal: 8),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if ((searchController.text).replaceAll(" ", "") == "") {
                        print("Blank search");
                      } else {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => Search(searchController.text)));
                      }
                    },
                    child: Container(
                      child: Icon(
                        Icons.search,
                        color: Colors.blueAccent,
                      ),
                      margin: EdgeInsets.fromLTRB(3, 0, 7, 0),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        print(value);
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Search Health"),
                    ),
                  )
                ],
              ),
            ),

            // suggestion container
            Container(
                height: 50,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: navBarItem.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          getNewsByQuery(navBarItem[index]);
                          print(navBarItem[index]);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                            child: Text(navBarItem[index],
                                style: TextStyle(
                                    fontSize: 19,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    })),

            //  news container
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: CarouselSlider(
                options: CarouselOptions(
                    height: 200, autoPlay: true, enlargeCenterPage: true),
                items: newsModelListCarousel.map((instance) {
                  return Builder(builder: (BuildContext context) {
                    return Container(
                        child : Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child : Stack(
                                children : [
                                  ClipRRect(
                                      borderRadius : BorderRadius.circular(10),
                                      child : Image.network(instance.newsImg!=null?instance.newsImg: "https://picsum.photos/250?image=9", fit: BoxFit.fitHeight, height: double.infinity,)
                                  ) ,
                                  Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(

                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Colors.black12.withOpacity(0),
                                                  Colors.black
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter
                                            )
                                        ),
                                        child : Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5 , vertical: 10),
                                            child:Text(instance.newsHead , style: TextStyle(fontSize: 18 , color: Colors.white , fontWeight: FontWeight.bold),)
                                        ),
                                      )
                                  ),
                                ]
                            )
                        )
                    );
                  });
                }).toList(),
              ),
            ),

            // headlines container
            Container(
              child: Column(
                children: [
                  Container(
                    margin : EdgeInsets.fromLTRB(15, 25, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("LATEST NEWS " , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 28
                        ),),
                      ],
                    ),
                  ),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: newsModelList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 1.0,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: newsModelList[index].newsImg!=null?Image.network(newsModelList[index].newsImg):Image.asset("assets/images/image.jpg")  // image dalna hai yahan
                                  ),

                                  Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black12.withOpacity(0),
                                                    Colors.black
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter
                                              )
                                          ),
                                          padding: EdgeInsets.fromLTRB(15, 15, 10, 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                newsModelList[index].newsHead,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Text(newsModelList[index].newsDes!=null?newsModelList[index].newsDes:"Wait..." , style: TextStyle(color: Colors.white , fontSize: 12)
                                                ,)
                                            ],
                                          )))
                                ],
                              )),
                        );
                      }),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: () {}, child: Text("SHOW MORE")),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  final List items = ["HELLO MAN", "NAMAS STAY", "DIRTY FELLOW"];
}