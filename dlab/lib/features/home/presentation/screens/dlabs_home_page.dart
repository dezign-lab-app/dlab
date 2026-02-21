import 'package:flutter/material.dart';

class DLabsHomePage extends StatelessWidget {
  const DLabsHomePage({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const _BottomNavBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _TopHeader(size: size),
          ),
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 1,
            toolbarHeight: size.height * 0.09,
            title: const _SearchBar(),
          ),
          SliverToBoxAdapter(
            child: _BannerSection(size: size),
          ),
          SliverToBoxAdapter(
            child: _CategoriesSection(size: size),
          ),
          const SliverToBoxAdapter(
            child: _SectionTitle(title: 'Recommended For You'),
          ),
          SliverToBoxAdapter(
            child: _HorizontalProducts(size: size),
          ),
          const SliverToBoxAdapter(
            child: _SectionTitle(title: 'Trending In Your Area'),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            sliver: _ProductGrid(size: size),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: size.height * 0.05),
          ),
        ],
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Location',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18),
                  SizedBox(width: 4),
                  Row(
                    children: [
                      Text(
                        'San Antinoe',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Color(0xff62B6CB),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: size.width * 0.12,
            width: size.width * 0.12,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffCAE9FF)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_none, color: Color(0xff1B4965)),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.055,
      decoration: BoxDecoration(
        color: Color(0xffF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xffCAE9FF)),
      ),
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xff9DB2CE),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              'Search here...',
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Color(0xff9DB2CE),
              ),
            ),
          ),
          Container(
            height: size.height * 0.045,
            width: size.height * 0.045,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              color: Color(0xff9DB2CE),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  const _BannerSection({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Container(
            height: size.height * 0.27,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xffCECECE)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'images/banner_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.black54,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.015,
                    left: size.width * 0.04,
                    child: Image.asset(
                      'images/dlab_logo.png',
                      height: size.height * 0.035,
                      fit: BoxFit.contain,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  Positioned(
                    left: size.width * 0.05,
                    top: size.height * 0.07,
                    child: SizedBox(
                      width: size.width * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our New Product\nin Headphones',
                            style: TextStyle(
                              fontSize: size.width * 0.055,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            'Shop now in lowest prices',
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xff1B4965),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'UP TO 50% OFF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.038,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: size.width * 0.02,
                    bottom: 0,
                    child: Image.asset(
                      'images/banner_headphones.png',
                      height: size.height * 0.23,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(isActive: false),
            SizedBox(width: size.width * 0.02),
            _dot(isActive: true),
            SizedBox(width: size.width * 0.02),
            _dot(isActive: false),
          ],
        ),
        SizedBox(height: size.height * 0.02),
      ],
    );
  }

  Widget _dot({required bool isActive}) {
    return Container(
      width: isActive ? 24 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Color(0xff1B4965) : Color(0xffCFCFCF),
        borderRadius: BorderRadius.circular(34),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    final categories = ['Deals', 'Free Shipping', 'Under 999', 'New', 'More'];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.015,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories For You',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Color(0xff6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            height: size.height * 0.14,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => SizedBox(width: size.width * 0.06),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      height: size.width * 0.18,
                      width: size.width * 0.18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xff1B4965).withOpacity(0.28),
                        ),
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        color: Color(0xff1B4965),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      categories[index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff111827),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  const _HorizontalProducts({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: size.width * 0.45,
            margin: EdgeInsets.only(right: size.width * 0.04),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  height: size.height * 0.12,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apple MacBook Pro Core i9',
                  maxLines: 2,
                ),
                const SizedBox(height: 5),
                const Text(
                  '₹2,24,900',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                const Text('Apple MacBook Pro'),
                const Text(
                  '₹2,24,900',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
        childCount: 6,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 600 ? 3 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xff111827),
      selectedItemColor: Color(0xff62B6CB),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
