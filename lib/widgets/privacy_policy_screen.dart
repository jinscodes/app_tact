import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0B0E1D), Color(0xFF2E2939)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Updated: November 30, 2025',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildSection(
                  'Introduction',
                  'Welcome to Tact. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you use our app and tell you about your privacy rights.',
                ),
                _buildSection(
                  'Information We Collect',
                  'We collect the following types of information:\n\n'
                      '• Account Information: Name, email address, and authentication credentials when you sign up\n'
                      '• Profile Data: Information you provide in your profile settings\n'
                      '• Usage Data: Information about how you use our app, including categories and links you create\n'
                      '• Device Information: Device type, operating system, and app version\n'
                      '• Authentication Data: Google or GitHub account information if you sign in with these services',
                ),
                _buildSection(
                  'How We Use Your Information',
                  'We use your information to:\n\n'
                      '• Provide and maintain our services\n'
                      '• Authenticate your identity and manage your account\n'
                      '• Personalize your experience\n'
                      '• Send you important notifications about your account\n'
                      '• Improve and optimize our app\n'
                      '• Ensure the security of our services\n'
                      '• Comply with legal obligations',
                ),
                _buildSection(
                  'Data Storage and Security',
                  'We use Firebase services to securely store your data. Your data is encrypted in transit and at rest. We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                ),
                _buildSection(
                  'Data Sharing',
                  'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n'
                      '• With your explicit consent\n'
                      '• To comply with legal obligations\n'
                      '• To protect our rights and prevent fraud\n'
                      '• With service providers who assist in operating our app (e.g., Firebase, Google)',
                ),
                _buildSection(
                  'Your Rights',
                  'You have the right to:\n\n'
                      '• Access your personal data\n'
                      '• Correct inaccurate data\n'
                      '• Request deletion of your data\n'
                      '• Export your data\n'
                      '• Withdraw consent at any time\n'
                      '• Object to processing of your data',
                ),
                _buildSection(
                  'Third-Party Services',
                  'Our app uses third-party services that may collect information used to identify you:\n\n'
                      '• Firebase Authentication and Firestore\n'
                      '• Google Sign-In\n'
                      '• GitHub OAuth\n\n'
                      'These services have their own privacy policies governing the use of your information.',
                ),
                _buildSection(
                  'Data Retention',
                  'We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this privacy policy. You can request deletion of your account and associated data at any time through the app settings.',
                ),
                _buildSection(
                  'Children\'s Privacy',
                  'Our services are not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
                ),
                _buildSection(
                  'Changes to This Policy',
                  'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the "Last Updated" date.',
                ),
                _buildSection(
                  'Contact Us',
                  'If you have any questions about this privacy policy or our data practices, please contact us at:\n\n'
                      'Email: jayhan0215@gmail.com\n'
                      'Website: https://jay-portfolio-99.netlify.app/',
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF7B68EE),
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14.sp,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
