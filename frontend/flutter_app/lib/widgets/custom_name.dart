import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/app_styles.dart';
import '../utils/navigation_utils.dart'; // For handling link taps

// Footer Widget Definition
class CustomFooter extends StatelessWidget {
  const CustomFooter({Key? key}) : super(key: key);

  // --- Mock Data for Footer Links ---
  static const List<Map<String, String>> companyLinks = [
    {'title': 'About Us', 'route': '/about'},
    {'title': 'Careers', 'route': '/careers'},
    {'title': 'Blog', 'route': '/blog'},
  ];

  static const List<Map<String, String>> helpLinks = [
    {'title': 'Contact Us', 'route': '/contact'},
    {'title': 'FAQ', 'route': '/faq'},
    {'title': 'Shipping & Returns', 'route': '/shipping'},
  ];

  static const List<Map<String, String>> legalLinks = [
    {'title': 'Terms of Service', 'route': '/terms'},
    {'title': 'Privacy Policy', 'route': '/privacy'},
  ];

  @override
  Widget build(BuildContext context) {
    // Determine the footer color (dark background for contrast)
    const Color footerBgColor = AppColors.textPrimary;
    const Color footerTextColor = AppColors.surfaceColor;

    // Use a Container to span the full width
    return Container(
      width: double.infinity,
      color: footerBgColor,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.kSpacingExtraLarge,
      ),

      child: Center(
        child: Container(
          // Constrain the content width to match the AppBar
          constraints: const BoxConstraints(
            maxWidth: AppConstants.kMaxContentWidth,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.kDefaultPadding,
          ),

          // Main content layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppConstants.kSpacingLarge * 2,
                runSpacing: AppConstants.kSpacingLarge,
                children: [
                  _buildBrandInfo(footerTextColor),

                  _buildLinkColumn('Company', companyLinks, footerTextColor),

                  _buildLinkColumn('Help Center', helpLinks, footerTextColor),

                  _buildLinkColumn('Legal', legalLinks, footerTextColor),
                ],
              ),

              // 2. Divider Line
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.kSpacingLarge,
                ),
                child: Divider(color: footerTextColor.withOpacity(0.2)),
              ),

              // 3. Copyright Row
              _buildCopyright(footerTextColor),
            ],
          ),
        ),
      ),
    );
  }

  // --- Builder Methods ---

  Widget _buildBrandInfo(Color textColor) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.kAppName,
            style: AppStyles.headingPrimary.copyWith(
              color: textColor,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppConstants.kSpacingMedium),
          Text(
            'Your best online shopping experience.',
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: AppConstants.kSpacingMedium),
          Row(
            children: [
              Icon(Icons.facebook, color: textColor.withOpacity(0.7), size: 24),
              AppSpaces.smallHorizontal,
              Icon(Icons.share, color: textColor.withOpacity(0.7), size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkColumn(
    String title,
    List<Map<String, String>> links,
    Color textColor,
  ) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppConstants.kSpacingMedium),
          ...links
              .map(
                (link) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.kSpacingSmall,
                  ),
                  child: InkWell(
                    onTap: () {
                      print('Navigating to: ${link['route']}');
                    },
                    child: Text(
                      link['title']!,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCopyright(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '© ${DateTime.now().year} ${AppConstants.kAppName}. All Rights Reserved.',
          style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
        ),
        Text(
          'Version ${AppConstants.kAppVersion}',
          style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
        ),
      ],
    );
  }
}
