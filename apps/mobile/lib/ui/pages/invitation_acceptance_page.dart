import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/ui/common/settings_page_layout.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:dukaan_ai_mobile/ui/pages/invitation_acceptance_panel.dart';
import 'package:flutter/material.dart';

class InvitationAcceptancePage extends StatelessWidget {
  const InvitationAcceptancePage({super.key});

  @override
  Widget build(BuildContext context) => SettingsPageLayout(
        title: context.strings.t('acceptInvitation'),
        subtitle: context.strings.t('acceptInvitationDetail'),
        child: ListView(
          children: const [
            DukaanCard(child: InvitationAcceptancePanel()),
          ],
        ),
      );
}
