import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocerry/utils.dart';

class ItemScreen extends StatelessWidget {
  final Item e;
  const ItemScreen({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 60,
        backgroundColor: primaryColor,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: const Color.fromARGB(255, 90, 90, 90),
              child: SvgPicture.asset(
                'assets/icons/cartIcon.svg',
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
          child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text('FRUITS',
                style: TextStyle(
                    fontSize: 20, color: mainColor, letterSpacing: 10)),
            const SizedBox(height: 10),
            Text(e.name,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                )),
            const SizedBox(height: 10),
            Text(
              "⭐ (${e.reviewCount} reviews)",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 150),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          MediaQuery.of(context).size.width / 2.7),
                      topRight: Radius.circular(
                          MediaQuery.of(context).size.width / 2.7),
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 55),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(10, -40),
                        child: Transform.scale(
                          scale: 2.6,
                          child: Image(
                            image: AssetImage(e.image),
                            height: 100,
                            width: 100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$ ${e.price}',
                                style: TextStyle(
                                    color: mainColor.withOpacity(0.6),
                                    fontSize: 35),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "PER KG",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 174, 173, 173),
                                    letterSpacing: 5),
                              )
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: iconBackgroundColor,
                            radius: 30,
                            child: SvgPicture.asset(
                              'assets/icons/heartIcon.svg',
                              height: 24,
                              width: 24,
                              colorFilter: const ColorFilter.mode(
                                  Colors.red, BlendMode.srcIn),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: iconsList
                            .map((iconDetail) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundColor: iconBackgroundColor,
                                      child: SvgPicture.asset(
                                        iconDetail.image,
                                        colorFilter: const ColorFilter.mode(
                                            Colors.grey, BlendMode.srcIn),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      iconDetail.head,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                              255, 157, 157, 157)),
                                    )
                                  ],
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          firstGestureDetector(),
                          GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                height: 45,
                                decoration: BoxDecoration(
                                    color: mainColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(13))),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Go To Cart',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 6, 2, 67),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    SvgPicture.asset(
                                      'assets/icons/arrowRight.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(
                                          Color.fromARGB(255, 6, 2, 67),
                                          BlendMode.srcIn),
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  GestureDetector firstGestureDetector() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(13))),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/icons/minus-solid.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                    Color.fromARGB(255, 157, 157, 157), BlendMode.srcIn),
              ),
            ),
            const Text(
              "0",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            IconButton(
              iconSize: 14,
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/icons/plus-solid.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                    Color.fromARGB(255, 157, 157, 157), BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
