import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AdminContactScreen extends StatelessWidget {
  const AdminContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = _adminContacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = contacts[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.city,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.support_agent,
                        size: 18,
                        color: AppTheme.mitsuiDarkBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c.phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminContact {
  final String city;
  final String name;
  final String phone;
  final String email;

  const _AdminContact({
    required this.city,
    required this.name,
    required this.phone,
    required this.email,
  });
}

const List<_AdminContact> _adminContacts = [
  _AdminContact(
    city: 'Delhi',
    name: 'Mr. Vijay Yadav',
    phone: '9810406781',
    email: 'Vi.Yadav@mitsui.com',
  ),
  _AdminContact(
    city: 'Delhi',
    name: 'Mr. Vijay Kumar',
    phone: '9818898192',
    email: 'Vi.Kumar@mitsui.com',
  ),
  _AdminContact(
    city: 'Mumbai',
    name: 'Mr. Manish Narvekar',
    phone: '98206 15138',
    email: 'M.Narvekar@mitsui.com',
  ),
  _AdminContact(
    city: 'Mumbai',
    name: 'Mr. Yogesh Paliwal',
    phone: '91673 73845',
    email: 'Y.Padwal@mitsui.com',
  ),
  _AdminContact(
    city: 'Mumbai',
    name: 'Mr. Arun Khedekar',
    phone: '98206 07233',
    email: 'A.Khedekar@mitsui.com',
  ),
  _AdminContact(
    city: 'Chennai',
    name: 'Mr. Sankara Gomathinayagam',
    phone: '9566099898',
    email: 'S.Gomathinayagam@mitsui.com',
  ),
  _AdminContact(
    city: 'Bangalore',
    name: 'Mr. Sankara Gomathinayagam',
    phone: '9566099898',
    email: 'S.Gomathinayagam@mitsui.com',
  ),
  _AdminContact(
    city: 'Bengaluru',
    name: 'Ms. Shreeja Sp',
    phone: '7428578328',
    email: 'S.Sp@mitsui.com',
  ),
  _AdminContact(
    city: 'Kolkata',
    name: 'Ms. Priyanjali Das',
    phone: '9775656765',
    email: 'P.Das@mitsui.com',
  ),
];

