class Urls {
  // Base URL — switch to HTTPS if your backend supports it
  static const String _baseUrl = 'http://35.73.30.144:2005/api/v1';

  // Authentication
  static const String registrationUrl = '$_baseUrl/Registration';
  static const String loginUrl = '$_baseUrl/Login';

  // User Profile
  // User Profile
  static const String updateProfileUrl = '$_baseUrl/ProfileUpdate';


  // Tasks
  static const String createNewTaskUrl = '$_baseUrl/createTask';
  static const String getNewTaskUrl = '$_baseUrl/listTaskByStatus/New';
  static const String getProgressTaskUrl = '$_baseUrl/listTaskByStatus/In%20Progress';
  static const String getCompletedTaskUrl = '$_baseUrl/listTaskByStatus/Completed';
  static const String getCancelledTaskUrl = '$_baseUrl/listTaskByStatus/Cancelled';
  static const String getTaskStatusCountUrl = '$_baseUrl/taskStatusCount';

  // Delete Task
  static String deleteTaskUrl(String taskId) => '$_baseUrl/deleteTask/$taskId';

  // Update Task Status
  static String updateTaskStatusUrl(String taskId, String status) =>
      '$_baseUrl/updateTaskStatus/$taskId/$status';

  // Optional: Build full URI safely
  static Uri buildUri(String endpoint) => Uri.parse('$_baseUrl/$endpoint');
}
