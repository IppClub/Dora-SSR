use ebur128::{EbuR128, Mode as LoudnessMode};
use rustysynth::{SoundFont, Synthesizer, SynthesizerSettings};
use serde::Deserialize;
use serde_json::{json, Value};
use std::collections::HashMap;
use std::f32::consts::TAU;
use std::ffi::{c_char, c_void, CStr, CString};
use std::fs::{self, File};
use std::io::{BufReader, BufWriter, Read, Write};
use std::path::{Component, Path, PathBuf};
use std::ptr;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use super::builtin::{release_seconds, BuiltinDrumKit, BuiltinInstrument, BuiltinSynth};
use crate::soundfont::load_sound_font;

type ProgressCallback = extern "C" fn(f32, *mut c_void);

#[cfg(not(test))]
extern "C" {
	fn dora_audio_encode_wav_to_ogg(
		input_path: *const c_char,
		output_path: *const c_char,
		quality: f32,
		progress: Option<ProgressCallback>,
		user_data: *mut c_void,
		progress_start: f32,
		progress_end: f32,
		bytes_written: *mut u64,
		error: *mut c_char,
		error_capacity: usize,
	) -> i32;
}

#[cfg(test)]
unsafe fn dora_audio_encode_wav_to_ogg(
	_input_path: *const c_char,
	_output_path: *const c_char,
	_quality: f32,
	_progress: Option<ProgressCallback>,
	_user_data: *mut c_void,
	_progress_start: f32,
	_progress_end: f32,
	_bytes_written: *mut u64,
	_error: *mut c_char,
	_error_capacity: usize,
) -> i32 {
	0
}

