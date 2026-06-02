import 'package:flutter/material.dart';

class MedicalCheckup1 extends StatelessWidget {
  const MedicalCheckup1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 1336),
          child: Container(
            width: 390,
            padding: const EdgeInsets.only(top: 80, bottom: 96),
            decoration: BoxDecoration(color: const Color(0xFFF7FBF0)),
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 672),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 138.84,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Langkah 1 dari 6',
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
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '15% Selesai',
                                          style: TextStyle(
                                            color: const Color(0xFF00490E),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            height: 1.33,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFC9E8CA),
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
                                        width: 45.30,
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
                            spacing: 8,
                            children: [
                              Container(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 350,
                                      child: Text(
                                        'Informasi Pribadi',
                                        style: TextStyle(
                                          color: const Color(0xFF181D17),
                                          fontSize: 24,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          height: 1.33,
                                          letterSpacing: -0.24,
                                        ),
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
                                    SizedBox(
                                      width: 350,
                                      child: Text(
                                        'Bantu kami mengenal Anda lebih baik untuk\nmemberikan analisis kesehatan yang akurat.',
                                        style: TextStyle(
                                          color: const Color(0xFF40493D),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                        ),
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
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
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
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0xFFF8FAFC),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: Color(0x0A000000),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 4),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                            ),
                                            child: Column(
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
                                                      SizedBox(
                                                        width: 316,
                                                        child: Text(
                                                          'Usia (Tahun)',
                                                          style: TextStyle(
                                                            color: const Color(0xFF40493D),
                                                            fontSize: 12,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w500,
                                                            height: 1.33,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Stack(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          height: 48,
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0xFFF1F5EB),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Positioned(
                                                                left: 40,
                                                                top: 14,
                                                                child: Container(
                                                                  width: 245,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        'Contoh: 25',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFF6B7280),
                                                                          fontSize: 16,
                                                                          fontFamily: 'Inter',
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                left: 40,
                                                                top: 12,
                                                                child: Container(
                                                                  width: 260,
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Expanded(child: Container(height: 24)),
                                                                      Container(
                                                                        height: double.infinity,
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Opacity(
                                                                              opacity: 0,
                                                                              child: ConstrainedBox(
                                                                                constraints: BoxConstraints(minWidth: 15),
                                                                                child: Container(width: 15, height: double.infinity),
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
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0xFFF8FAFC),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: Color(0x0A000000),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 4),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                            ),
                                            child: Column(
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
                                                      SizedBox(
                                                        width: 316,
                                                        child: Text(
                                                          'Jenis Kelamin',
                                                          style: TextStyle(
                                                            color: const Color(0xFF40493D),
                                                            fontSize: 12,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w500,
                                                            height: 1.33,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 8,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0xFFF1F5EB),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Positioned(
                                                                left: 0,
                                                                top: 0,
                                                                child: Container(
                                                                  width: 271.98,
                                                                  height: 48,
                                                                  padding: const EdgeInsets.only(
                                                                    top: 12,
                                                                    left: 227.98,
                                                                    right: 8,
                                                                    bottom: 12,
                                                                  ),
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Container(
                                                                        width: 24,
                                                                        height: 24,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: BoxDecoration(),
                                                                        child: Stack(),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: double.infinity,
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 240,
                                                                      child: Text(
                                                                        'Pilih',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFF181D17),
                                                                          fontSize: 16,
                                                                          fontFamily: 'Inter',
                                                                          fontWeight: FontWeight.w400,
                                                                          height: 1.50,
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
                                                      Container(
                                                        height: double.infinity,
                                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                                        decoration: ShapeDecoration(
                                                          color: const Color(0xFFF1F5EB),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
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
                                            padding: const EdgeInsets.all(16),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0xFFF8FAFC),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: Color(0x0A000000),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 4),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                            ),
                                            child: Column(
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
                                                      SizedBox(
                                                        width: 316,
                                                        child: Text(
                                                          'Berat Badan (kg)',
                                                          style: TextStyle(
                                                            color: const Color(0xFF40493D),
                                                            fontSize: 12,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w500,
                                                            height: 1.33,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Stack(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          height: 48,
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0xFFF1F5EB),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Positioned(
                                                                left: 40,
                                                                top: 14,
                                                                child: Container(
                                                                  width: 213,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        '0',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFF6B7280),
                                                                          fontSize: 16,
                                                                          fontFamily: 'Inter',
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                left: 40,
                                                                top: 12,
                                                                child: Container(
                                                                  width: 228,
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Expanded(child: Container(height: 24)),
                                                                      Container(
                                                                        height: double.infinity,
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Opacity(
                                                                              opacity: 0,
                                                                              child: ConstrainedBox(
                                                                                constraints: BoxConstraints(minWidth: 15),
                                                                                child: Container(width: 15, height: double.infinity),
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
                                                      Positioned(
                                                        left: 286.13,
                                                        top: 16,
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'kg',
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
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0xFFF8FAFC),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: Color(0x0A000000),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 4),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                            ),
                                            child: Column(
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
                                                      SizedBox(
                                                        width: 316,
                                                        child: Text(
                                                          'Tinggi Badan (cm)',
                                                          style: TextStyle(
                                                            color: const Color(0xFF40493D),
                                                            fontSize: 12,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w500,
                                                            height: 1.33,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Stack(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          height: 48,
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0xFFF1F5EB),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Positioned(
                                                                left: 40,
                                                                top: 14,
                                                                child: Container(
                                                                  width: 213,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        '0',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFF6B7280),
                                                                          fontSize: 16,
                                                                          fontFamily: 'Inter',
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                left: 40,
                                                                top: 12,
                                                                child: Container(
                                                                  width: 228,
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Expanded(child: Container(height: 24)),
                                                                      Container(
                                                                        height: double.infinity,
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Opacity(
                                                                              opacity: 0,
                                                                              child: ConstrainedBox(
                                                                                constraints: BoxConstraints(minWidth: 15),
                                                                                child: Container(width: 15, height: double.infinity),
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
                                                      Positioned(
                                                        left: 282.41,
                                                        top: 16,
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'cm',
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
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: const Color(0x4CC9E8CA),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1,
                                            color: const Color(0x33C9E8CA),
                                          ),
                                          borderRadius: BorderRadius.circular(16),
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
                                                      'Mengapa data ini penting?',
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
                                                      'Informasi fisik dasar membantu algoritma\nkami menghitung BMI dan memetakan\nstandar kesehatan yang sesuai dengan profil\ndemografis Anda.',
                                                      style: TextStyle(
                                                        color: const Color(0xFF4E6952),
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
                                            width: 128,
                                            height: 128,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Opacity(
                                                  opacity: 0.80,
                                                  child: Expanded(
                                                    child: Container(
                                                      width: double.infinity,
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage("https://placehold.co/128x128"),
                                                          fit: BoxFit.fill,
                                                        ),
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
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                                                          width: 350,
                                                          height: 60,
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
                                                      Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            'Lanjut',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 20,
                                                              fontFamily: 'Inter',
                                                              fontWeight: FontWeight.w600,
                                                              height: 1.40,
                                                            ),
                                                          ),
                                                        ],
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
                                                Container(
                                                  width: double.infinity,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Data Anda terenkripsi aman sesuai standar privasi kesehatan.',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: const Color(0xFF40493D),
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                          height: 1.27,
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
                      spacing: 103.39,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 16,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'Checkup Medis',
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
                            color: const Color(0xFFE5EADF),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0x33BFCABA),
                              ),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: double.infinity,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}