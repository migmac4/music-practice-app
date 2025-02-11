import 'instrument.dart';

enum PracticeCategory {
  chordsAndHarmony,
  technique,
  theory,
  improvisation,
  repertoire,
  scalesAndModes,
  rhythmAndStrumming,
  bowingTechnique,
  expressionAndDynamics,
  shiftingAndPosition,
  scalesAndArpeggios,
  leftHandTechnique,
  rhythmAndGroove,
  rudimentsAndStickControl,
  dynamicsAndArticulation,
  embouchureAndBreathControl,
  fingerTechnique,
  registerTransitions,
  articulationAndTonguing,
  scalesAndIntonation,
  postureAndHandPosition,
  readingTechniques,
  synthesizerAndSampling,
  scalesAndMelody,
  rhythmAndTiming;

  static List<PracticeCategory> getCategoriesForInstrument(Instrument instrument) {
    return switch (instrument) {
      Instrument.acousticGuitar => [
        chordsAndHarmony,
        technique,
        theory,
        improvisation,
        repertoire,
        scalesAndModes,
        rhythmAndStrumming,
      ],
      Instrument.electricGuitar => [
        chordsAndHarmony,
        technique,
        theory,
        improvisation,
        repertoire,
        scalesAndModes,
        rhythmAndStrumming,
      ],
      Instrument.violin => [
        bowingTechnique,
        expressionAndDynamics,
        theory,
        shiftingAndPosition,
        repertoire,
        scalesAndArpeggios,
        leftHandTechnique,
      ],
      Instrument.bass => [
        chordsAndHarmony,
        technique,
        theory,
        improvisation,
        repertoire,
        scalesAndArpeggios,
        rhythmAndGroove,
      ],
      Instrument.drums => [
        rudimentsAndStickControl,
        technique,
        theory,
        improvisation,
        repertoire,
        dynamicsAndArticulation,
        rhythmAndGroove,
      ],
      Instrument.clarinet => [
        embouchureAndBreathControl,
        fingerTechnique,
        theory,
        improvisation,
        repertoire,
        scalesAndIntonation,
        registerTransitions,
      ],
      Instrument.flute => [
        embouchureAndBreathControl,
        fingerTechnique,
        theory,
        improvisation,
        repertoire,
        scalesAndIntonation,
        registerTransitions,
      ],
      Instrument.trumpet => [
        embouchureAndBreathControl,
        fingerTechnique,
        theory,
        improvisation,
        repertoire,
        scalesAndIntonation,
        articulationAndTonguing,
      ],
      Instrument.saxophone => [
        embouchureAndBreathControl,
        articulationAndTonguing,
        theory,
        improvisation,
        repertoire,
        scalesAndIntonation,
        registerTransitions,
      ],
      Instrument.cello => [
        bowingTechnique,
        expressionAndDynamics,
        theory,
        shiftingAndPosition,
        repertoire,
        scalesAndArpeggios,
        leftHandTechnique,
      ],
      Instrument.piano => [
        postureAndHandPosition,
        readingTechniques,
        theory,
        improvisation,
        repertoire,
        scalesAndArpeggios,
        rhythmAndTiming,
      ],
      Instrument.keyboard => [
        postureAndHandPosition,
        synthesizerAndSampling,
        theory,
        improvisation,
        repertoire,
        scalesAndArpeggios,
        rhythmAndTiming,
      ],
      Instrument.ukulele => [
        chordsAndHarmony,
        technique,
        theory,
        improvisation,
        repertoire,
        scalesAndMelody,
        rhythmAndStrumming,
      ],
    };
  }
} 