const SAMPLE_RATE: i32 = 44_100;
/// Rendering uses a conservative fixed level; the completed mix is then normalized independently
/// of the selected synthesis backend.
const INTERNAL_RENDER_VOLUME: f32 = 0.25;
/// `audio.volume = 1` targets this integrated EBU R128 loudness. The volume value remains a linear
/// adjustment, so 0.5 is approximately 6 dB quieter and 2 is approximately 6 dB louder.
const STANDARD_LOUDNESS_LUFS: f64 = -14.0;
const TRUE_PEAK_CEILING_DBTP: f64 = -1.0;
const STEPS_PER_BAR: usize = 16;
const MIN_SECONDS: f64 = 4.0;
const MAX_TRACKS: usize = 32;
const MAX_NOTES: usize = 4096;
const MAX_BARS: usize = 512;
const MAX_TEMPO_CHANGES: usize = 128;
const MAX_PEDALS: usize = 512;
const KEY_NAMES: [&str; 12] = [
	"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B",
];
const STYLES: [&str; 7] = [
	"chiptune",
	"adventure",
	"calm",
	"tense",
	"victory",
	"hiphop",
	"jazz_hop",
];

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct Envelope {
	project_dir: String,
	definition: Definition,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct Definition {
	output: String,
	synth: SynthOptions,
	#[serde(default)]
	score: Option<ScoreDefinition>,
	#[serde(default)]
	composition: Option<CompositionDefinition>,
	#[serde(default)]
	arrangement: Option<ArrangementOptions>,
	#[serde(default)]
	instruments: Option<InstrumentOptions>,
	#[serde(default)]
	effects: Option<AudioOptions>,
	#[serde(default)]
	audio: Option<AudioOptions>,
	#[serde(default)]
	exports: Option<ExportOptions>,
	#[serde(default)]
	seed: Option<f64>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct SynthOptions {
	#[serde(default)]
	file: Option<String>,
	#[serde(default)]
	sample_rate: Option<i32>,
	#[serde(default)]
	polyphony: Option<usize>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct CompositionDefinition {
	style: String,
	#[serde(default)]
	seed: Option<f64>,
	#[serde(default)]
	duration: Option<f64>,
	#[serde(default)]
	tempo: Option<f64>,
	#[serde(default)]
	key: Option<String>,
	#[serde(default)]
	mode: Option<String>,
	#[serde(default)]
	progression: Option<Vec<String>>,
	#[serde(default)]
	structure: Option<Vec<String>>,
}

#[derive(Default, Deserialize)]
#[serde(rename_all = "camelCase")]
struct ArrangementOptions {
	#[serde(default)]
	intensity: Option<f64>,
	#[serde(default)]
	bars_per_section: Option<f64>,
	#[serde(default)]
	melody_complexity: Option<f64>,
	#[serde(default)]
	rhythm_complexity: Option<f64>,
	#[serde(default)]
	variation: Option<f64>,
	#[serde(default)]
	drum_gain: Option<f64>,
}

#[derive(Clone, Deserialize)]
#[serde(untagged)]
enum InstrumentSelection {
	Name(String),
	Preset(PresetSelection),
}

#[derive(Clone, Copy, Deserialize)]
struct PresetSelection {
	bank: i32,
	program: i32,
}

#[derive(Default, Deserialize)]
struct InstrumentOptions {
	#[serde(default)]
	lead: Option<InstrumentSelection>,
	#[serde(default)]
	bass: Option<InstrumentSelection>,
	#[serde(default)]
	harmony: Option<InstrumentSelection>,
	#[serde(default)]
	drums: Option<InstrumentSelection>,
}

#[derive(Clone, Default, Deserialize)]
#[serde(rename_all = "camelCase")]
struct AudioOptions {
	#[serde(default)]
	volume: Option<f64>,
	#[serde(default)]
	stereo: Option<bool>,
	#[serde(default)]
	reverb: Option<f64>,
	#[serde(default)]
	delay: Option<f64>,
	#[serde(default)]
	chorus: Option<f64>,
	#[serde(default)]
	distortion: Option<f64>,
	#[serde(default)]
	bit_crush: Option<f64>,
	#[serde(default)]
	low_pass: Option<f64>,
}

#[derive(Default, Deserialize)]
#[serde(rename_all = "camelCase")]
struct ExportOptions {
	#[serde(default)]
	stems: Option<bool>,
	#[serde(default)]
	intro_bars: Option<f64>,
	#[serde(default)]
	outro_bars: Option<f64>,
	#[serde(default)]
	stinger: Option<String>,
	#[serde(default)]
	midi: Option<bool>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct ScoreDefinition {
	bpm: f64,
	#[serde(default)]
	beats_per_bar: Option<f64>,
	#[serde(default)]
	beat_unit: Option<u8>,
	#[serde(default)]
	bars: Option<f64>,
	#[serde(default)]
	tempo_changes: Vec<TempoChange>,
	tracks: Vec<ScoreTrack>,
}

#[derive(Clone, Deserialize)]
struct TempoChange {
	beat: f64,
	bpm: f64,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct ScoreTrack {
	#[serde(default)]
	instrument: Option<String>,
	#[serde(default)]
	drum_kit: Option<String>,
	#[serde(default)]
	preset: Option<PresetSelection>,
	#[serde(default)]
	percussion: Option<bool>,
	notes: Vec<ScoreNote>,
	#[serde(default)]
	volume: Option<f64>,
	#[serde(default)]
	pan: Option<f64>,
	#[serde(default)]
	role: Option<String>,
	#[serde(default)]
	pedal: Vec<ScorePedal>,
}

#[derive(Deserialize)]
struct ScoreNote {
	pitch: Pitch,
	start: f64,
	duration: f64,
	#[serde(default)]
	velocity: Option<f64>,
}

#[derive(Deserialize)]
#[serde(untagged)]
enum Pitch {
	Number(f64),
	Name(String),
}

#[derive(Deserialize)]
struct ScorePedal {
	start: f64,
	duration: f64,
}

#[derive(Clone)]
struct Note {
	key: i32,
	velocity: i32,
	start: f64,
	end: f64,
}

#[derive(Clone)]
struct Pedal {
	start: f64,
	end: f64,
}

#[derive(Clone, Copy, PartialEq, Eq, Hash)]
enum Stem {
	Melody,
	Bass,
	Harmony,
	Drums,
}

impl Stem {
	fn name(self) -> &'static str {
		match self {
			Self::Melody => "melody",
			Self::Bass => "bass",
			Self::Harmony => "harmony",
			Self::Drums => "drums",
		}
	}

	fn suffix(self) -> &'static str {
		match self {
			Self::Melody => "_melody",
			Self::Bass => "_bass",
			Self::Harmony => "_harmony",
			Self::Drums => "_drums",
		}
	}

	fn from_name(name: &str) -> Option<Self> {
		match name {
			"melody" => Some(Self::Melody),
			"bass" => Some(Self::Bass),
			"harmony" => Some(Self::Harmony),
			"drums" => Some(Self::Drums),
			_ => None,
		}
	}
}

#[derive(Clone)]
struct Track {
	program: i32,
	bank: i32,
	percussion: bool,
	builtin: Option<BuiltinInstrument>,
	builtin_drum_level: f32,
	volume: f32,
	render_gain: f32,
	pan: f32,
	chorus_direction: f32,
	role: Stem,
	notes: Vec<Note>,
	pedals: Vec<Pedal>,
}

#[derive(Clone)]
struct Song {
	bpm: f64,
	beats_per_bar: usize,
	beat_unit: u8,
	bars: usize,
	duration: f64,
	master_gain: f32,
	tracks: Vec<Track>,
	tempo_changes: Vec<TempoChange>,
}

#[derive(Clone, Copy)]
struct PresetRef {
	bank: i32,
	program: i32,
	percussion: bool,
}

#[derive(Clone, Copy)]
enum TrackVoice {
	Builtin(BuiltinInstrument),
	SoundFont(PresetRef),
}

impl TrackVoice {
	fn is_builtin(self) -> bool {
		matches!(self, Self::Builtin(_))
	}

	fn program(self) -> i32 {
		match self {
			Self::Builtin(instrument) => instrument.midi_program(),
			Self::SoundFont(preset) => preset.program,
		}
	}

	fn bank(self) -> i32 {
		match self {
			Self::Builtin(_) => 0,
			Self::SoundFont(preset) => preset.bank,
		}
	}

	fn percussion(self) -> bool {
		match self {
			Self::Builtin(instrument) => instrument.is_percussion(),
			Self::SoundFont(preset) => preset.percussion,
		}
	}

	fn builtin(self) -> Option<BuiltinInstrument> {
		match self {
			Self::Builtin(instrument) => Some(instrument),
			Self::SoundFont(_) => None,
		}
	}

	#[cfg(test)]
	fn effective_bank(self) -> i32 {
		match self {
			Self::Builtin(instrument) => {
				if instrument.is_percussion() {
					128
				} else {
					0
				}
			}
			Self::SoundFont(preset) => preset.effective_bank(),
		}
	}
}

impl PresetRef {
	fn effective_bank(self) -> i32 {
		if self.percussion {
			self.bank + 128
		} else {
			self.bank
		}
	}
}

#[derive(Clone)]
struct Effects {
	volume: f32,
	stereo: bool,
	reverb: f32,
	delay: f32,
	chorus: f32,
	distortion: f32,
	bit_crush: f32,
	low_pass: f32,
}

#[derive(Clone)]
struct ResolvedComposition {
	style: String,
	seed: i64,
	bpm: f64,
	bars: usize,
	key: String,
	root: i32,
	mode: String,
	progression: Vec<i32>,
	structure: Vec<String>,
	bars_per_section: usize,
	melody_complexity: f64,
	rhythm_complexity: f64,
	variation: f64,
	intensity: f64,
	lead: TrackVoice,
	bass: TrackVoice,
	harmony: TrackVoice,
	drums: TrackVoice,
	drum_gain: f64,
	effects: Effects,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Groove {
	Standard,
	HipHop,
	JazzHop,
}

#[derive(Clone)]
struct StyleConfig {
	bpm: f64,
	mode: &'static str,
	progression: &'static [i32],
	melody_span: usize,
	melody_density: f64,
	lead: &'static str,
	bass: &'static str,
	harmony: &'static str,
	groove: Groove,
	hat_stride: usize,
	swing: f64,
	jazz_voicing: bool,
	melody_mix: f32,
	bass_mix: f32,
	harmony_mix: f32,
	drum_mix: f32,
	pad_mix: f32,
	kick_weight: f32,
	snare_weight: f32,
	drum_drive: f32,
	reverb: f64,
	delay: f64,
	chorus: f64,
	distortion: f64,
}

struct Rng {
	state: i64,
}

impl Rng {
	fn new(seed: i64) -> Self {
		let mut state = seed.unsigned_abs() as i64 % 2_147_483_647;
		if state <= 0 {
			state = 1;
		}
		Self { state }
	}

	fn next(&mut self) -> f64 {
		self.state = self.state * 16_807 % 2_147_483_647;
		(self.state - 1) as f64 / 2_147_483_646.0
	}
}

fn clamp01(value: f64) -> f64 {
	value.clamp(0.0, 1.0)
}

fn range(value: Option<f64>, name: &str, min: f64, max: f64) -> Result<(), String> {
	if let Some(value) = value {
		if !value.is_finite() || !(min..=max).contains(&value) {
			return Err(format!("{name} must be between {min} and {max}"));
		}
	}
	Ok(())
}

fn style_config(style: &str) -> StyleConfig {
	match style {
		"adventure" => StyleConfig {
			bpm: 124.0,
			mode: "major",
			progression: &[0, 3, 4, 0],
			melody_span: 2,
			melody_density: 0.82,
			lead: "strings",
			bass: "triangle",
			harmony: "organ",
			groove: Groove::Standard,
			hat_stride: 2,
			swing: 0.0,
			jazz_voicing: false,
			melody_mix: 0.28,
			bass_mix: 0.24,
			harmony_mix: 0.15,
			drum_mix: 0.22,
			pad_mix: 0.035,
			kick_weight: 1.0,
			snare_weight: 1.0,
			drum_drive: 1.0,
			reverb: 0.16,
			delay: 0.10,
			chorus: 0.18,
			distortion: 0.04,
		},
		"calm" => StyleConfig {
			bpm: 84.0,
			mode: "pentatonic",
			progression: &[0, 4, 3, 4],
			melody_span: 4,
			melody_density: 0.72,
			lead: "bell",
			bass: "sub",
			harmony: "pad",
			groove: Groove::Standard,
			hat_stride: 4,
			swing: 0.0,
			jazz_voicing: false,
			melody_mix: 0.30,
			bass_mix: 0.20,
			harmony_mix: 0.18,
			drum_mix: 0.10,
			pad_mix: 0.10,
			kick_weight: 1.0,
			snare_weight: 1.0,
			drum_drive: 1.0,
			reverb: 0.34,
			delay: 0.16,
			chorus: 0.28,
			distortion: 0.0,
		},
		"tense" => StyleConfig {
			bpm: 152.0,
			mode: "minor",
			progression: &[0, 5, 6, 4],
			melody_span: 2,
			melody_density: 0.88,
			lead: "saw",
			bass: "saw",
			harmony: "pulse",
			groove: Groove::Standard,
			hat_stride: 1,
			swing: 0.0,
			jazz_voicing: false,
			melody_mix: 0.24,
			bass_mix: 0.29,
			harmony_mix: 0.15,
			drum_mix: 0.26,
			pad_mix: 0.035,
			kick_weight: 1.0,
			snare_weight: 1.0,
			drum_drive: 1.0,
			reverb: 0.10,
			delay: 0.08,
			chorus: 0.10,
			distortion: 0.20,
		},
		"victory" => StyleConfig {
			bpm: 148.0,
			mode: "major",
			progression: &[0, 3, 4, 0],
			melody_span: 2,
			melody_density: 0.92,
			lead: "square",
			bass: "triangle",
			harmony: "organ",
			groove: Groove::Standard,
			hat_stride: 2,
			swing: 0.0,
			jazz_voicing: false,
			melody_mix: 0.31,
			bass_mix: 0.22,
			harmony_mix: 0.18,
			drum_mix: 0.24,
			pad_mix: 0.035,
			kick_weight: 1.0,
			snare_weight: 1.0,
			drum_drive: 1.0,
			reverb: 0.22,
			delay: 0.12,
			chorus: 0.16,
			distortion: 0.04,
		},
		"hiphop" => StyleConfig {
			bpm: 92.0,
			mode: "minor",
			progression: &[0, 5, 3, 4],
			melody_span: 4,
			melody_density: 0.58,
			lead: "pluck",
			bass: "sub",
			harmony: "pad",
			groove: Groove::HipHop,
			hat_stride: 1,
			swing: 0.52,
			jazz_voicing: false,
			melody_mix: 0.22,
			bass_mix: 0.30,
			harmony_mix: 0.14,
			drum_mix: 0.46,
			pad_mix: 0.045,
			kick_weight: 1.10,
			snare_weight: 1.12,
			drum_drive: 1.65,
			reverb: 0.10,
			delay: 0.08,
			chorus: 0.12,
			distortion: 0.08,
		},
		"jazz_hop" => StyleConfig {
			bpm: 88.0,
			mode: "dorian",
			progression: &[1, 4, 0, 5],
			melody_span: 4,
			melody_density: 0.62,
			lead: "guitar",
			bass: "sub",
			harmony: "piano",
			groove: Groove::JazzHop,
			hat_stride: 1,
			swing: 0.62,
			jazz_voicing: true,
			melody_mix: 0.20,
			bass_mix: 0.28,
			harmony_mix: 0.22,
			drum_mix: 0.46,
			pad_mix: 0.085,
			kick_weight: 1.18,
			snare_weight: 1.24,
			drum_drive: 1.85,
			reverb: 0.18,
			delay: 0.10,
			chorus: 0.20,
			distortion: 0.04,
		},
		_ => StyleConfig {
			bpm: 138.0,
			mode: "major",
			progression: &[0, 4, 5, 3],
			melody_span: 2,
			melody_density: 0.86,
			lead: "square",
			bass: "saw",
			harmony: "pulse",
			groove: Groove::Standard,
			hat_stride: 2,
			swing: 0.0,
			jazz_voicing: false,
			melody_mix: 0.28,
			bass_mix: 0.25,
			harmony_mix: 0.16,
			drum_mix: 0.22,
			pad_mix: 0.035,
			kick_weight: 1.0,
			snare_weight: 1.0,
			drum_drive: 1.0,
			reverb: 0.10,
			delay: 0.08,
			chorus: 0.12,
			distortion: 0.06,
		},
	}
}

fn default_builtin_drum_kit(style: &str) -> BuiltinDrumKit {
	match style {
		"hiphop" => BuiltinDrumKit::Electronic,
		"jazz_hop" => BuiltinDrumKit::LoFi,
		"calm" => BuiltinDrumKit::Brush,
		_ => BuiltinDrumKit::Acoustic,
	}
}

fn resolve_melodic_voice(
	value: Option<&InstrumentSelection>,
	name: &str,
	fallback: &str,
) -> Result<TrackVoice, String> {
	match value {
		None => Ok(TrackVoice::Builtin(
			BuiltinInstrument::from_name(fallback).expect("style instrument is valid"),
		)),
		Some(InstrumentSelection::Name(value)) => {
			let value = value.trim().to_lowercase();
			if value == "auto" {
				Ok(TrackVoice::Builtin(
					BuiltinInstrument::from_name(fallback).expect("style instrument is valid"),
				))
			} else if let Some(instrument) = BuiltinInstrument::from_name(&value) {
				Ok(TrackVoice::Builtin(instrument))
			} else {
				Err(format!("unknown instruments.{name} '{value}'"))
			}
		}
		Some(InstrumentSelection::Preset(value)) => {
			if !(0..=127).contains(&value.bank) || !(0..=127).contains(&value.program) {
				return Err(format!(
					"instruments.{name}.bank and program must be 0..127"
				));
			}
			Ok(TrackVoice::SoundFont(PresetRef {
				bank: value.bank,
				program: value.program,
				percussion: false,
			}))
		}
	}
}

fn resolve_drum_voice(
	value: Option<&InstrumentSelection>,
	style: &str,
) -> Result<TrackVoice, String> {
	match value {
		None => Ok(TrackVoice::Builtin(BuiltinInstrument::Drums(
			default_builtin_drum_kit(style),
		))),
		Some(InstrumentSelection::Name(value)) => {
			let value = value.trim().to_lowercase();
			let kit = if value == "auto" {
				default_builtin_drum_kit(style)
			} else {
				BuiltinDrumKit::from_name(&value)
					.ok_or_else(|| format!("unknown instruments.drums '{value}'"))?
			};
			Ok(TrackVoice::Builtin(BuiltinInstrument::Drums(kit)))
		}
		Some(InstrumentSelection::Preset(value)) => {
			if !(128..=255).contains(&value.bank) || !(0..=127).contains(&value.program) {
				return Err(
					"instruments.drums.bank must be 128..255 and program must be 0..127"
						.to_string(),
				);
			}
			Ok(TrackVoice::SoundFont(PresetRef {
				bank: value.bank - 128,
				program: value.program,
				percussion: true,
			}))
		}
	}
}

fn scale(mode: &str) -> &'static [i32] {
	match mode {
		"minor" => &[0, 2, 3, 5, 7, 8, 10],
		"pentatonic" => &[0, 2, 4, 7, 9],
		"harmonic_minor" => &[0, 2, 3, 5, 7, 8, 11],
		"dorian" => &[0, 2, 3, 5, 7, 9, 10],
		"phrygian" => &[0, 1, 3, 5, 7, 8, 10],
		"chromatic" => &[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
		_ => &[0, 2, 4, 5, 7, 9, 11],
	}
}

fn scale_note(root: i32, notes: &[i32], degree: i32) -> i32 {
	let len = notes.len() as i32;
	let octave = degree.div_euclid(len);
	let index = degree.rem_euclid(len) as usize;
	root + octave * 12 + notes[index]
}

fn roman_degree(value: &str) -> Option<i32> {
	let normalized = value.trim().trim_start_matches(['b', '#']).to_uppercase();
	match normalized.as_str() {
		"I" => Some(0),
		"II" => Some(1),
		"III" => Some(2),
		"IV" => Some(3),
		"V" => Some(4),
		"VI" => Some(5),
		"VII" => Some(6),
		_ => None,
	}
}

fn section_seed(seed: i64, label: &str, bar: usize, variation: f64) -> i64 {
	let hash = label
		.bytes()
		.fold(0i64, |hash, byte| (hash * 31 + byte as i64) % 2_147_483_647);
	seed + hash * 131 + bar as i64 * 104_729 + (variation * 10_000.0).floor() as i64 * 8_191
}

fn automatic_seed() -> i64 {
	static STEP: AtomicU64 = AtomicU64::new(0);
	let seconds = SystemTime::now()
		.duration_since(UNIX_EPOCH)
		.map(|value| value.as_secs())
		.unwrap_or(1);
	(seconds % 1_000_000_000) as i64 + STEP.fetch_add(1, Ordering::Relaxed) as i64 * 104_729
}

fn resolve_seed(value: Option<f64>) -> i64 {
	match value {
		Some(value) if value.is_finite() && value.abs() < 2_147_483_647.0 => value.floor() as i64,
		_ => automatic_seed(),
	}
}

fn resolve_composition(definition: &Definition) -> Result<ResolvedComposition, String> {
	let composition = definition
		.composition
		.as_ref()
		.ok_or_else(|| "composition is required".to_string())?;
	if !STYLES.contains(&composition.style.as_str()) && composition.style != "random" {
		return Err(format!("unknown style '{}'", composition.style));
	}
	if let Some(duration) = composition.duration {
		if !duration.is_finite() || duration < MIN_SECONDS {
			return Err(format!(
				"composition.duration must be at least {} seconds",
				MIN_SECONDS as i32
			));
		}
	}
	range(composition.tempo, "composition.tempo", 60.0, 200.0)?;
	let arrangement = definition.arrangement.as_ref();
	if let Some(value) = arrangement {
		range(value.intensity, "arrangement.intensity", 0.0, 1.0)?;
		range(
			value.bars_per_section,
			"arrangement.barsPerSection",
			1.0,
			8.0,
		)?;
		range(
			value.melody_complexity,
			"arrangement.melodyComplexity",
			0.0,
			1.0,
		)?;
		range(
			value.rhythm_complexity,
			"arrangement.rhythmComplexity",
			0.0,
			1.0,
		)?;
		range(value.variation, "arrangement.variation", 0.0, 1.0)?;
	}
	let seed = resolve_seed(composition.seed);
	let mut style_rng = Rng::new(seed);
	let style = if composition.style == "random" {
		STYLES[(style_rng.next() * STYLES.len() as f64).floor() as usize].to_string()
	} else {
		composition.style.clone()
	};
	let config = style_config(&style);
	let bpm = composition
		.tempo
		.unwrap_or(config.bpm)
		.floor()
		.clamp(60.0, 200.0);
	let requested_duration = composition.duration.unwrap_or(16.0).max(MIN_SECONDS);
	let bar_seconds = 240.0 / bpm;
	let min_bars = (MIN_SECONDS / bar_seconds).ceil().max(1.0) as usize;
	let requested_bars = (requested_duration / bar_seconds)
		.round()
		.max(min_bars as f64);
	if requested_bars > MAX_BARS as f64 {
		return Err(format!(
			"composition.duration requires more than {MAX_BARS} bars"
		));
	}
	let bars = requested_bars as usize;
	let key = composition
		.key
		.as_deref()
		.unwrap_or("random")
		.trim()
		.to_uppercase();
	let root = if key == "RANDOM" {
		(style_rng.next() * KEY_NAMES.len() as f64).floor() as usize
	} else {
		KEY_NAMES
			.iter()
			.position(|name| *name == key)
			.ok_or_else(|| format!("unknown composition.key '{key}'"))?
	};
	let mode_value = composition
		.mode
		.as_deref()
		.unwrap_or("auto")
		.trim()
		.to_lowercase();
	let mode = if mode_value == "auto" {
		config.mode.to_string()
	} else if [
		"major",
		"minor",
		"pentatonic",
		"harmonic_minor",
		"dorian",
		"phrygian",
		"chromatic",
	]
	.contains(&mode_value.as_str())
	{
		mode_value
	} else {
		return Err(format!("unknown composition.mode '{mode_value}'"));
	};
	let progression = if let Some(values) = &composition.progression {
		if values.is_empty() || values.iter().any(|value| value.trim().is_empty()) {
			return Err("composition.progression must not be empty".to_string());
		}
		values
			.iter()
			.enumerate()
			.map(|(index, value)| {
				roman_degree(value).ok_or_else(|| {
					format!("unknown composition.progression[{index}] chord '{value}'")
				})
			})
			.collect::<Result<Vec<_>, _>>()?
	} else {
		config.progression.to_vec()
	};
	let structure_values = composition
		.structure
		.as_ref()
		.cloned()
		.unwrap_or_else(|| vec!["A".into(), "A".into(), "B".into(), "A".into()]);
	if structure_values.is_empty() || structure_values.iter().any(|value| value.trim().is_empty()) {
		return Err("composition.structure must not be empty".to_string());
	}
	let structure = structure_values
		.into_iter()
		.map(|value| value.trim().to_uppercase())
		.collect::<Vec<String>>();
	let instruments = definition.instruments.as_ref();
	range(
		arrangement.and_then(|value| value.drum_gain),
		"arrangement.drumGain",
		0.0,
		8.0,
	)?;
	let audio = definition.effects.as_ref().or(definition.audio.as_ref());
	if let Some(audio) = audio {
		range(audio.volume, "effects.volume", 0.0, 8.0)?;
		range(audio.reverb, "effects.reverb", 0.0, 1.0)?;
		range(audio.delay, "effects.delay", 0.0, 1.0)?;
		range(audio.chorus, "effects.chorus", 0.0, 1.0)?;
		range(audio.distortion, "effects.distortion", 0.0, 1.0)?;
		range(audio.bit_crush, "effects.bitCrush", 0.0, 1.0)?;
		range(audio.low_pass, "effects.lowPass", 0.0, 1.0)?;
	}
	let effects = Effects {
		volume: audio.and_then(|value| value.volume).unwrap_or(1.0) as f32,
		stereo: audio.and_then(|value| value.stereo).unwrap_or(true),
		reverb: clamp01(
			audio
				.and_then(|value| value.reverb)
				.unwrap_or(config.reverb),
		) as f32,
		delay: clamp01(audio.and_then(|value| value.delay).unwrap_or(config.delay)) as f32,
		chorus: clamp01(
			audio
				.and_then(|value| value.chorus)
				.unwrap_or(config.chorus),
		) as f32,
		distortion: clamp01(
			audio
				.and_then(|value| value.distortion)
				.unwrap_or(config.distortion),
		) as f32,
		bit_crush: clamp01(audio.and_then(|value| value.bit_crush).unwrap_or(0.0)) as f32,
		low_pass: clamp01(audio.and_then(|value| value.low_pass).unwrap_or(0.0)) as f32,
	};
	let lead = resolve_melodic_voice(
		instruments.and_then(|value| value.lead.as_ref()),
		"lead",
		config.lead,
	)?;
	let bass = resolve_melodic_voice(
		instruments.and_then(|value| value.bass.as_ref()),
		"bass",
		config.bass,
	)?;
	let harmony = resolve_melodic_voice(
		instruments.and_then(|value| value.harmony.as_ref()),
		"harmony",
		config.harmony,
	)?;
	let drums = resolve_drum_voice(instruments.and_then(|value| value.drums.as_ref()), &style)?;
	Ok(ResolvedComposition {
		style,
		seed,
		bpm,
		bars,
		key: KEY_NAMES[root].to_string(),
		root: root as i32,
		mode,
		progression,
		structure,
		bars_per_section: arrangement
			.and_then(|value| value.bars_per_section)
			.unwrap_or(2.0)
			.floor()
			.clamp(1.0, 8.0) as usize,
		melody_complexity: clamp01(
			arrangement
				.and_then(|value| value.melody_complexity)
				.unwrap_or(0.55),
		),
		rhythm_complexity: clamp01(
			arrangement
				.and_then(|value| value.rhythm_complexity)
				.unwrap_or(0.45),
		),
		variation: clamp01(
			arrangement
				.and_then(|value| value.variation)
				.unwrap_or(0.25),
		),
		intensity: clamp01(arrangement.and_then(|value| value.intensity).unwrap_or(0.6)),
		lead,
		bass,
		harmony,
		drums,
		drum_gain: arrangement
			.and_then(|value| value.drum_gain)
			.unwrap_or(if drums.is_builtin() {
				1.0
			} else {
				match config.groove {
					Groove::JazzHop => 8.0,
					Groove::HipHop => 6.0,
					Groove::Standard => 1.0,
				}
			}),
		effects,
	})
}

fn step_seconds(options: &ResolvedComposition) -> f64 {
	60.0 / options.bpm / 4.0
}

fn note_at_step(
	notes: &mut Vec<Note>,
	options: &ResolvedComposition,
	config: &StyleConfig,
	key: i32,
	step: usize,
	span: usize,
	velocity: f64,
) {
	let seconds = step_seconds(options);
	let swing = if step % 2 == 1 {
		seconds * config.swing * 0.46
	} else {
		0.0
	};
	let start = step as f64 * seconds + swing;
	let duration = span as f64 * seconds * 0.92;
	notes.push(Note {
		key: key.clamp(0, 127),
		velocity: (clamp01(velocity) * 127.0).round().clamp(1.0, 127.0) as i32,
		start,
		end: (start + duration).min(options.bars as f64 * 16.0 * seconds),
	});
}

fn drum_velocity(
	config: &StyleConfig,
	voice: Stem,
	step: usize,
	bar: usize,
	intensity: f64,
	rhythm_complexity: f64,
) -> f64 {
	const HIP_KICK: [f64; 16] = [
		1.0, 0.0, 0.0, 0.32, 0.0, 0.0, 0.72, 0.0, 0.92, 0.0, 0.0, 0.35, 0.0, 0.58, 0.0, 0.0,
	];
	const HIP_SNARE: [f64; 16] = [
		0.0, 0.0, 0.0, 0.12, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.14, 0.0, 0.94, 0.0, 0.0, 0.10,
	];
	const HIP_HAT: [f64; 16] = [
		0.72, 0.32, 0.58, 0.28, 0.68, 0.34, 0.54, 0.30, 0.74, 0.32, 0.60, 0.28, 0.70, 0.36, 0.52,
		0.30,
	];
	const JAZZ_KICK: [f64; 16] = [
		0.98, 0.0, 0.0, 0.38, 0.0, 0.20, 0.66, 0.0, 0.82, 0.0, 0.32, 0.0, 0.0, 0.54, 0.0, 0.0,
	];
	const JAZZ_SNARE: [f64; 16] = [
		0.0, 0.0, 0.14, 0.0, 1.0, 0.0, 0.0, 0.18, 0.0, 0.10, 0.0, 0.0, 0.96, 0.0, 0.15, 0.0,
	];
	const JAZZ_HAT: [f64; 16] = [
		0.64, 0.24, 0.52, 0.22, 0.60, 0.26, 0.48, 0.24, 0.66, 0.24, 0.54, 0.22, 0.62, 0.28, 0.50,
		0.24,
	];
	if config.groove == Groove::Standard {
		return match voice {
			Stem::Bass => {
				if step == 0 || step == 8 {
					1.0
				} else if intensity > 0.78 && (step == 4 || step == 12) {
					0.72
				} else {
					0.0
				}
			}
			Stem::Melody => {
				if step == 4 || step == 12 {
					1.0
				} else {
					0.0
				}
			}
			Stem::Harmony => {
				let stride = if rhythm_complexity > 0.70 {
					1
				} else {
					config.hat_stride
				};
				if step % stride == 0 {
					if step % 4 == 0 {
						0.72
					} else {
						0.48
					}
				} else {
					0.0
				}
			}
			Stem::Drums => {
				if step == 14 && intensity > 0.48 {
					0.7
				} else {
					0.0
				}
			}
		};
	}
	let mut velocity = match (config.groove, voice) {
		(Groove::HipHop, Stem::Bass) => HIP_KICK[step],
		(Groove::HipHop, Stem::Melody) => HIP_SNARE[step],
		(Groove::HipHop, Stem::Harmony) => HIP_HAT[step],
		(Groove::HipHop, Stem::Drums) => {
			if step == 14 {
				0.52
			} else {
				0.0
			}
		}
		(Groove::JazzHop, Stem::Bass) => JAZZ_KICK[step],
		(Groove::JazzHop, Stem::Melody) => JAZZ_SNARE[step],
		(Groove::JazzHop, Stem::Harmony) => JAZZ_HAT[step],
		(Groove::JazzHop, Stem::Drums) => {
			if step == 14 && bar % 2 == 1 {
				0.42
			} else {
				0.0
			}
		}
		_ => 0.0,
	};
	if voice == Stem::Bass && step == 15 && bar % 4 == 3 {
		velocity = if config.groove == Groove::HipHop {
			0.42
		} else {
			0.34
		};
	}
	if config.groove == Groove::HipHop && voice == Stem::Harmony && step == 15 && bar % 2 == 1 {
		velocity = 0.58;
	}
	if config.groove == Groove::JazzHop && voice == Stem::Melody && step == 7 && bar % 2 == 1 {
		velocity = 0.12;
	}
	velocity * (0.72 + intensity * 0.36)
}

#[allow(dead_code)]
fn build_procedural_song_modern(options: &ResolvedComposition, seed_offset: i64) -> Song {
	let config = style_config(&options.style);
	let all_builtin = [options.lead, options.bass, options.harmony, options.drums]
		.into_iter()
		.all(TrackVoice::is_builtin);
	let builtin_mix_scale = if all_builtin { 1.0 } else { 0.72 };
	let notes_in_scale = scale(&options.mode);
	let root_note = 48 + options.root;
	let mut melody = Vec::new();
	let mut bass = Vec::new();
	let mut harmony = Vec::new();
	let mut drums = Vec::new();
	let chord_choices = [0, 2, 4, 7];
	let melody_span = if options.rhythm_complexity > 0.72 {
		1
	} else {
		config.melody_span
	};
	let density = clamp01(config.melody_density * (0.55 + options.melody_complexity * 0.65));
	for bar in 0..options.bars {
		let section_index = (bar / options.bars_per_section) % options.structure.len();
		let section = &options.structure[section_index];
		let bar_in_section = bar % options.bars_per_section;
		let mut rng = Rng::new(section_seed(
			options.seed + seed_offset,
			section,
			bar_in_section,
			options.variation,
		));
		let section_offset = section
			.as_bytes()
			.first()
			.map(|value| value.saturating_sub(b'A') as usize)
			.unwrap_or(0);
		let progression_index = (bar_in_section + section_offset) % options.progression.len();
		let chord_degree = options.progression[progression_index];
		let chord_root = scale_note(root_note, notes_in_scale, chord_degree);
		let bar_start = bar * STEPS_PER_BAR;

		let arp_steps: &[usize] = if config.groove == Groove::JazzHop {
			&[0, 3, 6, 10, 14]
		} else {
			&[0, 2, 4, 6, 8, 10, 12, 14]
		};
		for &local_step in arp_steps {
			if config.groove != Groove::JazzHop && options.intensity <= 0.25 && local_step % 2 != 0
			{
				continue;
			}
			let arp_tone = [0, 2, 4, 2][local_step % 4];
			note_at_step(
				&mut harmony,
				options,
				&config,
				scale_note(root_note + 12, notes_in_scale, chord_degree + arp_tone),
				bar_start + local_step,
				if config.groove == Groove::JazzHop {
					2
				} else {
					1
				},
				0.52 + options.intensity * 0.18,
			);
		}
		let chord_steps = if config.groove == Groove::JazzHop {
			vec![0, 8]
		} else {
			vec![0]
		};
		for chord_step in chord_steps {
			let chord_span = if config.groove == Groove::JazzHop {
				7
			} else {
				15
			};
			let third = if options.mode == "major" { 4 } else { 3 };
			let seventh = if options.mode == "major" { 11 } else { 10 };
			for (offset, velocity) in [(0, 0.52), (third, 0.42), (7, 0.40)] {
				note_at_step(
					&mut harmony,
					options,
					&config,
					chord_root + 12 + offset,
					bar_start + chord_step,
					chord_span,
					velocity,
				);
			}
			if config.jazz_voicing {
				note_at_step(
					&mut harmony,
					options,
					&config,
					chord_root + 12 + seventh,
					bar_start + chord_step,
					chord_span,
					0.36,
				);
			}
		}

		if config.groove == Groove::Standard {
			for local_step in (0..STEPS_PER_BAR).step_by(4) {
				let moving = options.intensity > 0.58 && local_step == 12;
				note_at_step(
					&mut bass,
					options,
					&config,
					scale_note(
						root_note - 12,
						notes_in_scale,
						chord_degree + if moving { 4 } else { 0 },
					),
					bar_start + local_step,
					4,
					0.76,
				);
			}
		} else {
			let starts = if config.groove == Groove::HipHop {
				[0, 6, 10, 14]
			} else {
				[0, 5, 10, 14]
			};
			for (index, local_step) in starts.into_iter().enumerate() {
				let degree = chord_degree
					+ if index == 1 {
						4
					} else if index == 3 {
						1
					} else {
						0
					};
				note_at_step(
					&mut bass,
					options,
					&config,
					scale_note(root_note - 12, notes_in_scale, degree),
					bar_start + local_step,
					[3, 2, 2, 2][index],
					0.84,
				);
			}
		}

		for local_step in (0..STEPS_PER_BAR).step_by(melody_span) {
			if rng.next() > density {
				continue;
			}
			let mut choice =
				chord_choices[(rng.next() * chord_choices.len() as f64).floor() as usize];
			if options.melody_complexity > 0.65 && rng.next() < options.melody_complexity * 0.35 {
				choice += 1;
			}
			let mut key = scale_note(root_note + 12, notes_in_scale, chord_degree + choice);
			if rng.next() < options.melody_complexity * 0.30 {
				key += 12;
			}
			if options.variation > 0.0 && section != "A" && rng.next() < options.variation * 0.5 {
				key += notes_in_scale[1];
			}
			note_at_step(
				&mut melody,
				options,
				&config,
				key,
				bar_start + local_step,
				melody_span,
				0.68 + rng.next() * 0.22,
			);
		}

		for local_step in 0..STEPS_PER_BAR {
			for (voice, key, span) in [
				(Stem::Bass, 36, 2),
				(Stem::Melody, 38, 2),
				(Stem::Harmony, 42, 1),
				(Stem::Drums, 46, 3),
			] {
				let velocity = drum_velocity(
					&config,
					voice,
					local_step,
					bar,
					options.intensity,
					options.rhythm_complexity,
				);
				if velocity > 0.0 {
					let velocity_scale = match voice {
						Stem::Bass => 110.0,
						Stem::Melody => 105.0,
						Stem::Harmony => 86.0,
						Stem::Drums => 90.0,
					};
					note_at_step(
						&mut drums,
						options,
						&config,
						key,
						bar_start + local_step,
						span,
						(clamp01(velocity) * velocity_scale).floor() / 127.0,
					);
					if voice == Stem::Melody
						&& matches!(config.groove, Groove::HipHop | Groove::JazzHop)
						&& velocity > 0.7 && options.intensity > 0.62
					{
						note_at_step(
							&mut drums,
							options,
							&config,
							39,
							bar_start + local_step,
							1,
							62.0 / 127.0,
						);
					}
				}
			}
		}
		if config.groove == Groove::Standard && options.intensity > 0.72 {
			note_at_step(&mut drums, options, &config, 49, bar_start, 2, 0.52);
		}
		if config.groove == Groove::Standard && options.rhythm_complexity > 0.68 {
			for (index, key) in [45, 47, 50].into_iter().enumerate() {
				note_at_step(
					&mut drums,
					options,
					&config,
					key,
					bar_start + 13 + index,
					1,
					0.52,
				);
			}
		}
	}
	let duration = options.bars as f64 * 240.0 / options.bpm;
	Song {
		bpm: options.bpm,
		beats_per_bar: 4,
		beat_unit: 4,
		bars: options.bars,
		duration,
		master_gain: if all_builtin { 0.72 } else { 1.0 },
		tempo_changes: Vec::new(),
		tracks: vec![
			Track {
				program: options.lead.program(),
				bank: options.lead.bank(),
				percussion: options.lead.percussion(),
				builtin: options.lead.builtin(),
				builtin_drum_level: 1.0,
				volume: if options.lead.is_builtin() {
					config.melody_mix * 2.0 * builtin_mix_scale
				} else {
					(0.62 + options.intensity * 0.16) as f32
				},
				render_gain: 1.0,
				pan: if options.lead.is_builtin() {
					0.18
				} else {
					-0.16
				},
				chorus_direction: 1.0,
				role: Stem::Melody,
				notes: melody,
				pedals: Vec::new(),
			},
			Track {
				program: options.bass.program(),
				bank: options.bass.bank(),
				percussion: options.bass.percussion(),
				builtin: options.bass.builtin(),
				builtin_drum_level: 1.0,
				volume: if options.bass.is_builtin() {
					config.bass_mix * 2.0 * builtin_mix_scale
				} else {
					(0.72 + options.intensity * 0.18) as f32
				},
				render_gain: 1.0,
				pan: 0.0,
				chorus_direction: 0.0,
				role: Stem::Bass,
				notes: bass,
				pedals: Vec::new(),
			},
			Track {
				program: options.harmony.program(),
				bank: options.harmony.bank(),
				percussion: options.harmony.percussion(),
				builtin: options.harmony.builtin(),
				builtin_drum_level: 1.0,
				volume: if options.harmony.is_builtin() {
					config.harmony_mix * 2.0 * builtin_mix_scale
				} else {
					(0.50 + options.intensity * 0.16) as f32
				},
				render_gain: 1.0,
				pan: if options.harmony.is_builtin() {
					-0.18
				} else {
					0.16
				},
				chorus_direction: -1.0,
				role: Stem::Harmony,
				notes: harmony,
				pedals: Vec::new(),
			},
			Track {
				program: options.drums.program(),
				bank: options.drums.bank(),
				percussion: options.drums.percussion(),
				builtin: options.drums.builtin(),
				builtin_drum_level: (0.32 + options.intensity * 0.85) as f32,
				volume: if options.drums.is_builtin() {
					2.0 * builtin_mix_scale
				} else {
					1.0
				},
				render_gain: options.drum_gain as f32,
				pan: if options.drums.is_builtin() {
					-0.02
				} else {
					0.0
				},
				chorus_direction: 0.0,
				role: Stem::Drums,
				notes: drums,
				pedals: Vec::new(),
			},
		],
	}
}

struct LegacyArrangement {
	melody_notes: Vec<i32>,
	melody_ages: Vec<usize>,
	bass_notes: Vec<i32>,
	bass_ages: Vec<usize>,
	arp_notes: Vec<i32>,
	chord_roots: Vec<i32>,
}

fn fill_legacy_note(notes: &mut [i32], ages: &mut [usize], start: usize, span: usize, note: i32) {
	let end = (start + span).min(notes.len());
	for index in start..end {
		notes[index] = note;
		ages[index] = index - start;
	}
}

fn build_legacy_arrangement(options: &ResolvedComposition, seed_offset: i64) -> LegacyArrangement {
	let total_steps = options.bars * STEPS_PER_BAR;
	let root_note = 48 + options.root;
	let notes_in_scale = scale(&options.mode);
	let config = style_config(&options.style);
	let melody_span = if options.rhythm_complexity > 0.72 {
		1
	} else {
		config.melody_span
	};
	let density = clamp01(config.melody_density * (0.55 + options.melody_complexity * 0.65));
	let mut result = LegacyArrangement {
		melody_notes: vec![-1; total_steps],
		melody_ages: vec![0; total_steps],
		bass_notes: vec![-1; total_steps],
		bass_ages: vec![0; total_steps],
		arp_notes: vec![-1; total_steps],
		chord_roots: vec![root_note; total_steps],
	};
	let chord_choices = [0, 2, 4, 7];
	for bar in 0..options.bars {
		let section_index = (bar / options.bars_per_section) % options.structure.len();
		let section = &options.structure[section_index];
		let bar_in_section = bar % options.bars_per_section;
		let mut rng = Rng::new(section_seed(
			options.seed + seed_offset,
			section,
			bar_in_section,
			options.variation,
		));
		let section_offset = section
			.as_bytes()
			.first()
			.map(|value| value.saturating_sub(b'A') as usize)
			.unwrap_or(0);
		let progression_index = (bar_in_section + section_offset) % options.progression.len();
		let chord_degree = options.progression[progression_index];
		let chord_root = scale_note(root_note, notes_in_scale, chord_degree);
		let bar_start = bar * STEPS_PER_BAR;
		for local_step in 0..STEPS_PER_BAR {
			let step = bar_start + local_step;
			result.chord_roots[step] = chord_root;
			let place_arp = if config.groove == Groove::JazzHop {
				[0, 3, 6, 10, 14].contains(&local_step)
			} else {
				options.intensity > 0.25 || local_step % 2 == 0
			};
			if place_arp {
				let arp_tone = [0, 2, 4, 2][local_step % 4];
				result.arp_notes[step] =
					scale_note(root_note + 12, notes_in_scale, chord_degree + arp_tone);
			}
		}
		if config.groove == Groove::Standard {
			for local_step in (0..STEPS_PER_BAR).step_by(4) {
				let moving = options.intensity > 0.58 && local_step == 12;
				fill_legacy_note(
					&mut result.bass_notes,
					&mut result.bass_ages,
					bar_start + local_step,
					4,
					scale_note(
						root_note - 12,
						notes_in_scale,
						chord_degree + if moving { 4 } else { 0 },
					),
				);
			}
		} else {
			let starts = if config.groove == Groove::HipHop {
				[0, 6, 10, 14]
			} else {
				[0, 5, 10, 14]
			};
			for (index, local_step) in starts.into_iter().enumerate() {
				let degree = chord_degree
					+ if index == 1 {
						4
					} else if index == 3 {
						1
					} else {
						0
					};
				fill_legacy_note(
					&mut result.bass_notes,
					&mut result.bass_ages,
					bar_start + local_step,
					[3, 2, 2, 2][index],
					scale_note(root_note - 12, notes_in_scale, degree),
				);
			}
		}
		for local_step in (0..STEPS_PER_BAR).step_by(melody_span) {
			if rng.next() > density {
				continue;
			}
			let mut choice =
				chord_choices[(rng.next() * chord_choices.len() as f64).floor() as usize];
			if options.melody_complexity > 0.65 && rng.next() < options.melody_complexity * 0.35 {
				choice += 1;
			}
			let mut note = scale_note(root_note + 12, notes_in_scale, chord_degree + choice);
			if rng.next() < options.melody_complexity * 0.30 {
				note += 12;
			}
			if options.variation > 0.0 && section != "A" && rng.next() < options.variation * 0.5 {
				note += notes_in_scale[1];
			}
			fill_legacy_note(
				&mut result.melody_notes,
				&mut result.melody_ages,
				bar_start + local_step,
				melody_span,
				note,
			);
		}
	}
	result
}

fn push_timed_note(
	notes: &mut Vec<Note>,
	key: i32,
	velocity: i32,
	start: f64,
	duration: f64,
	total_duration: f64,
) {
	notes.push(Note {
		key: key.clamp(0, 127),
		velocity: velocity.clamp(1, 127),
		start,
		end: (start + duration).min(total_duration),
	});
}

fn push_sustained_legacy_notes(
	target: &mut Vec<Note>,
	notes: &[i32],
	ages: &[usize],
	step_seconds: f64,
	velocity: i32,
	total_duration: f64,
) {
	for step in 0..notes.len() {
		if notes[step] < 0 || ages[step] != 0 {
			continue;
		}
		let mut span = 1;
		while step + span < notes.len()
			&& notes[step + span] == notes[step]
			&& ages[step + span] == span
		{
			span += 1;
		}
		push_timed_note(
			target,
			notes[step],
			velocity,
			step as f64 * step_seconds,
			span as f64 * step_seconds,
			total_duration,
		);
	}
}

/// Converts the original Music.ts arrangement into timed notes. The same timeline is used by
/// the SoundFont, built-in, and mixed renderers; only the per-track voice implementation differs.
fn build_procedural_song(options: &ResolvedComposition, seed_offset: i64) -> Song {
	let config = style_config(&options.style);
	let arrangement = build_legacy_arrangement(options, seed_offset);
	let step_seconds = step_seconds(options);
	let duration = options.bars as f64 * STEPS_PER_BAR as f64 * step_seconds;
	let all_builtin = [options.lead, options.bass, options.harmony, options.drums]
		.into_iter()
		.all(TrackVoice::is_builtin);
	let builtin_mix_scale = if all_builtin { 1.0 } else { 0.72 };
	let mut melody = Vec::new();
	let mut bass = Vec::new();
	let mut harmony = Vec::new();
	let mut drums = Vec::new();
	push_sustained_legacy_notes(
		&mut melody,
		&arrangement.melody_notes,
		&arrangement.melody_ages,
		step_seconds,
		92,
		duration,
	);
	push_sustained_legacy_notes(
		&mut bass,
		&arrangement.bass_notes,
		&arrangement.bass_ages,
		step_seconds,
		84,
		duration,
	);
	for (step, &note) in arrangement.arp_notes.iter().enumerate() {
		if note >= 0 {
			push_timed_note(
				&mut harmony,
				note,
				66,
				step as f64 * step_seconds,
				step_seconds * 0.72,
				duration,
			);
		}
	}
	for bar in 0..options.bars {
		let step = bar * STEPS_PER_BAR;
		let root = arrangement.chord_roots[step] + 12;
		let chord_duration = STEPS_PER_BAR as f64 * step_seconds * 0.96;
		push_timed_note(
			&mut harmony,
			root,
			54,
			step as f64 * step_seconds,
			chord_duration,
			duration,
		);
		if config.jazz_voicing {
			let third = if options.mode == "major" { 4 } else { 3 };
			let seventh = if options.mode == "major" { 11 } else { 10 };
			push_timed_note(
				&mut harmony,
				root + third,
				44,
				step as f64 * step_seconds,
				chord_duration,
				duration,
			);
			push_timed_note(
				&mut harmony,
				root + seventh,
				38,
				step as f64 * step_seconds,
				chord_duration,
				duration,
			);
		}
	}
	for step in 0..options.bars * STEPS_PER_BAR {
		let local_step = step % STEPS_PER_BAR;
		let bar = step / STEPS_PER_BAR;
		let swing = if local_step % 2 == 1 {
			step_seconds * config.swing * 0.46
		} else {
			0.0
		};
		let start = step as f64 * step_seconds + swing;
		for (role, key, note_duration, velocity_scale) in [
			(Stem::Bass, 36, step_seconds * 0.5, 110.0),
			(Stem::Melody, 38, step_seconds * 0.5, 105.0),
			(Stem::Harmony, 42, step_seconds * 0.25, 86.0),
			(Stem::Drums, 46, step_seconds * 0.75, 90.0),
		] {
			let velocity = drum_velocity(
				&config,
				role,
				local_step,
				bar,
				options.intensity,
				options.rhythm_complexity,
			);
			if velocity > 0.0 {
				push_timed_note(
					&mut drums,
					key,
					(clamp01(velocity) * velocity_scale).floor() as i32,
					start,
					note_duration,
					duration,
				);
				if role == Stem::Melody
					&& matches!(config.groove, Groove::HipHop | Groove::JazzHop)
					&& velocity > 0.7
					&& options.intensity > 0.62
				{
					push_timed_note(&mut drums, 39, 62, start, step_seconds * 0.375, duration);
				}
			}
		}
		if config.groove == Groove::Standard {
			if local_step % 4 == 2 && options.intensity > 0.82 {
				push_timed_note(&mut drums, 51, 48, start, step_seconds * 0.5, duration);
			}
			if local_step >= 13 && options.rhythm_complexity > 0.68 {
				push_timed_note(
					&mut drums,
					45 - (local_step as i32 - 13) * 2,
					70,
					start,
					step_seconds * 70.0 / 120.0,
					duration,
				);
			}
			if step % (options.bars_per_section * STEPS_PER_BAR) == 0 && options.intensity > 0.72 {
				push_timed_note(&mut drums, 49, 72, start, step_seconds, duration);
			}
		}
	}
	Song {
		bpm: options.bpm,
		beats_per_bar: 4,
		beat_unit: 4,
		bars: options.bars,
		duration,
		master_gain: if all_builtin { 0.72 } else { 1.0 },
		tempo_changes: Vec::new(),
		tracks: vec![
			Track {
				program: options.lead.program(),
				bank: options.lead.bank(),
				percussion: options.lead.percussion(),
				builtin: options.lead.builtin(),
				builtin_drum_level: 1.0,
				volume: if options.lead.is_builtin() {
					config.melody_mix * 2.0 * builtin_mix_scale
				} else {
					(0.62 + options.intensity * 0.16) as f32
				},
				render_gain: 1.0,
				pan: if options.lead.is_builtin() {
					0.18
				} else {
					-0.16
				},
				chorus_direction: 1.0,
				role: Stem::Melody,
				notes: melody,
				pedals: Vec::new(),
			},
			Track {
				program: options.bass.program(),
				bank: options.bass.bank(),
				percussion: options.bass.percussion(),
				builtin: options.bass.builtin(),
				builtin_drum_level: 1.0,
				volume: if options.bass.is_builtin() {
					config.bass_mix * 2.0 * builtin_mix_scale
				} else {
					(0.72 + options.intensity * 0.18) as f32
				},
				render_gain: 1.0,
				pan: 0.0,
				chorus_direction: 0.0,
				role: Stem::Bass,
				notes: bass,
				pedals: Vec::new(),
			},
			Track {
				program: options.harmony.program(),
				bank: options.harmony.bank(),
				percussion: options.harmony.percussion(),
				builtin: options.harmony.builtin(),
				builtin_drum_level: 1.0,
				volume: if options.harmony.is_builtin() {
					config.harmony_mix * 2.0 * builtin_mix_scale
				} else {
					(0.50 + options.intensity * 0.16) as f32
				},
				render_gain: 1.0,
				pan: if options.harmony.is_builtin() {
					-0.18
				} else {
					0.16
				},
				chorus_direction: -1.0,
				role: Stem::Harmony,
				notes: harmony,
				pedals: Vec::new(),
			},
			Track {
				program: options.drums.program(),
				bank: options.drums.bank(),
				percussion: options.drums.percussion(),
				builtin: options.drums.builtin(),
				builtin_drum_level: (0.32 + options.intensity * 0.85) as f32,
				volume: if options.drums.is_builtin() {
					2.0 * builtin_mix_scale
				} else {
					1.0
				},
				render_gain: options.drum_gain as f32,
				pan: if options.drums.is_builtin() {
					-0.02
				} else {
					0.0
				},
				chorus_direction: 0.0,
				role: Stem::Drums,
				notes: drums,
				pedals: Vec::new(),
			},
		],
	}
}

fn legacy_frequency(note: i32) -> f64 {
	440.0 * 2.0f64.powf((note as f64 - 69.0) / 12.0)
}

fn legacy_wave(phase: f64, instrument: BuiltinInstrument) -> f64 {
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
		BuiltinInstrument::Organ => {
			(phase * std::f64::consts::TAU).sin() * 0.72
				+ (phase * std::f64::consts::TAU * 3.0).sin() * 0.28
		}
		BuiltinInstrument::Piano => {
			(phase * std::f64::consts::TAU).sin() * 0.74
				+ (phase * std::f64::consts::TAU * 2.0).sin() * 0.18
				+ (phase * std::f64::consts::TAU * 3.0).sin() * 0.06
				+ (phase * std::f64::consts::TAU * 4.0).sin() * 0.02
		}
		BuiltinInstrument::Bell => {
			(phase * std::f64::consts::TAU).sin() * 0.68
				+ (phase * std::f64::consts::TAU * 4.0).sin() * 0.32
		}
		BuiltinInstrument::Fm => (phase * std::f64::consts::TAU
			+ (phase * std::f64::consts::TAU * 3.0).sin() * 2.2)
			.sin(),
		BuiltinInstrument::Pad => {
			(phase * std::f64::consts::TAU).sin() * 0.65
				+ (if phase < 0.5 {
					phase * 4.0 - 1.0
				} else {
					3.0 - phase * 4.0
				}) * 0.35
		}
		BuiltinInstrument::Sub => {
			(phase * std::f64::consts::TAU).sin() * 0.85
				+ (phase * std::f64::consts::TAU * 2.0).sin() * 0.15
		}
		BuiltinInstrument::Guitar => {
			(if phase < 0.5 {
				phase * 4.0 - 1.0
			} else {
				3.0 - phase * 4.0
			}) * 0.72 + (phase * std::f64::consts::TAU * 3.0).sin() * 0.28
		}
		BuiltinInstrument::Strings => {
			(1.0 - phase * 2.0) * 0.55 + (phase * std::f64::consts::TAU).sin() * 0.45
		}
		_ => (phase * std::f64::consts::TAU).sin(),
	}
}

fn legacy_envelope(
	time: f64,
	length: f64,
	attack: f64,
	release: f64,
	instrument: BuiltinInstrument,
) -> f64 {
	if time < 0.0 || time >= length {
		return 0.0;
	}
	let mut value = 1.0;
	if time < attack {
		value = time / attack;
	}
	let remaining = length - time;
	if remaining < release {
		value *= remaining / release;
	}
	if matches!(
		instrument,
		BuiltinInstrument::Pluck
			| BuiltinInstrument::Bell
			| BuiltinInstrument::Guitar
			| BuiltinInstrument::Piano
	) {
		let decay = if instrument == BuiltinInstrument::Bell {
			3.5
		} else if instrument == BuiltinInstrument::Piano {
			1.8
		} else {
			8.0
		};
		value *= 1.0 / (1.0 + time * decay);
	}
	clamp01(value)
}

fn uses_legacy_builtin_renderer(options: &ResolvedComposition) -> bool {
	let expected_kit = default_builtin_drum_kit(&options.style);
	matches!(options.lead, TrackVoice::Builtin(_))
		&& matches!(options.bass, TrackVoice::Builtin(_))
		&& matches!(options.harmony, TrackVoice::Builtin(_))
		&& matches!(options.drums, TrackVoice::Builtin(BuiltinInstrument::Drums(kit)) if kit == expected_kit)
}

fn melodic_builtin(voice: TrackVoice) -> BuiltinInstrument {
	match voice {
		TrackVoice::Builtin(instrument) => instrument,
		TrackVoice::SoundFont(_) => unreachable!("legacy renderer only accepts built-in voices"),
	}
}

fn render_legacy_procedural(
	options: &ResolvedComposition,
	output: &Path,
	stem_base: &Path,
	sample_rate: i32,
	stems: bool,
	progress: Option<ProgressCallback>,
	user_data: *mut c_void,
	progress_start: f32,
	progress_end: f32,
) -> Result<(RenderStats, Vec<PathBuf>), String> {
	let arrangement = build_legacy_arrangement(options, 0);
	let config = style_config(&options.style);
	let lead = melodic_builtin(options.lead);
	let bass_instrument = melodic_builtin(options.bass);
	let harmony_instrument = melodic_builtin(options.harmony);
	let channels = if options.effects.stereo { 2 } else { 1 };
	let step_seconds = 60.0 / options.bpm / 4.0;
	let duration = options.bars as f64 * STEPS_PER_BAR as f64 * step_seconds;
	let total_frames = (duration * sample_rate as f64).floor() as u64;
	let mut main_writer = WavWriter::create(output, sample_rate, channels, total_frames)?;
	let mut stem_writers = if stems {
		let mut result = HashMap::new();
		for role in [Stem::Melody, Stem::Bass, Stem::Harmony, Stem::Drums] {
			let path = sibling_path(stem_base, role.suffix(), ".wav");
			result.insert(
				role,
				(
					path.clone(),
					WavWriter::create(&path, sample_rate, channels, total_frames)?,
				),
			);
		}
		result
	} else {
		HashMap::new()
	};
	let mut noise_rng = Rng::new(options.seed + options.bars as i64 * 65_537 + 1);
	let noise = (0..2048)
		.map(|_| noise_rng.next() * 2.0 - 1.0)
		.collect::<Vec<_>>();
	let mut melody_phase = 0.0;
	let mut bass_phase = 0.0;
	let mut arp_phase = 0.0;
	let mut pad_phase = 0.0;
	let mut pad_third_phase = 0.0;
	let mut pad_seventh_phase = 0.0;
	let delay_frames = ((sample_rate as f64 * 60.0 / options.bpm * 0.5).floor() as usize).max(1);
	let reverb_frames = ((sample_rate as f64 * 0.073).floor() as usize).max(1);
	let mut delay_left = vec![0.0; delay_frames];
	let mut delay_right = vec![0.0; delay_frames];
	let mut reverb_left = vec![0.0; reverb_frames];
	let mut reverb_right = vec![0.0; reverb_frames];
	let mut filtered_left = 0.0;
	let mut filtered_right = 0.0;
	let fade_frames = ((sample_rate as f64 * 0.008).floor() as u64).max(1);
	let mut peak = 0.0f32;
	let mut clipping_samples = 0u64;
	let mut last_progress = 0u64;
	for frame in 0..total_frames {
		let time = frame as f64 / sample_rate as f64;
		let step_float = time / step_seconds;
		let step_index = (step_float.floor() as usize).min(arrangement.melody_notes.len() - 1);
		let step_time = (step_float - step_index as f64) * step_seconds;
		let local_step = step_index % STEPS_PER_BAR;
		let mut melody = 0.0;
		let mut bass = 0.0;
		let mut harmony = 0.0;
		let mut drums = 0.0;
		let melody_note = arrangement.melody_notes[step_index];
		if melody_note >= 0 {
			melody_phase =
				(melody_phase + legacy_frequency(melody_note) / sample_rate as f64) % 1.0;
			let note_time = arrangement.melody_ages[step_index] as f64 * step_seconds + step_time;
			let span = if options.rhythm_complexity > 0.72 {
				1
			} else {
				config.melody_span
			};
			let length = span as f64 * step_seconds * (0.72 + options.rhythm_complexity * 0.22);
			melody = legacy_wave(melody_phase, lead)
				* legacy_envelope(note_time, length, 0.004, 0.05f64.min(length * 0.3), lead)
				* config.melody_mix as f64;
		}
		let bass_note = arrangement.bass_notes[step_index];
		if bass_note >= 0 {
			bass_phase = (bass_phase + legacy_frequency(bass_note) / sample_rate as f64) % 1.0;
			let note_time = arrangement.bass_ages[step_index] as f64 * step_seconds + step_time;
			bass = legacy_wave(bass_phase, bass_instrument)
				* legacy_envelope(note_time, step_seconds * 3.75, 0.008, 0.08, bass_instrument)
				* config.bass_mix as f64;
		}
		let arp_note = arrangement.arp_notes[step_index];
		if arp_note >= 0 {
			arp_phase = (arp_phase + legacy_frequency(arp_note) / sample_rate as f64) % 1.0;
			harmony += legacy_wave(arp_phase, harmony_instrument)
				* legacy_envelope(
					step_time,
					step_seconds * 0.72,
					0.003,
					0.035f64.min(step_seconds * 0.25),
					harmony_instrument,
				) * config.harmony_mix as f64;
		}
		let pad_note = arrangement.chord_roots[step_index] + 12;
		let pad_envelope = if harmony_instrument == BuiltinInstrument::Piano {
			legacy_envelope(
				local_step as f64 * step_seconds + step_time,
				STEPS_PER_BAR as f64 * step_seconds * 0.96,
				0.003,
				0.25f64.min(step_seconds * 1.5),
				BuiltinInstrument::Piano,
			)
		} else {
			1.0
		};
		pad_phase = (pad_phase + legacy_frequency(pad_note) / sample_rate as f64) % 1.0;
		harmony +=
			legacy_wave(pad_phase, harmony_instrument) * config.pad_mix as f64 * pad_envelope;
		if config.jazz_voicing {
			let third = if options.mode == "major" { 4 } else { 3 };
			let seventh = if options.mode == "major" { 11 } else { 10 };
			pad_third_phase =
				(pad_third_phase + legacy_frequency(pad_note + third) / sample_rate as f64) % 1.0;
			pad_seventh_phase = (pad_seventh_phase
				+ legacy_frequency(pad_note + seventh) / sample_rate as f64)
				% 1.0;
			harmony += legacy_wave(pad_third_phase, harmony_instrument)
				* config.pad_mix as f64
				* pad_envelope
				* 0.62;
			harmony += legacy_wave(pad_seventh_phase, harmony_instrument)
				* config.pad_mix as f64
				* pad_envelope
				* 0.52;
		}
		let bar = step_index / STEPS_PER_BAR;
		let noise_sample = noise[frame as usize % noise.len()];
		let previous_noise = noise[(frame as usize + noise.len() - 1) % noise.len()];
		let drum_delay = if local_step % 2 == 1 {
			step_seconds * config.swing * 0.46
		} else {
			0.0
		};
		let drum_time = step_time - drum_delay;
		let kick_velocity = drum_velocity(
			&config,
			Stem::Bass,
			local_step,
			bar,
			options.intensity,
			options.rhythm_complexity,
		);
		let snare_velocity = drum_velocity(
			&config,
			Stem::Melody,
			local_step,
			bar,
			options.intensity,
			options.rhythm_complexity,
		);
		let hat_velocity = drum_velocity(
			&config,
			Stem::Harmony,
			local_step,
			bar,
			options.intensity,
			options.rhythm_complexity,
		);
		let open_hat_velocity = drum_velocity(
			&config,
			Stem::Drums,
			local_step,
			bar,
			options.intensity,
			options.rhythm_complexity,
		);
		let mut kick_decay = 0.0;
		if kick_velocity > 0.0 && drum_time >= 0.0 {
			let length = (step_seconds - drum_delay).min(if config.groove == Groove::Standard {
				0.16
			} else {
				0.22
			});
			if drum_time < length {
				kick_decay = 1.0 - drum_time / length;
				let phase = 47.0 * drum_time + 104.0 / 28.0 * (1.0 - (-drum_time * 28.0).exp());
				let body = (std::f64::consts::TAU * phase).sin() * kick_decay * kick_decay;
				let sub = (std::f64::consts::TAU * 47.0 * drum_time).sin() * kick_decay * 0.40;
				let click = (noise_sample - previous_noise) * (-drum_time * 95.0).exp() * 0.28;
				drums += (body + sub + click)
					* config.drum_mix as f64
					* kick_velocity * config.kick_weight as f64
					* 1.08;
			}
		}
		if snare_velocity > 0.0 && drum_time >= 0.0 {
			let length = (step_seconds - drum_delay).min(if config.groove == Groove::Standard {
				0.13
			} else {
				0.18
			});
			if drum_time < length {
				let decay = (1.0 - drum_time / length).powf(1.35);
				let snare_noise = noise_sample - previous_noise * 0.62;
				let body = (std::f64::consts::TAU * 185.0 * drum_time).sin() * 0.30
					+ (std::f64::consts::TAU * 330.0 * drum_time).sin() * 0.12;
				let snap = (noise_sample - previous_noise) * (-drum_time * 55.0).exp() * 0.34;
				drums += (snare_noise * 0.82 + body + snap)
					* decay * config.drum_mix as f64
					* snare_velocity
					* config.snare_weight as f64
					* 0.92;
				if snare_velocity > 0.7 {
					drums += snare_noise
						* (if (drum_time * 42.0) % 1.0 < 0.18 {
							1.0
						} else {
							0.0
						}) * decay * config.drum_mix as f64
						* 0.18;
				}
			}
		}
		if hat_velocity > 0.0 && drum_time >= 0.0 {
			let length = (step_seconds - drum_delay).min(if config.groove == Groove::Standard {
				0.045
			} else {
				0.065
			});
			if drum_time < length {
				drums += (noise_sample - previous_noise)
					* (1.0 - drum_time / length).powi(2)
					* config.drum_mix as f64
					* hat_velocity * 0.34;
			}
		}
		if open_hat_velocity > 0.0 && drum_time >= 0.0 {
			let length = (step_seconds - drum_delay).min(0.14);
			if drum_time < length {
				drums += (noise_sample - previous_noise)
					* (1.0 - drum_time / length)
					* config.drum_mix as f64
					* open_hat_velocity
					* 0.28;
			}
		}
		if config.groove == Groove::Standard && local_step % 4 == 2 && options.intensity > 0.82 {
			let length = step_seconds.min(0.08);
			if step_time < length {
				drums += (std::f64::consts::TAU * 1800.0 * step_time).sin()
					* (1.0 - step_time / length)
					* config.drum_mix as f64
					* 0.09;
			}
		}
		if config.groove == Groove::Standard && local_step >= 13 && options.rhythm_complexity > 0.68
		{
			let length = step_seconds.min(0.10);
			if step_time < length {
				let frequency = 150.0 - (local_step - 13) as f64 * 24.0;
				drums += (std::f64::consts::TAU * frequency * step_time).sin()
					* (1.0 - step_time / length)
					* config.drum_mix as f64
					* 0.26;
			}
		}
		let section_step = step_index % (options.bars_per_section * STEPS_PER_BAR);
		let section_time = section_step as f64 * step_seconds + step_time;
		if config.groove == Groove::Standard && section_time < 0.32 && options.intensity > 0.72 {
			drums += (noise_sample - previous_noise * 0.5)
				* (1.0 - section_time / 0.32)
				* config.drum_mix as f64
				* 0.16;
		}
		let duck = 1.0 - kick_decay * options.intensity * 0.24;
		melody *= duck * (0.72 + options.intensity * 0.42);
		bass *= 0.65 + options.intensity * 0.55;
		harmony *= duck * (0.50 + options.intensity * 0.62);
		drums *= (0.32 + options.intensity * 0.85) * options.drum_gain;
		if config.drum_drive > 1.0 {
			let driven = drums * config.drum_drive as f64
				/ (1.0 + drums.abs() * (config.drum_drive as f64 - 1.0) * 0.82);
			drums = drums * 0.52 + driven * 0.68;
		}
		let chorus_pan =
			(time * std::f64::consts::TAU * 0.35).sin() * options.effects.chorus as f64 * 0.18;
		let melody_left = melody * (0.82 - chorus_pan);
		let melody_right = melody * (1.18 + chorus_pan);
		let bass_left = bass;
		let bass_right = bass;
		let harmony_left = harmony * (1.18 + chorus_pan);
		let harmony_right = harmony * (0.82 - chorus_pan);
		let drums_left = drums * 1.02;
		let drums_right = drums * 0.98;
		let mut left = melody_left + bass_left + harmony_left + drums_left;
		let mut right = melody_right + bass_right + harmony_right + drums_right;
		let delay_pos = frame as usize % delay_frames;
		let reverb_pos = frame as usize % reverb_frames;
		let delayed_left = delay_left[delay_pos];
		let delayed_right = delay_right[delay_pos];
		let reverbed_left = reverb_left[reverb_pos];
		let reverbed_right = reverb_right[reverb_pos];
		delay_left[delay_pos] = left + delayed_right * 0.34;
		delay_right[delay_pos] = right + delayed_left * 0.34;
		reverb_left[reverb_pos] = left + reverbed_right * 0.42;
		reverb_right[reverb_pos] = right + reverbed_left * 0.42;
		left += delayed_left * options.effects.delay as f64
			+ reverbed_left * options.effects.reverb as f64 * 0.45;
		right += delayed_right * options.effects.delay as f64
			+ reverbed_right * options.effects.reverb as f64 * 0.45;
		if options.effects.low_pass > 0.0 {
			let rate = 1.0 - options.effects.low_pass as f64 * 0.94;
			filtered_left += (left - filtered_left) * rate;
			filtered_right += (right - filtered_right) * rate;
			left = filtered_left;
			right = filtered_right;
		} else {
			filtered_left = left;
			filtered_right = right;
		}
		let drive = 1.0 + options.effects.distortion as f64 * 5.0;
		left = left * drive / (1.0 + left.abs() * drive * 0.58);
		right = right * drive / (1.0 + right.abs() * drive * 0.58);
		if options.effects.bit_crush > 0.0 {
			let bits = (16.0 - (options.effects.bit_crush as f64 * 12.0).floor()).max(4.0);
			let levels = 2.0f64.powf(bits - 1.0);
			left = (left * levels + 0.5).floor() / levels;
			right = (right * levels + 0.5).floor() / levels;
		}
		let edge = (frame as f64 / fade_frames as f64)
			.min((total_frames - 1 - frame) as f64 / fade_frames as f64)
			.min(1.0)
			.max(0.0);
		let gain = options.effects.volume as f64 * edge * 0.72;
		left *= gain;
		right *= gain;
		peak = peak.max(left.abs() as f32).max(right.abs() as f32);
		if left.abs() > 1.0 || right.abs() > 1.0 {
			clipping_samples += 1;
		}
		main_writer.write(left as f32, right as f32, channels)?;
		for (role, left, right) in [
			(Stem::Melody, melody_left, melody_right),
			(Stem::Bass, bass_left, bass_right),
			(Stem::Harmony, harmony_left, harmony_right),
			(Stem::Drums, drums_left, drums_right),
		] {
			if let Some((_, writer)) = stem_writers.get_mut(&role) {
				writer.write((left * gain) as f32, (right * gain) as f32, channels)?;
			}
		}
		if frame.saturating_sub(last_progress) >= sample_rate as u64 / 2
			|| frame + 1 == total_frames
		{
			last_progress = frame;
			callback(
				progress,
				user_data,
				progress_start
					+ (progress_end - progress_start) * (frame + 1) as f32 / total_frames as f32,
			);
		}
	}
	let mut bytes_written = main_writer.finish()?;
	let mut paths = vec![output.to_path_buf()];
	for role in [Stem::Melody, Stem::Bass, Stem::Harmony, Stem::Drums] {
		if let Some((path, writer)) = stem_writers.remove(&role) {
			bytes_written += writer.finish()?;
			paths.push(path);
		}
	}
	Ok((
		RenderStats {
			bytes_written,
			peak,
			clipping_samples,
		},
		paths,
	))
}

fn note_name_to_midi(value: &str) -> Option<i32> {
	let value = value.trim();
	let mut chars = value.chars();
	let letter = chars.next()?.to_ascii_uppercase();
	let natural = match letter {
		'C' => 0,
		'D' => 2,
		'E' => 4,
		'F' => 5,
		'G' => 7,
		'A' => 9,
		'B' => 11,
		_ => return None,
	};
	let rest = chars.as_str();
	let (accidental, octave) = if let Some(rest) = rest.strip_prefix('#') {
		(1, rest)
	} else if let Some(rest) = rest.strip_prefix('b') {
		(-1, rest)
	} else {
		(0, rest)
	};
	let octave: i32 = octave.parse().ok()?;
	let key = (octave + 1) * 12 + natural + accidental;
	(0..=127).contains(&key).then_some(key)
}

fn resolve_pitch(value: &Pitch) -> Option<i32> {
	match value {
		Pitch::Number(value)
			if value.is_finite() && value.fract() == 0.0 && (0.0..=127.0).contains(value) =>
		{
			Some(*value as i32)
		}
		Pitch::Name(value) => note_name_to_midi(value),
		_ => None,
	}
}

fn beat_to_seconds(score: &ScoreDefinition, beat_unit: u8, beat: f64) -> f64 {
	let mut seconds = 0.0;
	let mut cursor = 0.0;
	let mut bpm = score.bpm;
	let unit_scale = beat_unit as f64 / 4.0;
	let mut changes = score.tempo_changes.clone();
	changes.sort_by(|a, b| a.beat.total_cmp(&b.beat));
	for change in changes {
		if change.beat > beat {
			break;
		}
		if change.beat > cursor {
			seconds += (change.beat - cursor) * 60.0 * unit_scale / bpm;
		}
		cursor = change.beat;
		bpm = change.bpm;
	}
	if beat > cursor {
		seconds += (beat - cursor) * 60.0 * unit_scale / bpm;
	}
	seconds
}

fn resolve_score(definition: &Definition) -> Result<(Song, Effects, i64), String> {
	let score = definition
		.score
		.as_ref()
		.ok_or_else(|| "score is required".to_string())?;
	if !score.bpm.is_finite() || !(30.0..=300.0).contains(&score.bpm) {
		return Err("score.bpm must be between 30 and 300".to_string());
	}
	let beats_per_bar = score.beats_per_bar.unwrap_or(4.0);
	if beats_per_bar.fract() != 0.0 || !(1.0..=16.0).contains(&beats_per_bar) {
		return Err("score.beatsPerBar must be an integer between 1 and 16".to_string());
	}
	let beat_unit = score.beat_unit.unwrap_or(4);
	if ![2, 4, 8, 16].contains(&beat_unit) {
		return Err("score.beatUnit must be 2, 4, 8, or 16".to_string());
	}
	if score.tracks.is_empty() || score.tracks.len() > MAX_TRACKS {
		return Err(format!(
			"score.tracks must contain between 1 and {MAX_TRACKS} tracks"
		));
	}
	if score.tempo_changes.len() > MAX_TEMPO_CHANGES {
		return Err(format!(
			"score.tempoChanges may contain at most {MAX_TEMPO_CHANGES} entries"
		));
	}
	let mut last_beat: f64 = 0.0;
	let mut note_count = 0usize;
	let mut note_boundaries = Vec::new();
	let mut tracks = Vec::with_capacity(score.tracks.len());
	for (index, source) in score.tracks.iter().enumerate() {
		let voice = match (source.instrument.as_deref(), source.preset) {
			(Some(name), None) => {
				if source.percussion.is_some() {
					return Err(format!(
						"score.tracks[{index}].percussion is only valid with preset"
					));
				}
				let instrument =
					if name == "drums" {
						let kit = source.drum_kit.as_deref().unwrap_or("acoustic");
						BuiltinInstrument::Drums(BuiltinDrumKit::from_name(kit).ok_or_else(
							|| format!("unknown score.tracks[{index}].drumKit '{kit}'"),
						)?)
					} else {
						if source.drum_kit.is_some() {
							return Err(format!(
							"score.tracks[{index}].drumKit is only valid for instrument 'drums'"
						));
						}
						BuiltinInstrument::from_name(name).ok_or_else(|| {
							format!("unknown score.tracks[{index}].instrument '{name}'")
						})?
					};
				TrackVoice::Builtin(instrument)
			}
			(None, Some(preset)) => {
				if source.drum_kit.is_some() {
					return Err(format!(
						"score.tracks[{index}].drumKit is only valid with instrument 'drums'"
					));
				}
				let percussion = source.percussion.unwrap_or(false);
				let bank_range = if percussion { 128..=255 } else { 0..=127 };
				if !bank_range.contains(&preset.bank) || !(0..=127).contains(&preset.program) {
					return Err(format!(
						"score.tracks[{index}].preset has an invalid bank or program for its percussion setting"
					));
				}
				TrackVoice::SoundFont(PresetRef {
					bank: if percussion {
						preset.bank - 128
					} else {
						preset.bank
					},
					program: preset.program,
					percussion,
				})
			}
			(Some(_), Some(_)) => {
				return Err(format!(
					"score.tracks[{index}] must use either instrument or preset, not both"
				));
			}
			(None, None) => {
				return Err(format!(
					"score.tracks[{index}] must provide instrument or preset"
				));
			}
		};
		range(
			source.volume,
			&format!("score.tracks[{index}].volume"),
			0.0,
			1.0,
		)?;
		range(source.pan, &format!("score.tracks[{index}].pan"), -1.0, 1.0)?;
		if source.pedal.len() > MAX_PEDALS {
			return Err(format!(
				"score.tracks[{index}].pedal may contain at most {MAX_PEDALS} entries"
			));
		}
		let inferred = match index {
			0 => Stem::Melody,
			1 => Stem::Bass,
			2 => Stem::Harmony,
			_ => Stem::Drums,
		};
		let role = match source.role.as_deref() {
			Some(value) => Stem::from_name(value)
				.ok_or_else(|| format!("unknown score.tracks[{index}].role '{value}'"))?,
			None => inferred,
		};
		let mut notes = Vec::with_capacity(source.notes.len());
		for (note_index, note) in source.notes.iter().enumerate() {
			let key = resolve_pitch(&note.pitch).ok_or_else(|| {
				format!(
					"score.tracks[{index}].notes[{note_index}].pitch must be MIDI 0..127 or scientific notation"
				)
			})?;
			if !note.start.is_finite() || note.start < 0.0 {
				return Err(format!(
					"score.tracks[{index}].notes[{note_index}].start must be zero or greater"
				));
			}
			if !note.duration.is_finite() || note.duration <= 0.0 {
				return Err(format!(
					"score.tracks[{index}].notes[{note_index}].duration must be greater than zero"
				));
			}
			range(
				note.velocity,
				&format!("score.tracks[{index}].notes[{note_index}].velocity"),
				0.0,
				1.0,
			)?;
			let end_beat = note.start + note.duration;
			last_beat = last_beat.max(end_beat);
			note_boundaries.push((note.start, 1i32));
			note_boundaries.push((end_beat, -1i32));
			notes.push(Note {
				key,
				velocity: (clamp01(note.velocity.unwrap_or(0.8)) * 127.0)
					.round()
					.clamp(1.0, 127.0) as i32,
				start: beat_to_seconds(score, beat_unit, note.start),
				end: beat_to_seconds(score, beat_unit, end_beat),
			});
			note_count += 1;
			if note_count > MAX_NOTES {
				return Err(format!("score may contain at most {MAX_NOTES} notes"));
			}
		}
		let mut pedals = Vec::with_capacity(source.pedal.len());
		for (pedal_index, pedal) in source.pedal.iter().enumerate() {
			if !pedal.start.is_finite() || pedal.start < 0.0 {
				return Err(format!(
					"score.tracks[{index}].pedal[{pedal_index}].start must be zero or greater"
				));
			}
			if !pedal.duration.is_finite() || pedal.duration <= 0.0 {
				return Err(format!(
					"score.tracks[{index}].pedal[{pedal_index}].duration must be greater than zero"
				));
			}
			let end = pedal.start + pedal.duration;
			last_beat = last_beat.max(end);
			pedals.push(Pedal {
				start: beat_to_seconds(score, beat_unit, pedal.start),
				end: beat_to_seconds(score, beat_unit, end),
			});
		}
		tracks.push(Track {
			program: voice.program(),
			bank: voice.bank(),
			percussion: voice.percussion(),
			builtin: voice.builtin(),
			builtin_drum_level: 1.0,
			volume: clamp01(source.volume.unwrap_or(1.0)) as f32,
			render_gain: 1.0,
			pan: source.pan.unwrap_or(0.0).clamp(-1.0, 1.0) as f32,
			chorus_direction: 1.0,
			role,
			notes,
			pedals,
		});
	}
	if note_count == 0 {
		return Err("score must contain at least one note".to_string());
	}
	note_boundaries.sort_by(|left, right| {
		left.0
			.total_cmp(&right.0)
			.then_with(|| left.1.cmp(&right.1))
	});
	let mut simultaneous = 0i32;
	for (_, delta) in note_boundaries {
		simultaneous += delta;
		if simultaneous > 64 {
			return Err("score may contain at most 64 simultaneous notes".to_string());
		}
	}
	for (index, change) in score.tempo_changes.iter().enumerate() {
		if !change.beat.is_finite() || change.beat < 0.0 {
			return Err(format!(
				"score.tempoChanges[{index}].beat must be zero or greater"
			));
		}
		if !change.bpm.is_finite() || !(30.0..=300.0).contains(&change.bpm) {
			return Err(format!(
				"score.tempoChanges[{index}].bpm must be between 30 and 300"
			));
		}
	}
	let bars = score
		.bars
		.unwrap_or_else(|| (last_beat / beats_per_bar).ceil().max(1.0));
	if bars.fract() != 0.0 || !(1.0..=MAX_BARS as f64).contains(&bars) {
		return Err(format!(
			"score.bars must be an integer between 1 and {MAX_BARS}"
		));
	}
	if last_beat > bars * beats_per_bar + 1e-9 {
		return Err("score notes extend beyond the declared bar count".to_string());
	}
	let score_beats = bars * beats_per_bar;
	let mut tempo_beats = score
		.tempo_changes
		.iter()
		.map(|change| change.beat)
		.collect::<Vec<_>>();
	tempo_beats.sort_by(|left, right| left.total_cmp(right));
	for pair in tempo_beats.windows(2) {
		if (pair[0] - pair[1]).abs() <= f64::EPSILON {
			return Err("score.tempoChanges must use unique beat positions".to_string());
		}
	}
	if tempo_beats
		.last()
		.is_some_and(|beat| *beat > score_beats + 1e-9)
	{
		return Err("score tempo changes extend beyond the declared bar count".to_string());
	}
	let duration = beat_to_seconds(score, beat_unit, score_beats);
	if !duration.is_finite() || duration < 1.0 {
		return Err("score duration must be at least 1 second".to_string());
	}
	let all_builtin = tracks.iter().all(|track| track.builtin.is_some());
	let audio = definition.audio.as_ref().or(definition.effects.as_ref());
	if let Some(audio) = audio {
		range(audio.volume, "audio.volume", 0.0, 8.0)?;
		range(audio.reverb, "audio.reverb", 0.0, 1.0)?;
		range(audio.delay, "audio.delay", 0.0, 1.0)?;
		range(audio.chorus, "audio.chorus", 0.0, 1.0)?;
		range(audio.distortion, "audio.distortion", 0.0, 1.0)?;
		range(audio.bit_crush, "audio.bitCrush", 0.0, 1.0)?;
		range(audio.low_pass, "audio.lowPass", 0.0, 1.0)?;
	}
	let effects = Effects {
		volume: audio.and_then(|value| value.volume).unwrap_or(1.0) as f32,
		stereo: audio.and_then(|value| value.stereo).unwrap_or(true),
		reverb: audio.and_then(|value| value.reverb).unwrap_or(0.12) as f32,
		delay: audio
			.and_then(|value| value.delay)
			.unwrap_or(if all_builtin { 0.08 } else { 0.0 }) as f32,
		chorus: audio.and_then(|value| value.chorus).unwrap_or(0.08) as f32,
		distortion: audio.and_then(|value| value.distortion).unwrap_or(0.0) as f32,
		bit_crush: audio.and_then(|value| value.bit_crush).unwrap_or(0.0) as f32,
		low_pass: audio.and_then(|value| value.low_pass).unwrap_or(0.0) as f32,
	};
	Ok((
		Song {
			bpm: score.bpm,
			beats_per_bar: beats_per_bar as usize,
			beat_unit,
			bars: bars as usize,
			duration,
			master_gain: 1.0,
			tracks,
			tempo_changes: score.tempo_changes.clone(),
		},
		effects,
		resolve_seed(definition.seed),
	))
}

#[derive(Clone, Copy)]
enum EventKind {
	NoteOff,
	Pedal,
	NoteOn,
}

#[derive(Clone, Copy)]
struct Event {
	sample: u64,
	kind: EventKind,
	data1: i32,
	data2: i32,
}

struct TrackRenderer {
	synth: TrackSynth,
	events: Vec<Event>,
	next_event: usize,
	volume: f32,
	left_gain: f32,
	right_gain: f32,
	channel: i32,
	role: Stem,
	builtin: bool,
	pan: f32,
	chorus_direction: f32,
}

enum TrackSynth {
	SoundFont(Synthesizer),
	Builtin(BuiltinSynth),
}

impl TrackSynth {
	fn note_on(&mut self, channel: i32, key: i32, velocity: i32) {
		match self {
			Self::SoundFont(synth) => synth.note_on(channel, key, velocity),
			Self::Builtin(synth) => synth.note_on(key, velocity),
		}
	}

	fn note_off(&mut self, channel: i32, key: i32) {
		match self {
			Self::SoundFont(synth) => synth.note_off(channel, key),
			Self::Builtin(synth) => synth.note_off(key),
		}
	}

	fn set_pedal(&mut self, channel: i32, down: bool) {
		match self {
			Self::SoundFont(synth) => {
				synth.process_midi_message(channel, 0xB0, 64, if down { 127 } else { 0 });
			}
			Self::Builtin(synth) => synth.set_pedal(down),
		}
	}

	fn render(&mut self, left: &mut [f32], right: &mut [f32]) {
		match self {
			Self::SoundFont(synth) => synth.render(left, right),
			Self::Builtin(synth) => synth.render(left, right),
		}
	}
}

struct Dsp {
	delay_left: Vec<f32>,
	delay_right: Vec<f32>,
	delay_pos: usize,
	reverb_left: Vec<f32>,
	reverb_right: Vec<f32>,
	reverb_pos: usize,
	filtered_left: f32,
	filtered_right: f32,
	effects: Effects,
}

impl Dsp {
	fn new(effects: Effects, sample_rate: i32, bpm: f64, external_reverb: bool) -> Self {
		let delay_frames = ((sample_rate as f64 * 60.0 / bpm * 0.5).round() as usize).max(1);
		let reverb_frames = ((sample_rate as f64 * 0.073).floor() as usize).max(1);
		Self {
			delay_left: vec![0.0; delay_frames],
			delay_right: vec![0.0; delay_frames],
			delay_pos: 0,
			reverb_left: if external_reverb {
				vec![0.0; reverb_frames]
			} else {
				Vec::new()
			},
			reverb_right: if external_reverb {
				vec![0.0; reverb_frames]
			} else {
				Vec::new()
			},
			reverb_pos: 0,
			filtered_left: 0.0,
			filtered_right: 0.0,
			effects,
		}
	}

	fn process(&mut self, mut left: f32, mut right: f32) -> (f32, f32) {
		if self.effects.delay > 0.0 {
			let delayed_left = self.delay_left[self.delay_pos];
			let delayed_right = self.delay_right[self.delay_pos];
			self.delay_left[self.delay_pos] = left + delayed_right * 0.34;
			self.delay_right[self.delay_pos] = right + delayed_left * 0.34;
			self.delay_pos = (self.delay_pos + 1) % self.delay_left.len();
			left += delayed_left * self.effects.delay;
			right += delayed_right * self.effects.delay;
		}
		if self.effects.reverb > 0.0 && !self.reverb_left.is_empty() {
			let reverbed_left = self.reverb_left[self.reverb_pos];
			let reverbed_right = self.reverb_right[self.reverb_pos];
			self.reverb_left[self.reverb_pos] = left + reverbed_right * 0.42;
			self.reverb_right[self.reverb_pos] = right + reverbed_left * 0.42;
			self.reverb_pos = (self.reverb_pos + 1) % self.reverb_left.len();
			left += reverbed_left * self.effects.reverb * 0.45;
			right += reverbed_right * self.effects.reverb * 0.45;
		}
		if self.effects.low_pass > 0.0 {
			let rate = 1.0 - self.effects.low_pass * 0.94;
			self.filtered_left += (left - self.filtered_left) * rate;
			self.filtered_right += (right - self.filtered_right) * rate;
			left = self.filtered_left;
			right = self.filtered_right;
		} else {
			self.filtered_left = left;
			self.filtered_right = right;
		}
		if self.effects.distortion > 0.0 {
			let drive = 1.0 + self.effects.distortion * 5.0;
			left = left * drive / (1.0 + left.abs() * drive * 0.58);
			right = right * drive / (1.0 + right.abs() * drive * 0.58);
		}
		if self.effects.bit_crush > 0.0 {
			let bits = (16.0 - self.effects.bit_crush * 12.0).floor().max(4.0) as i32;
			let levels = 2.0f32.powi(bits - 1);
			left = (left * levels + 0.5).floor() / levels;
			right = (right * levels + 0.5).floor() / levels;
		}
		(left, right)
	}
}

struct WavWriter {
	writer: Option<BufWriter<File>>,
	temp: PathBuf,
	output: PathBuf,
	data_size: u64,
}

impl WavWriter {
	fn create(output: &Path, sample_rate: i32, channels: u16, frames: u64) -> Result<Self, String> {
		if let Some(parent) = output.parent() {
			fs::create_dir_all(parent).map_err(|error| {
				format!(
					"failed to create output directory '{}': {error}",
					parent.display()
				)
			})?;
		}
		static TEMP_STEP: AtomicU64 = AtomicU64::new(0);
		let step = TEMP_STEP.fetch_add(1, Ordering::Relaxed);
		let name = output
			.file_name()
			.and_then(|value| value.to_str())
			.unwrap_or("music.wav");
		let temp =
			output.with_file_name(format!("{name}.{}.{}.music.tmp", std::process::id(), step));
		let _ = fs::remove_file(&temp);
		let file = File::create(&temp).map_err(|error| {
			format!(
				"failed to create temporary WAV '{}': {error}",
				temp.display()
			)
		})?;
		let mut writer = BufWriter::new(file);
		let data_size = frames
			.checked_mul(channels as u64)
			.and_then(|value| value.checked_mul(2))
			.ok_or_else(|| "WAV size overflow".to_string())?;
		if data_size > u32::MAX as u64 - 36 {
			return Err("WAV output exceeds the RIFF 32-bit size limit".to_string());
		}
		let byte_rate = sample_rate as u32 * channels as u32 * 2;
		let block_align = channels * 2;
		writer
			.write_all(b"RIFF")
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&(36 + data_size as u32).to_le_bytes())
			.map_err(|error| error.to_string())?;
		writer
			.write_all(b"WAVEfmt ")
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&16u32.to_le_bytes())
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&1u16.to_le_bytes())
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&channels.to_le_bytes())
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&(sample_rate as u32).to_le_bytes())
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&byte_rate.to_le_bytes())
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&block_align.to_le_bytes())
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&16u16.to_le_bytes())
			.map_err(|error| error.to_string())?;
		writer
			.write_all(b"data")
			.map_err(|error| error.to_string())?;
		writer
			.write_all(&(data_size as u32).to_le_bytes())
			.map_err(|error| error.to_string())?;
		Ok(Self {
			writer: Some(writer),
			temp,
			output: output.to_path_buf(),
			data_size,
		})
	}

	fn write(&mut self, left: f32, right: f32, channels: u16) -> Result<(), String> {
		let writer = self.writer.as_mut().expect("WAV writer is open");
		if channels == 1 {
			let mono = (((left + right) * 0.5).clamp(-1.0, 1.0) * 32767.0).round() as i16;
			writer
				.write_all(&mono.to_le_bytes())
				.map_err(|error| format!("failed while writing WAV data: {error}"))
		} else {
			let left = (left.clamp(-1.0, 1.0) * 32767.0).round() as i16;
			let right = (right.clamp(-1.0, 1.0) * 32767.0).round() as i16;
			writer
				.write_all(&left.to_le_bytes())
				.and_then(|_| writer.write_all(&right.to_le_bytes()))
				.map_err(|error| format!("failed while writing WAV data: {error}"))
		}
	}

	fn finish(mut self) -> Result<u64, String> {
		let mut writer = self.writer.take().expect("WAV writer is open");
		writer
			.flush()
			.map_err(|error| format!("failed to flush WAV output: {error}"))?;
		drop(writer);
		replace_file(&self.temp, &self.output)?;
		Ok(self.data_size + 44)
	}
}

