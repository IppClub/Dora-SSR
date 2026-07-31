use lewton::inside_ogg::OggStreamReader;
use rustysynth::SoundFont;
use std::fs;
use std::io::Cursor;
use std::path::Path;

const CHUNK_HEADER_SIZE: usize = 8;
const SAMPLE_HEADER_SIZE: usize = 46;
const SAMPLE_DATA_GUARD_SIZE: usize = 46;

#[derive(Clone, Copy)]
struct Chunk {
	size_offset: usize,
	data_start: usize,
	data_end: usize,
	padded_end: usize,
}

fn read_u32(data: &[u8], offset: usize) -> Result<u32, String> {
	let bytes = data
		.get(offset..offset + 4)
		.ok_or_else(|| "SoundFont chunk is truncated".to_string())?;
	Ok(u32::from_le_bytes(bytes.try_into().unwrap()))
}

fn write_u32(data: &mut [u8], offset: usize, value: u32) -> Result<(), String> {
	let target = data
		.get_mut(offset..offset + 4)
		.ok_or_else(|| "SoundFont chunk is truncated".to_string())?;
	target.copy_from_slice(&value.to_le_bytes());
	Ok(())
}

fn chunk_at(data: &[u8], offset: usize, limit: usize) -> Result<Chunk, String> {
	if offset + CHUNK_HEADER_SIZE > limit {
		return Err("SoundFont chunk header is truncated".to_string());
	}
	let size = read_u32(data, offset + 4)? as usize;
	let data_start = offset + CHUNK_HEADER_SIZE;
	let data_end = data_start
		.checked_add(size)
		.ok_or_else(|| "SoundFont chunk size overflow".to_string())?;
	let padded_end = data_end
		.checked_add(size & 1)
		.ok_or_else(|| "SoundFont chunk size overflow".to_string())?;
	if padded_end > limit {
		return Err("SoundFont chunk extends beyond its parent".to_string());
	}
	Ok(Chunk {
		size_offset: offset + 4,
		data_start,
		data_end,
		padded_end,
	})
}

fn find_chunk(
	data: &[u8],
	start: usize,
	limit: usize,
	id: &[u8; 4],
) -> Result<Option<Chunk>, String> {
	let mut offset = start;
	while offset + CHUNK_HEADER_SIZE <= limit {
		let chunk = chunk_at(data, offset, limit)?;
		if data.get(offset..offset + 4) == Some(id) {
			return Ok(Some(chunk));
		}
		offset = chunk.padded_end;
	}
	if offset != limit {
		return Err("SoundFont chunk list has invalid padding".to_string());
	}
	Ok(None)
}

fn find_list(data: &[u8], list_type: &[u8; 4]) -> Result<Chunk, String> {
	let riff_size = read_u32(data, 4)? as usize;
	let riff_end = 8usize
		.checked_add(riff_size)
		.ok_or_else(|| "SoundFont RIFF size overflow".to_string())?;
	if data.get(0..4) != Some(b"RIFF") || data.get(8..12) != Some(b"sfbk") || riff_end > data.len()
	{
		return Err("invalid SoundFont RIFF header".to_string());
	}
	let mut offset = 12;
	while offset + CHUNK_HEADER_SIZE <= riff_end {
		let chunk = chunk_at(data, offset, riff_end)?;
		if data.get(offset..offset + 4) == Some(b"LIST")
			&& data.get(chunk.data_start..chunk.data_start + 4) == Some(list_type)
		{
			return Ok(chunk);
		}
		offset = chunk.padded_end;
	}
	Err(format!(
		"SoundFont is missing the '{}' LIST",
		String::from_utf8_lossy(list_type)
	))
}

fn decode_sample(data: &[u8], index: usize) -> Result<Vec<i16>, String> {
	let mut reader = OggStreamReader::new(Cursor::new(data))
		.map_err(|error| format!("failed to open SF3 sample {index}: {error}"))?;
	if reader.ident_hdr.audio_channels != 1 {
		return Err(format!(
			"SF3 sample {index} uses {} channels; SoundFont samples must be mono",
			reader.ident_hdr.audio_channels
		));
	}
	let mut samples = Vec::new();
	while let Some(packet) = reader
		.read_dec_packet_itl()
		.map_err(|error| format!("failed to decode SF3 sample {index}: {error}"))?
	{
		samples.extend(packet);
	}
	if samples.len() < 2 {
		return Err(format!("SF3 sample {index} decoded to no audio"));
	}
	Ok(samples)
}

