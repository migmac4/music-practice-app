enum Instrument {
  acousticGuitar,
  bass,
  cello,
  clarinet,
  drums,
  electricGuitar,
  flute,
  keyboard,
  piano,
  saxophone,
  trumpet,
  ukulele,
  violin;

  String get iconPath => 'assets/icons/instruments/$name.svg';
} 
