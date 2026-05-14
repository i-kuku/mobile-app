import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class CandidateConfig {
  final String id;
  final GlobalKey key;
  final ContentAlign align;
  final String title;
  final String message;

  CandidateConfig({
    required this.id,
    required this.key,
    required this.align,
    required this.title,
    required this.message,
  });
}

