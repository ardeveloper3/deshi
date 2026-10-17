import 'package:carousel_slider/carousel_slider.dart';
import 'package:appwrite/models.dart' as models;
import 'package:deshi/core/constance/color_const.dart';
import 'package:deshi/core/constance/icons.dart';
import 'package:deshi/core/constance/textStyle.dart';
import 'package:deshi/core/data/models/banner_item.dart';
import 'package:deshi/core/services/appwrite_service.dart';
import 'package:deshi/core/utils/bottomSheet.dart';
import 'package:deshi/core/utils/infoCard.dart';
import 'package:deshi/core/utils/liquideButton.dart';
import 'package:deshi/core/utils/productCard.dart';
import 'package:deshi/core/utils/sellerProfile.dart';
import 'package:deshi/core/utils/smallButton.dart';
import 'package:deshi/core/widgets/animated_reveal.dart';
import 'package:deshi/core/widgets/appwrite_error_dialog.dart';
import 'package:deshi/feature/home/domain/repositories/ourInfo.dart';
import 'package:deshi/feature/home/presentation/screens/orders_screen.dart';
import 'package:deshi/feature/account/presentation/screens/account_screen.dart';
import 'package:deshi/feature/home/presentation/widgets/infoTile.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AppwriteService _appwriteService = AppwriteService();
  late Future<List<models.Row>> _productsFuture;
  late Future<List<BannerItem>> _bannersFuture;
  late Future<List<models.Row>> _sellersFuture;
  bool _productErrorShown = false;
  bool _bannerErrorShown = false;
  bool _sellerErrorShown = false;

  void OpeanBottomSheet({
    String productName = 'মুরগি',
    String productPrice = '659',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Bottomsheet(
          productName: productName,
          ProductPrice: productPrice,
        );
      },
    );
  }

  int currentIndex = 0;
  bool _isPinging = false;
  String? _appwriteStatus;

  List<OurInfo> ourInfos = [
    OurInfo(
      icon: ConstIcons.leafIcon,
      title: "১০০% দেশি",
      shortText: "খাঁটি গ্রামে পালিত",
    ),
    OurInfo(
      icon: ConstIcons.deliveryIcon,
      title: "হোম ডেলিভারি",
      shortText: "বাড়িতে পৌঁছে দিই",
    ),
    OurInfo(
      icon: ConstIcons.trustedIcon,
      title: "বিশ্বস্ত",
      shortText: "পরিচিত সরবরাহকারী",
    ),
    OurInfo(
      icon: ConstIcons.moneyIcon,
      title: "ন্যায্য মূল্য",
      shortText: "সাশ্রয়ী দাম",
    ),
  ];
  @override
  void initState() {
    super.initState();
    _productsFuture = _appwriteService.fetchProducts();
    _bannersFuture = _appwriteService.getBanners();
    _sellersFuture = _appwriteService.fetchSellers();
  }

  String _productValue(models.Row product, String key) {
    final value = product.data[key];
    return value?.toString().trim() ?? '';
  }

  String _productPrice(models.Row product) {
    final price = _productValue(product, 'price');
    return price.isEmpty ? 'দাম জানা নেই' : '৳ $price';
  }

  String _productQuantity(models.Row product) {
    final quantity = _productValue(product, 'quantity');
    if (quantity.isEmpty) {
      return 'স্টক তথ্য নেই';
    }

    final numericQuantity = num.tryParse(quantity);
    final displayQuantity = numericQuantity == null
        ? quantity
        : numericQuantity.toStringAsFixed(0);
    return 'স্টক: $displayQuantity টি';
  }

  void _showProductError(Object error) {
    if (_productErrorShown || !mounted) return;
    _productErrorShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('পণ্য লোড করা যায়নি'),
          content: Text(AppwriteService.errorMessage(error)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ঠিক আছে'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _productErrorShown = false;
                  _productsFuture = _appwriteService.fetchProducts();
                });
              },
              child: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      );
    });
  }

  void _showBannerError(Object error) {
    if (_bannerErrorShown || !mounted) return;
    _bannerErrorShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ব্যানার লোড করা যায়নি'),
          content: Text(AppwriteService.errorMessage(error)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ঠিক আছে'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _bannerErrorShown = false;
                  _bannersFuture = _appwriteService.getBanners();
                });
              },
              child: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      );
    });
  }

  void _showSellerError(Object error) {
    if (_sellerErrorShown || !mounted) return;
    _sellerErrorShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showAppwriteErrorDialog(
        context: context,
        title: 'সরবরাহকারী লোড করা যায়নি',
        error: error,
        onRetry: () {
          setState(() {
            _sellerErrorShown = false;
            _sellersFuture = _appwriteService.fetchSellers();
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final indicatorIndex = currentIndex % 4;

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(ConstIcons.appIcon, width: 50, height: 50),
        title: Text(
          "দেশি",
          style: TextConst.heading.copyWith(color: ColorConst.darkGreenColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'আমার অ্যাকাউন্ট',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AccountScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'স্থানীয় অর্ডার',
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder<void>(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const OrdersScreen(),
                  transitionDuration: const Duration(milliseconds: 420),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );
                        return FadeTransition(
                          opacity: curved,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.08, 0),
                              end: Offset.zero,
                            ).animate(curved),
                            child: child,
                          ),
                        );
                      },
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          if (_appwriteStatus != null)
            Tooltip(
              message: _appwriteStatus!,
              child: const Icon(Icons.info_outline, size: 20),
            ),
          Image.asset(ConstIcons.accountIcon, width: 40, height: 40),
          SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  children: [
                    SizedBox(height: 10),

                    AnimatedReveal(
                      child: FutureBuilder<List<BannerItem>>(
                        future: _bannersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: isWide ? 330 : 200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            _showBannerError(snapshot.error!);
                            return SizedBox(
                              height: isWide ? 330 : 200,
                              child: const Center(
                                child: Text('ব্যানার লোড করা যায়নি'),
                              ),
                            );
                          }
                          final bannerItems = snapshot.data ?? [];
                          if (bannerItems.isEmpty) {
                            return SizedBox(
                              height: isWide ? 330 : 200,
                              child: const Center(
                                child: Text('কোনো ব্যানার পাওয়া যায়নি'),
                              ),
                            );
                          }
                          return CarouselSlider(
                            options: CarouselOptions(
                              height: isWide ? 330.0 : 200.0,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 3),
                              enlargeCenterPage: false,
                              viewportFraction: 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                });
                              },
                            ),
                            items: bannerItems.map((banner) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    color: ColorConst.darkGreenColor,
                                    child: Image.network(
                                      banner.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.black.withAlpha(90),
                                      colorBlendMode: BlendMode.darken,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) => const SizedBox.shrink(),
                                    ),
                                  ),
                                  Center(
                                    child: Image.network(
                                      banner.imageUrl,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              color: Colors.white70,
                                              size: 42,
                                            );
                                          },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 10,
                                    child: SmallButton(
                                      title: 'অর্ডার করুন',
                                      onTap: () => OpeanBottomSheet(
                                        productName: banner.productName,
                                        productPrice: banner.price,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 20,
                                    left: 30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        bannerItems.length,
                                        (index) => Container(
                                          width: indicatorIndex == index
                                              ? 20
                                              : 10,
                                          height: 10,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: indicatorIndex == index
                                                ? ColorConst.lightGreen
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                    AnimatedReveal(
                      delay: const Duration(milliseconds: 120),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        color: ColorConst.darkGreenColor,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  ConstIcons.villageHome,
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "সরাসরি গ্রাম থেকে",
                                  style: TextConst.body.copyWith(
                                    color: ColorConst.lightGreen,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "গ্রামের দেশি হাঁস-মুরগি,",
                              style: TextConst.heading.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "এখন আপনার ঘরে,",
                              style: TextConst.subheading.copyWith(
                                color: ColorConst.lightGreen,
                              ),
                            ),
                            Text(
                              "গ্রামের পরিবার ও ছোট খামার থেকে সংগ্রহ করে আপনার বাসায় পৌঁছে দিই।",
                              style: TextConst.body.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Wrap(
                              spacing: 10,
                              runSpacing: 0,
                              children: [
                                LiquidButton(title: "✓ গ্রাম থেকে সংগ্রহ"),
                                LiquidButton(title: "✓ Home Delivery"),
                              ],
                            ),
                            LiquidButton(title: "✓ Fresh & Authentic"),

                          ],
                        ),
                      ),
                    ),
                    AnimatedReveal(
                      delay: const Duration(milliseconds: 220),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        color: ColorConst.cuteSugarColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "পণ্যের ধরন",
                              style: TextConst.heading.copyWith(
                                color: ColorConst.darkGreenColor,
                              ),
                            ),
                            Text(
                              "তাজা ও দেশি হাঁস-মুরগি সরাসরি গ্রাম থেকে",
                              style: TextConst.body.copyWith(
                                color: ColorConst.lightGreen,
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 365,
                              child: FutureBuilder<List<models.Row>>(
                                future: _productsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    _showProductError(snapshot.error!);
                                    return const Center(
                                      child: Text('পণ্য লোড করা যায়নি'),
                                    );
                                  }

                                  final products = snapshot.data ?? [];
                                  if (products.isEmpty) {
                                    return const Center(
                                      child: Text('কোনো পণ্য পাওয়া যায়নি'),
                                    );
                                  }

                                  return ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: products.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                      final name = _productValue(
                                        product,
                                        'productName',
                                      );
                                      final weight = _productValue(
                                        product,
                                        'weight',
                                      );

                                      return SizedBox(
                                        width: isWide ? 280 : 260,
                                        child: ProductCard(
                                          imageUrl: 'https://5.imimg.com/data5/ANDROID/Default/2023/1/AZ/KP/JE/144793528/product-jpeg-500x500.jpg',
                                          productName: name.isEmpty
                                              ? 'দেশি পণ্য'
                                              : name,
                                          availabilityText: _productQuantity(
                                            product,
                                          ),
                                          price: _productPrice(product),
                                          weight: weight.isEmpty
                                              ? 'তথ্য নেই'
                                              : weight,
                                          updatedText: 'অর্ডার করুন',
                                          isAvailable: true,
                                          onOrderPressed: () =>
                                              OpeanBottomSheet(
                                                productName: name.isEmpty
                                                    ? 'দেশি পণ্য'
                                                    : name,
                                                productPrice: _productValue(
                                                  product,
                                                  'price',
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    AnimatedReveal(
                      delay: const Duration(milliseconds: 320),
                      child: Container(
                        width: double.infinity,
                        color: ColorConst.cuteSugarColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "আমাদের গ্রামের সরবরাহকারীরা",
                                    style: TextConst.heading.copyWith(
                                      color: ColorConst.darkGreenColor,
                                    ),
                                  ),
                                  Text(
                                    "গ্রামের বিভিন্ন পরিবার ও ছোট খামার থেকে সংগ্রহ করা।",
                                    style: TextConst.subheading.copyWith(
                                      color: ColorConst.lightGreen,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  FutureBuilder<List<models.Row>>(
                                    future: _sellersFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        _showSellerError(snapshot.error!);
                                        return const Center(
                                          child: Text(
                                            'সরবরাহকারীর তথ্য পাওয়া যায়নি',
                                          ),
                                        );
                                      }
                                      final sellers = snapshot.data ?? [];
                                      if (sellers.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            'কোনো সরবরাহকারী পাওয়া যায়নি',
                                          ),
                                        );
                                      }
                                      return Wrap(
                                        alignment: WrapAlignment.spaceEvenly,
                                        spacing: isWide ? 70 : 24,
                                        runSpacing: 20,
                                        children: sellers.map((seller) {
                                          String value(String key) =>
                                              seller.data[key]?.toString().trim() ?? '';
                                          return SellerProfile(
                                            imageUrl: value('profileImageUrl'),
                                            name: value('sellerName'),
                                            address: value('address'),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "কেন আমাদের বেছে নেবেন?",
                                    style: TextConst.heading.copyWith(
                                      color: ColorConst.darkGreenColor,
                                    ),
                                  ),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isWide ? 4 : 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: isWide ? 1.1 : 1.0,
                                        ),
                                    itemCount: ourInfos.length,
                                    itemBuilder: (context, index) {
                                      final info = ourInfos[index];
                                      return InfoCard(
                                        icon: info.icon,
                                        title: info.title,
                                        shortText: info.shortText,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              color: ColorConst.darkGreenColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        ConstIcons.appIcon,
                                        width: 50,
                                        height: 50,
                                      ),
                                      Text(
                                        "দেশি",
                                        style: TextConst.heading.copyWith(
                                          color: ColorConst.lightGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "গ্রামের পরিবার ও ছোট খামার থেকে সংগ্রহ করে সরাসরি আপনার বাসায় পৌঁছে দিই।",
                                    style: TextConst.body.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  infoTile(
                                    icon: ConstIcons.callIcon,
                                    title: "0190715352",
                                  ),
                                  SizedBox(height: 10),
                                  infoTile(
                                    icon: ConstIcons.emailIcon,
                                    title: "deshi@gmail.com",
                                  ),
                                  SizedBox(height: 10),
                                  infoTile(
                                    icon: ConstIcons.locationIcon,
                                    title: " ঢাকা, বাংলাদেশ",
                                  ),
                                  SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                    ),
                                    child: Divider(
                                      color: Colors.white.withAlpha(100),
                                      thickness: 1,
                                      height: 1,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "© 2026 দেশি ঘরের পালা। সর্বস্বত্ব সংরক্ষিত।",
                                      style: TextConst.body.copyWith(
                                        color: ColorConst.lightGreen,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 700) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorConst.darkGreenColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: infoTile(
                        icon: ConstIcons.chekenIcon,
                        title: "মুরগি  অর্ডার করুন",
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorConst.lightGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: infoTile(
                        icon: ConstIcons.duckIcon,
                        title: " হাঁস অর্ডার করুন",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
