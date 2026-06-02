import 'package:flutter/material.dart';

class MedicalCheckup2 extends StatelessWidget {
  const MedicalCheckup2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 1718),
          child: Container(
            width: 390,
            padding: const EdgeInsets.only(bottom: 96),
            decoration: BoxDecoration(color: const Color(0xFFF7FBF0)),
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 672),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 96, left: 20, right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Container(
                                width: double.infinity,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  spacing: 29.36,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kebiasaan Makan',
                                          style: TextStyle(
                                            color: const Color(0xFF181D17),
                                            fontSize: 24,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            height: 1.33,
                                            letterSpacing: -0.24,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFEBEFE5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Langkah 2 dari 6',
                                            style: TextStyle(
                                              color: const Color(0xFF40493D),
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                              height: 1.33,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFE0E4DA),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 116.64,
                                        height: 8,
                                        decoration: BoxDecoration(color: const Color(0xFF0D631B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 40,
                            children: [
                              Container(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 16,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Container(
                                            width: 26.55,
                                            height: 32,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF00490E),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(9999),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '1',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.50,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(right: 24.69),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Berapa kali Anda makan ndalam sehari?',
                                                  style: TextStyle(
                                                    color: const Color(0xFF181D17),
                                                    fontSize: 20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 58,
                                            padding: const EdgeInsets.all(16),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0x7FBFCABA),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(right: 12),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Sekali',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  left: 317,
                                                  top: 23,
                                                  child: Opacity(
                                                    opacity: 0,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 58,
                                            padding: const EdgeInsets.all(16),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0x7FBFCABA),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(right: 12),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Dua kali',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  left: 317,
                                                  top: 23,
                                                  child: Opacity(
                                                    opacity: 0,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 58,
                                            padding: const EdgeInsets.all(16),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0x7FBFCABA),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(right: 12),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tiga kali',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  left: 317,
                                                  top: 23,
                                                  child: Opacity(
                                                    opacity: 0,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 58,
                                            padding: const EdgeInsets.all(16),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0x7FBFCABA),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(right: 12),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Lebih dari tiga kali',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  left: 317,
                                                  top: 23,
                                                  child: Opacity(
                                                    opacity: 0,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
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
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 16,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Container(
                                            width: 31.91,
                                            height: 32,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF00490E),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(9999),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '2',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.50,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(right: 59.20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Seberapa sering Anda makan\nmakanan cepat saji?',
                                                  style: TextStyle(
                                                    color: const Color(0xFF181D17),
                                                    fontSize: 20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF1F5EB),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: Colors.black.withValues(alpha: 0),
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              spacing: 16,
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0xFFBFCABA),
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tidak pernah',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: Colors.black.withValues(alpha: 0),
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              spacing: 16,
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0xFFBFCABA),
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '1–2 kali/minggu',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: Colors.black.withValues(alpha: 0),
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              spacing: 16,
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0xFFBFCABA),
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '3–5 kali/minggu',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: Colors.black.withValues(alpha: 0),
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              spacing: 16,
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0xFFBFCABA),
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Hampir setiap hari',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 16,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Container(
                                            width: 28.20,
                                            height: 32,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF00490E),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(9999),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '3',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.50,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(right: 75.86),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Apakah Anda mengonsumsi \nminuman manis?',
                                                  style: TextStyle(
                                                    color: const Color(0xFF181D17),
                                                    fontSize: 20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0x7FBFCABA),
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tidak pernah',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(24),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0x7FBFCABA),
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.only(right: 53.86),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Kadang-\nkadang',
                                                        style: TextStyle(
                                                          color: const Color(0xFF181D17),
                                                          fontSize: 16,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                          height: 1.50,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(24),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0x7FBFCABA),
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Sering',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(24),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0x7FBFCABA),
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Setiap hari',
                                                      style: TextStyle(
                                                        color: const Color(0xFF181D17),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 48,
                            left: 24,
                            right: 24,
                            bottom: 24,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF1F5EB),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0x33BFCABA),
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 24,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mengapa ini penting?',
                                          style: TextStyle(
                                            color: const Color(0xFF00490E),
                                            fontSize: 20,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            height: 1.40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pola makan yang konsisten dan\npengurangan gula proses adalah langkah\nmendasar untuk kesehatan metabolik jangka\npanjang dan stabilitas energi.',
                                          style: TextStyle(
                                            color: const Color(0xFF40493D),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.43,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                height: 128,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Colors.white.withValues(alpha: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Color(0x0C000000),
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/300x128"),
                                            fit: BoxFit.fill,
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
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 390,
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: ShapeDecoration(
                      color: const Color(0xCCF7FBF0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0x4CBFCABA),
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 85.83,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 16,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Medical Checkup',
                                  style: TextStyle(
                                    color: const Color(0xFF00490E),
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 1.40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFBFCABA),
                              ),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage("https://placehold.co/38x38"),
                                      fit: BoxFit.fill,
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
                Positioned(
                  left: 0,
                  top: 1540,
                  child: Container(
                    width: 390,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF7FBF0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0x33BFCABA),
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 12,
                          offset: Offset(0, -4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 672),
                          child: Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 16,
                              children: [
                                Container(
                                  width: 115.33,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: const Color(0xFF00490E),
                                      ),
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Kembali',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF00490E),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 226.67,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF0D631B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 226.67,
                                          height: 48,
                                          decoration: ShapeDecoration(
                                            color: Colors.white.withValues(alpha: 0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(9999),
                                            ),
                                            shadows: [
                                              BoxShadow(
                                                color: Color(0x19000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                                spreadRadius: -2,
                                              ),BoxShadow(
                                                color: Color(0x19000000),
                                                blurRadius: 6,
                                                offset: Offset(0, 4),
                                                spreadRadius: -1,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Lanjut',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.50,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                        ],
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}