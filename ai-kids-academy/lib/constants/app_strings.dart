enum AppLanguage { en, ru, he }

class AppStrings {
  AppStrings._();

  static String mascotName(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Бип';
      case AppLanguage.he:
        return 'ביפ';
      case AppLanguage.en:
        return 'Beep';
    }
  }

  static String appTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'AI Kids Academy';
      case AppLanguage.he:
        return 'AI Kids Academy';
      case AppLanguage.en:
        return 'AI Kids Academy';
    }
  }

  static String splashTagline(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Учись с ИИ — это весело!';
      case AppLanguage.he:
        return '!ללמוד עם AI זה כיף';
      case AppLanguage.en:
        return 'Learn with AI — it\'s fun!';
    }
  }

  static String chooseLanguage(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Выбери язык';
      case AppLanguage.he:
        return 'בחר שפה';
      case AppLanguage.en:
        return 'Choose Language';
    }
  }

  static String welcomeTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Привет, исследователь!';
      case AppLanguage.he:
        return '!שלום, חוקר';
      case AppLanguage.en:
        return 'Hello, Explorer!';
    }
  }

  static String welcomeSubtitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Я Бип — твой робот-друг.\nВместе мы узнаем всё про ИИ!';
      case AppLanguage.he:
        return 'אני ביפ — הרובוט החבר שלך.\n!ביחד נלמד הכל על AI';
      case AppLanguage.en:
        return 'I\'m Beep — your robot friend.\nTogether we\'ll learn all about AI!';
    }
  }

  static String startLearning(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Начать!';
      case AppLanguage.he:
        return '!בואו נתחיל';
      case AppLanguage.en:
        return 'Let\'s Start!';
    }
  }

  static String lessonMap(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'AI Kids Academy';
      case AppLanguage.he:
        return 'AI Kids Academy';
      case AppLanguage.en:
        return 'AI Kids Academy';
    }
  }

  static String lesson(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Урок';
      case AppLanguage.he:
        return 'שיעור';
      case AppLanguage.en:
        return 'Lesson';
    }
  }

  static String quiz(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Проверь себя!';
      case AppLanguage.he:
        return '!בוא נבדוק';
      case AppLanguage.en:
        return 'Quick Quiz!';
    }
  }

  static String correct(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Правильно! 🎉';
      case AppLanguage.he:
        return '!נכון 🎉';
      case AppLanguage.en:
        return 'Correct! 🎉';
    }
  }

  static String wrong(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Попробуй ещё раз!';
      case AppLanguage.he:
        return '!נסה שוב';
      case AppLanguage.en:
        return 'Try again!';
    }
  }

  static String correctPlayful(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return '🌟 Молодец! Всё верно!';
      case AppLanguage.he:
        return '!🌟 מדהים! נכון בדיוק';
      case AppLanguage.en:
        return '🌟 Amazing! You got it!';
    }
  }

  static String wrongPlayful(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Упс! Давай попробуем ещё! 💪';
      case AppLanguage.he:
        return '!אופס! בואו ננסה שוב 💪';
      case AppLanguage.en:
        return 'Oops! Let\'s try again! 💪';
    }
  }

  static String quizPlayful(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Помоги Бипу! 🤖';
      case AppLanguage.he:
        return '!עזור לביפ 🤖';
      case AppLanguage.en:
        return 'Help Beep! 🤖';
    }
  }

  static String readyForQuiz(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Я готов! 🎯';
      case AppLanguage.he:
        return '!אני מוכן 🎯';
      case AppLanguage.en:
        return 'I\'m Ready! 🎯';
    }
  }

  static String nextQuestion(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Следующий вопрос! →';
      case AppLanguage.he:
        return '!שאלה הבאה →';
      case AppLanguage.en:
        return 'Next Question! →';
    }
  }

  static String seeMyStars(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Смотреть мои звёзды! ⭐';
      case AppLanguage.he:
        return '!לראות את הכוכבים שלי ⭐';
      case AppLanguage.en:
        return 'See My Stars! ⭐';
    }
  }

  static String settingsTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Настройки';
      case AppLanguage.he:
        return 'הגדרות';
      case AppLanguage.en:
        return 'Settings';
    }
  }

  static String soundEffectsLabel(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Звуковые эффекты';
      case AppLanguage.he:
        return 'אפקטים קוליים';
      case AppLanguage.en:
        return 'Sound Effects';
    }
  }

  static String voiceNarrationLabel(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Голосовое озвучивание';
      case AppLanguage.he:
        return 'קריינות קולית';
      case AppLanguage.en:
        return 'Voice Narration';
    }
  }

  static String autoReadLabel(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Читать автоматически';
      case AppLanguage.he:
        return 'קריאה אוטומטית';
      case AppLanguage.en:
        return 'Auto-Read Pages';
    }
  }

  static String narrationHintText(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Для озвучивания нужен синтезатор речи на устройстве. Доступность зависит от версии Android.';
      case AppLanguage.he:
        return 'הקריינות מצריכה מנוע טקסט-לדיבור במכשיר. הזמינות תלויה בגרסת אנדרואיד.';
      case AppLanguage.en:
        return 'Narration requires a text-to-speech engine on the device. Availability depends on Android version.';
    }
  }

  static String wasFunTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Было весело?';
      case AppLanguage.he:
        return 'היה כיף?';
      case AppLanguage.en:
        return 'Was this fun?';
    }
  }

  static String feedbackFun(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Весело!';
      case AppLanguage.he:
        return '!כיף';
      case AppLanguage.en:
        return 'Fun!';
    }
  }

  static String feedbackOkay(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Нормально';
      case AppLanguage.he:
        return 'בסדר';
      case AppLanguage.en:
        return 'Okay';
    }
  }

  static String feedbackBoring(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Скучно';
      case AppLanguage.he:
        return 'משעמם';
      case AppLanguage.en:
        return 'Boring';
    }
  }

  static String feedbackThanks(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Спасибо! 🎉 Ты молодец!';
      case AppLanguage.he:
        return '!תודה 🎉 כל הכבוד';
      case AppLanguage.en:
        return 'Thanks! 🎉 You\'re awesome!';
    }
  }

  static String feedbackStatsTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Что думают дети';
      case AppLanguage.he:
        return 'מה ילדים חושבים';
      case AppLanguage.en:
        return 'How Kids Feel';
    }
  }

  static String nextLesson(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Следующий урок';
      case AppLanguage.he:
        return 'שיעור הבא';
      case AppLanguage.en:
        return 'Next Lesson';
    }
  }

  static String backToMap(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'На карту уроков';
      case AppLanguage.he:
        return 'חזור למפה';
      case AppLanguage.en:
        return 'Back to Map';
    }
  }

  static String rewardTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Отлично! Ты молодец!';
      case AppLanguage.he:
        return '!כל הכבוד! עשית עבודה נהדרת';
      case AppLanguage.en:
        return 'Awesome! Great job!';
    }
  }

  static String rewardSubtitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Ты прошёл урок и заработал звезду!';
      case AppLanguage.he:
        return '!השלמת את השיעור וזכית בכוכב';
      case AppLanguage.en:
        return 'You completed the lesson and earned a star!';
    }
  }

  static String progress(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Мой прогресс';
      case AppLanguage.he:
        return 'ההתקדמות שלי';
      case AppLanguage.en:
        return 'My Progress';
    }
  }

  static String lessonsCompleted(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Уроков пройдено';
      case AppLanguage.he:
        return 'שיעורים הושלמו';
      case AppLanguage.en:
        return 'Lessons Completed';
    }
  }

  static String starsEarned(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Звёзд получено';
      case AppLanguage.he:
        return 'כוכבים שהרווחת';
      case AppLanguage.en:
        return 'Stars Earned';
    }
  }

  static String parentInfo(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Для родителей';
      case AppLanguage.he:
        return 'למשפחה';
      case AppLanguage.en:
        return 'For Parents';
    }
  }

  static String parentInfoContent(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return '''AI Kids Academy — безопасное образовательное приложение для детей 5–7 лет.

🔒 Без рекламы
🔒 Без регистрации  
🔒 Без интернета (уроки хранятся локально)
🔒 Без сбора данных

Приложение обучает детей базовым понятиям искусственного интеллекта в игровой форме. Робот Бип ведёт ребёнка через 12 уроков с тестами и наградами.

Прогресс сохраняется на устройстве.''';
      case AppLanguage.he:
        return '''AI Kids Academy היא אפליקציה חינוכית בטוחה לילדים בגילאי 5–7.

🔒 ללא פרסומות
🔒 ללא הרשמה
🔒 ללא אינטרנט (שיעורים מאוחסנים מקומית)
🔒 ללא איסוף נתונים

האפליקציה מלמדת ילדים מושגי בסיס של בינה מלאכותית בצורה משחקית. הרובוט ביפ מוביל את הילד דרך 12 שיעורים עם חידונים ופרסים.

ההתקדמות נשמרת במכשיר.''';
      case AppLanguage.en:
        return '''AI Kids Academy is a safe educational app for children aged 5–7.

🔒 No ads
🔒 No registration
🔒 No internet required (lessons stored locally)
🔒 No data collection

The app teaches children basic AI concepts through play. The robot Beep guides the child through 12 lessons with quizzes and rewards.

Progress is saved on the device.''';
    }
  }

  static String completed(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Пройдено';
      case AppLanguage.he:
        return 'הושלם';
      case AppLanguage.en:
        return 'Completed';
    }
  }

  static String locked(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Закрыт';
      case AppLanguage.he:
        return 'נעול';
      case AppLanguage.en:
        return 'Locked';
    }
  }

  static String continueLesson(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Продолжить';
      case AppLanguage.he:
        return 'המשך';
      case AppLanguage.en:
        return 'Continue';
    }
  }

  static String questionOf(int current, int total, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Вопрос $current из $total';
      case AppLanguage.he:
        return 'שאלה $current מתוך $total';
      case AppLanguage.en:
        return 'Question $current of $total';
    }
  }

  static String finishQuiz(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Завершить тест!';
      case AppLanguage.he:
        return '!סיים חידון';
      case AppLanguage.en:
        return 'Finish Quiz!';
    }
  }

  static String score(int correct, int total, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Твой результат: $correct из $total';
      case AppLanguage.he:
        return 'התוצאה שלך: $correct מתוך $total';
      case AppLanguage.en:
        return 'Your score: $correct out of $total';
    }
  }

  static String resetProgress(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Сбросить прогресс';
      case AppLanguage.he:
        return 'אפס התקדמות';
      case AppLanguage.en:
        return 'Reset Progress';
    }
  }

  static String resetConfirm(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Ты уверен? Весь прогресс будет удалён.';
      case AppLanguage.he:
        return 'האם אתה בטוח? כל ההתקדמות תימחק.';
      case AppLanguage.en:
        return 'Are you sure? All progress will be deleted.';
    }
  }

  static String yes(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Да';
      case AppLanguage.he:
        return 'כן';
      case AppLanguage.en:
        return 'Yes';
    }
  }

  static String no(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Нет';
      case AppLanguage.he:
        return 'לא';
      case AppLanguage.en:
        return 'No';
    }
  }

  static String mascotEncouragement(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Ты справишься! Я верю в тебя!';
      case AppLanguage.he:
        return '!אתה יכול לעשות את זה! אני מאמין בך';
      case AppLanguage.en:
        return 'You can do it! I believe in you!';
    }
  }

  static String changeLanguage(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Изменить язык';
      case AppLanguage.he:
        return 'שנה שפה';
      case AppLanguage.en:
        return 'Change Language';
    }
  }

  // ── AI Lab ──────────────────────────────────────────────────────────────────

  static String aiLab(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Лаборатория Бипа';
      case AppLanguage.he:
        return 'מעבדת ביפ';
      case AppLanguage.en:
        return 'Beep\'s AI Lab';
    }
  }

  static String aiLabSubtitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Создай волшебную сцену!';
      case AppLanguage.he:
        return '!צור סצנה קסומה';
      case AppLanguage.en:
        return 'Create a magical scene!';
    }
  }

  static String chooseCharacter(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Выбери персонажа!';
      case AppLanguage.he:
        return '!בחר דמות';
      case AppLanguage.en:
        return 'Choose a character!';
    }
  }

  static String chooseStyle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Выбери стиль!';
      case AppLanguage.he:
        return '!בחר סגנון';
      case AppLanguage.en:
        return 'Choose a style!';
    }
  }

  static String chooseLocation(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Выбери место!';
      case AppLanguage.he:
        return '!בחר מקום';
      case AppLanguage.en:
        return 'Choose a place!';
    }
  }

  static String chooseAction(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Выбери действие!';
      case AppLanguage.he:
        return '!בחר פעולה';
      case AppLanguage.en:
        return 'Choose an action!';
    }
  }

  static String yourMagicScene(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return '✨ Твоя сцена! ✨';
      case AppLanguage.he:
        return '✨ הסצנה שלך! ✨';
      case AppLanguage.en:
        return '✨ Your Magic Scene! ✨';
    }
  }

  static String makeAnother(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Ещё одну!';
      case AppLanguage.he:
        return '!עוד אחד';
      case AppLanguage.en:
        return 'Make Another!';
    }
  }

  static String beepProud(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Бип в восторге!';
      case AppLanguage.he:
        return '!ביפ כל כך נרגש';
      case AppLanguage.en:
        return 'Beep is so excited!';
    }
  }

  // ── Reward ──────────────────────────────────────────────────────────────────

  static String beepSays(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Бип говорит:';
      case AppLanguage.he:
        return ':ביפ אומר';
      case AppLanguage.en:
        return 'Beep says:';
    }
  }

  // ── Sound ───────────────────────────────────────────────────────────────────

  static String soundOn(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Звук вкл.';
      case AppLanguage.he:
        return 'קול פועל';
      case AppLanguage.en:
        return 'Sound On';
    }
  }

  static String soundOff(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Звук выкл.';
      case AppLanguage.he:
        return 'קול כבוי';
      case AppLanguage.en:
        return 'Sound Off';
    }
  }

  static String createAgain(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Создать ещё!';
      case AppLanguage.he:
        return '!צור שוב';
      case AppLanguage.en:
        return 'Create Again!';
    }
  }

  static String scenesCreated(int n, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Создано картин: $n 🎨';
      case AppLanguage.he:
        return 'יצרת $n תמונות! 🎨';
      case AppLanguage.en:
        return n == 1 ? 'You created 1 scene! 🎨' : 'You created $n scenes! 🎨';
    }
  }

  // ── v0.9 Remote lessons ──────────────────────────────────────────────────

  static String appVersionLabel(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Версия приложения:';
      case AppLanguage.he:
        return ':גרסת אפליקציה';
      case AppLanguage.en:
        return 'App version:';
    }
  }

  static String contentVersionLabel(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Версия уроков:';
      case AppLanguage.he:
        return ':גרסת שיעורים';
      case AppLanguage.en:
        return 'Lessons version:';
    }
  }

  static String checkForUpdates(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Проверить обновления уроков';
      case AppLanguage.he:
        return 'בדוק עדכוני שיעורים';
      case AppLanguage.en:
        return 'Check for Lesson Updates';
    }
  }

  static String checking(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Проверяем…';
      case AppLanguage.he:
        return 'בודק…';
      case AppLanguage.en:
        return 'Checking…';
    }
  }

  static String lessonsUpToDate(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Уроки актуальны';
      case AppLanguage.he:
        return 'השיעורים עדכניים';
      case AppLanguage.en:
        return 'Lessons are up to date';
    }
  }

  static String lessonsUpdated(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Новые уроки загружены';
      case AppLanguage.he:
        return 'שיעורים חדשים הורדו';
      case AppLanguage.en:
        return 'New lessons downloaded';
    }
  }

  static String lessonsNoInternet(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Нет интернета, используем встроенные уроки';
      case AppLanguage.he:
        return 'אין אינטרנט, משתמשים בשיעורים המובנים';
      case AppLanguage.en:
        return 'No internet, using built-in lessons';
    }
  }

  static String lessonUpdateFailed(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Обновление не удалось, используем локальные уроки';
      case AppLanguage.he:
        return 'העדכון נכשל, משתמשים בשיעורים המקומיים';
      case AppLanguage.en:
        return 'Update failed, using safe local lessons';
    }
  }

  // ── v1.0 Badge Cabinet ───────────────────────────────────────────────────────

  static String badgeCabinetTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Витрина значков';
      case AppLanguage.he:
        return 'ארון תגים';
      case AppLanguage.en:
        return 'Badge Cabinet';
    }
  }

  static String badgesEarned(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'заработано';
      case AppLanguage.he:
        return 'הושגו';
      case AppLanguage.en:
        return 'earned';
    }
  }

  static String newBadgeUnlocked(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Новый значок!';
      case AppLanguage.he:
        return '!תג חדש';
      case AppLanguage.en:
        return 'New Badge!';
    }
  }

  static String viewBadges(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Посмотреть значки';
      case AppLanguage.he:
        return 'צפה בתגים';
      case AppLanguage.en:
        return 'View Badges';
    }
  }

  /// Returns the emoji for a badge ID.
  static String badgeEmoji(String id) {
    const map = {
      'first_lesson': '🌟',
      'three_lessons': '🔥',
      'five_lessons': '🚀',
      'all_done': '👑',
      'ai_explorer': '🧪',
      'perfect_quiz': '⭐',
      'creative_thinker': '🎨',
    };
    return map[id] ?? '🏅';
  }

  /// Returns the localised name for a badge ID.
  static String badgeName(String id, AppLanguage lang) {
    const en = {
      'first_lesson': 'First Step!',
      'three_lessons': 'On a Roll!',
      'five_lessons': 'Star Learner',
      'all_done': 'AI Master',
      'ai_explorer': 'AI Explorer',
      'perfect_quiz': 'Quiz Champion',
      'creative_thinker': 'Creative Thinker',
    };
    const ru = {
      'first_lesson': 'Первый шаг!',
      'three_lessons': 'В ударе!',
      'five_lessons': 'Звёздный ученик',
      'all_done': 'Мастер ИИ',
      'ai_explorer': 'Исследователь ИИ',
      'perfect_quiz': 'Чемпион викторины',
      'creative_thinker': 'Творческий мыслитель',
    };
    const he = {
      'first_lesson': '!צעד ראשון',
      'three_lessons': '!בדרך הנכונה',
      'five_lessons': 'לומד מצטיין',
      'all_done': 'מאסטר AI',
      'ai_explorer': 'חוקר AI',
      'perfect_quiz': 'אלוף החידונים',
      'creative_thinker': 'חושב יצירתי',
    };
    switch (lang) {
      case AppLanguage.en:
        return en[id] ?? id;
      case AppLanguage.ru:
        return ru[id] ?? id;
      case AppLanguage.he:
        return he[id] ?? id;
    }
  }

  /// Returns the localised description for a badge ID.
  static String badgeDesc(String id, AppLanguage lang) {
    const en = {
      'first_lesson': 'Completed your first lesson',
      'three_lessons': 'Completed 3 lessons',
      'five_lessons': 'Completed 5 lessons',
      'all_done': 'Completed all 12 lessons!',
      'ai_explorer': 'Visited the AI Lab',
      'perfect_quiz': 'Perfect score on a quiz',
      'creative_thinker': 'Created 5 stories in the AI Lab',
    };
    const ru = {
      'first_lesson': 'Завершил первый урок',
      'three_lessons': 'Завершил 3 урока',
      'five_lessons': 'Завершил 5 уроков',
      'all_done': 'Завершил все 12 уроков!',
      'ai_explorer': 'Посетил Лабораторию ИИ',
      'perfect_quiz': 'Прошёл викторину без ошибок',
      'creative_thinker': 'Создал 5 историй в лаборатории',
    };
    const he = {
      'first_lesson': 'השלמת את השיעור הראשון',
      'three_lessons': 'השלמת 3 שיעורים',
      'five_lessons': 'השלמת 5 שיעורים',
      'all_done': '!השלמת את כל 12 השיעורים',
      'ai_explorer': 'ביקרת במעבדת ה-AI',
      'perfect_quiz': 'ציון מושלם בחידון',
      'creative_thinker': 'יצרת 5 סיפורים במעבדה',
    };
    switch (lang) {
      case AppLanguage.en:
        return en[id] ?? id;
      case AppLanguage.ru:
        return ru[id] ?? id;
      case AppLanguage.he:
        return he[id] ?? id;
    }
  }

  // ── v1.0 About Screen ────────────────────────────────────────────────────────

  static String aboutTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'О приложении';
      case AppLanguage.he:
        return 'אודות';
      case AppLanguage.en:
        return 'About';
    }
  }

  static String aboutPrivacyTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Конфиденциальность';
      case AppLanguage.he:
        return 'פרטיות';
      case AppLanguage.en:
        return 'Privacy';
    }
  }

  static String aboutPrivacyBody(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Персональные данные не собираются. Интернет не требуется. Без аккаунтов. Безопасно для детей.';
      case AppLanguage.he:
        return 'לא נאסף מידע אישי. לא נדרש חיבור לאינטרנט. ללא חשבונות. בטוח לילדים.';
      case AppLanguage.en:
        return 'No personal data collected. No internet required. No accounts. Safe for children.';
    }
  }

  static String aboutTermsTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Условия использования';
      case AppLanguage.he:
        return 'תנאי שימוש';
      case AppLanguage.en:
        return 'Terms of Use';
    }
  }

  static String aboutTermsBody(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Приложение создано в образовательных целях. Весь контент безопасен для детей. Без покупок.';
      case AppLanguage.he:
        return 'האפליקציה מסופקת למטרות חינוכיות. כל התוכן בטוח לילדים. ללא רכישות.';
      case AppLanguage.en:
        return 'For educational purposes. All content is safe for children. No purchases required.';
    }
  }

  static String aboutCreditsTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'Создано с ❤️';
      case AppLanguage.he:
        return 'נבנה עם ❤️';
      case AppLanguage.en:
        return 'Built with ❤️';
    }
  }

  static String aboutCreditsBody(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'AI Kids Academy создан на Flutter.\nДля детей 5–7 лет.\nРобот Бип всегда рядом!';
      case AppLanguage.he:
        return 'AI Kids Academy נבנה עם Flutter.\nלילדים בגילאי 5–7.\n!הרובוט ביפ תמיד כאן';
      case AppLanguage.en:
        return 'AI Kids Academy is built with Flutter.\nDesigned for children aged 5–7.\nRobot Beep is always here!';
    }
  }

  // ── v1.0 Beep Encouragements ─────────────────────────────────────────────────

  /// Returns a list of Beep encouragement phrases for random selection.
  static List<String> beepEncouragements(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return [
          'Вау!',
          'Как творчески!',
          'Ты потрясающий!',
          'Отличная мысль!',
          'Я так горжусь тобой!',
          'Ты умнеешь с каждым днём!',
          'Продолжай!',
          'Отличная работа!',
        ];
      case AppLanguage.he:
        return [
          '!וואו',
          '!כמה יצירתי',
          '!אתה מדהים',
          '!חשיבה נהדרת',
          '!אני כל כך גאה בך',
          '!אתה נעשה חכם יותר כל יום',
          '!המשך כך',
          '!עבודה מצוינת',
        ];
      case AppLanguage.en:
        return [
          'Wow!',
          "That's creative!",
          "You're amazing!",
          'Great thinking!',
          "I'm so proud of you!",
          "You're getting smarter every day!",
          'Keep going!',
          'Super work!',
        ];
    }
  }
}
