import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DashboardFeature extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const DashboardFeature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  @override
  List<Object?> get props => [id, title, subtitle, icon, route];
}
