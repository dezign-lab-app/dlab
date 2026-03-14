import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'dlabs_home_page.dart';

// ─────────────────────────────────────────────
// PRODUCT DETAILS PAGE
// ─────────────────────────────────────────────
class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  // ── Colors (matches AppColors in home page) ──
  static const Color primary    = Color(0xFF1B4965);
  static const Color secondary  = Color(0xFF62B6CB);
  static const Color muted      = Color(0xFF6B7280);
  static const Color errorRed   = Color(0xFFFF383C);
  static const Color bgLight    = Color(0xFFF4F9FF);
  static const Color darkNav    = Color(0xFF111827);
  static const Color textPrimary = Color(0xFF111827);

  static const String _imgProxyBase = 'http://app.dezign-lab.com:3000';

  // ── State ──
  late final PageController _pageController;
  int _currentImagePage = 0;

  List<VariantModel> _variants = [];
  VariantModel? _selectedVariant;
  bool _loadingVariants = true;

  late final int _fakeMrp;
  bool _showFullDesc = false;

  late Future<List<ProductModel>> _relatedFuture;

  // ── All images shown in the slider ──
  List<String> get _displayImages {
    if (_selectedVariant != null && _selectedVariant!.images.isNotEmpty) {
      return _selectedVariant!.images;
    }
    return widget.product.images.isNotEmpty
        ? widget.product.images
        : [];
  }

  // ── Active price (variant or product) ──
  double get _displayPrice {
    if (_selectedVariant != null) {
      return _selectedVariant!.salePrice ??
          _selectedVariant!.regularPrice ??
          widget.product.regularPrice;
    }
    return widget.product.salePrice ?? widget.product.regularPrice;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Stable fake MRP: seed with product id so it doesn't change on rebuild
    final rng = Random(widget.product.id);
    _fakeMrp = _displayPrice.round() + 200 + rng.nextInt(201); // +200..+400

    _relatedFuture = ProductService.fetchProducts(limit: 4, offset: 10);

    if (widget.product.isVariable) {
      ProductService.fetchVariants(widget.product.id).then((v) {
        if (mounted) {
          setState(() {
            _variants = v;
            _loadingVariants = false;
          });
        }
      });
    } else {
      _loadingVariants = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _imgUrl(String url) => kIsWeb
      ? '$_imgProxyBase/api/image-proxy?url=${Uri.encodeComponent(url)}'
      : url;

  String _fmt(double price) => '\$${price.toStringAsFixed(0)}';

  // ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSlider(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductHeader(),
                        const SizedBox(height: 20),
                        _buildVariantAndPrice(),
                        const SizedBox(height: 20),
                        _buildDeliveryInfo(),
                        const SizedBox(height: 20),
                        _buildDescription(),
                        const SizedBox(height: 24),
                        _buildRelatedProducts(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildStickyActionButtons(),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: primary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Details',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCAE9FF)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const IconButton(
            icon: Icon(Icons.notifications_none, color: primary, size: 22),
            onPressed: null,
          ),
        ),
      ],
    );
  }

  // ── Image slider ────────────────────────────
  Widget _buildImageSlider() {
    final images = _displayImages;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 350,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE1E1E1)),
          ),
          child: images.isEmpty
              ? const Center(
                  child: Icon(Icons.devices_other_rounded,
                      size: 160, color: Color(0xFFCAE9FF)),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) =>
                        setState(() => _currentImagePage = i),
                    itemBuilder: (_, i) => Image.network(
                      _imgUrl(images[i]),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.devices_other_rounded,
                            size: 160, color: Color(0xFFCAE9FF)),
                      ),
                    ),
                  ),
                ),
        ),
        // Dots indicator
        if (images.length > 1)
          Positioned(
            bottom: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(images.length, (i) {
                final isActive = i == _currentImagePage;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: isActive ? 22 : 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.black
                        : Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(31),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // ── Product header (name + rating) ──────────
  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDD4A00),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Row(
                children: [
                  Text('4.7',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  Icon(Icons.star, color: Colors.white, size: 12),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('(90 Reviews)',
                style: TextStyle(color: muted, fontSize: 16)),
            const Spacer(),
            const Text('Only 5 left in stock',
                style: TextStyle(color: errorRed, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  // ── Variant selector + Price ─────────────────
  Widget _buildVariantAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: variant selector or colour circles
        Expanded(
          child: _loadingVariants
              ? const SizedBox(
                  height: 40,
                  child: Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : _variants.isNotEmpty
                  ? _buildVariantSelector()
                  : _buildColorCircles(),
        ),
        const SizedBox(width: 16),
        // Right: price
        _buildPriceBlock(),
      ],
    );
  }

  Widget _buildVariantSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose variant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _variants.map((v) {
            final selected = _selectedVariant?.id == v.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVariant = selected ? null : v;
                  _currentImagePage = 0;
                  _pageController.jumpToPage(0);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.white,
                  border: Border.all(
                      color: selected ? primary : const Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  v.variantName,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : textPrimary,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorCircles() {
    // Placeholder colour circles when no real variants
    const colors = [Colors.black, Colors.grey, Color(0xFF1B4965)];
    const names = ['Black', 'Grey', 'Blue'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose color',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(colors.length, (i) {
            final selected = i == 0;
            return Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected
                        ? secondary
                        : const Color(0xFFDDDDDD),
                    width: 2),
              ),
              child: Tooltip(
                message: names[i],
                child: CircleAvatar(
                    radius: 12, backgroundColor: colors[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPriceBlock() {
    final price = _displayPrice;
    final saveAmt = _fakeMrp - price.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _fmt(price),
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _fmt(_fakeMrp.toDouble()),
              style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: muted,
                  fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              'Save \$$saveAmt',
              style: const TextStyle(
                  color: errorRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  // ── Delivery ─────────────────────────────────
  Widget _buildDeliveryInfo() {
    return const Row(
      children: [
        Icon(Icons.check_circle, color: Color(0xFF26A541), size: 18),
        SizedBox(width: 8),
        Text('Free Delivery by Tomorrow',
            style: TextStyle(
                color: Color(0xFF26A541), fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Description with expand ──────────────────
  Widget _buildDescription() {
    final shortDesc = widget.product.shortDescription;
    final fullDesc = widget.product.description;

    if (shortDesc == null && fullDesc == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        const Divider(color: Color(0xFFF2F2F2), thickness: 1),
        const SizedBox(height: 12),
        const Text(
          'Description',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primary),
        ),
        const SizedBox(height: 10),
        // Short description always visible
        if (shortDesc != null && shortDesc.trim().isNotEmpty)
          Text(
            _stripHtml(shortDesc),
            style: const TextStyle(
                color: Color(0xFF374151), fontSize: 15, height: 1.6),
          ),
        // Full description — toggleable
        if (fullDesc != null && fullDesc.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          if (_showFullDesc)
            Text(
              _stripHtml(fullDesc),
              style: const TextStyle(
                  color: Color(0xFF374151), fontSize: 15, height: 1.6),
            ),
          GestureDetector(
            onTap: () => setState(() => _showFullDesc = !_showFullDesc),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text(
                    _showFullDesc ? 'Show less' : 'Read full description',
                    style: const TextStyle(
                        color: primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showFullDesc
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── You may also like ────────────────────────
  Widget _buildRelatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFFF2F2F2), thickness: 1),
        const SizedBox(height: 12),
        const Text(
          'You May Also Like',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primary),
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<ProductModel>>(
          future: _relatedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ));
            }
            final products = (snapshot.data ?? [])
                .where((p) => p.id != widget.product.id)
                .take(4)
                .toList();
            if (products.isEmpty) return const SizedBox.shrink();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => _RelatedCard(
                product: products[i],
                imgUrl: _imgUrl,
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Sticky CTA ───────────────────────────────
  Widget _buildStickyActionButtons() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_outlined, color: primary),
              label: const Text('Add to Cart',
                  style: TextStyle(color: primary, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.white),
              label: const Text('Buy Now',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Utility: strip HTML tags from descriptions ──
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }
}

// ─────────────────────────────────────────────
// RELATED PRODUCT CARD (You may also like)
// ─────────────────────────────────────────────
class _RelatedCard extends StatelessWidget {
  final ProductModel product;
  final String Function(String) imgUrl;

  const _RelatedCard({required this.product, required this.imgUrl});

  static const Color primary      = Color(0xFF1B4965);
  static const Color bgLight      = Color(0xFFF4F9FF);
  static const Color textPrimary  = Color(0xFF111827);
  static const Color muted        = Color(0xFF6B7280);
  static const Color cardBorder   = Color(0xFFF2F2F2);

  String _fmt(double price) => '\$${price.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final hasSale = product.salePrice != null &&
        product.salePrice! < product.regularPrice;
    final displayPrice =
        hasSale ? product.salePrice! : product.regularPrice;

    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailsPage(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                color: bgLight,
                child: product.imageUrl != null
                    ? Image.network(
                        imgUrl(product.imageUrl!),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.devices_other_rounded,
                              size: 50, color: Color(0xFFCAE9FF)),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.devices_other_rounded,
                            size: 50, color: Color(0xFFCAE9FF)),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: textPrimary),
            ),
            const SizedBox(height: 4),
            // Price
            Text(
              _fmt(displayPrice),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textPrimary),
            ),
            // Stars
            const SizedBox(height: 4),
            Row(
              children: List.generate(
                5,
                (i) => Icon(Icons.star_rounded,
                    size: 11,
                    color: i < 4
                        ? const Color(0xFFFFC107)
                        : Colors.grey.shade300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
