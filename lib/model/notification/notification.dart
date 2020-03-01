class Notification {
  final String title;
  final String message;
  final String url;
  final DateTime timestamp;
  final bool persistent;

  Notification(this.title, this.message, this.url, this.timestamp, this.persistent);
}