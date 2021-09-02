// TODO Implement this library.
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String capitalizeFirstofEach() {
    String m = this.split(" ").map((e) => e.capitalize()).toList().join(' ');

    return m;
  }
}
