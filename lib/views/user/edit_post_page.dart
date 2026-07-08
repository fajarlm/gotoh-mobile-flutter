import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fe_mobile/model/post_model.dart';
import 'package:fe_mobile/services/post_service.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage>
    with SingleTickerProviderStateMixin {
  // ── Colors ─────────────────────────────────────────────────────────────────
  static const _primaryGreen = Color(0xFF0D631B);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _bgColor = Color(0xFFFAFDF9);
  static const _textDark = Color(0xFF1B3C21);
  static const _textMid = Color(0xFF6B8B72);
  static const _textLight = Color(0xFF8FA89A);
  static const _cardColor = Colors.white;
  static const _borderColor = Color(0xFFE2EFE0);
  static const _dangerColor = Color(0xFFBA1A1A);

  // ── State ──────────────────────────────────────────────────────────────────
  late TextEditingController _contentCtrl;
  late String _selectedType;
  File? _imageFile;
  bool _removeExistingImage = false;
  bool _isSubmitting = false;
  late AnimationController _btnAnim;
  late Animation<double> _btnScale;

  final ImagePicker _picker = ImagePicker();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(text: widget.post.content ?? '');
    _selectedType = widget.post.type;

    _btnAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _btnAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _btnAnim.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Image Handling ─────────────────────────────────────────────────────────
  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _imageFile = File(picked.path);
          _removeExistingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Gagal memilih gambar: $e', isError: true);
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _imageFile = File(picked.path);
          _removeExistingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Gagal membuka kamera: $e', isError: true);
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _removeExistingImage = true;
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageSourceSheet(
        onGallery: () {
          Navigator.pop(context);
          _pickFromGallery();
        },
        onCamera: () {
          Navigator.pop(context);
          _pickFromCamera();
        },
      ),
    );
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submitEdit() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty && _imageFile == null && _removeExistingImage) {
      _showSnack('Konten atau gambar tidak boleh kosong.', isError: true);
      return;
    }

    _focusNode.unfocus();
    setState(() => _isSubmitting = true);

    final res = await PostService.updatePost(
      id: widget.post.id,
      content: content.isEmpty ? null : content,
      type: _selectedType,
      imageFile: _imageFile,
      removeImage: _removeExistingImage,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      Navigator.pop(context, true); // signal refresh
    } else {
      _showSnack(
        res['message'] ?? 'Gagal memperbarui postingan.',
        isError: true,
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _dangerColor : _primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  bool get _hasExistingImage =>
      widget.post.image != null && widget.post.image!.isNotEmpty;

  bool get _showingImage =>
      _imageFile != null || (_hasExistingImage && !_removeExistingImage);

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildAuthorPreview(),
                    const SizedBox(height: 20),
                    _buildTypeSelector(),
                    const SizedBox(height: 20),
                    _buildContentInput(),
                    const SizedBox(height: 20),
                    _buildImageSection(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: Colors.white,
          ),
          const Expanded(
            child: Text(
              'Edit Postingan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ── Author Preview ─────────────────────────────────────────────────────────
  Widget _buildAuthorPreview() {
    final user = widget.post.user;
    final avatarUrl = user?.avatarUrl ?? '';
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: _lightGreen,
          backgroundImage: avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl.isEmpty
              ? Text(
                  user?.initials ?? '?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.username ?? 'Kamu',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFC9E7CA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_rounded, size: 10, color: _primaryGreen),
                  SizedBox(width: 4),
                  Text(
                    'Mengedit postingan',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Type Selector ──────────────────────────────────────────────────────────
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visibilitas',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textMid,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _TypeCard(
                label: 'Publik',
                description: 'Semua orang dapat melihat',
                icon: Icons.public_rounded,
                value: 'public',
                selected: _selectedType == 'public',
                onTap: () => setState(() => _selectedType = 'public'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TypeCard(
                label: 'Privat',
                description: 'Hanya kamu yang bisa lihat',
                icon: Icons.lock_outline_rounded,
                value: 'private',
                selected: _selectedType == 'private',
                onTap: () => setState(() => _selectedType = 'private'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Content Input ──────────────────────────────────────────────────────────
  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konten',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textMid,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: _contentCtrl,
            focusNode: _focusNode,
            maxLines: 7,
            minLines: 4,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 15, height: 1.6, color: _textDark),
            decoration: const InputDecoration(
              hintText: 'Tulis sesuatu yang bermanfaat...',
              hintStyle: TextStyle(color: _textLight, fontSize: 15),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  // ── Image Section ──────────────────────────────────────────────────────────
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Foto',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textMid,
                letterSpacing: 0.5,
              ),
            ),
            if (_showingImage)
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 14,
                        color: _primaryGreen,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Ganti Foto',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_showingImage) _buildImagePreview() else _buildImagePicker(),
      ],
    );
  }

  Widget _buildImagePreview() {
    Widget imgWidget;
    if (_imageFile != null) {
      imgWidget = Image.file(
        _imageFile!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      );
    } else {
      imgWidget = Image.network(
        widget.post.imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 220,
          color: const Color(0xFFF0F0F0),
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: _textLight,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: imgWidget),
        // Gradient overlay at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 60,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        // Remove button
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        // "Foto Baru" badge if new file selected
        if (_imageFile != null)
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Foto Baru',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: _primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tambah Foto',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Galeri atau Kamera',
              style: TextStyle(fontSize: 11, color: _textLight),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTapDown: (_) => _btnAnim.forward(),
      onTapUp: (_) {
        _btnAnim.reverse();
        if (!_isSubmitting) _submitEdit();
      },
      onTapCancel: () => _btnAnim.reverse(),
      child: ScaleTransition(
        scale: _btnScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isSubmitting
                  ? [Colors.grey.shade400, Colors.grey.shade400]
                  : [const Color(0xFF0D631B), const Color(0xFF1B8C2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isSubmitting
                ? []
                : [
                    BoxShadow(
                      color: _primaryGreen.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Type Card Widget ──────────────────────────────────────────────────────────
class _TypeCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  static const _primaryGreen = Color(0xFF0D631B);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _textDark = Color(0xFF1A2218);
  static const _textLight = Color(0xFF8FA89A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _primaryGreen : const Color(0xFFE0E4DA),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? _primaryGreen.withOpacity(0.12)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? _primaryGreen : _textLight,
                ),
                if (selected)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: _primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? _primaryGreen : _textDark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: selected ? const Color(0xFF4E6952) : _textLight,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Image Source Bottom Sheet ──────────────────────────────────────────────────
class _ImageSourceSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _ImageSourceSheet({required this.onGallery, required this.onCamera});

  static const _textDark = Color(0xFF1B3C21);
  static const _textMid = Color(0xFF6B8B72);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EFE0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pilih Sumber Foto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dari mana kamu ingin mengambil gambar?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8FA89A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  subtitle: 'Dari koleksi foto',
                  onTap: onGallery,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  subtitle: 'Ambil foto baru',
                  onTap: onCamera,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2EFE0)),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textMid,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  static const _primaryGreen = Color(0xFF0D631B);
  static const _lightGreen = Color(0xFFF4F8F4);
  static const _textDark = Color(0xFF1B3C21);
  static const _textMid = Color(0xFF6B8B72);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _lightGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2EFE0)),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: _textMid,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
