import 'schedule_repository.dart';
import '../../subjects/data/subject_repository.dart';

class AcademicSeedService {
  const AcademicSeedService({
    required SubjectRepository subjectRepository,
    required ScheduleRepository scheduleRepository,
  }) : _subjectRepository = subjectRepository,
       _scheduleRepository = scheduleRepository;

  final SubjectRepository _subjectRepository;
  final ScheduleRepository _scheduleRepository;

  Future<void> seedIfNeeded() async {
    await _subjectRepository.seedIfEmpty();
    await _scheduleRepository.seedIfEmpty();
  }
}
