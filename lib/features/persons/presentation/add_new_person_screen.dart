import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/text_field/custom_text_field.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';
import 'package:sodais_finance/features/persons/presentation/controllers/add_new_person_form_controller.dart';

class AddNewPersonScreen extends ConsumerStatefulWidget {
  const AddNewPersonScreen({super.key});

  @override
  ConsumerState<AddNewPersonScreen> createState() => _AddNewPersonScreenState();
}

class _AddNewPersonScreenState extends ConsumerState<AddNewPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(addNewPersonFormProvider.notifier);
    final didSave = await formNotifier.submit(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      email: _emailController.text,
      balanceText: _balanceController.text,
    );

    if (didSave && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(addNewPersonFormProvider.select((state) => state.errorMessage), (
      previous,
      next,
    ) {
      if (next == null || next == previous || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next), backgroundColor: Colors.red),
      );
    });

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formState = ref.watch(addNewPersonFormProvider);
    final formNotifier = ref.read(addNewPersonFormProvider.notifier);
    final selectedImagePath = formState.selectedImagePath;
    final hasImage =
        selectedImagePath != null && File(selectedImagePath).existsSync();
    final pagePadding = sizeConstants.spacingMedium;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(LocaleKeys.addNewPerson.tr()),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            sizeConstants.spacingXSmall,
            pagePadding,
            pagePadding,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: FilledButton.icon(
            onPressed: formState.isSaving ? null : _handleSave,
            icon: formState.isSaving
                ? SizedBox(
                    width: sizeConstants.iconSmall,
                    height: sizeConstants.iconSmall,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.save_outlined, size: sizeConstants.iconMedium),
            label: Text(
              formState.isSaving
                  ? LocaleKeys.saving.tr()
                  : LocaleKeys.save.tr(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            pagePadding,
            pagePadding,
            sizeConstants.spacingXXLarge * 2,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTypeToggle(
                      context: context,
                      selectedType: formState.type,
                      onSelect: formNotifier.setType,
                    ),
                    SizedBox(height: sizeConstants.spacingMedium),
                    Center(
                      child: GestureDetector(
                        onTap: formNotifier.pickImageFromGallery,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: sizeConstants.imageMedium,
                              height: sizeConstants.imageMedium,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: ClipOval(
                                child: hasImage
                                    ? Image.file(
                                        File(selectedImagePath),
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: sizeConstants.iconXLarge,
                                        color: theme.hintColor,
                                      ),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: sizeConstants.avatarXSmall,
                                height: sizeConstants.avatarXSmall,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.cardColor),
                                ),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: sizeConstants.iconSmall,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingMedium),
                    CustomTextField(
                      controller: _nameController,
                      label: LocaleKeys.name.tr(),
                      hintText: LocaleKeys.name.tr(),
                      prefixIconData: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return LocaleKeys.nameRequired.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    CustomTextField(
                      controller: _phoneController,
                      label: LocaleKeys.phone.tr(),
                      hintText: LocaleKeys.phone.tr(),
                      prefixIconData: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    CustomTextField(
                      controller: _emailController,
                      label: LocaleKeys.emailAddress.tr(),
                      hintText: LocaleKeys.emailAddress.tr(),
                      prefixIconData: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return null;
                        final isValid = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email);
                        return isValid
                            ? null
                            : LocaleKeys.invalidEmailAddress.tr();
                      },
                    ),
                    SizedBox(height: sizeConstants.spacingSmall),
                    CustomTextField(
                      controller: _addressController,
                      label: LocaleKeys.address.tr(),
                      hintText: LocaleKeys.address.tr(),
                      prefixIconData: Icons.location_on_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: sizeConstants.spacingMedium),
                    Container(
                      padding: EdgeInsets.all(sizeConstants.spacingMedium),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(
                          sizeConstants.radiusMedium,
                        ),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: sizeConstants.iconMedium,
                                color: colors.primary,
                              ),
                              SizedBox(width: sizeConstants.spacingXSmall),
                              Text(
                                LocaleKeys.openingBalance.tr(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sizeConstants.spacingMedium),
                          CustomTextField(
                            controller: _balanceController,
                            label: LocaleKeys.balance.tr(),
                            hintText: LocaleKeys.balance.tr(),
                            prefixIconData: Icons.attach_money,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              return double.tryParse(value.trim()) == null
                                  ? LocaleKeys.invalidNumber.tr()
                                  : null;
                            },
                          ),
                          SizedBox(height: sizeConstants.spacingSmall),
                          Row(
                            children: [
                              Expanded(
                                child: _buildBalanceDirectionCard(
                                  context: context,
                                  title: LocaleKeys.youPay.tr(),
                                  icon: Icons.arrow_outward,
                                  reverseIcon: true,
                                  selected:
                                      formState.openingBalanceDirection ==
                                      OpeningBalanceDirection.youPay,
                                  activeColor: Colors.red,
                                  onTap: () {
                                    formNotifier.setOpeningBalanceDirection(
                                      OpeningBalanceDirection.youPay,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: sizeConstants.spacingSmall),
                              Expanded(
                                child: _buildBalanceDirectionCard(
                                  context: context,
                                  title: LocaleKeys.youReceive.tr(),
                                  icon: Icons.arrow_outward,
                                  reverseIcon: false,
                                  selected:
                                      formState.openingBalanceDirection ==
                                      OpeningBalanceDirection.youReceive,
                                  activeColor: Colors.green,
                                  onTap: () {
                                    formNotifier.setOpeningBalanceDirection(
                                      OpeningBalanceDirection.youReceive,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sizeConstants.spacingSmall),
                          _buildBalanceDirectionNotes(
                            context: context,
                            selectedDirection:
                                formState.openingBalanceDirection,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sizeConstants.spacingLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle({
    required BuildContext context,
    required PersonType selectedType,
    required ValueChanged<PersonType> onSelect,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
      ),
      padding: EdgeInsets.all(sizeConstants.spacingXXSmall),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              context: context,
              title: LocaleKeys.customer.tr(),
              selected: selectedType == PersonType.customer,
              onTap: () => onSelect(PersonType.customer),
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              context: context,
              title: LocaleKeys.supplier.tr(),
              selected: selectedType == PersonType.supplier,
              onTap: () => onSelect(PersonType.supplier),
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              context: context,
              title: LocaleKeys.both.tr(),
              selected: selectedType == PersonType.both,
              onTap: () => onSelect(PersonType.both),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: sizeConstants.spacingXSmall),
        decoration: BoxDecoration(
          color: selected ? theme.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? colors.primary : theme.hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceDirectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool reverseIcon,
    required bool selected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: sizeConstants.spacingSmall,
          vertical: sizeConstants.spacingXSmall,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
          border: Border.all(
            color: selected ? activeColor : theme.dividerColor,
          ),
          color: selected
              ? activeColor.withValues(alpha: 0.10)
              : theme.colorScheme.surfaceContainerLow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? activeColor : theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: sizeConstants.spacingXXSmall),
            Transform.rotate(
              angle: reverseIcon ? 3.14159 : 0,
              child: Icon(
                icon,
                size: sizeConstants.iconSmall + 2,
                color: selected ? activeColor : theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDirectionNotes({
    required BuildContext context,
    required OpeningBalanceDirection selectedDirection,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceDirectionNoteItem(
          context: context,
          label: LocaleKeys.youPay.tr(),
          note: LocaleKeys.youPayNote.tr(),
          active: selectedDirection == OpeningBalanceDirection.youPay,
          color: Colors.red,
          textTheme: textTheme,
        ),
        SizedBox(height: sizeConstants.spacingXXSmall + 2),
        _buildBalanceDirectionNoteItem(
          context: context,
          label: LocaleKeys.youReceive.tr(),
          note: LocaleKeys.youReceiveNote.tr(),
          active: selectedDirection == OpeningBalanceDirection.youReceive,
          color: Colors.green,
          textTheme: textTheme,
        ),
      ],
    );
  }

  Widget _buildBalanceDirectionNoteItem({
    required BuildContext context,
    required String label,
    required String note,
    required bool active,
    required Color color,
    required TextTheme textTheme,
  }) {
    final hintColor = Theme.of(context).hintColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: sizeConstants.spacingXXSmall + 1),
          child: Icon(
            Icons.circle,
            size: sizeConstants.fontXSmall - 2,
            color: active ? color : hintColor,
          ),
        ),
        SizedBox(width: sizeConstants.spacingXSmall),
        Expanded(
          child: Text(
            '$label: $note',
            style: textTheme.bodySmall?.copyWith(
              color: active ? color : hintColor,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
