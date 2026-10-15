# GeneralUser GS Preset Catalog

This catalog is generated from the `Audio/GeneralUserGS.sf3` file packaged with the engine. Bank and program values are zero-based and are the actual preset coordinates stored in the SoundFont.

- Presets: 287
- For melodic presets in banks 0–127, use `preset: { bank, program }` and omit `percussion`.
- For percussion presets, use the Bank 128 entries with `percussion: true`.
- Bank 120 also contains GS drum-map presets and is listed for completeness; Bank 128 is the intended percussion selection through the music API.

Example:

```ts
synth: { file: "Audio/GeneralUserGS.sf3" },
score: {
	bpm: 120,
	tracks: [
		{ preset: { bank: 0, program: 0 }, notes: pianoNotes },
		{ preset: { bank: 128, program: 32 }, percussion: true, notes: drumNotes },
	],
},
```

## Bank 0

| Bank | Program | Preset |
| ---: | ---: | --- |
| 0 | 0 | Grand Piano |
| 0 | 1 | Bright Grand Piano |
| 0 | 2 | Electric Grand Piano |
| 0 | 3 | Honky-Tonk Piano |
| 0 | 4 | Tine Electric Piano |
| 0 | 5 | FM Electric Piano |
| 0 | 6 | Harpsichord |
| 0 | 7 | Clavinet |
| 0 | 8 | Celeste |
| 0 | 9 | Glockenspiel |
| 0 | 10 | Music Box |
| 0 | 11 | Vibraphone |
| 0 | 12 | Marimba |
| 0 | 13 | Xylophone |
| 0 | 14 | Tubular Bells |
| 0 | 15 | Dulcimer |
| 0 | 16 | Tonewheel Organ |
| 0 | 17 | Percussive Organ |
| 0 | 18 | Rock Organ |
| 0 | 19 | Pipe Organ |
| 0 | 20 | Reed Organ |
| 0 | 21 | Accordion |
| 0 | 22 | Harmonica |
| 0 | 23 | Bandoneon |
| 0 | 24 | Nylon Guitar |
| 0 | 25 | Steel Guitar |
| 0 | 26 | Jazz Guitar |
| 0 | 27 | Clean Guitar |
| 0 | 28 | Muted Guitar |
| 0 | 29 | Overdrive Guitar |
| 0 | 30 | Distortion Guitar |
| 0 | 31 | Guitar Harmonics |
| 0 | 32 | Acoustic Bass |
| 0 | 33 | Finger Bass |
| 0 | 34 | Pick Bass |
| 0 | 35 | Fretless Bass |
| 0 | 36 | Slap Bass 1 |
| 0 | 37 | Slap Bass 2 |
| 0 | 38 | Synth Bass 1 |
| 0 | 39 | Synth Bass 2 |
| 0 | 40 | Violin |
| 0 | 41 | Viola |
| 0 | 42 | Cello |
| 0 | 43 | Double Bass |
| 0 | 44 | Tremolo Strings |
| 0 | 45 | Pizzicato Strings |
| 0 | 46 | Orchestral Harp |
| 0 | 47 | Timpani |
| 0 | 48 | Fast Strings |
| 0 | 49 | Slow Strings |
| 0 | 50 | Synth Strings 1 |
| 0 | 51 | Synth Strings 2 |
| 0 | 52 | Concert Choir |
| 0 | 53 | Voice Oohs |
| 0 | 54 | Synth Voice |
| 0 | 55 | Orchestra Hit |
| 0 | 56 | Trumpet |
| 0 | 57 | Trombone |
| 0 | 58 | Tuba |
| 0 | 59 | Muted Trumpet |
| 0 | 60 | French Horns |
| 0 | 61 | Brass Section |
| 0 | 62 | Synth Brass 1 |
| 0 | 63 | Synth Brass 2 |
| 0 | 64 | Soprano Sax |
| 0 | 65 | Alto Sax |
| 0 | 66 | Tenor Sax |
| 0 | 67 | Baritone Sax |
| 0 | 68 | Oboe |
| 0 | 69 | English Horn |
| 0 | 70 | Bassoon |
| 0 | 71 | Clarinet |
| 0 | 72 | Piccolo |
| 0 | 73 | Flute |
| 0 | 74 | Recorder |
| 0 | 75 | Pan Flute |
| 0 | 76 | Bottle Blow |
| 0 | 77 | Shakuhachi |
| 0 | 78 | Whistle |
| 0 | 79 | Ocarina |
| 0 | 80 | Square Lead |
| 0 | 81 | Saw Lead |
| 0 | 82 | Synth Calliope |
| 0 | 83 | Chiffer Lead |
| 0 | 84 | Charang |
| 0 | 85 | Solo Vox |
| 0 | 86 | 5th Saw Wave |
| 0 | 87 | Bass & Lead |
| 0 | 88 | Fantasia |
| 0 | 89 | Warm Pad |
| 0 | 90 | Polysynth |
| 0 | 91 | Space Voice |
| 0 | 92 | Bowed Glass |
| 0 | 93 | Metal Pad |
| 0 | 94 | Halo Pad |
| 0 | 95 | Sweep Pad |
| 0 | 96 | Ice Rain |
| 0 | 97 | Soundtrack |
| 0 | 98 | Crystal |
| 0 | 99 | Atmosphere |
| 0 | 100 | Brightness |
| 0 | 101 | Goblin |
| 0 | 102 | Echo Drops |
| 0 | 103 | Star Theme |
| 0 | 104 | Sitar |
| 0 | 105 | Banjo |
| 0 | 106 | Shamisen |
| 0 | 107 | Koto |
| 0 | 108 | Kalimba |
| 0 | 109 | Bagpipes |
| 0 | 110 | Fiddle |
| 0 | 111 | Shenai |
| 0 | 112 | Tinker Bell |
| 0 | 113 | Agogo |
| 0 | 114 | Steel Drums |
| 0 | 115 | Wood Block |
| 0 | 116 | Taiko Drum |
| 0 | 117 | Melodic Tom |
| 0 | 118 | Synth Drum |
| 0 | 119 | Reverse Cymbal |
| 0 | 120 | Fret Noise |
| 0 | 121 | Breath Noise |
| 0 | 122 | Seashore |
| 0 | 123 | Birds |
| 0 | 124 | Telephone 1 |
| 0 | 125 | Helicopter |
| 0 | 126 | Applause |
| 0 | 127 | Gun Shot |