impl Drop for WavWriter {
	fn drop(&mut self) {
		let _ = fs::remove_file(&self.temp);
	}
}

struct WavLevel {
	loudness_lufs: f64,
	true_peak: f64,
}

struct LoudnessNormalization {
	loudness_lufs: f64,
	true_peak: f32,
	gain: f32,
}

fn read_pcm16_wav_header(
	reader: &mut BufReader<File>,
	path: &Path,
	sample_rate: i32,
	channels: u16,
) -> Result<([u8; 44], usize), String> {
	let mut header = [0u8; 44];
	reader
		.read_exact(&mut header)
		.map_err(|error| format!("failed to read WAV '{}': {error}", path.display()))?;
	if &header[0..4] != b"RIFF"
		|| &header[8..12] != b"WAVE"
		|| &header[12..16] != b"fmt "
		|| u16::from_le_bytes([header[20], header[21]]) != 1
		|| u16::from_le_bytes([header[22], header[23]]) != channels
		|| u32::from_le_bytes([header[24], header[25], header[26], header[27]])
			!= sample_rate as u32
		|| u16::from_le_bytes([header[34], header[35]]) != 16
		|| &header[36..40] != b"data"
	{
		return Err(format!(
			"generated WAV '{}' has an unsupported format",
			path.display()
		));
	}
	let data_size = u32::from_le_bytes([header[40], header[41], header[42], header[43]]) as usize;
	if data_size % (channels as usize * 2) != 0 {
		return Err(format!(
			"generated WAV '{}' contains a partial PCM frame",
			path.display()
		));
	}
	Ok((header, data_size))
}

