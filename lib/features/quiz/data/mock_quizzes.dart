import 'models/quiz_question.dart';

/// Mock quiz questions for UI development.
const List<QuizQuestion> mockQuizQuestions = [
  // ── Computer Science ──
  QuizQuestion(
    id: 'q_001',
    question: 'What is the time complexity of binary search?',
    options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
    correctIndex: 1,
    explanation: 'Binary search divides the search space in half with each step, resulting in O(log n) time complexity.',
    courseCode: 'CSC 301',
    topic: 'Data Structures',
  ),
  QuizQuestion(
    id: 'q_002',
    question: 'Which data structure uses LIFO (Last In, First Out)?',
    options: ['Queue', 'Stack', 'Linked List', 'Tree'],
    correctIndex: 1,
    explanation: 'A Stack follows the LIFO principle — the last element pushed is the first one popped.',
    courseCode: 'CSC 301',
    topic: 'Data Structures',
  ),
  QuizQuestion(
    id: 'q_003',
    question: 'What does CPU stand for?',
    options: ['Central Process Unit', 'Central Processing Unit', 'Computer Personal Unit', 'Central Processor Utility'],
    correctIndex: 1,
    explanation: 'CPU stands for Central Processing Unit — the primary component that executes instructions.',
    courseCode: 'CSC 101',
    topic: 'Introduction to Computing',
  ),
  QuizQuestion(
    id: 'q_004',
    question: 'Which sorting algorithm has the best average-case time complexity?',
    options: ['Bubble Sort', 'Selection Sort', 'Merge Sort', 'Insertion Sort'],
    correctIndex: 2,
    explanation: 'Merge Sort has O(n log n) average-case complexity, which is optimal among comparison-based sorts.',
    courseCode: 'CSC 301',
    topic: 'Algorithms',
  ),
  QuizQuestion(
    id: 'q_005',
    question: 'In OOP, what is encapsulation?',
    options: [
      'Inheriting from a parent class',
      'Hiding internal state and requiring interaction through methods',
      'Creating multiple forms of a function',
      'Breaking code into modules',
    ],
    correctIndex: 1,
    explanation: 'Encapsulation bundles data with methods that operate on it, hiding internals from outside access.',
    courseCode: 'CSC 201',
    topic: 'Programming',
  ),
  QuizQuestion(
    id: 'q_006',
    question: 'What is the primary function of an operating system?',
    options: [
      'Run applications',
      'Manage hardware and software resources',
      'Connect to the internet',
      'Compile source code',
    ],
    correctIndex: 1,
    explanation: 'An OS manages hardware resources and provides services for application software.',
    courseCode: 'CSC 305',
    topic: 'Operating Systems',
  ),
  QuizQuestion(
    id: 'q_007',
    question: 'Which of these is NOT a type of machine learning?',
    options: ['Supervised Learning', 'Unsupervised Learning', 'Reinforcement Learning', 'Compiled Learning'],
    correctIndex: 3,
    explanation: 'The three main types are supervised, unsupervised, and reinforcement learning. "Compiled Learning" is not a real type.',
    courseCode: 'CSC 401',
    topic: 'Artificial Intelligence',
  ),

  // ── Electrical Engineering ──
  QuizQuestion(
    id: 'q_008',
    question: 'What is Ohm\'s Law?',
    options: ['V = IR', 'P = IV', 'F = ma', 'E = mc²'],
    correctIndex: 0,
    explanation: 'Ohm\'s Law states that Voltage (V) equals Current (I) multiplied by Resistance (R).',
    courseCode: 'EEE 301',
    topic: 'Circuit Theory',
  ),
  QuizQuestion(
    id: 'q_009',
    question: 'What is the unit of electrical capacitance?',
    options: ['Ohm', 'Henry', 'Farad', 'Watt'],
    correctIndex: 2,
    explanation: 'The Farad (F) is the SI unit of electrical capacitance, named after Michael Faraday.',
    courseCode: 'EEE 301',
    topic: 'Circuit Theory',
  ),
  QuizQuestion(
    id: 'q_010',
    question: 'In a logic gate, what does AND output when both inputs are 1?',
    options: ['0', '1', 'Undefined', 'Depends on clock'],
    correctIndex: 1,
    explanation: 'An AND gate outputs 1 only when ALL inputs are 1.',
    courseCode: 'EEE 201',
    topic: 'Digital Electronics',
  ),

  // ── Mathematics ──
  QuizQuestion(
    id: 'q_011',
    question: 'What is the derivative of sin(x)?',
    options: ['-sin(x)', 'cos(x)', 'tan(x)', '-cos(x)'],
    correctIndex: 1,
    explanation: 'The derivative of sin(x) with respect to x is cos(x).',
    courseCode: 'MTH 201',
    topic: 'Calculus',
  ),
  QuizQuestion(
    id: 'q_012',
    question: 'What is the integral of 1/x?',
    options: ['x²', 'ln|x| + C', '1/x² + C', 'e^x + C'],
    correctIndex: 1,
    explanation: 'The integral of 1/x is the natural logarithm: ln|x| + C.',
    courseCode: 'MTH 201',
    topic: 'Calculus',
  ),
  QuizQuestion(
    id: 'q_013',
    question: 'What is i² in complex numbers?',
    options: ['1', '-1', 'i', '0'],
    correctIndex: 1,
    explanation: 'By definition, i is the imaginary unit where i² = -1.',
    courseCode: 'MTH 301',
    topic: 'Complex Analysis',
  ),

  // ── Business ──
  QuizQuestion(
    id: 'q_014',
    question: 'What does ROI stand for?',
    options: ['Rate of Income', 'Return on Investment', 'Risk of Inflation', 'Revenue on Interest'],
    correctIndex: 1,
    explanation: 'ROI measures the gain or loss generated relative to the amount of money invested.',
    courseCode: 'BUS 301',
    topic: 'Financial Management',
  ),
  QuizQuestion(
    id: 'q_015',
    question: 'Which of the following is a function of management?',
    options: ['Coding', 'Planning', 'Soldering', 'Debugging'],
    correctIndex: 1,
    explanation: 'Planning is one of the four primary functions of management (Planning, Organizing, Leading, Controlling).',
    courseCode: 'BUS 101',
    topic: 'Management',
  ),

  // ── Mechanical Engineering ──
  QuizQuestion(
    id: 'q_016',
    question: 'What is Newton\'s Second Law of Motion?',
    options: ['F = ma', 'E = mc²', 'PV = nRT', 'V = IR'],
    correctIndex: 0,
    explanation: 'Newton\'s Second Law states that Force equals mass times acceleration (F = ma).',
    courseCode: 'MEE 201',
    topic: 'Engineering Mechanics',
  ),
  QuizQuestion(
    id: 'q_017',
    question: 'What is the first law of thermodynamics about?',
    options: ['Entropy always increases', 'Energy cannot be created or destroyed', 'Absolute zero is unattainable', 'Heat flows from hot to cold'],
    correctIndex: 1,
    explanation: 'The first law of thermodynamics is the law of conservation of energy.',
    courseCode: 'MEE 301',
    topic: 'Thermodynamics',
  ),

  // ── More CS ──
  QuizQuestion(
    id: 'q_018',
    question: 'What is a deadlock in operating systems?',
    options: [
      'A process that runs forever',
      'Two or more processes waiting for each other indefinitely',
      'A memory overflow error',
      'A broken network connection',
    ],
    correctIndex: 1,
    explanation: 'A deadlock occurs when two or more processes each hold resources the other needs, creating a circular wait.',
    courseCode: 'CSC 305',
    topic: 'Operating Systems',
  ),
  QuizQuestion(
    id: 'q_019',
    question: 'Which Python keyword is used to define a function?',
    options: ['func', 'function', 'def', 'define'],
    correctIndex: 2,
    explanation: 'In Python, the "def" keyword is used to define a function.',
    courseCode: 'CSC 201',
    topic: 'Programming',
  ),
  QuizQuestion(
    id: 'q_020',
    question: 'What does HTML stand for?',
    options: [
      'Hyper Text Markup Language',
      'High Tech Modern Language',
      'Hyper Transfer Markup Language',
      'Home Tool Markup Language',
    ],
    correctIndex: 0,
    explanation: 'HTML stands for HyperText Markup Language, the standard markup language for web pages.',
    courseCode: 'CSC 101',
    topic: 'Introduction to Computing',
  ),
];

/// Available topics derived from mock data.
final List<String> availableTopics = mockQuizQuestions
    .map((q) => q.topic)
    .toSet()
    .toList()
  ..sort();