fn decode_sf3(data: &[u8]) -> Result<Vec<u8>, String> {
	let sdta = find_list(data, b"sdta")?;
	let smpl = find_chunk(data, sdta.data_start + 4, sdta.data_end, b"smpl")?
		.ok_or_else(|| "SoundFont is missing the smpl chunk".to_string())?;
	if data.get(smpl.data_start..smpl.data_start + 4) != Some(b"OggS") {
		return Ok(data.to_vec());
	}
	let pdta = find_list(data, b"pdta")?;
	let shdr = find_chunk(data, pdta.data_start + 4, pdta.data_end, b"shdr")?
		.ok_or_else(|| "SoundFont is missing the shdr chunk".to_string())?;
	let shdr_size = shdr.data_end - shdr.data_start;
	if shdr_size < SAMPLE_HEADER_SIZE * 2 || shdr_size % SAMPLE_HEADER_SIZE != 0 {
		return Err("SoundFont sample headers have an invalid size".to_string());
	}

	let sample_count = shdr_size / SAMPLE_HEADER_SIZE - 1;
	let compressed = &data[smpl.data_start..smpl.data_end];
	let mut pcm = Vec::<i16>::new();
	let mut headers = Vec::with_capacity(sample_count);
	for index in 0..sample_count {
		let header = shdr.data_start + index * SAMPLE_HEADER_SIZE;
		let compressed_start = read_u32(data, header + 20)? as usize;
		let compressed_end = read_u32(data, header + 24)? as usize;
		let loop_start = read_u32(data, header + 28)?;
		let loop_end = read_u32(data, header + 32)?;
		if compressed_start >= compressed_end || compressed_end > compressed.len() {
			return Err(format!("SF3 sample {index} has invalid compressed offsets"));
		}
		let decoded = decode_sample(&compressed[compressed_start..compressed_end], index)?;
		let start = u32::try_from(pcm.len())
			.map_err(|_| "decoded SF3 sample data exceeds the SF2 limit".to_string())?;
		let decoded_len = u32::try_from(decoded.len())
			.map_err(|_| "decoded SF3 sample is too large".to_string())?;
		let end = start
			.checked_add(decoded_len)
			.ok_or_else(|| "decoded SF3 sample data exceeds the SF2 limit".to_string())?;
		if loop_start > loop_end || loop_end > decoded_len {
			return Err(format!("SF3 sample {index} has invalid loop offsets"));
		}
		headers.push((start, end, start + loop_start, start + loop_end));
		pcm.extend(decoded);
	}
	// SF2 requires at least 46 zero-valued guard samples after the final sample.
	pcm.resize(
		pcm.len()
			.checked_add(SAMPLE_DATA_GUARD_SIZE)
			.ok_or_else(|| "decoded SF3 sample data is too large".to_string())?,
		0,
	);

	let pcm_byte_size = pcm
		.len()
		.checked_mul(2)
		.ok_or_else(|| "decoded SF3 sample data is too large".to_string())?;
	let pcm_byte_size_u32 = u32::try_from(pcm_byte_size)
		.map_err(|_| "decoded SF3 sample data exceeds the SF2 limit".to_string())?;
	let old_padded_size = smpl.padded_end - smpl.data_start;
	let new_padded_size = pcm_byte_size + (pcm_byte_size & 1);
	let new_len = data
		.len()
		.checked_sub(old_padded_size)
		.and_then(|value| value.checked_add(new_padded_size))
		.ok_or_else(|| "decoded SoundFont size overflow".to_string())?;
	let mut output = Vec::with_capacity(new_len);
	output.extend_from_slice(&data[..smpl.data_start]);
	for sample in pcm {
		output.extend_from_slice(&sample.to_le_bytes());
	}
	if pcm_byte_size & 1 != 0 {
		output.push(0);
	}
	output.extend_from_slice(&data[smpl.padded_end..]);

	write_u32(&mut output, smpl.size_offset, pcm_byte_size_u32)?;
	let delta = i64::try_from(new_padded_size).unwrap() - i64::try_from(old_padded_size).unwrap();
	let new_sdta_size = i64::from(read_u32(data, sdta.size_offset)?) + delta;
	if !(0..=i64::from(u32::MAX)).contains(&new_sdta_size) {
		return Err("decoded SF3 sdta chunk exceeds the RIFF limit".to_string());
	}
	write_u32(&mut output, sdta.size_offset, new_sdta_size as u32)?;
	let riff_size = u32::try_from(output.len() - 8)
		.map_err(|_| "decoded SF3 exceeds the RIFF size limit".to_string())?;
	write_u32(&mut output, 4, riff_size)?;

	let shdr_shifted = usize::try_from(i64::try_from(shdr.data_start).unwrap() + delta)
		.map_err(|_| "decoded SF3 sample-header offset overflow".to_string())?;
	for (index, (start, end, loop_start, loop_end)) in headers.into_iter().enumerate() {
		let header = shdr_shifted + index * SAMPLE_HEADER_SIZE;
		write_u32(&mut output, header + 20, start)?;
		write_u32(&mut output, header + 24, end)?;
		write_u32(&mut output, header + 28, loop_start)?;
		write_u32(&mut output, header + 32, loop_end)?;
	}
	Ok(output)
}

pub fn load_sound_font(path: &Path) -> Result<SoundFont, String> {
	let data = fs::read(path)
		.map_err(|error| format!("failed to open SoundFont '{}': {error}", path.display()))?;
	let decoded = decode_sf3(&data)
		.map_err(|error| format!("failed to decode SoundFont '{}': {error}", path.display()))?;
	SoundFont::new(&mut Cursor::new(decoded))
		.map_err(|error| format!("failed to load SoundFont '{}': {error}", path.display()))
}

#[cfg(test)]
mod tests {
	use super::{decode_sf3, read_u32};

	#[test]
	fn rejects_invalid_riff() {
		let error = decode_sf3(b"not a soundfont").unwrap_err();
		assert!(error.contains("truncated") || error.contains("invalid"));
	}

	#[test]
	fn reads_little_endian_values() {
		assert_eq!(read_u32(&[0, 1, 2, 3, 4], 1).unwrap(), 0x04030201);
	}
}