fn analyze_wav_level(path: &Path, sample_rate: i32, channels: u16) -> Result<WavLevel, String> {
	let mut reader = BufReader::new(
		File::open(path)
			.map_err(|error| format!("failed to open WAV '{}': {error}", path.display()))?,
	);
	let (_, data_size) = read_pcm16_wav_header(&mut reader, path, sample_rate, channels)?;
	let mode = LoudnessMode::I | LoudnessMode::TRUE_PEAK;
	let mut meter = EbuR128::new(channels as u32, sample_rate as u32, mode)
		.map_err(|error| format!("failed to create loudness meter: {error}"))?;
	let mut bytes = vec![0u8; 65_536];
	let mut samples = Vec::with_capacity(bytes.len() / 2);
	let mut remaining = data_size;
	while remaining > 0 {
		let count = remaining.min(bytes.len());
		reader
			.read_exact(&mut bytes[..count])
			.map_err(|error| format!("failed while measuring WAV '{}': {error}", path.display()))?;
		samples.clear();
		samples.extend(
			bytes[..count]
				.chunks_exact(2)
				.map(|value| i16::from_le_bytes([value[0], value[1]])),
		);
		meter
			.add_frames_i16(&samples)
			.map_err(|error| format!("failed while measuring WAV '{}': {error}", path.display()))?;
		remaining -= count;
	}
	let loudness_lufs = meter
		.loudness_global()
		.map_err(|error| format!("failed to measure WAV loudness: {error}"))?;
	let mut true_peak = 0.0f64;
	for channel in 0..channels as u32 {
		true_peak = true_peak.max(
			meter
				.true_peak(channel)
				.map_err(|error| format!("failed to measure WAV true peak: {error}"))?,
		);
	}
	Ok(WavLevel {
		loudness_lufs,
		true_peak,
	})
}

