import 'package:flutter/material.dart';
import '../data/quiz_repository.dart';
import '../models/question.dart';
import '../widgets/flashcard_view.dart';
import '../widgets/stats_bar.dart';

class FlashcardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const FlashcardScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  final QuizRepository _repository = QuizRepository();

  int _selectedWeek = 1;
  List<Question> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Question state tracking
  final Map<String, String> _userGuesses = {};
  final Set<String> _mastered = {};
  final Set<String> _needsReview = {};

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _repository.loadQuestions();
    final weekData = _repository.getWeek(_selectedWeek);
    setState(() {
      _questions = weekData != null ? List.from(weekData.questions) : [];
      _currentIndex = 0;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  void _nextCard() {
    if (_questions.isEmpty) return;
    if (_currentIndex < _questions.length - 1) {
      _changeCard(_currentIndex + 1);
    }
  }

  void _previousCard() {
    if (_questions.isEmpty) return;
    if (_currentIndex > 0) {
      _changeCard(_currentIndex - 1);
    }
  }

  void _changeCard(int newIndex) {
    if (_flipController.isCompleted) {
      _flipController.reverse();
    }
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _shuffleQuestions() {
    if (_questions.isEmpty) return;
    if (_flipController.isCompleted) {
      _flipController.reverse();
    }
    setState(() {
      _questions.shuffle();
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔀 Cards shuffled!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _resetProgress() {
    setState(() {
      _userGuesses.clear();
      _mastered.clear();
      _needsReview.clear();
      _currentIndex = 0;
      final weekData = _repository.getWeek(_selectedWeek);
      _questions = weekData != null ? List.from(weekData.questions) : [];
      if (_flipController.isCompleted) {
        _flipController.reverse();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔁 Progress reset!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _markMastered(Question q) {
    setState(() {
      _mastered.add(q.id);
      _needsReview.remove(q.id);
    });
    if (_currentIndex < _questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _nextCard();
      });
    }
  }

  void _markNeedsReview(Question q) {
    setState(() {
      _needsReview.add(q.id);
      _mastered.remove(q.id);
    });
    if (_currentIndex < _questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _nextCard();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solid State Quiz')),
        body: const Center(
          child: Text('No questions available for this week.'),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final selectedOption = _userGuesses[currentQuestion.id];
    final isMastered = _mastered.contains(currentQuestion.id);
    final needsReview = _needsReview.contains(currentQuestion.id);

    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<int>(
          initialValue: _selectedWeek,
          onSelected: (week) {
            if (week != _selectedWeek) {
              setState(() {
                _selectedWeek = week;
              });
              _loadData();
            }
          },
          tooltip: 'Select Week',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Solid State Quiz',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Text(
                    _selectedWeek == 0
                        ? 'All 111 Questions ▼'
                        : 'Week $_selectedWeek (${_questions.length} Questions) ▼',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          itemBuilder: (context) {
            final weeks = _repository.availableWeeks;
            final items = <PopupMenuEntry<int>>[];

            // "All Weeks" option
            items.add(
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(
                      _selectedWeek == 0
                          ? Icons.check_circle
                          : Icons.auto_stories,
                      size: 16,
                      color: _selectedWeek == 0
                          ? theme.colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'All 111 Questions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
            items.add(const PopupMenuDivider());

            for (final w in weeks) {
              final wData = _repository.getWeek(w);
              final count = wData?.questions.length ?? 10;
              items.add(
                PopupMenuItem<int>(
                  value: w,
                  child: Row(
                    children: [
                      Icon(
                        w == _selectedWeek
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: w == _selectedWeek
                            ? theme.colorScheme.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text('Week $w ($count Questions)'),
                    ],
                  ),
                ),
              );
            }
            return items;
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Shuffle cards',
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffleQuestions,
          ),
          IconButton(
            tooltip: 'Questions Grid',
            icon: const Icon(Icons.grid_view),
            onPressed: () => _showQuestionsGrid(context),
          ),
          IconButton(
            tooltip: widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Stats and Progress Indicator
            StatsBar(
              total: _questions.length,
              masteredCount: _mastered.length,
              reviewCount: _needsReview.length,
              currentIndex: _currentIndex,
            ),

            // Flashcard with Swipe Detection
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < -200) {
                    // Swipe Left -> Next
                    _nextCard();
                  } else if (details.primaryVelocity! > 200) {
                    // Swipe Right -> Previous
                    _previousCard();
                  }
                },
                child: FlashcardView(
                  question: currentQuestion,
                  currentIndex: _currentIndex,
                  totalQuestions: _questions.length,
                  animation: _flipAnimation,
                  onFlip: _flipCard,
                  selectedOption: selectedOption,
                  onOptionSelected: (opt) {
                    setState(() {
                      _userGuesses[currentQuestion.id] = opt;
                    });
                  },
                  isMastered: isMastered,
                  needsReview: needsReview,
                  onMarkMastered: () => _markMastered(currentQuestion),
                  onMarkNeedsReview: () => _markNeedsReview(currentQuestion),
                ),
              ),
            ),

            // Bottom Navigation Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  ElevatedButton.icon(
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Prev'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  // Flip Card Button
                  FilledButton.icon(
                    onPressed: _flipCard,
                    icon: const Icon(Icons.flip, size: 20),
                    label: const Text('Flip Card'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),

                  // Next Button
                  ElevatedButton.icon(
                    onPressed: _currentIndex < _questions.length - 1 ? _nextCard : null,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionsGrid(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedWeek == 0
                            ? 'All 111 Questions'
                            : 'Week $_selectedWeek Questions',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.restart_alt, size: 18),
                        label: const Text('Reset All'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _resetProgress();
                        },
                      )
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final q = _questions[index];
                        final isCur = index == _currentIndex;
                        final isM = _mastered.contains(q.id);
                        final isR = _needsReview.contains(q.id);

                        Color bg;
                        Color textC;

                        if (isCur) {
                          bg = Theme.of(context).colorScheme.primary;
                          textC = Colors.white;
                        } else if (isM) {
                          bg = Colors.green.shade100;
                          textC = Colors.green.shade900;
                        } else if (isR) {
                          bg = Colors.orange.shade100;
                          textC = Colors.orange.shade900;
                        } else {
                          bg = Theme.of(context).dividerColor.withValues(alpha: 0.1);
                          textC = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            _changeCard(index);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCur ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Q${q.questionNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textC,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
