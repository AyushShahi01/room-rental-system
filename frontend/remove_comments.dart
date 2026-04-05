import 'dart:io';

void main() {
  final dir = Directory('c:/Users/admin/Desktop/room-rental-system/frontend/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Remove block comments
    content = content.replaceAll(RegExp(r'\/\*[\s\S]*?\*\/'), '');
    
    // Remove single line comments (but not http://)
    final lines = content.split('\n');
    final newLines = <String>[];
    for (var line in lines) {
      if (line.trim().startsWith('//')) {
        continue;
      }
      
      var idx = line.indexOf('//');
      if (idx != -1) {
        // Check if it's not a URL
        if (idx == 0 || line[idx - 1] != ':') {
          line = line.substring(0, idx);
        }
      }
      
      newLines.add(line);
    }
    
    file.writeAsStringSync(newLines.join('\n'));
  }
}