fn scale_pcm16_wav(path: &Path, sample_rate: i32, channels: u16, gain: f64) -> Result<(), String> {
	let mut reader = BufReader::new(
		File::open(path)
			.map_err(|error| format!("failed to open WAV '{}': {error}", path.display()))?,
	);
	let (header, data_size) = read_pcm16_wav_header(&mut reader, path, sample_rate, channels)?;
	static NORMALIZE_STEP: AtomicU64 = AtomicU64::new(0);
	let step = NORMALIZE_STEP.fetch_add(1, Ordering::Relaxed);
	let name = path
		.file_name()
		.and_then(|value| value.to_str())
		.unwrap_or("music.wav");
	let temp = path.with_file_name(format!(
		"{name}.{}.{}.music.normalize.tmp",
		std::process::id(),
		step
	));
	let _ = fs::remove_file(&temp);
	let _guard = TempPath(temp.clone());
	let mut writer = BufWriter::new(File::create(&temp).map_err(|error| {
		format!(
			"failed to create normalized WAV '{}': {error}",
			temp.display()
		)
	})?);
	writer
		.write_all(&header)
		.map_err(|error| format!("failed to write normalized WAV header: {error}"))?;
	let mut bytes = vec![0u8; 65_536];
	let mut remaining = data_size;
	while remaining > 0 {
		let count = remaining.min(bytes.len());
		reader
			.read_exact(&mut bytes[..count])
			.map_err(|error| format!("failed while reading WAV '{}': {error}", path.display()))?;
		for value in bytes[..count].chunks_exact_mut(2) {
			let sample = i16::from_le_bytes([value[0], value[1]]);
			let scaled = (sample as f64 * gain)
				.round()
				.clamp(i16::MIN as f64, i16::MAX as f64) as i16;
			value.copy_from_slice(&scaled.to_le_bytes());
		}
		writer.write_all(&bytes[..count]).map_err(|error| {
			format!(
				"failed while writing normalized WAV '{}': {error}",
				path.display()
			)
		})?;
		remaining -= count;
	}
	writer
		.flush()
		.map_err(|error| format!("failed to flush normalized WAV: {error}"))?;
	drop(writer);
	replace_file(&temp, path)
}

