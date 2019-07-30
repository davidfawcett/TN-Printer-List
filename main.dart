import 'dart:io';

// C3320 black toner max is 11000 
// C5576 black toner max is 26000
// C3375 black toner max is 26000; colour toner is 18400 maybe 150000 (yellow tested)

void main() {

  String ipPreface = '172.16.3.';
  Map<String, String> ipList = {'Admin (C5576)': '92',
  'Jr Reception (C3376)' : '64', 
  'Visual Arts (C3376)':'62', 
  'Southwood Centre (C3376)':'59', 
  'Senior College Lower (C5576)':'37', 
  'Senior College Upper (C3376)':'33', 
  'CMWood Staffroom (C5576)':'32', 
  'Senior Library (C5576)':'154', 
  'Colebrook (C3376)':'122',
  'Music (C3320)':'155',
  'Community Relations (C3320)':'153',
  'Middle School Girls (C3320)':'152',
  'Middle School Boys (C3320)':'151'};

  List<String> inkType = ['Black Toner',
  'Yellow Toner',
  'Magenta Toner',
  'Cyan Toner',
  'Black Drum',
  'Yellow Drum',
  'Magenta Drum',
  'Cyan Drum'];

  ipList.forEach((printerName, printerIP) {
    String fullIp = ipPreface+printerIP;
    Process.run('snmpwalk', ['-v', '2c','-c', 'public', fullIp, 'iso.3.6.1.2.1.43.11.1.1.9.1'])
    .catchError((error)=>print(error))
    .then((ProcessResult result) {
      List inkLevels = [];
      RegExp exp = RegExp(r"(?<level>\s\d+)");
      Iterable<RegExpMatch> findInkLevels = exp.allMatches(result.stdout);

      int count = 0;
        findInkLevels.forEach((match) {
          if (inkType[count].contains('Toner')){
            if(printerName.contains('C5576')){
              int percentLevel = int.parse(match.namedGroup('level')) ~/ 260; 
              inkLevels.add(inkType[count] + " : " + percentLevel.toString() + "%"); 
            }
            else if(printerName.contains('C3320')){
              
              int percentLevel = int.parse(match.namedGroup('level')) ~/ 110; 
              inkLevels.add(inkType[count] + " : " + percentLevel.toString() + "%");
            }
            else if(printerName.contains('C3376')){
              if(inkType[count].contains('Black')) {
                int percentLevel = int.parse(match.namedGroup('level')) ~/ 260; 
                inkLevels.add(inkType[count] + " : " + percentLevel.toString() + '%');
              }
              else {
              int percentLevel = int.parse(match.namedGroup('level')) ~/ 150; 
              inkLevels.add(inkType[count] + " : " + percentLevel.toString() + '%');
              }
            }
          }
          count ++;
        });
        
        print('\n\n'+ printerName + '\n');
        inkLevels.forEach((level) => print(level));
    }).then((result){
      print('\nPress ENTER for next printer');
      stdin.readLineSync();});
  });
}