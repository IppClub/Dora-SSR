use std::f32::consts::TAU;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum BuiltinInstrument {
	Square,
	Pulse,
	Saw,
	Triangle,
	Sine,
	Organ,
	Piano,
	Bell,
	Pluck,
	Fm,
	Pad,
	Sub,
	Guitar,
	Strings,
	Noise,
	Drums(BuiltinDrumKit),
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum BuiltinDrumKit {
	Acoustic,
	Electronic,
	LoFi,
	Brush,
}

impl BuiltinInstrument {
	pub(crate) fn from_name(value: &str) -> Option<Self> {
		match value {
			"square" => Some(Self::Square),
			"pulse" => Some(Self::Pulse),
			"saw" => Some(Self::Saw),
			"triangle" => Some(Self::Triangle),
			"sine" => Some(Self::Sine),
			"organ" => Some(Self::Organ),
			"piano" => Some(Self::Piano),
			"bell" => Some(Self::Bell),
			"pluck" => Some(Self::Pluck),
			"fm" => Some(Self::Fm),
			"pad" => Some(Self::Pad),
			"sub" => Some(Self::Sub),
			"guitar" => Some(Self::Guitar),
			"strings" => Some(Self::Strings),
			"noise" => Some(Self::Noise),
			_ => None,
		}
	}

	pub(crate) fn midi_program(self) -> i32 {
		match self {
			Self::Square => 80,
			Self::Pulse => 80,
			Self::Saw => 81,
			Self::Triangle => 80,
			Self::Sine => 80,
			Self::Organ => 16,
			Self::Piano => 0,
			Self::Bell => 14,
			Self::Pluck => 45,
			Self::Fm => 5,
			Self::Pad => 88,
			Self::Sub => 38,
			Self::Guitar => 24,
			Self::Strings => 48,
			Self::Noise | Self::Drums(_) => 0,
		}
	}

	pub(crate) fn is_percussion(self) -> bool {
		matches!(self, Self::Drums(_))
	}
}

impl BuiltinDrumKit {
	pub(crate) fn from_name(value: &str) -> Option<Self> {
		match value {
			"acoustic" => Some(Self::Acoustic),
			"electronic" => Some(Self::Electronic),
			"lofi" => Some(Self::LoFi),
			"brush" => Some(Self::Brush),
			_ => None,
		}
	}
}

#[derive(Clone)]
struct PianoVoice {
	frequency: f32,
	second_ratio: f32,
	third_ratio: f32,
	fourth_ratio: f32,
	first_weight: f32,
	second_weight: f32,
	third_weight: f32,
	fourth_weight: f32,
	decay_rate: f32,
}

#[derive(Clone)]
struct Voice {
	key: i32,
	velocity: f32,
	phase: f32,
	age: u64,
	released_at: Option<u64>,
	held_by_pedal: bool,
	seed: u32,
	piano: Option<PianoVoice>,
}

pub(crate) struct BuiltinSynth {
	instrument: BuiltinInstrument,
	sample_rate: f32,
	voices: Vec<Voice>,
	pedal: bool,
	voice_step: u32,
	drum_level: f32,
}

impl BuiltinSynth {
	pub(crate) fn new(instrument: BuiltinInstrument, sample_rate: i32, drum_level: f32) -> Self {
		Self {
			instrument,
			sample_rate: sample_rate as f32,
			voices: Vec::new(),
			pedal: false,
			voice_step: 0,
			drum_level,
		}
	}

	pub(crate) fn note_on(&mut self, key: i32, velocity: i32) {
		self.voice_step = self.voice_step.wrapping_add(1);
		let velocity = (velocity as f32 / 127.0).clamp(0.0, 1.0);
		self.voices.push(Voice {
			key,
			velocity,
			phase: 0.0,
			age: 0,
			released_at: None,
			held_by_pedal: false,
			seed: (key as u32)
				.wrapping_mul(0x9E37_79B9)
				.wrapping_add(self.voice_step.wrapping_mul(0x85EB_CA6B)),
			piano: matches!(self.instrument, BuiltinInstrument::Piano)
				.then(|| resolve_piano_voice(key, velocity)),
		});
	}

	pub(crate) fn note_off(&mut self, key: i32) {
		for voice in self
			.voices
			.iter_mut()
			.filter(|voice| voice.key == key && voice.released_at.is_none())
		{
			if self.pedal && !self.instrument.is_percussion() {
				voice.held_by_pedal = true;
			} else {
				voice.released_at = Some(voice.age);
			}
		}
	}

	pub(crate) fn set_pedal(&mut self, down: bool) {
		self.pedal = down;
		if !down {
			for voice in self.voices.iter_mut().filter(|voice| voice.held_by_pedal) {
				voice.held_by_pedal = false;
				voice.released_at = Some(voice.age);
			}
		}
	}

	pub(crate) fn render(&mut self, left: &mut [f32], right: &mut [f32]) {
		for (left, right) in left.iter_mut().zip(right.iter_mut()) {
			let mut sample = 0.0f32;
			for voice in &mut self.voices {
				sample += if let BuiltinInstrument::Drums(kit) = self.instrument {
					render_drum_voice(voice, kit, self.sample_rate)
				} else {
					render_melodic_voice(voice, self.instrument, self.sample_rate)
				};
				voice.age += 1;
			}
			self.voices.retain(|voice| {
				if self.instrument.is_percussion() {
					voice.age < drum_length(voice.key, self.sample_rate)
				} else {
					voice.released_at.is_none_or(|released| {
						voice.age - released < release_samples(self.instrument, self.sample_rate)
					})
				}
			});
			if let BuiltinInstrument::Drums(kit) = self.instrument {
				sample = shape_drum_bus(sample, kit, self.drum_level);
			}
			*left = sample;
			*right = sample;
		}
	}
}

fn frequency(key: i32) -> f32 {
	440.0 * 2.0f32.powf((key as f32 - 69.0) / 12.0)
}

fn noise(seed: u32, sample: u64) -> f32 {
	let mut value = seed ^ (sample as u32).wrapping_mul(0x9E37_79B9);
	value ^= value >> 16;
	value = value.wrapping_mul(0x7FEB_352D);
	value ^= value >> 15;
	value = value.wrapping_mul(0x846C_A68B);
	value ^= value >> 16;
	(value as f32 / u32::MAX as f32) * 2.0 - 1.0
}

fn resolve_piano_voice(key: i32, velocity: f32) -> PianoVoice {
	let (mut second_weight, mut third_weight, mut fourth_weight);
	if key <= 69 {
		let blend = ((key as f32 - 45.0) / 24.0).clamp(0.0, 1.0);
		second_weight = 0.88 + (0.22 - 0.88) * blend;
		third_weight = 0.52 + (0.07 - 0.52) * blend;
		fourth_weight = 0.20 + (0.04 - 0.20) * blend;
	} else {
		let blend = ((key as f32 - 69.0) / 24.0).clamp(0.0, 1.0);
		second_weight = 0.22 + (0.08 - 0.22) * blend;
		third_weight = 0.07 + (0.02 - 0.07) * blend;
		fourth_weight = 0.04 * (1.0 - blend);
	}
	let brightness = 0.72 + velocity.clamp(0.0, 1.0) * 0.38;
	second_weight *= brightness;
	third_weight *= brightness;
	fourth_weight *= brightness;
	let weight_sum = 1.0 + second_weight + third_weight + fourth_weight;
	let inharmonicity = ((key as f32 - 69.0) / 24.0).clamp(0.0, 1.0) * 0.004;
	PianoVoice {
		frequency: frequency(key),
		second_ratio: 2.0 * (1.0 + inharmonicity * 4.0).sqrt(),
		third_ratio: 3.0 * (1.0 + inharmonicity * 9.0).sqrt(),
		fourth_ratio: 4.0 * (1.0 + inharmonicity * 16.0).sqrt(),
		first_weight: 1.0 / weight_sum,
		second_weight: second_weight / weight_sum,
		third_weight: third_weight / weight_sum,
		fourth_weight: fourth_weight / weight_sum,
		decay_rate: 1.2 + ((key as f32 - 45.0) / 48.0).clamp(0.0, 1.0) * 6.0,
	}
}

fn piano_wave(voice: &Voice, age: f32) -> f32 {
	let piano = voice.piano.as_ref().expect("piano voice parameters");
	let phase = age * piano.frequency * TAU;
	(phase).sin() * piano.first_weight
		+ (phase * piano.second_ratio).sin() * piano.second_weight
		+ (phase * piano.third_ratio).sin() * piano.third_weight
		+ (phase * piano.fourth_ratio).sin() * piano.fourth_weight
}

fn waveform(phase: f32, instrument: BuiltinInstrument, sample: u64, seed: u32) -> f32 {
	match instrument {
		BuiltinInstrument::Square => {
			if phase < 0.5 {
				0.7
			} else {
				-0.7
			}
		}
		BuiltinInstrument::Pulse => {
			if phase < 0.25 {
				0.75
			} else {
				-0.45
			}
		}
		BuiltinInstrument::Saw => 1.0 - phase * 2.0,
		BuiltinInstrument::Triangle | BuiltinInstrument::Pluck => {
			if phase < 0.5 {
				phase * 4.0 - 1.0
			} else {
				3.0 - phase * 4.0
			}
		}
		BuiltinInstrument::Sine => (phase * TAU).sin(),
		BuiltinInstrument::Sub => (phase * TAU).sin() * 0.85 + (phase * TAU * 2.0).sin() * 0.15,
		BuiltinInstrument::Organ => (phase * TAU).sin() * 0.72 + (phase * TAU * 3.0).sin() * 0.28,
		BuiltinInstrument::Piano => unreachable!("piano uses its per-note partial model"),
		BuiltinInstrument::Bell => (phase * TAU).sin() * 0.68 + (phase * TAU * 4.0).sin() * 0.32,
		BuiltinInstrument::Fm => (phase * TAU + (phase * TAU * 3.0).sin() * 2.2).sin(),
		BuiltinInstrument::Pad => {
			let triangle = if phase < 0.5 {
				phase * 4.0 - 1.0
			} else {
				3.0 - phase * 4.0
			};
			(phase * TAU).sin() * 0.65 + triangle * 0.35
		}
		BuiltinInstrument::Guitar => {
			let triangle = if phase < 0.5 {
				phase * 4.0 - 1.0
			} else {
				3.0 - phase * 4.0
			};
			triangle * 0.72 + (phase * TAU * 3.0).sin() * 0.28
		}
		BuiltinInstrument::Strings => (1.0 - phase * 2.0) * 0.55 + (phase * TAU).sin() * 0.45,
		BuiltinInstrument::Noise => noise(seed, sample),
		BuiltinInstrument::Drums(_) => 0.0,
	}
}

fn render_melodic_voice(voice: &mut Voice, instrument: BuiltinInstrument, sample_rate: f32) -> f32 {
	let age = voice.age as f32 / sample_rate;
	let attack = match instrument {
		BuiltinInstrument::Pad | BuiltinInstrument::Strings => 0.08,
		BuiltinInstrument::Piano => 0.008,
		_ => 0.005,
	};
	let attack_gain = (age / attack).clamp(0.0, 1.0);
	let decay = match instrument {
		BuiltinInstrument::Piano => {
			let rate = voice
				.piano
				.as_ref()
				.expect("piano voice parameters")
				.decay_rate;
			(-age * rate).exp() * 0.97 + (-age * 1.2).exp() * 0.03
		}
		BuiltinInstrument::Pluck | BuiltinInstrument::Guitar => 1.0 / (1.0 + age * 8.0),
		BuiltinInstrument::Bell => 1.0 / (1.0 + age * 3.5),
		_ => 1.0,
	};
	let release = voice.released_at.map_or(1.0, |released| {
		let elapsed =
			(voice.age - released) as f32 / release_samples(instrument, sample_rate) as f32;
		(1.0 - elapsed).clamp(0.0, 1.0)
	});
	let wave = if instrument == BuiltinInstrument::Piano {
		piano_wave(voice, age)
	} else {
		waveform(voice.phase, instrument, voice.age, voice.seed)
	};
	let value = wave * voice.velocity * attack_gain * decay * release;
	voice.phase = (voice.phase + frequency(voice.key) / sample_rate) % 1.0;
	value
}

pub(crate) fn release_seconds(instrument: BuiltinInstrument) -> f32 {
	match instrument {
		BuiltinInstrument::Pad => 0.20,
		BuiltinInstrument::Piano => 0.12,
		_ => 0.06,
	}
}

fn release_samples(instrument: BuiltinInstrument, sample_rate: f32) -> u64 {
	(sample_rate * release_seconds(instrument)) as u64
}

fn drum_length(key: i32, sample_rate: f32) -> u64 {
	let seconds = match key {
		35 | 36 => 0.22,
		38 | 39 | 40 => 0.18,
		42 | 44 => 0.065,
		46 => 0.14,
		49 | 51 | 52 | 55 | 57 | 59 => 0.55,
		_ => 0.22,
	};
	(sample_rate * seconds) as u64
}

fn render_drum_voice(voice: &mut Voice, kit: BuiltinDrumKit, sample_rate: f32) -> f32 {
	let time = voice.age as f32 / sample_rate;
	let velocity = voice.velocity;
	let raw_noise = noise(voice.seed, voice.age);
	let previous_noise = noise(voice.seed, voice.age.saturating_sub(1));
	let high_noise = raw_noise - previous_noise;
	let brush = matches!(kit, BuiltinDrumKit::Brush);
	let sample = match voice.key {
		35 | 36 => {
			let length = 0.22;
			let decay = (1.0 - time / length).clamp(0.0, 1.0);
			let phase = 47.0 * time + 104.0 / 28.0 * (1.0 - (-time * 28.0).exp());
			let body = (TAU * phase).sin() * decay * decay;
			let sub = (TAU * 47.0 * time).sin() * decay * 0.40;
			let click = high_noise * (-time * 95.0).exp() * 0.28;
			(body + sub + click) * drum_kick_weight(kit) * 1.08
		}
		38 | 40 => {
			let length = if brush { 0.20 } else { 0.18 };
			let decay = (1.0 - time / length).clamp(0.0, 1.0).powf(1.35);
			let snare_noise = raw_noise - previous_noise * 0.62;
			let body = (TAU * 185.0 * time).sin() * 0.30 + (TAU * 330.0 * time).sin() * 0.12;
			let snap = high_noise * (-time * 55.0).exp() * 0.34;
			let brush_gain = if brush { 0.72 } else { 1.0 };
			(snare_noise * 0.82 + body + snap) * decay * drum_snare_weight(kit) * 0.92 * brush_gain
		}
		39 => {
			let decay = (1.0 - time / 0.18).clamp(0.0, 1.0).powf(1.35);
			let burst = if (time * 42.0) % 1.0 < 0.18 { 1.0 } else { 0.0 };
			// Procedural arrangements emit the legacy clap layer at MIDI velocity 62.
			// Compensate here so that the rendered burst keeps the original 0.18 mix.
			(raw_noise - previous_noise * 0.62) * decay * burst * (0.18 * 127.0 / 62.0)
		}
		42 | 44 => {
			let decay = (1.0 - time / 0.065).clamp(0.0, 1.0).powi(2);
			high_noise * decay * 0.34
		}
		46 => high_noise * (1.0 - time / 0.14).clamp(0.0, 1.0) * 0.28,
		49 | 51 | 52 | 55 | 57 | 59 => {
			let metallic =
				(TAU * 1327.0 * time).sin() + (TAU * 1867.0 * time).sin() * 0.6 + high_noise * 0.8;
			metallic * (-time * 7.0).exp() * 0.32
		}
		41 | 43 | 45 | 47 | 48 | 50 => {
			let pitch = 92.0 + (voice.key - 41) as f32 * 12.0;
			(TAU * pitch * time).sin() * (-time * 18.0).exp() * 0.72
		}
		_ => raw_noise * (-time * 20.0).exp() * 0.45,
	};
	sample * velocity
}

fn drum_kick_weight(kit: BuiltinDrumKit) -> f32 {
	match kit {
		BuiltinDrumKit::Electronic => 1.10,
		BuiltinDrumKit::LoFi => 1.18,
		_ => 1.0,
	}
}

fn drum_snare_weight(kit: BuiltinDrumKit) -> f32 {
	match kit {
		BuiltinDrumKit::Electronic => 1.12,
		BuiltinDrumKit::LoFi => 1.24,
		_ => 1.0,
	}
}

fn shape_drum_bus(sample: f32, kit: BuiltinDrumKit, level: f32) -> f32 {
	let (mix, drive) = match kit {
		BuiltinDrumKit::Acoustic => (0.24, 1.0),
		BuiltinDrumKit::Electronic => (0.46, 1.65),
		BuiltinDrumKit::LoFi => (0.46, 1.85),
		BuiltinDrumKit::Brush => (0.20, 1.0),
	};
	let sample = sample * mix * level;
	if drive <= 1.0 {
		sample
	} else {
		let driven = sample * drive / (1.0 + sample.abs() * (drive - 1.0) * 0.82);
		sample * 0.52 + driven * 0.68
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn named_instruments_and_drum_kits_are_explicit() {
		assert_eq!(
			BuiltinInstrument::from_name("piano"),
			Some(BuiltinInstrument::Piano)
		);
		assert_eq!(
			BuiltinDrumKit::from_name("electronic"),
			Some(BuiltinDrumKit::Electronic)
		);
		assert!(BuiltinInstrument::from_name("grand_piano").is_none());
	}

	#[test]
	fn builtin_synth_renders_finite_audio() {
		let mut synth = BuiltinSynth::new(BuiltinInstrument::Piano, 44_100, 1.0);
		synth.note_on(60, 100);
		let mut left = vec![0.0; 2048];
		let mut right = vec![0.0; 2048];
		synth.render(&mut left, &mut right);
		assert!(left.iter().all(|sample| sample.is_finite()));
		assert!(left.iter().any(|sample| sample.abs() > 0.001));
		assert_eq!(left, right);
	}

	#[test]
	fn piano_parameters_match_the_last_typescript_fallback() {
		let piano = resolve_piano_voice(60, 0.8);
		assert!((piano.first_weight - 0.547_765_14).abs() < 0.000_001);
		assert!((piano.second_weight - 0.262_226_1).abs() < 0.000_001);
		assert!((piano.third_weight - 0.133_917_61).abs() < 0.000_001);
		assert!((piano.fourth_weight - 0.056_091_15).abs() < 0.000_001);
		assert_eq!(piano.second_ratio, 2.0);
		assert_eq!(piano.third_ratio, 3.0);
		assert_eq!(piano.fourth_ratio, 4.0);
		assert!((piano.decay_rate - 3.075).abs() < 0.000_001);
	}

	#[test]
	fn jazz_hop_drum_bus_keeps_the_heavier_legacy_drive() {
		let input = 0.4;
		let level = 0.83;
		let acoustic = shape_drum_bus(input, BuiltinDrumKit::Acoustic, level);
		let electronic = shape_drum_bus(input, BuiltinDrumKit::Electronic, level);
		let lofi = shape_drum_bus(input, BuiltinDrumKit::LoFi, level);
		assert!(electronic > acoustic);
		assert!(lofi > electronic);
		assert!((lofi - 0.253_053_04).abs() < 0.000_01);
	}
}