## Bank 1

| Bank | Program | Preset |
| ---: | ---: | --- |
| 1 | 38 | Synth Bass 101 |
| 1 | 44 | Tremolo Strings Mono |
| 1 | 48 | Fast Strings Mono |
| 1 | 49 | Slow Strings Mono |
| 1 | 52 | Concert Choir Mono |
| 1 | 56 | Trumpet 2 |
| 1 | 57 | Trombone 2 |
| 1 | 60 | Solo French Horn |
| 1 | 61 | Brass Section Mono |
| 1 | 80 | Square Wave |
| 1 | 81 | Saw Wave |
| 1 | 98 | Synth Mallet |
| 1 | 120 | Cut Noise |
| 1 | 121 | Fl. Key Click |
| 1 | 122 | Rain |
| 1 | 123 | Dog |
| 1 | 124 | Telephone 2 |
| 1 | 125 | Car-Engine |
| 1 | 126 | Laughing |
| 1 | 127 | Machine Gun |

## Bank 2

| Bank | Program | Preset |
| ---: | ---: | --- |
| 2 | 102 | Echo Pan |
| 2 | 120 | String Slap |
| 2 | 122 | Thunder |
| 2 | 123 | Horse Gallop |
| 2 | 124 | Door Creaking |
| 2 | 125 | Car-Stop |
| 2 | 126 | Scream |
| 2 | 127 | Lasergun |

## Bank 3

| Bank | Program | Preset |
| ---: | ---: | --- |
| 3 | 122 | Wind |
| 3 | 123 | Bird 2 |
| 3 | 124 | Door |
| 3 | 125 | Car-Pass |
| 3 | 126 | Punch |
| 3 | 127 | Explosion |

## Bank 4

| Bank | Program | Preset |
| ---: | ---: | --- |
| 4 | 122 | Stream |
| 4 | 124 | Scratch |
| 4 | 125 | Car-Crash |
| 4 | 126 | Heart Beat |

## Bank 5

| Bank | Program | Preset |
| ---: | ---: | --- |
| 5 | 122 | Bubbles |
| 5 | 124 | Windchime |
| 5 | 125 | Siren |
| 5 | 126 | Footsteps |

## Bank 6

| Bank | Program | Preset |
| ---: | ---: | --- |
| 6 | 125 | Train |

## Bank 7

| Bank | Program | Preset |
| ---: | ---: | --- |
| 7 | 125 | Jet Plane |

## Bank 8

| Bank | Program | Preset |
| ---: | ---: | --- |
| 8 | 4 | Chorused Tine EP |
| 8 | 5 | Chorused FM EP |
| 8 | 6 | Coupled Harpsichord |
| 8 | 14 | Church Bells |
| 8 | 16 | Detuned Tnwl. Organ |
| 8 | 17 | Detuned Perc. Organ |
| 8 | 19 | Pipe Organ 2 |
| 8 | 21 | Italian Accordion |
| 8 | 24 | Ukulele |
| 8 | 25 | 12-String Guitar |
| 8 | 26 | Hawaiian Guitar |
| 8 | 27 | Chorused Clean Gt. |
| 8 | 28 | Funk Guitar |
| 8 | 30 | Feedback Guitar |
| 8 | 31 | Guitar Feedback |
| 8 | 38 | Acid Bass |
| 8 | 39 | Beef FM Bass |
| 8 | 48 | Orchestra Pad |
| 8 | 50 | Synth Strings 3 |
| 8 | 61 | Brass Section 2 |
| 8 | 62 | Synth Brass 3 |
| 8 | 63 | Synth Brass 4 |
| 8 | 80 | Sine Wave |
| 8 | 81 | Doctor Solo |
| 8 | 107 | Taisho Koto |
| 8 | 115 | Castanets |
| 8 | 116 | Concert Bass Drum |
| 8 | 117 | Melodic Tom 2 |
| 8 | 118 | 808 Tom |
| 8 | 125 | Starship |