fn normalize_rendered_wavs(
	paths: &[PathBuf],
	volume: f32,
	sample_rate: i32,
	channels: u16,
) -> Result<LoudnessNormalization, String> {
	let main = paths
		.first()
		.ok_or_else(|| "music renderer produced no WAV files".to_string())?;
	let source = analyze_wav_level(main, sample_rate, channels)?;
	let peak_ceiling = 10.0f64.powf(TRUE_PEAK_CEILING_DBTP / 20.0);
	let gain = if volume <= 0.0 {
		0.0
	} else if !source.loudness_lufs.is_finite() || source.true_peak <= 0.0 {
		1.0
	} else {
		let target_lufs = STANDARD_LOUDNESS_LUFS + 20.0 * (volume as f64).log10();
		let loudness_gain = 10.0f64.powf((target_lufs - source.loudness_lufs) / 20.0);
		loudness_gain.min(peak_ceiling / source.true_peak)
	};
	for path in paths {
		scale_pcm16_wav(path, sample_rate, channels, gain)?;
	}
	let loudness_lufs = if gain > 0.0 && source.loudness_lufs.is_finite() {
		source.loudness_lufs + 20.0 * gain.log10()
	} else {
		-70.0
	};
	Ok(LoudnessNormalization {
		loudness_lufs,
		true_peak: (source.true_peak * gain).min(1.0) as f32,
		gain: gain as f32,
	})
}

struct TempPath(PathBuf);

impl Drop for TempPath {
	fn drop(&mut self) {
		let _ = fs::remove_file(&self.0);
	}
}

fn encode_wav_to_ogg(
	input: &Path,
	output: &Path,
	progress: Option<ProgressCallback>,
	user_data: *mut c_void,
	progress_start: f32,
	progress_end: f32,
) -> Result<u64, String> {
	if let Some(parent) = output.parent() {
		fs::create_dir_all(parent).map_err(|error| {
			format!(
				"failed to create Ogg output directory '{}': {error}",
				parent.display()
			)
		})?;
	}
	static OGG_STEP: AtomicU64 = AtomicU64::new(0);
	let step = OGG_STEP.fetch_add(1, Ordering::Relaxed);
	let name = output
		.file_name()
		.and_then(|value| value.to_str())
		.unwrap_or("music.ogg");
	let temp = output.with_file_name(format!("{name}.{}.{}.music.tmp", std::process::id(), step));
	let _ = fs::remove_file(&temp);
	let _temp_guard = TempPath(temp.clone());
	let input_path = CString::new(input.to_string_lossy().as_bytes())
		.map_err(|_| format!("WAV path contains a null byte: '{}'", input.display()))?;
	let temp_path = CString::new(temp.to_string_lossy().as_bytes())
		.map_err(|_| format!("Ogg path contains a null byte: '{}'", temp.display()))?;
	let mut bytes_written = 0u64;
	let mut error = vec![0 as c_char; 1024];
	let success = unsafe {
		dora_audio_encode_wav_to_ogg(
			input_path.as_ptr(),
			temp_path.as_ptr(),
			0.5,
			progress,
			user_data,
			progress_start,
			progress_end,
			&mut bytes_written,
			error.as_mut_ptr(),
			error.len(),
		)
	};
	if success == 0 {
		let reason = unsafe { CStr::from_ptr(error.as_ptr()) }
			.to_string_lossy()
			.into_owned();
		return Err(format!(
			"failed to encode Ogg '{}': {}",
			output.display(),
			if reason.is_empty() {
				"unknown encoder error"
			} else {
				&reason
			}
		));
	}
	replace_file(&temp, output)?;
	Ok(bytes_written)
}

fn replace_file(temp: &Path, output: &Path) -> Result<(), String> {
	static BACKUP_STEP: AtomicU64 = AtomicU64::new(0);
	let step = BACKUP_STEP.fetch_add(1, Ordering::Relaxed);
	let name = output
		.file_name()
		.and_then(|value| value.to_str())
		.unwrap_or("asset");
	let backup = output.with_file_name(format!("{name}.{}.{}.music.bak", std::process::id(), step));
	let _ = fs::remove_file(&backup);
	let had_output = output.exists();
	if had_output {
		fs::rename(output, &backup)
			.map_err(|error| format!("failed to back up existing output: {error}"))?;
	}
	if let Err(error) = fs::rename(temp, output) {
		if had_output {
			let _ = fs::rename(&backup, output);
		}
		return Err(format!("failed to install generated asset: {error}"));
	}
	if had_output {
		let _ = fs::remove_file(backup);
	}
	Ok(())
}

fn seconds_to_sample(seconds: f64, sample_rate: i32, total_frames: u64) -> u64 {
	((seconds * sample_rate as f64).round() as u64).min(total_frames)
}

fn create_track_renderer(
	sound_font: Option<&Arc<SoundFont>>,
	track: Track,
	sample_rate: i32,
	polyphony: usize,
	reverb: f32,
	chorus: f32,
	total_frames: u64,
) -> Result<TrackRenderer, String> {
	let builtin = track.builtin.is_some();
	let channel = if track.percussion {
		Synthesizer::PERCUSSION_CHANNEL as i32
	} else {
		0
	};
	let synth = if let Some(instrument) = track.builtin {
		TrackSynth::Builtin(BuiltinSynth::new(
			instrument,
			sample_rate,
			track.builtin_drum_level,
		))
	} else {
		let sound_font =
			sound_font.ok_or_else(|| "SoundFont track has no loaded SoundFont file".to_string())?;
		let mut settings = SynthesizerSettings::new(sample_rate);
		settings.block_size = 64;
		settings.maximum_polyphony = polyphony;
		settings.enable_reverb_and_chorus = reverb > 0.0 || chorus > 0.0;
		let mut synth = Synthesizer::new(sound_font, &settings)
			.map_err(|error| format!("failed to create SoundFont synthesizer: {error}"))?;
		synth.process_midi_message(channel, 0xB0, 0, track.bank);
		synth.process_midi_message(channel, 0xC0, track.program, 0);
		synth.process_midi_message(channel, 0xB0, 91, (reverb * 127.0).round() as i32);
		synth.process_midi_message(channel, 0xB0, 93, (chorus * 127.0).round() as i32);
		TrackSynth::SoundFont(synth)
	};
	let mut events = Vec::with_capacity(track.notes.len() * 2 + track.pedals.len() * 2);
	let builtin_release_seconds = track
		.builtin
		.filter(|instrument| !instrument.is_percussion())
		.map(release_seconds)
		.unwrap_or(0.0);
	for note in track.notes {
		events.push(Event {
			sample: seconds_to_sample(note.start, sample_rate, total_frames),
			kind: EventKind::NoteOn,
			data1: note.key,
			data2: note.velocity,
		});
		let note_end = seconds_to_sample(note.end, sample_rate, total_frames);
		let release = (builtin_release_seconds
			.min(((note.end - note.start).max(0.0) * 0.45) as f32)
			* sample_rate as f32) as u64;
		events.push(Event {
			sample: note_end.saturating_sub(release),
			kind: EventKind::NoteOff,
			data1: note.key,
			data2: 0,
		});
	}
	if !builtin {
		for pedal in track.pedals {
			events.push(Event {
				sample: seconds_to_sample(pedal.start, sample_rate, total_frames),
				kind: EventKind::Pedal,
				data1: 64,
				data2: 127,
			});
			events.push(Event {
				sample: seconds_to_sample(pedal.end, sample_rate, total_frames),
				kind: EventKind::Pedal,
				data1: 64,
				data2: 0,
			});
		}
	}
	events.sort_by_key(|event| {
		(
			event.sample,
			match event.kind {
				EventKind::NoteOff => 0,
				EventKind::Pedal => 1,
				EventKind::NoteOn => 2,
			},
		)
	});
	let (left_gain, right_gain) = if builtin {
		((1.0 - track.pan) * 0.5, (1.0 + track.pan) * 0.5)
	} else {
		let angle = (track.pan + 1.0) * std::f32::consts::FRAC_PI_4;
		(angle.cos(), angle.sin())
	};
	Ok(TrackRenderer {
		synth,
		events,
		next_event: 0,
		volume: track.volume * track.render_gain,
		left_gain,
		right_gain,
		channel,
		role: track.role,
		builtin,
		pan: track.pan,
		chorus_direction: track.chorus_direction,
	})
}

fn apply_events(track: &mut TrackRenderer, sample: u64) {
	while track.next_event < track.events.len() && track.events[track.next_event].sample <= sample {
		let event = track.events[track.next_event];
		match event.kind {
			EventKind::NoteOff => track.synth.note_off(track.channel, event.data1),
			EventKind::Pedal => track.synth.set_pedal(track.channel, event.data2 >= 64),
			EventKind::NoteOn => track.synth.note_on(track.channel, event.data1, event.data2),
		}
		track.next_event += 1;
	}
}

fn next_event_sample(tracks: &[TrackRenderer], fallback: u64) -> u64 {
	tracks
		.iter()
		.filter_map(|track| track.events.get(track.next_event).map(|event| event.sample))
		.min()
		.unwrap_or(fallback)
}

struct RenderStats {
	bytes_written: u64,
	peak: f32,
	clipping_samples: u64,
}

fn sibling_path(output: &Path, suffix: &str, extension: &str) -> PathBuf {
	let stem = output
		.file_stem()
		.and_then(|value| value.to_str())
		.unwrap_or("music");
	output.with_file_name(format!("{stem}{suffix}{extension}"))
}

fn validate_song_presets(sound_font: &SoundFont, song: &Song) -> Result<(), String> {
	for (index, track) in song.tracks.iter().enumerate() {
		if track.builtin.is_some() {
			continue;
		}
		let preset = PresetRef {
			bank: track.bank,
			program: track.program,
			percussion: track.percussion,
		};
		let bank = preset.effective_bank();
		let available = sound_font.get_presets().iter().any(|candidate| {
			candidate.get_bank_number() == bank && candidate.get_patch_number() == track.program
		});
		if !available {
			return Err(format!(
				"SoundFont preset not found for {} track {}: bank {}, program {}",
				track.role.name(),
				index,
				bank,
				track.program
			));
		}
	}
	Ok(())
}

fn render_song(
	sound_font: Option<&Arc<SoundFont>>,
	song: Song,
	effects: Effects,
	output: &Path,
	stem_base: &Path,
	sample_rate: i32,
	polyphony: usize,
	stems: bool,
	progress: Option<ProgressCallback>,
	user_data: *mut c_void,
	progress_start: f32,
	progress_end: f32,
) -> Result<(RenderStats, Vec<PathBuf>), String> {
	if let Some(sound_font) = sound_font {
		validate_song_presets(sound_font, &song)?;
	} else if song.tracks.iter().any(|track| track.builtin.is_none()) {
		return Err("SoundFont track has no loaded SoundFont file".to_string());
	}
	let channels = if effects.stereo { 2 } else { 1 };
	let total_frames = (song.duration * sample_rate as f64).floor() as u64;
	let master_gain = song.master_gain;
	let mut tracks = song
		.tracks
		.into_iter()
		.map(|track| {
			create_track_renderer(
				sound_font,
				track,
				sample_rate,
				polyphony,
				effects.reverb,
				effects.chorus,
				total_frames,
			)
		})
		.collect::<Result<Vec<_>, _>>()?;
	let mut main_writer = WavWriter::create(output, sample_rate, channels, total_frames)?;
	let mut stem_writers = if stems {
		let mut result = HashMap::new();
		for role in [Stem::Melody, Stem::Bass, Stem::Harmony, Stem::Drums] {
			let path = sibling_path(stem_base, role.suffix(), ".wav");
			result.insert(
				role,
				(
					path.clone(),
					WavWriter::create(&path, sample_rate, channels, total_frames)?,
				),
			);
		}
		result
	} else {
		HashMap::new()
	};
	const CHUNK: usize = 4096;
	let mut frame = 0u64;
	let mut peak = 0.0f32;
	let mut clipping_samples = 0u64;
	let mut left = vec![0.0f32; CHUNK];
	let mut right = vec![0.0f32; CHUNK];
	let mut track_left = vec![0.0f32; CHUNK];
	let mut track_right = vec![0.0f32; CHUNK];
	let mut stem_left = HashMap::new();
	let mut stem_right = HashMap::new();
	for role in [Stem::Melody, Stem::Bass, Stem::Harmony, Stem::Drums] {
		stem_left.insert(role, vec![0.0f32; CHUNK]);
		stem_right.insert(role, vec![0.0f32; CHUNK]);
	}
	let mut dsp = Dsp::new(effects.clone(), sample_rate, song.bpm, sound_font.is_none());
	let fade_frames = (sample_rate as u64 / 125).max(1);
	let mut last_progress = 0u64;
	while frame < total_frames {
		for track in &mut tracks {
			apply_events(track, frame);
		}
		let next_event = next_event_sample(&tracks, total_frames);
		let remaining = total_frames - frame;
		let until_event = if next_event > frame {
			next_event - frame
		} else {
			remaining
		};
		let count = remaining.min(until_event).min(CHUNK as u64) as usize;
		if count == 0 {
			continue;
		}
		left[..count].fill(0.0);
		right[..count].fill(0.0);
		for values in stem_left.values_mut() {
			values[..count].fill(0.0);
		}
		for values in stem_right.values_mut() {
			values[..count].fill(0.0);
		}
		for track in &mut tracks {
			track
				.synth
				.render(&mut track_left[..count], &mut track_right[..count]);
			let role_left = stem_left.get_mut(&track.role).expect("known stem");
			let role_right = stem_right.get_mut(&track.role).expect("known stem");
			for index in 0..count {
				let (left_gain, right_gain) =
					if track.builtin && track.chorus_direction != 0.0 && effects.chorus > 0.0 {
						let time = (frame + index as u64) as f32 / sample_rate as f32;
						let modulation = (time * TAU * 0.35).sin()
							* effects.chorus * 0.16
							* track.chorus_direction;
						let pan = (track.pan + modulation).clamp(-1.0, 1.0);
						((1.0 - pan) * 0.5, (1.0 + pan) * 0.5)
					} else {
						(track.left_gain, track.right_gain)
					};
				let sample_left = track_left[index] * track.volume * left_gain;
				let sample_right = track_right[index] * track.volume * right_gain;
				left[index] += sample_left;
				right[index] += sample_right;
				role_left[index] += sample_left;
				role_right[index] += sample_right;
			}
		}
		for index in 0..count {
			let absolute_frame = frame + index as u64;
			let edge = ((absolute_frame as f32 / fade_frames as f32).min(1.0))
				.min(((total_frames - 1 - absolute_frame) as f32 / fade_frames as f32).min(1.0));
			let (mut sample_left, mut sample_right) = dsp.process(left[index], right[index]);
			sample_left *= effects.volume * master_gain * edge;
			sample_right *= effects.volume * master_gain * edge;
			peak = peak.max(sample_left.abs()).max(sample_right.abs());
			if sample_left.abs() > 1.0 || sample_right.abs() > 1.0 {
				clipping_samples += 1;
			}
			main_writer.write(sample_left, sample_right, channels)?;
			for role in [Stem::Melody, Stem::Bass, Stem::Harmony, Stem::Drums] {
				if let Some((_, writer)) = stem_writers.get_mut(&role) {
					writer.write(
						stem_left[&role][index] * effects.volume * master_gain * edge,
						stem_right[&role][index] * effects.volume * master_gain * edge,
						channels,
					)?;
				}
			}
		}
		frame += count as u64;
		if frame.saturating_sub(last_progress) >= sample_rate as u64 / 2 || frame == total_frames {
			last_progress = frame;
			if let Some(callback) = progress {
				let ratio = if total_frames == 0 {
					1.0
				} else {
					frame as f32 / total_frames as f32
				};
				callback(
					progress_start + (progress_end - progress_start) * ratio,
					user_data,
				);
			}
		}
	}
	let mut bytes_written = main_writer.finish()?;
	let mut paths = vec![output.to_path_buf()];
	for role in [Stem::Melody, Stem::Bass, Stem::Harmony, Stem::Drums] {
		if let Some((path, writer)) = stem_writers.remove(&role) {
			bytes_written += writer.finish()?;
			paths.push(path);
		}
	}
	Ok((
		RenderStats {
			bytes_written,
			peak,
			clipping_samples,
		},
		paths,
	))
}

