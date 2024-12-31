import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _FaqSearchDelegate(faqItems: _faqItems),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find answers to common questions about our emergency response system',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // Categories
              _buildCategorySection(context),
              const SizedBox(height: 24),

              // FAQ Items
              ..._faqItems.map((item) => _buildFaqItem(context, item)).toList(),

              const SizedBox(height: 32),

              // Still Need Help Section
              _buildNeedHelpSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final categories = [
      {'icon': Icons.app_settings_alt, 'label': 'General'},
      {'icon': Icons.security, 'label': 'Safety'},
      {'icon': Icons.account_circle, 'label': 'Account'},
      {'icon': Icons.settings, 'label': 'Settings'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['label'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          item['question']!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['answer']!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                if (item['additionalInfo'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['additionalInfo']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedHelpSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Still Need Help?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'If you couldn\'t find the answer you\'re looking for, our support team is here to help.',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHelpButton(
                context,
                icon: Icons.mail_outline,
                label: 'Email Support',
                onTap: () {
                  // Add email support action
                },
              ),
              _buildHelpButton(
                context,
                icon: Icons.chat_bubble_outline,
                label: 'Live Chat',
                onTap: () {
                  // Add live chat action
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

// Search Delegate for FAQ
class _FaqSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, String>> faqItems;

  _FaqSearchDelegate({required this.faqItems});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = faqItems.where((item) {
      return item['question']!.toLowerCase().contains(query.toLowerCase()) ||
          item['answer']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(
            item['question']!,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            item['answer']!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            close(context, item['question']!);
          },
        );
      },
    );
  }
}

// FAQ Data
final List<Map<String, String>> _faqItems = [
  {
    'question': 'What is this emergency response system?',
    'answer':
        'Our map-based emergency response system is a cutting-edge platform designed to connect users with emergency services quickly and efficiently. It uses real-time location tracking and advanced mapping technology to ensure help reaches you as fast as possible.',
    'additionalInfo': 'Available 24/7 in all major cities across the country.',
  },
  {
    'question': 'How do I use this app in an emergency?',
    'answer':
        '1. Open the app\n2. Tap the emergency button\n3. Select the type of emergency\n4. Confirm your location or adjust if needed\n5. Wait for confirmation and stay on the line',
    'additionalInfo': 'The average response time is under 3 minutes.',
  },
  {
    'question': 'What types of emergencies does this app handle?',
    'answer':
        'Our app handles various emergency situations including medical emergencies, fire, police assistance, and natural disasters. Each type of emergency is routed to the appropriate response team.',
  },
  {
    'question': 'Is my location data secure?',
    'answer':
        'Yes, we take your privacy seriously. Your location data is encrypted and only shared with emergency responders when you initiate an emergency call. We never store or sell your location data.',
    'additionalInfo': 'Compliant with GDPR and other privacy regulations.',
  },
  {
    'question': 'What if I lose internet connection?',
    'answer':
        'The app includes an offline mode that can still call emergency services using your device\'s cellular connection. Some features may be limited, but core emergency functions remain operational.',
  },
  {
    'question': 'How accurate is the location tracking?',
    'answer':
        'Our system uses GPS, Wi-Fi, and cellular triangulation to provide accuracy typically within 10 meters. In urban areas, accuracy can be even better.',
  },
  {
    'question': 'Can I use this app for someone else\'s emergency?',
    'answer':
        'Yes, you can report emergencies on behalf of others. The app allows you to manually input a different location or share the location of the person in need.',
  },
  {
    'question': 'Is there a cost to use this service?',
    'answer':
        'The basic emergency services are completely free. Premium features like family tracking and automated emergency alerts are available with a subscription.',
    'additionalInfo': 'Premium features start at \$4.99/month.',
  },
];