## Bank 9

| Bank | Program | Preset |
| ---: | ---: | --- |
| 9 | 14 | Carillon |
| 9 | 125 | Burst Noise |

## Bank 11

| Bank | Program | Preset |
| ---: | ---: | --- |
| 11 | 0 | Piano & Str.-Fade |
| 11 | 1 | Piano & Str.-Sus |
| 11 | 4 | Tine & FM EPs |
| 11 | 5 | Piano & FM EP |
| 11 | 6 | Harpsichord noVel |
| 11 | 8 | Tinkling Bells |
| 11 | 11 | Vibraphone No Trem. |
| 11 | 14 | Bell Tower |
| 11 | 16 | Tonewheel Org noVel |
| 11 | 17 | Percussive Org noVel |
| 11 | 18 | Rock Organ noVel |
| 11 | 19 | Pipe Organ noVel |
| 11 | 20 | Reed Organ noVel |
| 11 | 29 | Wah Guitar (CC21) |
| 11 | 38 | Techno Bass |
| 11 | 39 | Pulse Bass |
| 11 | 49 | Velo Strings |
| 11 | 50 | Synth Strings 4 |
| 11 | 51 | Synth Strings 5 |
| 11 | 61 | Brass Section 3 |
| 11 | 78 | Whistlin' |
| 11 | 81 | Sawtooth Stab |
| 11 | 88 | Harpsi Pad |
| 11 | 89 | Solar Wind |
| 11 | 96 | Mystery Pad |
| 11 | 98 | Synth Chime |
| 11 | 100 | Bright Saw Stack |
| 11 | 119 | Cymbal Crash |
| 11 | 121 | Filter Snap |
| 11 | 122 | Howling Winds |
| 11 | 127 | Interference |

## Bank 12

| Bank | Program | Preset |
| ---: | ---: | --- |
| 12 | 0 | Bell Piano |
| 12 | 4 | Bell Tine EP |
| 12 | 6 | Coupled Harpsi noVel |
| 12 | 10 | Christmas Bells |
| 12 | 16 | Detun Tnwl Org noVel |
| 12 | 17 | Detun Perc Org noVel |
| 12 | 19 | Pipe Organ 2 noVel |
| 12 | 27 | Clean Guitar 2 |
| 12 | 38 | Mean Saw Bass |
| 12 | 48 | Full Orchestra |
| 12 | 49 | Velo Strings Mono |
| 12 | 80 | Square Lead 2 |
| 12 | 81 | Saw Lead 2 |
| 12 | 88 | Fantasia 2 |
| 12 | 89 | Solar Wind 2 |
| 12 | 119 | Tambourine |
| 12 | 122 | White Noise Wave |
| 12 | 127 | Shooting Star |

## Bank 13

| Bank | Program | Preset |
| ---: | ---: | --- |
| 13 | 48 | Woodwind Choir |
| 13 | 80 | Square Lead 3 |
| 13 | 81 | Saw Lead 3 |
| 13 | 88 | Night Vision |

## Bank 16

| Bank | Program | Preset |
| ---: | ---: | --- |
| 16 | 25 | Mandolin |

## Bank 24

| Bank | Program | Preset |
| ---: | ---: | --- |
| 24 | 75 | Tin Whistle |

## Bank 25

| Bank | Program | Preset |
| ---: | ---: | --- |
| 25 | 75 | Tin Whistle Nm |

## Bank 26

| Bank | Program | Preset |
| ---: | ---: | --- |
| 26 | 75 | Tin Whistle Or |

## Bank 120

| Bank | Program | Preset |
| ---: | ---: | --- |
| 120 | 0 | Standard 1 Kit |
| 120 | 1 | Standard 2 Kit |
| 120 | 2 | Standard 3 Kit |
| 120 | 8 | Room Kit |
| 120 | 16 | Power Kit |
| 120 | 24 | Electronic Kit |
| 120 | 25 | 808/909 Kit |
| 120 | 26 | Dance Kit |
| 120 | 32 | Jazz Kit |
| 120 | 40 | Brush Kit |
| 120 | 48 | Orchestral Kit |
| 120 | 56 | SFX Kit |
| 120 | 127 | CM-64/32L Kit |

## Bank 128

| Bank | Program | Preset |
| ---: | ---: | --- |
| 128 | 0 | Standard 1 |
| 128 | 1 | Standard 2 |
| 128 | 2 | Standard 3 |
| 128 | 8 | Room |
| 128 | 16 | Power |
| 128 | 24 | Electronic |
| 128 | 25 | 808/909 |
| 128 | 26 | Dance |
| 128 | 32 | Jazz |
| 128 | 40 | Brush |
| 128 | 48 | Orchestral |
| 128 | 56 | SFX |
| 128 | 127 | CM-64/32L |
