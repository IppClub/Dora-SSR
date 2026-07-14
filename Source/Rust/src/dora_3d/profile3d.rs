use std::collections::VecDeque;
use std::sync::{Mutex, OnceLock};

const MAX_UPLOAD_RECORDS: usize = 256;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct UploadCommandRecord {
	pub kind: u8,
	pub phase: u8,
	pub elapsed_micros: u64,
	pub bytes: u64,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct UploadProfileTotals {
	pub commands: u64,
	pub bytes: u64,
	pub elapsed_micros: u64,
	pub max_command_micros: u64,
}

#[derive(Debug, Default)]
struct UploadProfileState {
	totals: UploadProfileTotals,
	records: VecDeque<UploadCommandRecord>,
}

fn state() -> &'static Mutex<UploadProfileState> {
	static STATE: OnceLock<Mutex<UploadProfileState>> = OnceLock::new();
	STATE.get_or_init(|| Mutex::new(UploadProfileState::default()))
}

pub fn record_upload(kind: u8, phase: u8, elapsed_micros: u64, bytes: u64) {
	let mut state = state().lock().unwrap();
	state.totals.commands += 1;
	state.totals.bytes += bytes;
	state.totals.elapsed_micros += elapsed_micros;
	state.totals.max_command_micros = state.totals.max_command_micros.max(elapsed_micros);
	if state.records.len() == MAX_UPLOAD_RECORDS {
		state.records.pop_front();
	}
	state.records.push_back(UploadCommandRecord {
		kind,
		phase,
		elapsed_micros,
		bytes,
	});
}

pub fn upload_totals() -> UploadProfileTotals {
	state().lock().unwrap().totals
}

pub fn upload_records() -> Vec<UploadCommandRecord> {
	state().lock().unwrap().records.iter().copied().collect()
}

pub fn clear() {
	*state().lock().unwrap() = UploadProfileState::default();
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn upload_profile_tracks_totals_and_records() {
		clear();
		record_upload(1, 2, 30, 1024);
		record_upload(1, 3, 10, 256);
		assert_eq!(
			upload_totals(),
			UploadProfileTotals {
				commands: 2,
				bytes: 1280,
				elapsed_micros: 40,
				max_command_micros: 30,
			}
		);
		assert_eq!(upload_records().len(), 2);
	}
}
