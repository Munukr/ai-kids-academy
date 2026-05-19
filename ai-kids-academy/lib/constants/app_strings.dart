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
        return 'Карта уроков';
      case AppLanguage.he:
        return 'מפת שיעורים';
      case AppLanguage.en:
        return 'Lesson Map';
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
        return 'Ты справишься! Я верю в тебя! 🤖';
      case AppLanguage.he:
        return '!אתה יכול לעשות את זה! אני מאמין בך 🤖';
      case AppLanguage.en:
        return 'You can do it! I believe in you! 🤖';
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
}