struct MidiEvent {
	tick: u64,
	order: i32,
	data: Vec<u8>,
}

fn seconds_to_beat(song: &Song, seconds: f64) -> f64 {
	let unit_scale = song.beat_unit as f64 / 4.0;
	let mut elapsed = 0.0;
	let mut beat = 0.0;
	let mut bpm = song.bpm;
	let mut changes = song.tempo_changes.clone();
	changes.sort_by(|a, b| a.beat.total_cmp(&b.beat));
	for change in changes {
		let segment_seconds = (change.beat - beat).max(0.0) * 60.0 * unit_scale / bpm;
		if elapsed + segment_seconds >= seconds {
			return beat + (seconds - elapsed) * bpm / (60.0 * unit_scale);
		}
		elapsed += segment_seconds;
		beat = change.beat;
		bpm = change.bpm;
	}
	beat + (seconds - elapsed).max(0.0) * bpm / (60.0 * unit_scale)
}

fn variable_length(mut value: u64) -> Vec<u8> {
	let mut bytes = vec![(value & 0x7f) as u8];
	value >>= 7;
	while value > 0 {
		bytes.push(((value & 0x7f) as u8) | 0x80);
		value >>= 7;
	}
	bytes.reverse();
	bytes
}

fn midi_bytes(song: &Song) -> Vec<u8> {
	let ticks_per_quarter = 480u64;
	let ticks_per_beat = ticks_per_quarter * 4 / song.beat_unit as u64;
	let mut events = Vec::new();
	let tempo = |bpm: f64| (60_000_000.0 * song.beat_unit as f64 / 4.0 / bpm).floor() as u32;
	let initial_tempo = tempo(song.bpm);
	events.push(MidiEvent {
		tick: 0,
		order: -4,
		data: vec![
			0xff,
			0x51,
			3,
			((initial_tempo >> 16) & 0xff) as u8,
			((initial_tempo >> 8) & 0xff) as u8,
			(initial_tempo & 0xff) as u8,
		],
	});
	let denominator = match song.beat_unit {
		2 => 1,
		4 => 2,
		8 => 3,
		_ => 4,
	};
	events.push(MidiEvent {
		tick: 0,
		order: -3,
		data: vec![0xff, 0x58, 4, song.beats_per_bar as u8, denominator, 24, 8],
	});
	for change in &song.tempo_changes {
		let value = tempo(change.bpm);
		events.push(MidiEvent {
			tick: (change.beat * ticks_per_beat as f64).round() as u64,
			order: -5,
			data: vec![
				0xff,
				0x51,
				3,
				((value >> 16) & 0xff) as u8,
				((value >> 8) & 0xff) as u8,
				(value & 0xff) as u8,
			],
		});
	}
	for (track_index, track) in song.tracks.iter().enumerate() {
		let channel = if track.percussion {
			9
		} else {
			let mut channel = (track_index % 15) as u8;
			if channel >= 9 {
				channel += 1;
			}
			channel
		};
		events.push(MidiEvent {
			tick: 0,
			order: -2,
			data: vec![0xc0 + channel, track.program as u8],
		});
		for note in &track.notes {
			let start = (seconds_to_beat(song, note.start) * ticks_per_beat as f64).round() as u64;
			let end = (seconds_to_beat(song, note.end) * ticks_per_beat as f64)
				.round()
				.max(start as f64 + 1.0) as u64;
			let velocity = (note.velocity as f32 * track.volume)
				.round()
				.clamp(1.0, 127.0) as u8;
			events.push(MidiEvent {
				tick: start,
				order: 1,
				data: vec![0x90 + channel, note.key as u8, velocity],
			});
			events.push(MidiEvent {
				tick: end,
				order: 0,
				data: vec![0x80 + channel, note.key as u8, 0],
			});
		}
		for pedal in &track.pedals {
			let start = (seconds_to_beat(song, pedal.start) * ticks_per_beat as f64).round() as u64;
			let end = (seconds_to_beat(song, pedal.end) * ticks_per_beat as f64).round() as u64;
			events.push(MidiEvent {
				tick: start,
				order: -1,
				data: vec![0xb0 + channel, 64, 127],
			});
			events.push(MidiEvent {
				tick: end,
				order: 0,
				data: vec![0xb0 + channel, 64, 0],
			});
		}
	}
	events.sort_by_key(|event| (event.tick, event.order));
	let mut track_data = Vec::new();
	let mut last_tick = 0;
	for event in events {
		track_data.extend(variable_length(event.tick.saturating_sub(last_tick)));
		track_data.extend(event.data);
		last_tick = event.tick;
	}
	track_data.extend([0, 0xff, 0x2f, 0]);
	let mut result = Vec::new();
	result.extend(b"MThd");
	result.extend(6u32.to_be_bytes());
	result.extend(0u16.to_be_bytes());
	result.extend(1u16.to_be_bytes());
	result.extend((ticks_per_quarter as u16).to_be_bytes());
	result.extend(b"MTrk");
	result.extend((track_data.len() as u32).to_be_bytes());
	result.extend(track_data);
	result
}

fn write_asset(output: &Path, data: &[u8]) -> Result<u64, String> {
	if let Some(parent) = output.parent() {
		fs::create_dir_all(parent).map_err(|error| {
			format!(
				"failed to create output directory '{}': {error}",
				parent.display()
			)
		})?;
	}
	static STEP: AtomicU64 = AtomicU64::new(0);
	let step = STEP.fetch_add(1, Ordering::Relaxed);
	let name = output
		.file_name()
		.and_then(|value| value.to_str())
		.unwrap_or("asset");
	let temp = output.with_file_name(format!("{name}.{}.{}.music.tmp", std::process::id(), step));
	let _ = fs::remove_file(&temp);
	fs::write(&temp, data).map_err(|error| {
		format!(
			"failed to write generated asset '{}': {error}",
			temp.display()
		)
	})?;
	replace_file(&temp, output)?;
	Ok(data.len() as u64)
}

fn valid_relative_path(value: &str) -> bool {
	if value.trim().is_empty() {
		return false;
	}
	let path = Path::new(value);
	!path.is_absolute()
		&& path
			.components()
			.all(|component| matches!(component, Component::Normal(_) | Component::CurDir))
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum OutputFormat {
	Wav,
	Ogg,
}

impl OutputFormat {
	fn extension(self) -> &'static str {
		match self {
			Self::Wav => ".wav",
			Self::Ogg => ".ogg",
		}
	}
}

fn project_output(project: &Path, value: &str) -> Result<(PathBuf, OutputFormat), String> {
	if !valid_relative_path(value) {
		return Err(
			"output must be a project-relative path that stays inside the project".to_string(),
		);
	}
	let extension = Path::new(value)
		.extension()
		.and_then(|value| value.to_str())
		.unwrap_or("");
	let format = if extension.eq_ignore_ascii_case("wav") {
		OutputFormat::Wav
	} else if extension.eq_ignore_ascii_case("ogg") {
		OutputFormat::Ogg
	} else {
		return Err("output must use the .wav or .ogg extension".to_string());
	};
	let output = project.join(value);
	if output.is_dir() {
		return Err("target path is a directory".to_string());
	}
	Ok((output, format))
}

fn temporary_wav_path(output: &Path) -> PathBuf {
	static STEP: AtomicU64 = AtomicU64::new(0);
	let step = STEP.fetch_add(1, Ordering::Relaxed);
	let name = output
		.file_name()
		.and_then(|value| value.to_str())
		.unwrap_or("music.ogg");
	output.with_file_name(format!(
		"{name}.{}.{}.music.render.wav",
		std::process::id(),
		step
	))
}

fn relative_string(project: &Path, output: &Path) -> Result<String, String> {
	let relative = output
		.strip_prefix(project)
		.map_err(|_| "generated path escaped the project directory".to_string())?;
	Ok(relative
		.components()
		.filter_map(|component| match component {
			Component::Normal(value) => value.to_str(),
			_ => None,
		})
		.collect::<Vec<_>>()
		.join("/"))
}

fn resolve_sound_font(
	definition: &Definition,
	resolved_sound_font_path: Option<&str>,
) -> Result<PathBuf, String> {
	let filename = definition
		.synth
		.file
		.as_deref()
		.map(str::trim)
		.filter(|value| !value.is_empty())
		.ok_or_else(|| "synth.file is required when using a SoundFont preset".to_string())?;
	let path = PathBuf::from(resolved_sound_font_path.unwrap_or_default());
	if !path.is_absolute() || !path.is_file() {
		return Err(format!("SoundFont file not found: {filename}"));
	}
	let extension = path
		.extension()
		.and_then(|value| value.to_str())
		.unwrap_or("");
	if !extension.eq_ignore_ascii_case("sf2") && !extension.eq_ignore_ascii_case("sf3") {
		return Err(format!(
			"SoundFont file must use the .sf2 or .sf3 extension: {filename}"
		));
	}
	Ok(path)
}

fn sample_rate(definition: &Definition) -> Result<i32, String> {
	let value = definition.synth.sample_rate.unwrap_or(SAMPLE_RATE);
	if !(16_000..=192_000).contains(&value) {
		return Err("synth.sampleRate must be between 16000 and 192000".to_string());
	}
	Ok(value)
}

fn polyphony(definition: &Definition) -> Result<usize, String> {
	let value = definition.synth.polyphony.unwrap_or(128);
	if !(8..=256).contains(&value) {
		return Err("synth.polyphony must be between 8 and 256".to_string());
	}
	Ok(value)
}

fn export_options(definition: &Definition) -> Result<(bool, usize, usize, String, bool), String> {
	let exports = definition.exports.as_ref();
	let stems = exports.and_then(|value| value.stems).unwrap_or(false);
	let intro = exports.and_then(|value| value.intro_bars).unwrap_or(0.0);
	let outro = exports.and_then(|value| value.outro_bars).unwrap_or(0.0);
	if !intro.is_finite() || intro.fract() != 0.0 || !(0.0..=8.0).contains(&intro) {
		return Err("exports.introBars must be an integer between 0 and 8".to_string());
	}
	if !outro.is_finite() || outro.fract() != 0.0 || !(0.0..=8.0).contains(&outro) {
		return Err("exports.outroBars must be an integer between 0 and 8".to_string());
	}
	let stinger = exports
		.and_then(|value| value.stinger.clone())
		.unwrap_or_else(|| "none".to_string());
	if !["none", "victory", "failure", "both"].contains(&stinger.as_str()) {
		return Err(format!("unknown stinger '{stinger}'"));
	}
	Ok((
		stems,
		intro as usize,
		outro as usize,
		stinger,
		exports.and_then(|value| value.midi).unwrap_or(false),
	))
}

fn callback(progress: Option<ProgressCallback>, user_data: *mut c_void, value: f32) {
	if let Some(progress) = progress {
		progress(value.clamp(0.0, 1.0), user_data);
	}
}

fn render_definition(
	envelope: Envelope,
	resolved_sound_font_path: Option<&str>,
	progress: Option<ProgressCallback>,
	user_data: *mut c_void,
) -> Result<Value, String> {
	let project = PathBuf::from(&envelope.project_dir);
	if !project.is_absolute() || !project.is_dir() {
		return Err("projectDir must be an existing absolute directory".to_string());
	}
	if envelope.definition.score.is_some() == envelope.definition.composition.is_some() {
		return Err("use either score or composition, not both".to_string());
	}
	let output_value = envelope.definition.output.trim();
	let (output, output_format) = project_output(&project, output_value)?;
	let sample_rate = sample_rate(&envelope.definition)?;
	let polyphony = polyphony(&envelope.definition)?;
	let (stems, intro_bars, outro_bars, stinger, export_midi) =
		export_options(&envelope.definition)?;
	if envelope.definition.score.is_some()
		&& (intro_bars > 0 || outro_bars > 0 || stinger != "none")
	{
		return Err("exact scores do not support introBars, outroBars, or stingers".to_string());
	}
	callback(progress, user_data, 0.02);
	let resolved_composition = if envelope.definition.composition.is_some() {
		Some(resolve_composition(&envelope.definition)?)
	} else {
		None
	};
	let (song, effects, seed, style, key, mode, description_prefix) =
		if envelope.definition.score.is_some() {
			let (song, effects, seed) = resolve_score(&envelope.definition)?;
			let prefix = format!(
				"Saved {} bars from an exact {}-track score at {} BPM",
				song.bars,
				song.tracks.len(),
				song.bpm
			);
			(
				song,
				effects,
				seed,
				"score".to_string(),
				"custom".to_string(),
				"custom".to_string(),
				prefix,
			)
		} else {
			let options = resolved_composition
				.as_ref()
				.expect("procedural composition was resolved");
			let song = build_procedural_song(&options, 0);
			let prefix = format!(
				"Saved {} bars of {} background music in {} {} at {} BPM",
				options.bars, options.style, options.key, options.mode, options.bpm
			);
			(
				song,
				options.effects.clone(),
				options.seed,
				options.style.clone(),
				options.key.clone(),
				options.mode.clone(),
				prefix,
			)
		};
	callback(progress, user_data, 0.06);
	let needs_sound_font = song.tracks.iter().any(|track| track.builtin.is_none());
	let sound_font = if needs_sound_font {
		let path = resolve_sound_font(&envelope.definition, resolved_sound_font_path)?;
		Some(Arc::new(load_sound_font(&path)?))
	} else {
		None
	};
	callback(progress, user_data, 0.10);
	let mut files = Vec::new();
	let mut bytes_written = 0u64;
	let mut peak = 0.0f32;
	let mut clipping_samples = 0u64;
	let main_loudness_lufs;
	let main_normalization_gain;
	let mut segment_specs: Vec<(String, ResolvedComposition)> = Vec::new();
	if let Some(base) = resolved_composition.as_ref() {
		if intro_bars > 0 {
			let mut segment = base.clone();
			segment.bars = intro_bars;
			segment.seed += 3001;
			segment_specs.push(("_intro".to_string(), segment));
		}
		if outro_bars > 0 {
			let mut segment = base.clone();
			segment.bars = outro_bars;
			segment.seed += 6007;
			segment_specs.push(("_outro".to_string(), segment));
		}
		for (suffix, segment_style, seed_offset) in match stinger.as_str() {
			"victory" => vec![("_victory", "victory", 9001)],
			"failure" => vec![("_failure", "tense", 12007)],
			"both" => vec![("_victory", "victory", 9001), ("_failure", "tense", 12007)],
			_ => Vec::new(),
		} {
			let config = style_config(segment_style);
			let mut segment = base.clone();
			segment.style = segment_style.to_string();
			segment.seed += seed_offset;
			segment.bars = 1;
			segment.mode = config.mode.to_string();
			segment.progression = config.progression.to_vec();
			if matches!(segment.lead, TrackVoice::Builtin(_)) {
				segment.lead = TrackVoice::Builtin(
					BuiltinInstrument::from_name(config.lead).expect("style instrument is valid"),
				);
				segment.bass = TrackVoice::Builtin(
					BuiltinInstrument::from_name(config.bass).expect("style instrument is valid"),
				);
				segment.harmony = TrackVoice::Builtin(
					BuiltinInstrument::from_name(config.harmony)
						.expect("style instrument is valid"),
				);
			}
			segment.intensity = 0.9;
			segment_specs.push((suffix.to_string(), segment));
		}
	}
	let render_count = 1 + segment_specs.len();
	let main_end = 0.10 + 0.80 / render_count as f32;
	let mut ogg_sources: Vec<(PathBuf, PathBuf, TempPath)> = Vec::new();
	let (main_render_output, main_temp) = if output_format == OutputFormat::Ogg {
		let path = temporary_wav_path(&output);
		(path.clone(), Some(TempPath(path)))
	} else {
		(output.clone(), None)
	};
	let channels = if effects.stereo { 2 } else { 1 };
	let requested_volume = effects.volume;
	let (mut stats, rendered_paths) = if resolved_composition
		.as_ref()
		.is_some_and(uses_legacy_builtin_renderer)
	{
		let mut render_options = resolved_composition
			.as_ref()
			.expect("resolved composition")
			.clone();
		render_options.effects.volume = INTERNAL_RENDER_VOLUME;
		render_legacy_procedural(
			&render_options,
			&main_render_output,
			&output,
			sample_rate,
			stems,
			progress,
			user_data,
			0.10,
			main_end,
		)?
	} else {
		let mut render_effects = effects.clone();
		render_effects.volume = INTERNAL_RENDER_VOLUME;
		render_song(
			sound_font.as_ref(),
			song.clone(),
			render_effects,
			&main_render_output,
			&output,
			sample_rate,
			polyphony,
			stems,
			progress,
			user_data,
			0.10,
			main_end,
		)?
	};
	let normalization =
		normalize_rendered_wavs(&rendered_paths, requested_volume, sample_rate, channels)?;
	stats.peak = normalization.true_peak;
	main_loudness_lufs = normalization.loudness_lufs;
	main_normalization_gain = normalization.gain;
	peak = peak.max(stats.peak);
	clipping_samples += stats.clipping_samples;
	if output_format == OutputFormat::Wav {
		bytes_written += stats.bytes_written;
		for path in rendered_paths {
			files.push(relative_string(&project, &path)?);
		}
	} else {
		for path in rendered_paths {
			if path != main_render_output {
				bytes_written += fs::metadata(&path)
					.map_err(|error| {
						format!(
							"failed to inspect generated stem '{}': {error}",
							path.display()
						)
					})?
					.len();
				files.push(relative_string(&project, &path)?);
			}
		}
		ogg_sources.push((
			main_render_output,
			output.clone(),
			main_temp.expect("Ogg output has a temporary WAV"),
		));
	}
	for (index, (suffix, options)) in segment_specs.into_iter().enumerate() {
		let segment_output = sibling_path(&output, &suffix, output_format.extension());
		let (segment_render_output, segment_temp) = if output_format == OutputFormat::Ogg {
			let path = temporary_wav_path(&segment_output);
			(path.clone(), Some(TempPath(path)))
		} else {
			(segment_output.clone(), None)
		};
		let start = 0.10 + 0.80 * (index + 1) as f32 / render_count as f32;
		let end = 0.10 + 0.80 * (index + 2) as f32 / render_count as f32;
		let requested_volume = options.effects.volume;
		let (mut stats, rendered_paths) = if uses_legacy_builtin_renderer(&options) {
			let mut render_options = options.clone();
			render_options.effects.volume = INTERNAL_RENDER_VOLUME;
			render_legacy_procedural(
				&render_options,
				&segment_render_output,
				&segment_output,
				sample_rate,
				false,
				progress,
				user_data,
				start,
				end,
			)?
		} else {
			let segment_song = build_procedural_song(&options, 0);
			let mut render_effects = options.effects.clone();
			render_effects.volume = INTERNAL_RENDER_VOLUME;
			render_song(
				sound_font.as_ref(),
				segment_song,
				render_effects,
				&segment_render_output,
				&segment_output,
				sample_rate,
				polyphony,
				false,
				progress,
				user_data,
				start,
				end,
			)?
		};
		let normalization =
			normalize_rendered_wavs(&rendered_paths, requested_volume, sample_rate, channels)?;
		stats.peak = normalization.true_peak;
		peak = peak.max(stats.peak);
		clipping_samples += stats.clipping_samples;
		if output_format == OutputFormat::Wav {
			bytes_written += stats.bytes_written;
			for path in rendered_paths {
				files.push(relative_string(&project, &path)?);
			}
		} else {
			ogg_sources.push((
				segment_render_output,
				segment_output,
				segment_temp.expect("Ogg output has a temporary WAV"),
			));
		}
	}
	let midi_path = if export_midi {
		callback(progress, user_data, 0.93);
		let path = sibling_path(&output, "", ".mid");
		let midi = midi_bytes(&song);
		bytes_written += write_asset(&path, &midi)?;
		let relative = relative_string(&project, &path)?;
		files.push(relative.clone());
		Some(relative)
	} else {
		None
	};
	if output_format == OutputFormat::Ogg {
		let count = ogg_sources.len().max(1);
		let mut encoded_files = Vec::with_capacity(ogg_sources.len() + files.len());
		for (index, (wav_path, path, _guard)) in ogg_sources.iter().enumerate() {
			let start = 0.94 + 0.05 * index as f32 / count as f32;
			let end = 0.94 + 0.05 * (index + 1) as f32 / count as f32;
			bytes_written += encode_wav_to_ogg(wav_path, &path, progress, user_data, start, end)?;
			let relative = relative_string(&project, &path)?;
			encoded_files.push(relative);
		}
		encoded_files.extend(files);
		files = encoded_files;
	}
	callback(progress, user_data, 1.0);
	let mut result = json!({
		"success": true,
		"path": output_value,
		"files": files,
		"bytesWritten": bytes_written,
		"durationSeconds": (song.duration * 100.0).round() / 100.0,
		"sampleRate": sample_rate,
		"channels": channels,
		"seed": seed,
		"style": style,
		"bpm": song.bpm,
		"bars": song.bars,
		"key": key,
		"mode": mode,
		"description": format!(
			"{description_prefix} to {output_value}, plus {} companion asset(s).",
			files.len().saturating_sub(1)
		),
		"peak": peak,
		"clippingSamples": clipping_samples,
		"loudnessLufs": main_loudness_lufs,
		"normalizationGain": main_normalization_gain
	});
	if let Some(path) = midi_path {
		result["midiPath"] = Value::String(path);
	}
	Ok(result)
}

