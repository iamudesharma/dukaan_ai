import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Creates the workspace for a freshly registered owner.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _name = TextEditingController();
  final _legalName = TextEditingController();
  final _locationName = TextEditingController(text: 'Main Shop');
  final _gstin = TextEditingController();
  final _stateCode = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // The create button tracks whether a shop name has been typed.
    _name.addListener(_onNameChanged);
  }

  void _onNameChanged() => setState(() {});

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _legalName.dispose();
    _locationName.dispose();
    _gstin.dispose();
    _stateCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).createBusiness(
            name: _name.text.trim(),
            legalName: _legalName.text.trim(),
            locationName: _locationName.text.trim(),
            gstin: _gstin.text.trim().toUpperCase(),
            stateCode: _stateCode.text.trim(),
          );
      // The shell reads locations through this provider; it was empty until now.
      ref.invalidate(locationsProvider);
    } on AuthFailure catch (failure) {
      setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DukaanTokens.space4),
          children: [
            DukaanHeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DukaanHeroEyebrow('DukaanAI · One last step'),
                  const SizedBox(height: DukaanTokens.space2),
                  DukaanHeroText(
                    strings.t('onboardingTitle'),
                    style: DukaanTokens.textDisplay,
                  ),
                  const SizedBox(height: DukaanTokens.space2),
                  DukaanHeroText(strings.t('onboardingDetail')),
                ],
              ),
            ),
            const SizedBox(height: DukaanTokens.space4),
            DukaanCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DukaanField(
                    label: strings.t('shopName'),
                    child: TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                          const InputDecoration(hintText: 'e.g. Gupta Traders'),
                    ),
                  ),
                  const SizedBox(height: DukaanTokens.space3),
                  DukaanField(
                    label: strings.t('shopLegalName'),
                    child: TextField(
                      controller: _legalName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(),
                    ),
                  ),
                  const SizedBox(height: DukaanTokens.space3),
                  DukaanField(
                    label: strings.t('shopLocation'),
                    child: TextField(
                      controller: _locationName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(),
                    ),
                  ),
                  const SizedBox(height: DukaanTokens.space3),
                  DukaanField(
                    label: strings.t('shopGstin'),
                    child: TextField(
                      controller: _gstin,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 15,
                      decoration: const InputDecoration(
                          hintText: '07AAAAA0000A1Z5', counterText: ''),
                    ),
                  ),
                  const SizedBox(height: DukaanTokens.space3),
                  DukaanField(
                    label: strings.t('shopStateCode'),
                    child: TextField(
                      controller: _stateCode,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      decoration: const InputDecoration(
                          hintText: '07', counterText: ''),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: DukaanTokens.space3),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: DukaanTokens.space4),
                  FilledButton(
                    onPressed: _submitting || _name.text.trim().isEmpty
                        ? null
                        : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(strings.t('createShop')),
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
