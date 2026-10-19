import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String productName;
  final String availabilityText;
  final String price;
  final String weight;
  final String updatedText;
  final bool isAvailable;
  final VoidCallback? onOrderPressed;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.availabilityText,
    required this.price,
    required this.weight,
    required this.updatedText,
    this.isAvailable = true,
    this.onOrderPressed,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (mounted) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF05DF72).withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // IMAGE SECTION
              // =========================
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.70,
                    child: Image.asset(
                      widget.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 25,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  // Available Badge
                  if (widget.isAvailable)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF05DF72),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              size: 13,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Available',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // =========================
              // CONTENT SECTION
              // =========================
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 15, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      widget.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF075B3A),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Availability + Updated
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4FFF1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF05DF72),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    widget.availabilityText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.notoSansBengali(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF087A4A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 7),

                        Expanded(
                          child: Text(
                            widget.updatedText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Price Label
                    Text(
                      'আনুমানিক দাম',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Price
                    Text(
                      widget.price,
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF075B3A),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Weight
                    Text(
                      'ওজন: ${widget.weight}',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // ORDER BUTTON
                    // =========================
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: widget.onOrderPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF075B3A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Text(
                          'অর্ডার করুন',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
