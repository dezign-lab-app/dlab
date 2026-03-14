import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_details_page.dart';

// ─────────────────────────────────────────────
// HOME PAGE ENTRY (router target)
// ─────────────────────────────────────────────
class DLabsHomePage extends StatelessWidget {
  const DLabsHomePage({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context) => const MainShell();
}

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF1B4965);
  static const secondary = Color(0xFF62B6CB);
  static const secondBlue = Color(0xFF27C4F4);
  static const bgLight = Color(0xFFF4F9FF);
  static const border = Color(0xFFCAE9FF);
  static const cardBorder = Color(0xFFF2F2F2);
  static const muted = Color(0xFF6B7280);
  static const textPrimary = Color(0xFF111827);
  static const darkBg = Color(0xFF111827);
  static const navActive = Color(0xFF62B6CB);
  static const navInactive = Color(0xFF676D75);
  static const red = Color(0xFFFF0005);
}

// ─────────────────────────────────────────────
// MAIN SHELL (with bottom nav)
// ─────────────────────────────────────────────
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    CategoriesPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onSelectPage: (pageIndex) =>
            setState(() => _currentIndex = pageIndex),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectPage;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onSelectPage,
  });

  void _handleTap(int index) {
    final pageIndex = index > 2 ? index - 1 : index;
    onSelectPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final barHeight = (w * 0.145).clamp(56.0, 72.0);
          final totalHeight = barHeight;
          final centerSize = (barHeight * 0.9).clamp(52.0, 68.0);
          final iconSize = (w * 0.06).clamp(22.0, 26.0);
          final labelSize = (w * 0.03).clamp(11.0, 13.0);

          return Container(
            height: totalHeight,
            color: AppColors.darkBg,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: barHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavItemImage(
                            index: 0,
                            currentIndex: currentIndex,
                            assetPath: 'assets/icons/home.png',
                            label: 'Home',
                            iconSize: iconSize,
                            labelSize: labelSize,
                            onTap: _handleTap,
                          ),
                        ),
                        Expanded(
                          child: _NavItemImage(
                            index: 1,
                            currentIndex: currentIndex,
                            assetPath: 'assets/icons/category.png',
                            label: 'Categories',
                            iconSize: iconSize,
                            labelSize: labelSize,
                            onTap: _handleTap,
                          ),
                        ),
                        SizedBox(width: centerSize * 0.7),
                        Expanded(
                          child: _NavItemImage(
                            index: 3,
                            currentIndex: currentIndex,
                            assetPath: 'assets/icons/cart.png',
                            label: 'Cart',
                            iconSize: iconSize,
                            labelSize: labelSize,
                            onTap: _handleTap,
                          ),
                        ),
                        Expanded(
                          child: _NavItemImage(
                            index: 4,
                            currentIndex: currentIndex,
                            assetPath: 'assets/icons/user.png',
                            label: 'Profile',
                            iconSize: iconSize,
                            labelSize: labelSize,
                            onTap: _handleTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: barHeight - (centerSize * 0.75),
                  child: Container(
                    width: centerSize,
                    height: centerSize,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.darkBg, width: centerSize * 0.08),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/center.png',
                        width: iconSize,
                        height: iconSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavItemImage extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String assetPath;
  final String label;
  final double iconSize;
  final double labelSize;
  final ValueChanged<int> onTap;

  const _NavItemImage({
    required this.index,
    required this.currentIndex,
    required this.assetPath,
    required this.label,
    required this.iconSize,
    required this.labelSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            width: iconSize,
            height: iconSize,
            color: isActive ? AppColors.navActive : AppColors.navInactive,
          ),
          SizedBox(height: labelSize * 0.4),
          Text(label,
              style: TextStyle(
                fontSize: labelSize,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCity = 'San Antonio';
  String _selectedCountry = 'United States';
  final List<ProductModel> _infiniteProducts = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(),
          _buildStickySearch(),
          SliverToBoxAdapter(child: _buildBody()),
          SliverToBoxAdapter(child: _buildTrustBadges()),
          _buildInfiniteProductsGrid(),
          SliverToBoxAdapter(child: _buildInfiniteFooter()),
        ],
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    final threshold = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final products = await ProductService.fetchProducts(
      limit: _pageSize,
      offset: _offset,
    );
    if (!mounted) return;
    setState(() {
      _infiniteProducts.addAll(products);
      _offset += products.length;
      _isLoadingMore = false;
      if (products.length < _pageSize) _hasMore = false;
    });
  }

  Widget _buildTrustBadges() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(height: 0.5, color: const Color(0xFF9DB2CE)),
        const TrustBadgesRow(),
        Container(height: 0.5, color: const Color(0xFF9DB2CE)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfiniteFooter() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox(height: 80);
  }

  SliverToBoxAdapter _buildInfiniteProductsGrid() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _ProductGrid(products: _infiniteProducts),
      ),
    );
  }

  SliverAppBar _buildSliverHeader() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      floating: true,
      snap: true,
      expandedHeight: 64,
      collapsedHeight: 44,
      toolbarHeight: 44,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Row(
                      children: [
                        _iconButton(Icons.notifications_outlined),
                        const SizedBox(width: 8),
                        _iconButton(Icons.shopping_cart_outlined),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 0),
                GestureDetector(
                  onTap: _showLocationPicker,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '$_selectedCity, $_selectedCountry',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppColors.secondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 24),
    );
  }

  SliverAppBar _buildStickySearch() {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 68,
      title: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(width: 12),
            Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text('Search products...',
                  style: TextStyle(color: AppColors.muted, fontSize: 15)),
            ),
            Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.document_scanner_outlined,
                  color: AppColors.muted, size: 22),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
      titleSpacing: 20,
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const BannerSlider(),
        const SizedBox(height: 20),
        const QuickLinksRow(),
        const SizedBox(height: 20),
        const CategoriesSection(),
        const SizedBox(height: 20),
        ProductSection(title: 'Top Deals', showSeeAll: true),
        const PromoBanner(),
        const TrendingSection(),
        const SizedBox(height: 20),
        const AdBanner(),
        const SizedBox(height: 20),
        ProductSection(
          title: 'Discover products for you',
          saleOnly: true,
          limit: 4,
          showSeeAll: true,
        ),
        const ResponsiveDealsSection(),
        const SizedBox(height: 20),
        ProductSection(title: 'New Arrivals', offset: 40),
      ],
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LocationPickerSheet(
        initialCity: _selectedCity,
        initialCountry: _selectedCountry,
        onApply: (city, state, country) {
          setState(() {
            _selectedCity = city;
            _selectedCountry = country;
          });
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NOMINATIM LOCATION MODEL
// ─────────────────────────────────────────────
class LocationResult {
  final String displayName;
  final String city;
  final String state;
  final String country;
  final String countryCode;

  const LocationResult({
    required this.displayName,
    required this.city,
    required this.state,
    required this.country,
    required this.countryCode,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    final addr = (json['address'] as Map<String, dynamic>?) ?? {};
    final city = addr['city'] as String? ??
        addr['town'] as String? ??
        addr['village'] as String? ??
        addr['municipality'] as String? ??
        addr['county'] as String? ??
        '';
    final state = addr['state'] as String? ?? '';
    final country = addr['country'] as String? ?? '';
    final code = addr['country_code'] as String? ?? '';
    final parts = [city, state, country].where((s) => s.isNotEmpty).toList();
    final display =
        parts.isNotEmpty ? parts.join(', ') : json['display_name'] as String? ?? '';
    return LocationResult(
      displayName: display,
      city: city,
      state: state,
      country: country,
      countryCode: code.toUpperCase(),
    );
  }
}

// ─────────────────────────────────────────────
// NOMINATIM SERVICE
// ─────────────────────────────────────────────
class NominatimService {
  static const _nominatim = 'https://nominatim.openstreetmap.org';
  static const _corsProxy = 'https://corsproxy.io/?';

  static Future<List<LocationResult>> search(String query,
      {int limit = 7}) async {
    if (query.trim().length < 2) return [];

    final nominatimPath =
        '$_nominatim/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=$limit';

    final uri = Uri.parse(
      kIsWeb ? '$_corsProxy${Uri.encodeComponent(nominatimPath)}' : nominatimPath,
    );

    try {
      final headers = kIsWeb
          ? <String, String>{}
          : <String, String>{
              'User-Agent': 'DLabApp/1.0 (contact@dezign-lab.com)',
              'Accept': 'application/json',
            };

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      final seen = <String>{};
      final results = <LocationResult>[];
      for (final item in data) {
        final r = LocationResult.fromJson(item as Map<String, dynamic>);
        final key = '${r.city}|${r.country}';
        if (r.city.isNotEmpty && seen.add(key)) results.add(r);
      }
      return results;
    } catch (_) {
      return [];
    }
  }
}

// ─────────────────────────────────────────────
// PRODUCT MODEL
// ─────────────────────────────────────────────
class ProductModel {
  final int id;
  final String name;
  final List<String> images;
  final String? imageUrl; // first image — kept for backward compat
  final double? salePrice;
  final double regularPrice;
  final int? categoryId;
  final String? shortDescription;
  final String? description;
  final bool isVariable;

  const ProductModel({
    required this.id,
    required this.name,
    this.images = const [],
    this.imageUrl,
    this.salePrice,
    required this.regularPrice,
    this.categoryId,
    this.shortDescription,
    this.description,
    this.isVariable = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imgRaw = json['images'];
    final imgs =
        imgRaw is List ? imgRaw.whereType<String>().toList() : <String>[];
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      images: imgs,
      imageUrl: imgs.isNotEmpty ? imgs[0] : null,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      regularPrice: (json['regular_price'] as num?)?.toDouble() ?? 0,
      categoryId: json['category_id'] as int?,
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      isVariable: json['is_variable'] as bool? ?? false,
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT SERVICE  (Supabase REST — anon key + RLS)
// ─────────────────────────────────────────────
class ProductService {
  static const _url = 'https://zzqeibxwasikdmdoijfb.supabase.co';
  static const _key =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6cWVpYnh3YXNpa2RtZG9pamZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5OTQwMTAsImV4cCI6MjA4NzU3MDAxMH0'
      '.guvKAPuNIw8Ln5m-r6i99eGu2tOjuHvNArYfh9Q2Prk';

  static Map<String, String> get _h =>
      {'apikey': _key, 'Authorization': 'Bearer $_key'};

  static Future<List<ProductModel>> fetchProducts({
    int limit = 10,
    int offset = 0,
    bool saleOnly = false,
    int? categoryId,
  }) async {
    final buf = StringBuffer(
      '$_url/rest/v1/products'
      '?select=id,name,images,sale_price,regular_price,category_id,short_description,description,is_variable'
      '&is_active=eq.true'
      '&order=id.desc'
      '&limit=$limit'
      '&offset=$offset',
    );
    if (saleOnly) buf.write('&sale_price=not.is.null');
    if (categoryId != null) buf.write('&category_id=eq.$categoryId');
    try {
      final r =
          await http.get(Uri.parse(buf.toString()), headers: _h);
      if (r.statusCode != 200) return [];
      return (jsonDecode(r.body) as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final r = await http.get(
        Uri.parse(
            '$_url/rest/v1/categories?select=id,name,slug&order=name.asc'),
        headers: _h,
      );
      if (r.statusCode != 200) return [];
      return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<List<VariantModel>> fetchVariants(int productId) async {
    try {
      final r = await http.get(
        Uri.parse(
          '$_url/rest/v1/product_variants'
          '?select=id,variant_name,images,sale_price,regular_price'
          '&product_id=eq.$productId'
          '&is_active=eq.true'
          '&order=id.asc',
        ),
        headers: _h,
      );
      if (r.statusCode != 200) return [];
      return (jsonDecode(r.body) as List)
          .map((e) => VariantModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

// ─────────────────────────────────────────────
// VARIANT MODEL
// ─────────────────────────────────────────────
class VariantModel {
  final int id;
  final String variantName;
  final List<String> images;
  final double? salePrice;
  final double? regularPrice;

  const VariantModel({
    required this.id,
    required this.variantName,
    required this.images,
    this.salePrice,
    this.regularPrice,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    final imgRaw = json['images'];
    final imgs =
        imgRaw is List ? imgRaw.whereType<String>().toList() : <String>[];
    return VariantModel(
      id: json['id'] as int,
      variantName: json['variant_name'] as String? ?? '',
      images: imgs,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      regularPrice: (json['regular_price'] as num?)?.toDouble(),
    );
  }
}

// ─────────────────────────────────────────────
// LOCATION PICKER SHEET
// ─────────────────────────────────────────────
class _LocationPickerSheet extends StatefulWidget {
  final String initialCity;
  final String initialCountry;
  final void Function(String city, String state, String country) onApply;

  const _LocationPickerSheet({
    required this.initialCity,
    required this.initialCountry,
    required this.onApply,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<LocationResult> _suggestions = [];
  LocationResult? _selected;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text =
        '${widget.initialCity}, ${widget.initialCountry}';
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await NominatimService.search(value);
      if (mounted) setState(() { _suggestions = results; _isLoading = false; });
    });
  }

  void _selectResult(LocationResult r) {
    setState(() {
      _selected = r;
      _suggestions = [];
      _searchController.text = r.displayName;
    });
    _focusNode.unfocus();
  }

  void _apply() {
    if (_selected != null) {
      widget.onApply(_selected!.city, _selected!.state, _selected!.country);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text('Select Location',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Type a city or area to search',
                      style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. Mumbai, London, New York...',
                        hintStyle: const TextStyle(
                            color: AppColors.muted, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.primary),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.primary),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        color: AppColors.muted, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _suggestions = [];
                                        _selected = null;
                                      });
                                    },
                                  )
                                : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_suggestions.isNotEmpty)
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.cardBorder),
                  itemBuilder: (ctx, i) {
                    final r = _suggestions[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.bgLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: AppColors.primary, size: 18),
                      ),
                      title: Text(
                        r.city.isNotEmpty ? r.city : r.displayName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: r.state.isNotEmpty || r.country.isNotEmpty
                          ? Text(
                              [r.state, r.country]
                                  .where((s) => s.isNotEmpty)
                                  .join(', '),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted),
                            )
                          : null,
                      trailing: Text(r.countryCode,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary)),
                      onTap: () => _selectResult(r),
                    );
                  },
                ),
              ),
            if (!_isLoading &&
                _suggestions.isEmpty &&
                _searchController.text.trim().length >= 2 &&
                _selected == null)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Row(
                  children: [
                    Icon(Icons.search_off_rounded,
                        color: AppColors.muted, size: 18),
                    SizedBox(width: 8),
                    Text('No results found. Try another name.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
            if (_selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_selected!.displayName,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected != null
                        ? AppColors.primary
                        : AppColors.muted,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: _selected != null ? 2 : 0,
                  ),
                  onPressed: _selected != null ? _apply : null,
                  child: const Text('Confirm Location',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BANNER SLIDER
// ─────────────────────────────────────────────
class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _banners = [
    'assets/images/banners/banner1.png',
    'assets/images/banners/banner2.png',
    'assets/images/banners/banner1.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        final next = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final bannerWidth = (maxW - 40).clamp(280.0, 760.0);
        final bannerHeight = (bannerWidth * 0.45).clamp(150.0, 240.0);
        return Column(
          children: [
            SizedBox(
              height: bannerHeight,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _banners.length,
                itemBuilder: (ctx, i) =>
                    _buildBannerCard(_banners[i], bannerWidth, bannerHeight),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppColors.primary : const Color(0xFFCFCFCF),
                    borderRadius: BorderRadius.circular(34),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBannerCard(String imagePath, double w, double h) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: SizedBox(
          width: w,
          height: h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROMO BANNER
// ─────────────────────────────────────────────
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 390 / 134,
          child: Image.asset(
            'assets/images/promo/banner.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUICK LINKS ROW
// ─────────────────────────────────────────────
class QuickLinksRow extends StatelessWidget {
  const QuickLinksRow({super.key});

  static const _items = [
    {'label': 'Deals', 'asset': 'assets/icons/quick_actions/sale.png'},
    {'label': 'Free Shipping', 'asset': 'assets/icons/quick_actions/free.png'},
    {'label': 'Under ₹999', 'asset': 'assets/icons/quick_actions/gift.png'},
    {'label': 'New', 'asset': 'assets/icons/quick_actions/new.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _items
            .map((item) => Expanded(
                  child: _QuickLinkItem(
                    label: item['label'] as String,
                    assetPath: item['asset'] as String,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _QuickLinkItem extends StatelessWidget {
  final String label;
  final String assetPath;
  const _QuickLinkItem({required this.label, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final circleSize =
        (MediaQuery.of(context).size.width / 7).clamp(52.0, 68.0);
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.28), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(circleSize * 0.2),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORIES SECTION
// ─────────────────────────────────────────────
class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  static const List<String> categories = [
    'ACTION CAM LAB', 'AUDIO LAB', 'BAGS & CASES LAB', 'CABLE LAB',
    'CAR ACCESSORY LAB', 'DISPLAY LAB', 'DORAEMON', 'EDUCATION LAB',
    'ENERGY LAB', 'GAMING LAB', 'HEALTH LAB', 'HOME LAB',
    'KIDS & TOYS LAB', 'MOBILITY LAB', 'OFFICE LAB', 'OUTDOOR LAB',
    'PC LAB', 'PETS LAB', 'ROBOT LAB', 'SECURITY LAB', 'SHINCHAN', 'SMART LAB',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Categories For you',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const CategoriesPage(showBottomNav: true)),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('See all',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: AppColors.muted)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoriesPage(
                    initialCategory: categories[i],
                    showBottomNav: true,
                  ),
                ),
              ),
              child: _CategoryItem(label: categories[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  const _CategoryItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primary.withOpacity(0.28), width: 1),
            color: AppColors.bgLight,
          ),
          child: Center(
            child: Text(label.substring(0, 1),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22)),
          ),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: SizedBox(
            width: 72,
            child: Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT SECTION
// ─────────────────────────────────────────────
class ProductSection extends StatefulWidget {
  final String title;
  final int offset;
  final bool saleOnly;
  final int limit;
  final bool showSeeAll;

  const ProductSection({
    super.key,
    required this.title,
    this.offset = 0,
    this.saleOnly = false,
    this.limit = 10,
    this.showSeeAll = false,
  });

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  late final Future<List<ProductModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductService.fetchProducts(
      limit: widget.limit,
      offset: widget.offset,
      saleOnly: widget.saleOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  if (widget.showSeeAll)
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('See all',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: AppColors.muted)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (widget.title == 'Top Deals')
              SizedBox(
                height: 280,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) => _ProductCard(product: products[i]),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ProductGrid(products: products),
              ),
          ],
        );
      },
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 50) / 2;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: products
          .map((p) => SizedBox(width: w, child: _ProductCard(product: p)))
          .toList(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  String _fmt(double price) => '\$${price.toStringAsFixed(0)}';

  /// On web, images from dezign-lab.com are routed through our own backend
  /// proxy so we avoid CORS errors AND WordPress hotlink-protection 403s
  /// that third-party proxies (e.g. corsproxy.io) trigger.
  static const _imgProxyBase = 'http://app.dezign-lab.com:3000';

  String _imgUrl(String url) =>
      kIsWeb
          ? '$_imgProxyBase/api/image-proxy?url=${Uri.encodeComponent(url)}'
          : url;

  int _discountPct() {
    final sp = product.salePrice;
    if (sp == null || product.regularPrice == 0) return 0;
    return ((product.regularPrice - sp) / product.regularPrice * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = w < 400 ? (w - 50) / 2 : 189.0;
    final hasSale = product.salePrice != null &&
        product.salePrice! < product.regularPrice;
    final displayPrice = hasSale ? product.salePrice! : product.regularPrice;
    final discount = _discountPct();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailsPage(product: product),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final dense = maxW < 170;
          final compact = maxW < 150;
          final imgH = compact ? 76.0 : dense ? 86.0 : 100.0;
          final nameSize = compact ? 11.0 : dense ? 12.0 : 13.0;
          final priceSize = compact ? 11.0 : dense ? 12.0 : 13.0;
          final metaSize = compact ? 9.0 : dense ? 10.0 : 11.0;
          final ratingSize = compact ? 10.0 : 12.0;
          final buttonHeight = compact ? 32.0 : dense ? 36.0 : 40.0;
          final buttonIcon = compact ? 14.0 : dense ? 16.0 : 18.0;
          final buttonText = compact ? 11.0 : dense ? 12.0 : 13.0;
          final pad = compact ? 8.0 : 10.0;
          final gapSm = compact ? 4.0 : 6.0;
          final gapMd = compact ? 6.0 : 10.0;

          return Container(
            width: cardW,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      height: imgH,
                      color: Colors.white,
                      child: product.imageUrl != null
                          ? Image.network(
                              _imgUrl(product.imageUrl!),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(Icons.devices_other_rounded,
                                    size: imgH * 0.6,
                                    color: AppColors.border),
                              ),
                            )
                          : Center(
                              child: Icon(Icons.devices_other_rounded,
                                  size: imgH * 0.6,
                                  color: AppColors.border),
                            ),
                    ),
                    Positioned(
                      left: 0,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: dense ? 5 : 6,
                            vertical: dense ? 2 : 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text('4.5',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: dense ? 9 : 10,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: 3),
                            Icon(Icons.star_rounded,
                                color: Colors.white, size: dense ? 9 : 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: gapMd),
                SizedBox(
                  width: double.infinity,
                  child: Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: nameSize, color: AppColors.textPrimary)),
                ),
                SizedBox(height: gapSm),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(_fmt(displayPrice),
                          style: TextStyle(
                              fontSize: priceSize,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      if (hasSale) ...
                        [
                          Text(_fmt(product.regularPrice),
                              style: TextStyle(
                                  fontSize: metaSize,
                                  color: AppColors.muted,
                                  decoration: TextDecoration.lineThrough)),
                          if (discount > 0)
                            Text('$discount% off',
                                style: TextStyle(
                                    fontSize: metaSize,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600)),
                        ],
                    ],
                  ),
                ),
                SizedBox(height: gapSm),
                Row(
                  children: List.generate(
                      5,
                      (i) => Icon(Icons.star_rounded,
                          size: ratingSize,
                          color: i < 4
                              ? const Color(0xFFFFC107)
                              : Colors.grey.shade300)),
                ),
                SizedBox(height: gapMd),
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(Icons.shopping_cart_outlined,
                        color: Colors.white, size: buttonIcon),
                    label: Text('Add to Cart',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: buttonText,
                            fontWeight: FontWeight.w400)),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRENDING SECTION
// ─────────────────────────────────────────────
class TrendingSection extends StatefulWidget {
  const TrendingSection({super.key});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  late final Future<List<ProductModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductService.fetchProducts(limit: 4, offset: 20);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Trending in your Area',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('See all',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: AppColors.muted)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProductGrid(products: products),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// AD BANNER
// ─────────────────────────────────────────────
class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 388 / 142,
          child: Image.asset(
            'assets/promo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DEALS AND OFFERS SECTION
// ─────────────────────────────────────────────
class ResponsiveDealsSection extends StatelessWidget {
  const ResponsiveDealsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Deals & Offers',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFFFF5500),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: DealCard(
                  title: 'Electronics',
                  subtitle: 'Up to 40% off',
                  borderColor: Color(0xFF0095FF),
                  imagePath: 'assets/offertwo.png',
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: DealCard(
                  title: 'Home Lab',
                  subtitle: 'Up to 40% off',
                  borderColor: Color(0xFFFF5500),
                  imagePath: 'assets/offerone.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DealCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color borderColor;
  final String imagePath;

  const DealCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 184 / 190,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRUST BADGES ROW — infinite auto-scrolling marquee
// ─────────────────────────────────────────────
class TrustBadgesRow extends StatefulWidget {
  const TrustBadgesRow({super.key});

  @override
  State<TrustBadgesRow> createState() => _TrustBadgesRowState();
}

class _TrustBadgesRowState extends State<TrustBadgesRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _badges = [
    {'icon': Icons.lock_outlined, 'label': 'Secure Payment'},
    {'icon': Icons.replay_rounded, 'label': 'Easy Return'},
    {'icon': Icons.verified_outlined, 'label': 'Verified Sellers'},
    {'icon': Icons.workspace_premium_outlined, 'label': 'Top Brands'},
    {'icon': Icons.support_agent_outlined, 'label': '24/7 Support'},
    {'icon': Icons.local_offer_rounded, 'label': 'Best Prices'},
  ];

  static const double _chipWidth = 130.0;
  double get _setWidth => _badges.length * _chipWidth;

  @override
  void initState() {
    super.initState();
    final durationMs = (_setWidth / 60 * 1000).round();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = _controller.value * _setWidth;
            return Stack(
              children: [
                Positioned(
                  left: -offset,
                  child: _BadgeStrip(badges: _badges, chipWidth: _chipWidth),
                ),
                Positioned(
                  left: _setWidth - offset,
                  child: _BadgeStrip(badges: _badges, chipWidth: _chipWidth),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BadgeStrip extends StatelessWidget {
  final List<Map<String, Object>> badges;
  final double chipWidth;
  const _BadgeStrip({required this.badges, required this.chipWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: badges.map((b) {
        return SizedBox(
          width: chipWidth,
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(b['icon'] as IconData, color: AppColors.red, size: 15),
              const SizedBox(width: 4),
              Text(b['label'] as String,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.red,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// STUB PAGES (for bottom nav)
// ─────────────────────────────────────────────
const kPrimary = AppColors.primary;
const kOrange = Color(0xFFFF5500);
const kBgLight = Color(0xFFF9F9F9);
const kBorderBlue = AppColors.border;
const kMuted = AppColors.muted;
const kMuted2 = Color(0xFF757575);

class CategoryItem {
  final int id;
  final String name;
  final String iconAsset;

  const CategoryItem({
    required this.id,
    required this.name,
    this.iconAsset = '',
  });
}

class CategoriesPage extends StatefulWidget {
  final String? initialCategory;
  final bool showBottomNav;
  const CategoriesPage({
    super.key,
    this.initialCategory,
    this.showBottomNav = false,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final ScrollController _categoryScrollController = ScrollController();
  final Map<int, int> _categoryCounts = {};

  List<CategoryItem> _categories = [];
  int _selectedIndex = 0;
  int? _selectedCatId;
  String _selectedCatName = '';
  List<ProductModel> _products = [];
  bool _catsLoading = true;
  bool _prodsLoading = false;

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await ProductService.fetchCategories();
    if (!mounted) return;
    final items = cats
        .map((c) => CategoryItem(
              id: c['id'] as int,
              name: c['name'] as String? ?? '',
            ))
        .toList();

    int initialIndex = 0;
    if (widget.initialCategory != null) {
      final idx = items.indexWhere(
          (c) => c.name == widget.initialCategory);
      if (idx >= 0) initialIndex = idx;
    }

    setState(() {
      _categories = items;
      _selectedIndex = initialIndex;
      _catsLoading = false;
      if (_categories.isNotEmpty) {
        final selected = _categories[_selectedIndex];
        _selectedCatId = selected.id;
        _selectedCatName = selected.name;
      }
    });
    if (_selectedCatId != null) _loadProducts(_selectedCatId!);
  }

  Future<void> _loadProducts(int catId) async {
    setState(() => _prodsLoading = true);
    final prods =
        await ProductService.fetchProducts(categoryId: catId, limit: 50);
    if (!mounted) return;
    setState(() {
      _products = prods;
      _prodsLoading = false;
      _categoryCounts[catId] = prods.length;
    });
  }

  void _selectIndex(int index) {
    if (index == _selectedIndex) return;
    final selected = _categories[index];
    setState(() {
      _selectedIndex = index;
      _selectedCatId = selected.id;
      _selectedCatName = selected.name;
      _products = [];
    });
    _loadProducts(selected.id);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final sidebarWidth =
      isTablet ? 175.0 : size.width < 380 ? 110.0 : 130.0;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: widget.showBottomNav
          ? _BottomNavBar(
              currentIndex: 1,
              onSelectPage: (pageIndex) {
                Navigator.of(context, rootNavigator: true)
                    .pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => MainShell(initialIndex: pageIndex),
                  ),
                  (route) => false,
                );
              },
            )
          : null,
      body: SafeArea(
        child: _catsLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopHeader(isTablet: isTablet),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      top: isTablet ? 20 : 14,
                      bottom: isTablet ? 14 : 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 22 : 20,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Browse by department',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: isTablet ? 15 : 14,
                            color: kMuted2,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CategorySidebar(
                          width: sidebarWidth,
                          categories: _categories,
                          selectedIndex: _selectedIndex,
                          categoryCounts: _categoryCounts,
                          scrollController: _categoryScrollController,
                          onSelect: _selectIndex,
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_selectedCatName.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                                    child: Text(
                                      _selectedCatName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: _prodsLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : _products.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No products found',
                                                style: TextStyle(color: AppColors.muted),
                                              ),
                                            )
                                          : LayoutBuilder(
                                                builder: (context, constraints) {
                                                final w = constraints.maxWidth;
                                                final crossAxisCount = w >= 1100
                                                  ? 4
                                                  : w >= 850
                                                    ? 3
                                                    : w >= 600
                                                      ? 2
                                                      : 2;
                                                return GridView.builder(
                                                  padding: const EdgeInsets.all(12),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: crossAxisCount,
                                                    crossAxisSpacing: 12,
                                                    mainAxisSpacing: 12,
                                                  childAspectRatio: w < 200
                                                    ? 0.52
                                                    : w < 260
                                                      ? 0.54
                                                      : w < 320
                                                        ? 0.56
                                                        : 0.60,
                                                  ),
                                                  itemCount: _products.length,
                                                  itemBuilder: (ctx, i) =>
                                                      _ProductCard(product: _products[i]),
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY PAGE UI
// ─────────────────────────────────────────────
class _TopHeader extends StatelessWidget {
  final bool isTablet;
  const _TopHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    const hPad = 20.0;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(hPad, 10, hPad, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isTablet ? 110 : 94,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Image.asset(
                      'assets/d-lab-logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'San Antonio, United States',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppColors.secondary),
                    ],
                  ),
                ],
              ),
              const Row(
                children: [
                  _IconButton(icon: Icons.notifications_none_rounded),
                  SizedBox(width: 10),
                  _IconButton(icon: Icons.shopping_cart_outlined),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: kBgLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorderBlue),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: kPrimary, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Search products...',
                    style: TextStyle(
                      color: Color(0xFF9DB2CE),
                      fontSize: 15,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/icons/zoom.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  const _IconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: kBorderBlue),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Icon(icon, color: kPrimary, size: 20),
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  final double width;
  final List<CategoryItem> categories;
  final int selectedIndex;
  final Map<int, int> categoryCounts;
  final ScrollController scrollController;
  final ValueChanged<int> onSelect;

  const _CategorySidebar({
    required this.width,
    required this.categories,
    required this.selectedIndex,
    required this.categoryCounts,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: kBgLight),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: RawScrollbar(
              controller: scrollController,
              thumbColor: kMuted2,
              radius: const Radius.circular(20),
              thickness: 8,
              trackColor: Colors.white,
              trackVisibility: true,
              thumbVisibility: true,
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: categories.length,
                itemBuilder: (ctx, i) => _CategoryTile(
                  item: categories[i],
                  itemCount: categoryCounts[categories[i].id],
                  isSelected: i == selectedIndex,
                  onTap: () => onSelect(i),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset(2, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryItem item;
  final int? itemCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.item,
    required this.itemCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          border: isSelected
              ? const Border(
                  left: BorderSide(color: kPrimary, width: 2.5),
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(-2, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(2, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? kPrimary.withOpacity(0.10)
                    : Colors.grey.shade200,
              ),
              child: ClipOval(
                child: _CategoryIcon(assetPath: item.iconAsset),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.2,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (itemCount != null)
                    Text(
                      '$itemCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: kPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String assetPath;
  const _CategoryIcon({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    if (assetPath.isEmpty) {
      return const Center(
        child: Icon(Icons.image_outlined, size: 20, color: kMuted),
      );
    }
    return Image.asset(
      assetPath,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.image_outlined, size: 20, color: kMuted),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Cart', style: TextStyle(fontSize: 24))),
      );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Profile', style: TextStyle(fontSize: 24))),
      );
}
