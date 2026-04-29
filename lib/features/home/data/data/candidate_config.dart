import 'package:ikuku/features/home/data/model/candidate_config.dart';
import 'package:ikuku/features/home/data/model/quick_action.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

final List<CandidateConfig> candidateConfigs = [
  CandidateConfig(
    id: 'batches',
    key: batchesKey,
    align: ContentAlign.bottom,
    title: 'Chicken Batches',
    message:
        'Click here to add a new batch of birds or manage your existing ones. Think of it as your digital coop!',
  ),
  CandidateConfig(
    id: 'reports',
    key: reportsKey,
    align: ContentAlign.bottom,
    title: 'Farm Reports',
    message:
        'Log daily updates on growth and health here so you never miss a beat in your flock\'s performance.',
  ),
  CandidateConfig(
    id: 'store',
    key: storeKey,
    align: ContentAlign.top,
    title: 'Farm Store',
    message:
        'Keep track of your feeds, vaccines, and supplies to ensure you never run out of the essentials.',
  ),
  CandidateConfig(
    id: 'tips',
    key: tipsKey,
    align: ContentAlign.top,
    title: 'Smart Tips',
    message:
        'Browse short videos and articles packed with expert advice on better farm management and bird care.',
  ),
  CandidateConfig(
    id: 'summary',
    key: summaryKey,
    align: ContentAlign.top,
    title: 'Farm Summary',
    message:
        'Check this section for a clear view of your finances and a bird\'s-eye view of your overall progress.',
  ),
  CandidateConfig(
    id: 'extension',
    key: extensionKey,
    align: ContentAlign.top,
    title: 'Extension Service',
    message:
        'Find and contact local experts and extension officers nearby whenever you need an extra hand or professional advice.',
  ),
];
