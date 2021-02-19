class Notification {
  final String title;
  final String message;
  final String url;
  final String linkText;
  final DateTime timestamp;
  final bool persistent;

  Notification({this.title, this.message, this.url, this.linkText, this.timestamp, this.persistent});
}