import 'dart:io';

//dart run easy_localization:generate -S "assets/translations" -O "lib/core/localization"
// dart run easy_localization:generate -S "assets/translations" -O "lib/core/localization" -o "locale_keys.g.dart" -f keys
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart tool/run.dart <command>');
    print('Available: gen, clean, build');
    return;
  }

  final command = args[0];

  switch (command) {
    case 'genlocales':
      await _execute("flutter", commands['gen_locale']!);
      await _execute("flutter", commands['gen_locale_loader']!);
      break;
    case 'gen':
      await _execute('flutter', [
        'pub',
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ]);
      break;
    default:
      print('Unknown command: $command');
  }
}

Future<void> _execute(String cmd, List<String> args) async {
  final process = await Process.start(
    cmd,
    args,
    mode: ProcessStartMode.inheritStdio,
  );
  await process.exitCode;
}

const commands = {
  "gen_locale": [
    'run',
    'easy_localization:generate',
    '-S',
    'assets/translations',
    '-O',
    'lib/core/localization',
    '-o',
    'locale_keys.g.dart',
    '-f',
    'keys',
  ],
  "gen_locale_loader": [
    'run',
    'easy_localization:generate',
    '-S',
    'assets/translations',
    '-O',
    'lib/core/localization',
  ],
  "generate": [
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ],
};