fn result_string(value: Value) -> *mut c_char {
	CString::new(value.to_string())
		.map(CString::into_raw)
		.unwrap_or(ptr::null_mut())
}

#[no_mangle]
pub unsafe extern "C" fn dora_music_render(
	request_json: *const c_char,
	sound_font_path: *const c_char,
	progress: Option<ProgressCallback>,
	user_data: *mut c_void,
) -> *mut c_char {
	if request_json.is_null() {
		return result_string(json!({
			"success": false,
			"message": "render request pointer is null"
		}));
	}
	let result = std::panic::catch_unwind(|| {
		let request_text = CStr::from_ptr(request_json)
			.to_str()
			.map_err(|error| format!("render request is not valid UTF-8: {error}"))?;
		let envelope: Envelope = serde_json::from_str(request_text)
			.map_err(|error| format!("invalid music definition JSON: {error}"))?;
		let resolved_sound_font_path =
			if sound_font_path.is_null() {
				None
			} else {
				Some(CStr::from_ptr(sound_font_path).to_str().map_err(|error| {
					format!("resolved SoundFont path is not valid UTF-8: {error}")
				})?)
			};
		render_definition(envelope, resolved_sound_font_path, progress, user_data)
	});
	match result {
		Ok(Ok(value)) => result_string(value),
		Ok(Err(message)) => result_string(json!({
			"success": false,
			"message": format!("invalid music definition: {message}")
		})),
		Err(_) => result_string(json!({
			"success": false,
			"message": "music generator stopped unexpectedly"
		})),
	}
}

#[no_mangle]
pub unsafe extern "C" fn dora_music_string_free(value: *mut c_char) {
	if !value.is_null() {
		drop(CString::from_raw(value));
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	fn envelope(definition: &str) -> String {
		format!(
			r#"{{
				"projectDir": "/tmp",
				"definition": {definition}
			}}"#
		)
	}

	#[test]
	fn rejects_unsafe_output() {
		let value: Envelope = serde_json::from_str(&envelope(
			r#"{
				"output": "../bad.wav",
				"synth": {},
				"composition": {"style": "calm"}
			}"#,
		))
		.unwrap();
		assert!(project_output(Path::new(&value.project_dir), &value.definition.output).is_err());
	}

	#[test]
	fn output_extension_selects_audio_format() {
		let (_, wav) = project_output(Path::new("/tmp"), "Audio/cue.WAV").unwrap();
		let (_, ogg) = project_output(Path::new("/tmp"), "Audio/theme.ogg").unwrap();
		assert!(matches!(wav, OutputFormat::Wav));
		assert!(matches!(ogg, OutputFormat::Ogg));
		assert!(project_output(Path::new("/tmp"), "Audio/theme.mp3").is_err());
		assert!(project_output(Path::new("/tmp"), "Audio/theme").is_err());
	}

	#[test]
	fn soundfont_requires_an_explicit_file() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {},
				"score": {"bpm": 60, "tracks": []}
			}"#,
		)
		.unwrap();
		assert_eq!(
			resolve_sound_font(&definition, None).unwrap_err(),
			"synth.file is required when using a SoundFont preset"
		);
	}

	#[test]
	fn soundfont_uses_the_engine_resolved_existing_path() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {"file": "Audio/GeneralUserGS.sf3"},
				"score": {"bpm": 60, "tracks": []}
			}"#,
		)
		.unwrap();
		let resolved = Path::new(env!("CARGO_MANIFEST_DIR"))
			.join("../../Assets/Audio/GeneralUserGS.sf3")
			.canonicalize()
			.unwrap();
		assert_eq!(
			resolve_sound_font(&definition, resolved.to_str()).unwrap(),
			resolved
		);
		assert!(
			resolve_sound_font(&definition, Some("Audio/GeneralUserGS.sf3"))
				.unwrap_err()
				.contains("file not found")
		);
	}

	#[test]
	fn procedural_generation_is_deterministic() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {},
				"composition": {"style": "jazz_hop", "seed": 42, "duration": 8}
			}"#,
		)
		.unwrap();
		let options = resolve_composition(&definition).unwrap();
		assert_eq!(options.drums.effective_bank(), 128);
		assert_eq!(options.drums.program(), 0);
		assert_eq!(options.drum_gain, 1.0);
		let first = build_procedural_song(&options, 0);
		let second = build_procedural_song(&options, 0);
		assert_eq!(first.master_gain, 0.72);
		assert_eq!(first.tracks[0].volume, 0.40);
		assert_eq!(first.tracks[1].volume, 0.56);
		assert_eq!(first.tracks[2].volume, 0.44);
		assert_eq!(first.tracks[3].volume, 2.0);
		assert_eq!(first.tracks[0].notes.len(), second.tracks[0].notes.len());
		assert_eq!(first.tracks[0].notes[0].key, second.tracks[0].notes[0].key);
		assert_eq!(first.tracks[3].notes.len(), second.tracks[3].notes.len());
	}

	#[test]
	fn procedural_drums_select_soundfont_preset_and_layer_claps() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {},
				"composition": {"style": "jazz_hop", "seed": 42, "duration": 8},
				"arrangement": {"intensity": 0.84, "drumGain": 2.5},
				"instruments": {
					"lead": {"bank": 0, "program": 24},
					"bass": {"bank": 0, "program": 38},
					"harmony": {"bank": 0, "program": 0},
					"drums": {"bank": 128, "program": 32}
				}
			}"#,
		)
		.unwrap();
		let options = resolve_composition(&definition).unwrap();
		assert_eq!(options.drums.effective_bank(), 128);
		assert_eq!(options.drums.program(), 32);
		assert_eq!(options.drum_gain, 2.5);
		let song = build_procedural_song(&options, 0);
		assert_eq!(song.tracks[3].program, 32);
		assert_eq!(
			song.tracks[3]
				.notes
				.iter()
				.filter(|note| note.key == 39)
				.count(),
			6
		);
	}

	#[test]
	fn procedural_instruments_accept_soundfont_presets() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {},
				"composition": {"style": "calm"},
				"instruments": {
					"lead": {"bank": 3, "program": 24},
					"bass": {"bank": 4, "program": 38},
					"harmony": {"bank": 5, "program": 0},
					"drums": {"bank": 129, "program": 16}
				}
			}"#,
		)
		.unwrap();
		let options = resolve_composition(&definition).unwrap();
		assert_eq!(options.lead.bank(), 3);
		assert_eq!(options.lead.program(), 24);
		assert_eq!(options.bass.bank(), 4);
		assert_eq!(options.harmony.bank(), 5);
		assert_eq!(options.drums.effective_bank(), 129);
		assert_eq!(options.drums.program(), 16);
	}

	#[test]
	fn procedural_instrument_presets_validate_role_banks() {
		let melodic: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {},
				"composition": {"style": "calm"},
				"instruments": {
					"lead": {"bank": 128, "program": 0},
					"bass": {"bank": 0, "program": 38},
					"harmony": {"bank": 0, "program": 0},
					"drums": {"bank": 128, "program": 0}
				}
			}"#,
		)
		.unwrap();
		assert!(resolve_composition(&melodic)
			.err()
			.unwrap()
			.contains("instruments.lead.bank"));

		let drums: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {},
				"composition": {"style": "calm"},
				"instruments": {
					"lead": {"bank": 0, "program": 24},
					"bass": {"bank": 0, "program": 38},
					"harmony": {"bank": 0, "program": 0},
					"drums": {"bank": 0, "program": 0}
				}
			}"#,
		)
		.unwrap();
		assert!(resolve_composition(&drums)
			.err()
			.unwrap()
			.contains("instruments.drums.bank"));
	}

	#[test]
	fn procedural_instruments_mix_builtin_names_and_soundfont_presets() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {},
				"composition": {"style": "jazz_hop"},
				"instruments": {
					"lead": "pluck",
					"bass": {"bank": 0, "program": 38},
					"harmony": "piano",
					"drums": {"bank": 128, "program": 0}
				}
			}"#,
		)
		.unwrap();
		let options = resolve_composition(&definition).unwrap();
		assert!(options.lead.is_builtin());
		assert!(!options.bass.is_builtin());
		assert!(options.harmony.is_builtin());
		assert!(!options.drums.is_builtin());
		let song = build_procedural_song(&options, 0);
		assert_eq!(song.master_gain, 1.0);
		assert!(song.tracks[0].builtin.is_some());
		assert!(song.tracks[1].builtin.is_none());
		assert!(song.tracks[2].builtin.is_some());
		assert!(song.tracks[3].builtin.is_none());
	}

	#[test]
	fn exact_score_mixes_builtin_and_soundfont_tracks() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {"file": "Audio/GeneralUserGS.sf3"},
				"score": {
					"bpm": 120,
					"bars": 1,
					"tracks": [
						{
							"instrument": "sub",
							"notes": [{"pitch": "C3", "start": 0, "duration": 1}]
						},
						{
							"preset": {"bank": 0, "program": 0},
							"notes": [{"pitch": "C4", "start": 0, "duration": 1}]
						}
					]
				}
			}"#,
		)
		.unwrap();
		let (song, _, _) = resolve_score(&definition).unwrap();
		assert!(song.tracks[0].builtin.is_some());
		assert!(song.tracks[1].builtin.is_none());
	}

	#[test]
	fn procedural_duration_can_exceed_five_minutes() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.ogg",
				"synth": {},
				"composition": {"style": "calm", "duration": 360, "tempo": 120}
			}"#,
		)
		.unwrap();
		let options = resolve_composition(&definition).unwrap();
		assert_eq!(options.bars, 180);
	}

	#[test]
	fn exact_score_duration_can_exceed_five_minutes() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.ogg",
				"synth": {},
				"score": {
					"bpm": 60,
					"bars": 76,
					"tracks": [{
						"instrument": "piano",
						"notes": [{"pitch": "C4", "start": 0, "duration": 1}]
					}]
				}
			}"#,
		)
		.unwrap();
		let (song, _, _) = resolve_score(&definition).unwrap();
		assert_eq!(song.duration, 304.0);
	}

	#[test]
	fn master_gain_can_boost_quiet_scores() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.ogg",
				"synth": {},
				"score": {
					"bpm": 60,
					"bars": 1,
					"tracks": [{
						"instrument": "piano",
						"notes": [{"pitch": "C4", "start": 0, "duration": 1}]
					}]
				},
				"audio": {"volume": 6.8}
			}"#,
		)
		.unwrap();
		let (_, effects, _) = resolve_score(&definition).unwrap();
		assert_eq!(effects.volume, 6.8);
	}

	#[test]
	fn parses_scientific_pitch_names() {
		assert_eq!(note_name_to_midi("C4"), Some(60));
		assert_eq!(note_name_to_midi("F#4"), Some(66));
		assert_eq!(note_name_to_midi("Bb3"), Some(58));
		assert_eq!(note_name_to_midi("H4"), None);
	}

	#[test]
	fn midi_has_standard_header() {
		let definition: Definition = serde_json::from_str(
			r#"{
				"output": "music.wav",
				"synth": {},
				"composition": {"style": "calm", "seed": 7, "duration": 8}
			}"#,
		)
		.unwrap();
		let options = resolve_composition(&definition).unwrap();
		let song = build_procedural_song(&options, 0);
		let bytes = midi_bytes(&song);
		assert_eq!(&bytes[0..4], b"MThd");
		assert!(bytes.windows(4).any(|value| value == b"MTrk"));
	}

	#[test]
	fn normalizes_integrated_loudness_and_preserves_volume_as_an_offset() {
		fn write_tone(path: &Path) {
			let frames = SAMPLE_RATE as u64;
			let mut writer = WavWriter::create(path, SAMPLE_RATE, 2, frames).unwrap();
			for frame in 0..frames {
				let sample = (frame as f32 * 440.0 * TAU / SAMPLE_RATE as f32).sin() * 0.05;
				writer.write(sample, sample, 2).unwrap();
			}
			writer.finish().unwrap();
		}

		let id = format!(
			"dora-music-normalize-{}-{}",
			std::process::id(),
			automatic_seed()
		);
		let neutral = std::env::temp_dir().join(format!("{id}-neutral.wav"));
		let quiet = std::env::temp_dir().join(format!("{id}-quiet.wav"));
		write_tone(&neutral);
		write_tone(&quiet);

		let neutral_result =
			normalize_rendered_wavs(std::slice::from_ref(&neutral), 1.0, SAMPLE_RATE, 2).unwrap();
		let quiet_result =
			normalize_rendered_wavs(std::slice::from_ref(&quiet), 0.5, SAMPLE_RATE, 2).unwrap();
		let neutral_level = analyze_wav_level(&neutral, SAMPLE_RATE, 2).unwrap();
		let quiet_level = analyze_wav_level(&quiet, SAMPLE_RATE, 2).unwrap();

		assert!((neutral_level.loudness_lufs - STANDARD_LOUDNESS_LUFS).abs() < 0.1);
		assert!((quiet_level.loudness_lufs - (STANDARD_LOUDNESS_LUFS - 6.0206)).abs() < 0.1);
		assert!((neutral_level.loudness_lufs - neutral_result.loudness_lufs).abs() < 0.1);
		assert!((quiet_level.loudness_lufs - quiet_result.loudness_lufs).abs() < 0.1);
		assert!(neutral_level.true_peak <= 10.0f64.powf(TRUE_PEAK_CEILING_DBTP / 20.0) + 0.001);
		assert!(quiet_level.true_peak <= 10.0f64.powf(TRUE_PEAK_CEILING_DBTP / 20.0) + 0.001);

		let _ = fs::remove_file(neutral);
		let _ = fs::remove_file(quiet);
	}

	#[test]
	fn rejects_invalid_procedural_values_instead_of_falling_back() {
		for definition in [
			r#"{"output":"music.wav","synth":{},"composition":{"style":"calm","mode":"majro"}}"#,
			r#"{"output":"music.wav","synth":{},"composition":{"style":"calm","key":"H"}}"#,
			r#"{"output":"music.wav","synth":{},"composition":{"style":"calm","structure":["A",""]}}"#,
			r#"{"output":"music.wav","synth":{},"composition":{"style":"calm"},"instruments":{"lead":"kazoo"}}"#,
			r#"{"output":"music.wav","synth":{},"composition":{"style":"calm"},"instruments":{"drums":"cardboard"}}"#,
			r#"{"output":"music.wav","synth":{},"composition":{"style":"calm"},"arrangement":{"drumGain":9}}"#,
			r#"{"output":"music.wav","synth":{},"composition":{"style":"calm"},"effects":{"volume":9}}"#,
		] {
			let definition: Definition = serde_json::from_str(definition).unwrap();
			assert!(resolve_composition(&definition).is_err());
		}
	}
}
