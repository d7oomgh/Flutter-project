// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'How can we help you?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 24),

              // Contact Cards
              _buildContactCard(
                context,
                icon: Icons.phone,
                title: 'Call Us',
                subtitle: '555-555-5555',
                onTap: () => _makePhoneCall('5555555555'),
              ),
              _buildContactCard(
                context,
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@example.com',
                onTap: () => _launchURL('mailto:support@example.com'),
              ),
              _buildContactCard(
                context,
                icon: Icons.location_on,
                title: 'Visit Us',
                subtitle: '123 Main St, Anytown, KSA',
                onTap: () => _launchURL('https://maps.google.com/?q=123+Main+St,+Anytown,+KSA'),
              ),

              SizedBox(height: 32),

              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildFAQItem(
                context,
                question: 'How do I reset my password?',
                answer: 'You can reset your password by clicking on the "Forgot Password" link on the login screen.',
              ),
              _buildFAQItem(
                context,
                question: 'What are your business hours?',
                answer: 'We are available 24/7 for your support needs.',
              ),
              _buildFAQItem(
                context,
                question: 'How long does it take to get a response?',
                answer: 'We typically respond to all inquiries within 24 hours.',
              ),

              // Social Media Section
              SizedBox(height: 32),
              Text(
                'Follow Us',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildSocialButton(
                    icon: Icons.facebook,
                    onTap: () => _launchURL('https://facebook.com'),
                  ),
                  SizedBox(width: 16),
                  _buildSocialButton(
                    icon: Icons.telegram,
                    onTap: () => _launchURL('https://telegram.org'),
                  ),
                  SizedBox(width: 16),
                  _buildSocialButton(
                    icon: Icons.whatshot,
                    onTap: () => _launchURL('https://twitter.com'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Icon(icon),
      ),
    );
  }
}