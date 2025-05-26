import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.privacy_tip, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.privacyPolicy,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: March 19, 2024',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Introduction',
                'My Freezer ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application ("App").',
              ),
              _buildSection(
                context,
                'Information We Collect',
                'We collect the following types of information:\n\n'
                    '• User Account Information: When you create an account, we collect your email address and password (stored securely using encryption).\n'
                    '• User Content: Information you input into the app, such as food inventory items, expiration dates, and storage locations.\n'
                    '• Device Data: Basic device information such as device type, operating system version, and unique device identifiers.\n'
                    '• Usage Data: Information about how you interact with the app, including features used and time spent in the app.',
              ),
              _buildSection(
                context,
                'How We Use Your Information',
                'We use the collected information to:\n\n'
                    '• Provide and maintain the App\'s functionality\n'
                    '• Improve and personalize your experience\n'
                    '• Send you important updates about the App\n'
                    '• Respond to your support requests\n'
                    '• Analyze app usage to improve our services',
              ),
              _buildSection(
                context,
                'Data Storage and Security',
                '• All data is stored locally on your device\n'
                    '• We use industry-standard security measures to protect your information\n'
                    '• Your data is encrypted during transmission\n'
                    '• We do not share your personal information with third parties',
              ),
              _buildSection(
                context,
                'Children\'s Privacy',
                'Our App is not directed to children under 13 years of age. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
              ),
              _buildSection(
                context,
                'Your Rights',
                'You have the right to:\n\n'
                    '• Access your personal information\n'
                    '• Correct inaccurate data\n'
                    '• Delete your account and associated data\n'
                    '• Export your data\n'
                    '• Opt-out of non-essential communications',
              ),
              _buildSection(
                context,
                'Changes to This Privacy Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
              ),
              _buildSection(
                  context,
                  'Contact Us',
                  'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                      '• Email: onlytarg@gmail.com'),
              _buildSection(
                context,
                'Compliance',
                'This Privacy Policy complies with:\n\n'
                    '• General Data Protection Regulation (GDPR)\n'
                    '• California Consumer Privacy Act (CCPA)\n'
                    '• Children\'s Online Privacy Protection Act (COPPA)\n'
                    '• App Store Guidelines\n'
                    '• Google Play Store Requirements',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
