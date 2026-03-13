import 'models/past_question.dart';

/// Realistic mock data for developing the UI before backend integration.
const List<PastQuestion> mockPastQuestions = [
  // ── Computer Science ──
  PastQuestion(
    id: 'pq_001',
    courseCode: 'CSC 301',
    courseTitle: 'Data Structures & Algorithms',
    year: '2023/2024',
    semester: '1st Semester',
    department: 'Computer Science',
    level: 300,
  ),
  PastQuestion(
    id: 'pq_002',
    courseCode: 'CSC 201',
    courseTitle: 'Computer Programming II',
    year: '2023/2024',
    semester: '1st Semester',
    department: 'Computer Science',
    level: 200,
  ),
  PastQuestion(
    id: 'pq_003',
    courseCode: 'CSC 401',
    courseTitle: 'Artificial Intelligence',
    year: '2022/2023',
    semester: '2nd Semester',
    department: 'Computer Science',
    level: 400,
  ),
  PastQuestion(
    id: 'pq_004',
    courseCode: 'CSC 101',
    courseTitle: 'Introduction to Computing',
    year: '2023/2024',
    semester: '2nd Semester',
    department: 'Computer Science',
    level: 100,
  ),
  PastQuestion(
    id: 'pq_005',
    courseCode: 'CSC 305',
    courseTitle: 'Operating Systems',
    year: '2022/2023',
    semester: '1st Semester',
    department: 'Computer Science',
    level: 300,
  ),

  // ── Electrical Engineering ──
  PastQuestion(
    id: 'pq_006',
    courseCode: 'EEE 301',
    courseTitle: 'Circuit Theory II',
    year: '2023/2024',
    semester: '1st Semester',
    department: 'Electrical Engineering',
    level: 300,
  ),
  PastQuestion(
    id: 'pq_007',
    courseCode: 'EEE 401',
    courseTitle: 'Control Systems Engineering',
    year: '2022/2023',
    semester: '2nd Semester',
    department: 'Electrical Engineering',
    level: 400,
  ),
  PastQuestion(
    id: 'pq_008',
    courseCode: 'EEE 201',
    courseTitle: 'Digital Electronics',
    year: '2023/2024',
    semester: '2nd Semester',
    department: 'Electrical Engineering',
    level: 200,
  ),

  // ── Mechanical Engineering ──
  PastQuestion(
    id: 'pq_009',
    courseCode: 'MEE 301',
    courseTitle: 'Thermodynamics II',
    year: '2023/2024',
    semester: '1st Semester',
    department: 'Mechanical Engineering',
    level: 300,
  ),
  PastQuestion(
    id: 'pq_010',
    courseCode: 'MEE 201',
    courseTitle: 'Engineering Mechanics',
    year: '2022/2023',
    semester: '1st Semester',
    department: 'Mechanical Engineering',
    level: 200,
  ),

  // ── Business Administration ──
  PastQuestion(
    id: 'pq_011',
    courseCode: 'BUS 301',
    courseTitle: 'Financial Management',
    year: '2023/2024',
    semester: '2nd Semester',
    department: 'Business Administration',
    level: 300,
  ),
  PastQuestion(
    id: 'pq_012',
    courseCode: 'BUS 101',
    courseTitle: 'Principles of Management',
    year: '2022/2023',
    semester: '1st Semester',
    department: 'Business Administration',
    level: 100,
  ),

  // ── Mathematics ──
  PastQuestion(
    id: 'pq_013',
    courseCode: 'MTH 201',
    courseTitle: 'Mathematical Methods I',
    year: '2023/2024',
    semester: '1st Semester',
    department: 'Mathematics',
    level: 200,
  ),
  PastQuestion(
    id: 'pq_014',
    courseCode: 'MTH 301',
    courseTitle: 'Complex Analysis',
    year: '2022/2023',
    semester: '2nd Semester',
    department: 'Mathematics',
    level: 300,
  ),
  PastQuestion(
    id: 'pq_015',
    courseCode: 'MTH 101',
    courseTitle: 'Elementary Mathematics I',
    year: '2023/2024',
    semester: '1st Semester',
    department: 'Mathematics',
    level: 100,
  ),
];

/// Available filter options derived from mock data.
final List<String> availableYears = [
  '2023/2024',
  '2022/2023',
];

final List<String> availableDepartments = [
  'Computer Science',
  'Electrical Engineering',
  'Mechanical Engineering',
  'Business Administration',
  'Mathematics',
];

final List<int> availableLevels = [100, 200, 300, 400, 500];

final List<String> availableSemesters = [
  '1st Semester',
  '2nd Semester',
];
