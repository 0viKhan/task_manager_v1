class Urls {
  static const String _baseUrl = 'http://35.73.30.144:2005/api/v1';

  // Authentication
  static const String registrationUrl = '$_baseUrl/Registration';
  static const String loginUrl = '$_baseUrl/Login';

  // User Profile
  static const String updateProfileUrl = '$_baseUrl/UpdateProfile';

  // Tasks
  static const String createNewTaskUrl = '$_baseUrl/createTask';
  static const String getNewTaskUrl = '$_baseUrl/listTaskByStatus/New';
  static const String getProgressTaskUrl = '$_baseUrl/listTaskByStatus/Progress';
  static const String getCompletedTaskUrl = '$_baseUrl/listTaskByStatus/Completed';
  static const String getCancelledTaskUrl = '$_baseUrl/listTaskByStatus/Cancelled';

  static const String getTaskStatusCountUrl = '$_baseUrl/getTaskStatusCount';

  // Delete Task
  static String deleteTaskUrl(String taskId) => '$_baseUrl/deleteTask/$taskId';

  // ✅ Update Task Status
  static String updateTaskStatusUrl(String taskId, String status) =>
      '$_baseUrl/updateTaskStatus/$taskId/$status';
}
