import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';

enum ExpenseBudgetPeriod {
  weekly('Semanal'),
  monthly('Mensual');

  const ExpenseBudgetPeriod(this.label);

  final String label;
}

enum GradeScale {
  zeroToFive('0 a 5', 5, 3),
  zeroToTen('0 a 10', 10, 6),
  zeroToHundred('0 a 100', 100, 60);

  const GradeScale(this.label, this.maxValue, this.defaultPassingGrade);

  final String label;
  final int maxValue;
  final double defaultPassingGrade;
}

class AppSettingsRepository {
  const AppSettingsRepository(this._database);

  static const _themeModeKey = 'theme_mode';
  static const _seedColorKey = 'seed_color';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _expenseBudgetCentsKey = 'expense_budget_cents';
  static const _expenseBudgetPeriodKey = 'expense_budget_period';
  static const _gradeScaleKey = 'grade_scale';
  static const _passingGradeKey = 'passing_grade';
  static const _universityNameKey = 'university_name';
  static const _careerNameKey = 'career_name';
  static const _currentSemesterKey = 'current_semester';
  static const _taskReminderMinutesKey = 'task_reminder_minutes';
  static const _studyReminderMinutesKey = 'study_reminder_minutes';

  final AppDatabase _database;

  Future<ThemeMode?> getThemeMode() async {
    final value = await _database.settingsDao.getValue(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  Future<Color?> getSeedColor() async {
    final value = await _database.settingsDao.getValue(_seedColorKey);
    final colorValue = int.tryParse(value ?? '');
    return colorValue == null ? null : Color(colorValue);
  }

  Future<bool> getOnboardingCompleted() async {
    final value = await _database.settingsDao.getValue(_onboardingCompletedKey);
    return value == 'true';
  }

  Future<int?> getExpenseBudgetCents() async {
    final value = await _database.settingsDao.getValue(_expenseBudgetCentsKey);
    return int.tryParse(value ?? '');
  }

  Future<ExpenseBudgetPeriod?> getExpenseBudgetPeriod() async {
    final value = await _database.settingsDao.getValue(_expenseBudgetPeriodKey);
    return switch (value) {
      'weekly' => ExpenseBudgetPeriod.weekly,
      'monthly' => ExpenseBudgetPeriod.monthly,
      _ => null,
    };
  }

  Future<GradeScale?> getGradeScale() async {
    final value = await _database.settingsDao.getValue(_gradeScaleKey);
    return switch (value) {
      'zeroToFive' => GradeScale.zeroToFive,
      'zeroToTen' => GradeScale.zeroToTen,
      'zeroToHundred' => GradeScale.zeroToHundred,
      _ => null,
    };
  }

  Future<double?> getPassingGrade() async {
    final value = await _database.settingsDao.getValue(_passingGradeKey);
    return double.tryParse(value ?? '');
  }

  Future<String> getUniversityName() async {
    return await _database.settingsDao.getValue(_universityNameKey) ?? '';
  }

  Future<String> getCareerName() async {
    return await _database.settingsDao.getValue(_careerNameKey) ?? '';
  }

  Future<String> getCurrentSemester() async {
    return await _database.settingsDao.getValue(_currentSemesterKey) ?? '';
  }

  Future<int?> getTaskReminderMinutes() async {
    final value = await _database.settingsDao.getValue(_taskReminderMinutesKey);
    return int.tryParse(value ?? '');
  }

  Future<int?> getStudyReminderMinutes() async {
    final value = await _database.settingsDao.getValue(
      _studyReminderMinutesKey,
    );
    return int.tryParse(value ?? '');
  }

  Future<void> setThemeMode(ThemeMode themeMode) {
    return _database.settingsDao.setValue(
      key: _themeModeKey,
      value: themeMode.name,
    );
  }

  Future<void> setSeedColor(Color color) {
    return _database.settingsDao.setValue(
      key: _seedColorKey,
      value: color.toARGB32().toString(),
    );
  }

  Future<void> setOnboardingCompleted(bool completed) {
    return _database.settingsDao.setValue(
      key: _onboardingCompletedKey,
      value: completed.toString(),
    );
  }

  Future<void> setExpenseBudget({
    required int cents,
    required ExpenseBudgetPeriod period,
  }) async {
    await _database.settingsDao.setValue(
      key: _expenseBudgetCentsKey,
      value: cents.toString(),
    );
    await _database.settingsDao.setValue(
      key: _expenseBudgetPeriodKey,
      value: period.name,
    );
  }

  Future<void> setGradeScale(GradeScale scale) {
    return _database.settingsDao.setValue(
      key: _gradeScaleKey,
      value: scale.name,
    );
  }

  Future<void> setPassingGrade(double grade) {
    return _database.settingsDao.setValue(
      key: _passingGradeKey,
      value: grade.toString(),
    );
  }

  Future<void> setAcademicProfile({
    required String universityName,
    required String careerName,
    required String currentSemester,
  }) async {
    await _database.settingsDao.setValue(
      key: _universityNameKey,
      value: universityName,
    );
    await _database.settingsDao.setValue(
      key: _careerNameKey,
      value: careerName,
    );
    await _database.settingsDao.setValue(
      key: _currentSemesterKey,
      value: currentSemester,
    );
  }

  Future<void> setTaskReminderMinutes(int minutes) {
    return _database.settingsDao.setValue(
      key: _taskReminderMinutesKey,
      value: minutes.toString(),
    );
  }

  Future<void> setStudyReminderMinutes(int minutes) {
    return _database.settingsDao.setValue(
      key: _studyReminderMinutesKey,
      value: minutes.toString(),
    );
  }
}
