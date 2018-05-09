// Created by Julian Dunskus

import Foundation

typealias Chunk = AIFFDecodable & AIFFEncodable

struct Main: Chunk {
	var common: Common!
	var soundData: SoundData!
	var chunks: [RawChunk]
	
	init(from decoder: AIFFDecoder) {
		let name = decoder.readString(length: 4)
		assert(name == "AIFF")
		chunks = []
		while !decoder.isAtEnd {
			let raw = decoder.decodeRawChunk()
			switch raw.id {
			case .common:
				assert(common == nil)
				common = raw.decodeContent(as: Common.self)
			case .soundData:
				assert(soundData == nil)
				soundData = raw.decodeContent(as: SoundData.self)
			default:
				chunks.append(raw)
			}
		}
		assert(common != nil)
		assert(soundData != nil)
	}
	
	func encode(to encoder: AIFFEncoder) {
		encoder.writeString("AIFF")
		encoder.encode(common, as: .common)
		encoder.encode(soundData, as: .soundData)
		for chunk in chunks {
			encoder.encode(chunk)
		}
	}
	
	func decodeSoundData() -> [SampleFrame] {
		assert(soundData.offset == 0)
		assert(soundData.blockSize == 0)
		
		let decoder = AIFFDecoder(for: soundData.soundData)
		defer { assert(decoder.isAtEnd) }
		return (1...common.sampleFrameCount)
			.map { _ in SampleFrame(from: decoder, common: common) }
	}
	
	mutating func encodeSoundData(_ frames: [SampleFrame]) {
		let encoder = AIFFEncoder()
		for frame in frames {
			frame.encode(to: encoder, common: common)
		}
		soundData.soundData = encoder.data
		common.sampleFrameCount = UInt32(frames.count)
	}
}

struct Common: Chunk {
	var channelCount: Int16
	/// How many sample frames there are. Each frame contains `channelCount` samples. 
	var sampleFrameCount: UInt32
	/// how many bits (`1...32`) each sample consists of
	var sampleSize: Int16
	/// how many sample frames there are per second
	var sampleRate: Float80
	
	init(from decoder: AIFFDecoder) {
		channelCount = decoder.read()
		sampleFrameCount = decoder.read()
		sampleSize = decoder.read()
		sampleRate = decoder.read(length: 10)
	}
	
	func encode(to encoder: AIFFEncoder) {
		encoder.write(channelCount)
		encoder.write(sampleFrameCount)
		encoder.write(sampleSize)
		encoder.write(sampleRate, length: 10)
	}
}

struct SoundData: Chunk {
	/// how many bytes of empty space there are before the first byte of sound (for block-aligned data; 0 by default)
	var offset: UInt32
	/// size of the blocks that the sound data is aligned to, in bytes (used in conjunction with `offset`)
	var blockSize: UInt32
	var soundData: Data
	
	init(from decoder: AIFFDecoder) {
		offset = decoder.read()
		blockSize = decoder.read()
		soundData = decoder.readBytes(decoder.data.endIndex - decoder.position)
	}
	
	func encode(to encoder: AIFFEncoder) {
		encoder.write(offset)
		encoder.write(blockSize)
		encoder.writeBytes(soundData)
	}
}

typealias SampleFrames = [SampleFrame]

struct SampleFrame {
	/// the sample at this time for each channel
	var samples: [Sample]
	
	init(from decoder: AIFFDecoder, common: Common) {
		assert(common.sampleSize == 16)
		samples = (1...common.channelCount)
			.map { _ in Sample(decoder.read() as Int16) }
	}
	
	func encode(to encoder: AIFFEncoder, common: Common) {
		assert(common.sampleSize == 16)
		for sample in samples {
			encoder.write(Int16(sample))
		}
	}
	
	func map(_ transform: (Sample) throws -> Sample) rethrows -> SampleFrame {
		var copy = self
		copy.samples = try samples.map(transform)
		return copy
	}
}

typealias Sample = Int32 // samples are 32-bit at most
