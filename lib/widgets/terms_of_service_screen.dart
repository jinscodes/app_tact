import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
            'Terms of Service',
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
                  'Agreement to Terms',
                  'By accessing or using Tact, you agree to be bound by these Terms of Service and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using or accessing this app.',
                ),
                _buildSection(
                  'Description of Service',
                  'Tact is a link organization and management application that allows users to:\n\n'
                      '• Create and manage categories for organizing links\n'
                      '• Store and access web links efficiently\n'
                      '• Sync data across devices\n'
                      '• Create notes and annotations\n'
                      '• Customize their organizational system',
                ),
                _buildSection(
                  'Account Registration',
                  'To use certain features of the app, you must register for an account. You agree to:\n\n'
                      '• Provide accurate and complete registration information\n'
                      '• Maintain the security of your account credentials\n'
                      '• Notify us immediately of any unauthorized access\n'
                      '• Be responsible for all activities under your account\n'
                      '• Not share your account with others',
                ),
                _buildSection(
                  'User Responsibilities',
                  'You are responsible for:\n\n'
                      '• All content you store or share through the app\n'
                      '• Ensuring your use complies with applicable laws\n'
                      '• Maintaining backup copies of your important data\n'
                      '• Using the service in a lawful and respectful manner\n'
                      '• Not attempting to compromise the security of the service',
                ),
                _buildSection(
                  'Prohibited Activities',
                  'You agree not to:\n\n'
                      '• Use the app for any illegal purpose\n'
                      '• Attempt to gain unauthorized access to any part of the service\n'
                      '• Transmit viruses, malware, or harmful code\n'
                      '• Harass, abuse, or harm other users\n'
                      '• Impersonate others or misrepresent your identity\n'
                      '• Scrape, crawl, or data mine the service\n'
                      '• Reverse engineer or decompile the app\n'
                      '• Use automated systems to access the service',
                ),
                _buildSection(
                  'Content Ownership',
                  'You retain all rights to the content you store in Tact. By using our service, you grant us a license to:\n\n'
                      '• Store and process your content to provide the service\n'
                      '• Create backups for data protection\n'
                      '• Use aggregated, anonymized data for service improvement\n\n'
                      'This license ends when you delete your content or account.',
                ),
                _buildSection(
                  'Intellectual Property',
                  'The app, including its design, features, code, and content (excluding user content), is owned by Tact and protected by copyright, trademark, and other intellectual property laws. You may not copy, modify, distribute, or create derivative works without our express permission.',
                ),
                _buildSection(
                  'Service Availability',
                  'We strive to provide reliable service but do not guarantee:\n\n'
                      '• Uninterrupted access to the service\n'
                      '• Error-free operation\n'
                      '• That the service will meet your specific requirements\n'
                      '• That defects will be corrected immediately\n\n'
                      'We reserve the right to modify, suspend, or discontinue the service at any time.',
                ),
                _buildSection(
                  'Data Backup and Loss',
                  'While we implement backup systems, we recommend maintaining your own backups of important data. We are not liable for any data loss, corruption, or deletion that may occur.',
                ),
                _buildSection(
                  'Third-Party Services',
                  'Our app integrates with third-party services (Google, GitHub, Firebase). Your use of these services is subject to their respective terms and privacy policies. We are not responsible for third-party service failures or changes.',
                ),
                _buildSection(
                  'Limitation of Liability',
                  'To the maximum extent permitted by law, Tact shall not be liable for:\n\n'
                      '• Any indirect, incidental, or consequential damages\n'
                      '• Loss of data, profits, or business opportunities\n'
                      '• Service interruptions or data breaches\n'
                      '• Actions of third parties\n\n'
                      'Our total liability shall not exceed the amount you paid for the service in the past 12 months.',
                ),
                _buildSection(
                  'Termination',
                  'We reserve the right to terminate or suspend your account if you:\n\n'
                      '• Violate these Terms of Service\n'
                      '• Engage in fraudulent or illegal activities\n'
                      '• Abuse or misuse the service\n'
                      '• Fail to comply with our policies\n\n'
                      'You may terminate your account at any time through the app settings.',
                ),
                _buildSection(
                  'Privacy',
                  'Your use of Tact is also governed by our Privacy Policy. By using the service, you consent to our collection and use of information as described in the Privacy Policy.',
                ),
                _buildSection(
                  'Changes to Terms',
                  'We may update these Terms of Service from time to time. We will notify you of material changes by:\n\n'
                      '• Posting the updated terms in the app\n'
                      '• Sending an email notification\n'
                      '• Displaying an in-app notification\n\n'
                      'Continued use of the service after changes constitutes acceptance of the new terms.',
                ),
                _buildSection(
                  'Governing Law',
                  'These Terms of Service shall be governed by and construed in accordance with the laws of the jurisdiction in which our company is registered, without regard to its conflict of law provisions.',
                ),
                _buildSection(
                  'Dispute Resolution',
                  'Any disputes arising from these terms or your use of the service shall be resolved through:\n\n'
                      '1. Good faith negotiation between the parties\n'
                      '2. Mediation if negotiation fails\n'
                      '3. Binding arbitration if mediation is unsuccessful',
                ),
                _buildSection(
                  'Contact Information',
                  'If you have questions about these Terms of Service, please contact us:\n\n'
                      'Email: jayhan0215@gmail.com\n'
                      'Website: https://jay-portfolio-99.netlify.app/\n\n'
                      'For legal inquiries:\n'
                      'Email: jay0215@gmail.com',
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
