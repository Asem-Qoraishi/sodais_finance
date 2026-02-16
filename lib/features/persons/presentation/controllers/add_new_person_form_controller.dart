import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/persons_controller.dart';

part 'add_new_person_form_controller.g.dart';

enum OpeningBalanceDirection { youPay, youReceive }

@immutable
class AddNewPersonFormState {
  final PersonType type;
  final OpeningBalanceDirection openingBalanceDirection;
  final String? selectedImagePath;
  final bool isSaving;
  final String? errorMessage;

  const AddNewPersonFormState({
    this.type = PersonType.customer,
    this.openingBalanceDirection = OpeningBalanceDirection.youReceive,
    this.selectedImagePath,
    this.isSaving = false,
    this.errorMessage,
  });

  AddNewPersonFormState copyWith({
    PersonType? type,
    OpeningBalanceDirection? openingBalanceDirection,
    String? selectedImagePath,
    bool clearImage = false,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddNewPersonFormState(
      type: type ?? this.type,
      openingBalanceDirection:
          openingBalanceDirection ?? this.openingBalanceDirection,
      selectedImagePath: clearImage
          ? null
          : (selectedImagePath ?? this.selectedImagePath),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class AddNewPersonForm extends _$AddNewPersonForm {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  AddNewPersonFormState build() => const AddNewPersonFormState();

  void setType(PersonType type) {
    state = state.copyWith(type: type, clearError: true);
  }

  void setOpeningBalanceDirection(OpeningBalanceDirection direction) {
    state = state.copyWith(
      openingBalanceDirection: direction,
      clearError: true,
    );
  }

  Future<void> pickImageFromGallery() async {
    if (state.isSaving) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
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
    required String name,
    required String balanceText,
    String? phone,
    String? address,
    String? email,
  }) async {
    if (state.isSaving) return false;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final rawBalance = double.tryParse(balanceText.trim()) ?? 0.0;
      final openingBalance =
          state.openingBalanceDirection == OpeningBalanceDirection.youReceive
          ? rawBalance.abs()
          : -rawBalance.abs();
      final persistedImagePath = await _persistImageIfNeeded(
        state.selectedImagePath,
      );

      await ref
          .read(personsControllerProvider.notifier)
          .addPerson(
            name: name.trim(),
            image: persistedImagePath,
            phone: _trimToNull(phone),
            address: _trimToNull(address),
            email: _trimToNull(email),
            type: state.type,
            balance: openingBalance,
          );

      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return false;
    }
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
    final imagesDir = Directory(p.join(appDir.path, 'person_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = p.extension(path).toLowerCase();
    final fileName =
        'person_${DateTime.now().millisecondsSinceEpoch}${extension.isEmpty ? '.jpg' : extension}';
    final targetPath = p.join(imagesDir.path, fileName);
    await sourceFile.copy(targetPath);

    return targetPath;
  }

  bool _isManagedImagePath(String path) {
    return path.contains(
      '${Platform.pathSeparator}person_images${Platform.pathSeparator}',
    );
  }
}
