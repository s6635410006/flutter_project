import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_project/views/notification_center_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key, required this.onOrderCake, required this.onOpenCart});

  final void Function({
    required String name,
    required int price,
    required String imageUrl,
  }) onOrderCake;
  final VoidCallback onOpenCart;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // เก็บ ID ของการ์ดที่ถูกกด favorite
  final Set<dynamic> _favoriteIds = {};

  final _supabase = Supabase.instance.client;

  List<_CategoryItem> _categories = [];
  List<_CakeItem> _cakes = [];
  bool _isLoading = true;
  dynamic _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _bannerImages = const [
    'assets/images/c1.jpg',
    'assets/images/c2.jpg',
    'assets/images/c3.jpg',
  ];
  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _bannerController = PageController();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_bannerController.hasClients) return;
      final nextIndex = (_currentBannerIndex + 1) % _bannerImages.length;
      _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _fetchData() async {
    try {
      final categoryData = await _supabase.from('categories').select();
      final productData = await _supabase.from('products').select();
      
      if (mounted) {
        setState(() {
          _categories = categoryData.map((e) => _CategoryItem.fromJson(e)).toList();
          _cakes = productData.map((e) => _CakeItem.fromJson(e)).toList();
          if (_categories.isNotEmpty && _selectedCategoryId == null) {
            _selectedCategoryId = _categories.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchQuery.trim().toLowerCase();
    final displayedCakes = (_selectedCategoryId == null
            ? _cakes
            : _cakes
                .where((cake) =>
                    cake.categoryId?.toString() ==
                    _selectedCategoryId?.toString())
                .toList())
        .where((cake) {
          if (q.isEmpty) return true;
          return cake.name.toLowerCase().contains(q);
        })
        .toList();

    final selectedCategoryName = _categories
        .where((c) => c.id?.toString() == _selectedCategoryId?.toString())
        .map((c) => c.label)
        .firstOrNull ?? 'เค้กแนะนำสำหรับคุณ';

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/bg_pattern.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.85),
            BlendMode.lighten,
          ),
        ),
      ),
      child: Scaffold(
        // โครงหน้าหลักของ Home ตามดีไซน์ตัวอย่าง
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Cake Ease',
          style: TextStyle(
            color: const Color(0xFF6F4E5C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          _NotificationBell(
            supabase: _supabase,
            color: const Color(0xFF6F4E5C),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationCenterPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7A4D60)))
          : SingleChildScrollView(
              child: Column(
          children: [
            // ช่องค้นหา
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E4DE),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                  decoration: InputDecoration(
                    hintText: 'ค้นหาเค้กที่ท่านต้องการ...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon: _searchQuery.trim().isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.grey.shade600),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                              setState(() => _searchQuery = '');
                            },
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // แบนเนอร์โปรโมชั่นหลัก
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 170,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _bannerController,
                      itemCount: _bannerImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentBannerIndex = index;
                        });
                      },
                      itemBuilder: (_, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(_bannerImages[index],
                                fit: BoxFit.cover),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.45),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Text(
                                    'SEASONAL PICK',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      letterSpacing: 1.5,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Strawberry Dream',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'ลดสูงสุด 20% สำหรับเค้กปอนด์',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      bottom: 14,
                      right: 16,
                      child: Row(
                        children: List.generate(_bannerImages.length, (index) {
                          final isActive = index == _currentBannerIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(left: 6),
                            width: isActive ? 16 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // หัวข้อหมวดหมู่ + ปุ่มดูทั้งหมด
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'หมวดหมู่',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6F4E5C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // รายการหมวดหมู่แบบเลื่อนแนวนอน
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategoryId?.toString() == category.id?.toString();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category.id;
                      });
                    },
                    child: _CategoryCircle(
                      item: category,
                      isSelected: isSelected,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemCount: _categories.length,
              ),
            ),

            // หัวข้อสินค้าแนะนำ
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedCategoryName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ),

            // กริดรายการสินค้าเค้ก 2 คอลัมน์
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: displayedCakes.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'ไม่มีสินค้าในหมวดหมู่นี้',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  : GridView.builder(
                      itemCount: displayedCakes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 18,
                      ),
                      itemBuilder: (_, index) {
                        final cake = displayedCakes[index];
                        final isFavorite = _favoriteIds.contains(cake.id);
                        return _CakeCard(
                          cake: cake,
                          isFavorite: isFavorite,
                          onOrderTap: () {
                            widget.onOrderCake(
                              name: cake.name,
                              price: cake.price,
                              imageUrl: cake.imageUrl,
                            );
                            widget.onOpenCart();
                          },
                          onFavoriteTap: () {
                            setState(() {
                              if (isFavorite) {
                                _favoriteIds.remove(cake.id);
                              } else {
                                _favoriteIds.add(cake.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.supabase,
    required this.color,
    required this.onPressed,
  });

  final SupabaseClient supabase;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return IconButton(
        icon: const Icon(Icons.notifications_none_outlined),
        color: color,
        onPressed: onPressed,
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('custom_requests')
          .stream(primaryKey: ['id'])
          .eq('userid', user.id)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        final data = snapshot.data ?? const <Map<String, dynamic>>[];
        final unreadCount =
            data.where((r) => r['status']?.toString() == 'price_quoted').length;

        return IconButton(
          onPressed: onPressed,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_outlined, color: color),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({required this.item, this.isSelected = false});

  final _CategoryItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // วงกลมหมวดหมู่ 1 รายการ (ไอคอน + ชื่อ)
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isSelected ? const Color(0xFFF7D8E0) : const Color(0xFFEAE7E2),
          ),
          child: Icon(
            item.icon,
            size: 22,
            color: const Color(0xFF5A3D49),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 62,
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}

class _CakeCard extends StatefulWidget {
  const _CakeCard({
    required this.cake,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onOrderTap,
  });

  final _CakeItem cake;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onOrderTap;

  @override
  State<_CakeCard> createState() => _CakeCardState();
}

class _CakeCardState extends State<_CakeCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // การ์ดสินค้า 1 ใบ (รูป, ปุ่มหัวใจ, ชื่อ, ราคา, ปุ่ม ORDER)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.network(
                  widget.cake.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.broken_image, color: Colors.grey, size: 32),
                          SizedBox(height: 4),
                          Text(
                            'No Image',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: widget.onFavoriteTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_outline,
                      size: 19,
                      color: const Color(0xFF7A4D60),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.cake.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        if (widget.cake.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final textStyle = TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.2,
              );
              final textSpan = TextSpan(text: widget.cake.description, style: textStyle);
              final textPainter = TextPainter(
                text: textSpan,
                maxLines: 2,
                textDirection: TextDirection.ltr,
              );
              textPainter.layout(maxWidth: constraints.maxWidth);
              final isOverflowing = textPainter.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cake.description,
                    maxLines: _isExpanded ? 10 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  if (isOverflowing)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _isExpanded ? 'แสดงน้อยลง' : 'แสดงเพิ่มเติม',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A4D60),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '฿${widget.cake.price}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E3136),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: widget.onOrderTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF7A4D60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Text(
                  'ORDER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.id,
    required this.icon,
    required this.label,
    this.active = false,
  });

  final dynamic id;
  final IconData icon; // ไอคอนหมวดหมู่
  final String label; // ชื่อหมวดหมู่
  final bool active; // สถานะหมวดหมู่ที่ถูกเลือก

  factory _CategoryItem.fromJson(Map<String, dynamic> json) {
    IconData getIcon(String code) {
      switch (code) {
        case 'cake': return Icons.cake;
        case 'favorite': return Icons.favorite;
        case 'delivery_dining': return Icons.delivery_dining;
        case 'palette': return Icons.palette;
        default: return Icons.more_horiz;
      }
    }
    
    return _CategoryItem(
      id: json['id'],
      icon: getIcon(json['icon_code']?.toString() ?? ''),
      label: json['name']?.toString() ?? '',
      active: json['is_active'] ?? false,
    );
  }
}

class _CakeItem {
  const _CakeItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description = '',
    this.categoryId,
  });

  final dynamic id;
  final String name; // ชื่อสินค้า
  final int price; // ราคาสินค้า
  final String imageUrl; // URL รูปสินค้า
  final String description; // รายละเอียดสินค้า
  final dynamic categoryId; // ไอดีหมวดหมู่

  factory _CakeItem.fromJson(Map<String, dynamic> json) {
    return _CakeItem(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageurl']?.toString() ?? json['image_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['categoryid'],
    );
  }
}
