import 'package:flutter/material.dart';

class Item {
  final String name;
  final double price;
  final int reviewCount;
  final String image;

  Item({
    required this.name,
    required this.price,
    required this.reviewCount,
    required this.image,
  });
}

List<Item> itemList = [
  Item(
    name: 'BLUEBERRY',
    price: 5.66,
    reviewCount: 433,
    image: 'assets/images/blueberry.png',
  ),
  Item(
    name: 'ORANGE',
    price: 8.82,
    reviewCount: 200,
    image: 'assets/images/orange.png',
  ),
];

Color MainColor = const Color(0XFFF4C750);
Color PrimaryColor = const Color(0XFF1E1E1E);
Color SecondaryColor = const Color(0XFF2C2C2C);
Color tColor = const Color(0XFF161616);
Color iconBack = const Color(0XFF262626);

class IconDetail {
  final String image;
  final String head;

  IconDetail({
    required this.image,
    required this.head,
  });
}

List<IconDetail> iconsList = [
  IconDetail(image: 'assets/icons/LikeOutline.svg', head: 'Quality\nAssurance'),
  IconDetail(image: 'assets/icons/StartOutline.svg', head: 'Highly\nRated'),
  IconDetail(image: 'assets/icons/SpoonOutline.svg', head: 'Best In\nTaste'),
];
