import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/presentation/controllers/products_controller.dart';

part 'add_new_product_form_controller.g.dart';

@immutable
class AddNewProductFormState {
  final String? selectedImagePath;
  final String? selectedCategoryId;
  final bool isSaving;
  final String? errorMessage;

  const AddNewProductFormState({
    this.selectedImagePath,
    this.selectedCategoryId,
    this.isSaving = false,
    this.errorMessage,
  });

  AddNewProductFormState copyWith({
    String? selectedImagePath,
    bool clearImage = false,
    String? selectedCategoryId,
    bool clearCategory = false,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddNewProductFormState(
      selectedImagePath: clearImage
          ? null
          : (selectedImagePath ?? this.selectedImagePath),
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class AddNewProductForm extends _$AddNewProductForm {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  AddNewProductFormState build() => const AddNewProductFormState();

  void initialize({String? imagePath, String? categoryId}) {
    state = AddNewProductFormState(
      selectedImagePath: _trimToNull(imagePath),
      selectedCategoryId: _trimToNull(categoryId),
    );
  }

  void setCategoryId(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId, clearError: true);
  }

  Future<void> pickImageFromGallery() async {
    if (state.isSaving) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      state = state.copyWith(
        selectedImagePath: pickedFile.path,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<bool> submit({
    Product? editingProduct,
    required String name,
    String? sku,
    String? description,
    String? purchasePriceText,
    String? sellingPriceText,
    String? taxRateText,
    String? stockText,
    String? reorderLevelText,
    String? location,
  }) async {
    if (state.isSaving) return false;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final persistedImagePath = await _persistImageIfNeeded(
        state.selectedImagePath,
      );
      final purchasePrice = _parseDouble(purchasePriceText);
      final sellingPrice = _parseDouble(sellingPriceText);
      final taxRate = _parseDouble(taxRateText);
      final stock = _parseInt(stockText);
      final reorderLevel = _parseInt(reorderLevelText);
      final trimmedName = name.trim();
      final productsController = ref.read(productsControllerProvider.notifier);

      if (editingProduct == null) {
        await productsController.addProduct(
          name: trimmedName,
          sku: _trimToNull(sku),
          categoryId: _trimToNull(state.selectedCategoryId),
          description: _trimToNull(description),
          imagePath: persistedImagePath,
          purchasePrice: purchasePrice,
          sellingPrice: sellingPrice,
          taxRate: taxRate,
          stock: stock,
          reorderLevel: reorderLevel,
          location: _trimToNull(location),
        );
      } else {
        await productsController.updateProduct(
          Product(
            id: editingProduct.id,
            name: trimmedName,
            description: _trimToNull(description),
            imagePath: persistedImagePath,
            sku: _trimToNull(sku),
            categoryId: _trimToNull(state.selectedCategoryId),
            purchasePrice: purchasePrice,
            sellingPrice: sellingPrice,
            taxRate: taxRate,
            stock: stock,
            reorderLevel: reorderLevel,
            location: _trimToNull(location),
            createdAt: editingProduct.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
      }

      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return false;
    }
  }

  double _parseDouble(String? value) {
    return double.tryParse((value ?? '').trim()) ?? 0.0;
  }

  int _parseInt(String? value) {
    final parsed = int.tryParse((value ?? '').trim()) ?? 0;
    return parsed < 0 ? 0 : parsed;
  }

  String? _trimToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<String?> _persistImageIfNeeded(String? sourcePath) async {
    final path = _trimToNull(sourcePath);
    if (path == null) return null;
    if (_isManagedImagePath(path)) return path;

    final sourceFile = File(path);
    if (!await sourceFile.exists()) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'product_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = p.extension(path).toLowerCase();
    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}${extension.isEmpty ? '.jpg' : extension}';
    final targetPath = p.join(imagesDir.path, fileName);
    await sourceFile.copy(targetPath);

    return targetPath;
  }

  bool _isManagedImagePath(String path) {
    return path.contains(
      '${Platform.pathSeparator}product_images${Platform.pathSeparator}',
    );
  }
}
