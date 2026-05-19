class ContentBlock {
  final String type;
  final String text;

  const ContentBlock({required this.type, required this.text});

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] as String,
      text: json['text'] as String,
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correct;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correct,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correct: json['correct'] as int,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<ContentBlock> content;
  final List<QuizQuestion> quiz;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.content,
    required this.quiz,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      content: (json['content'] as List)
          .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      quiz: (json['quiz'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
