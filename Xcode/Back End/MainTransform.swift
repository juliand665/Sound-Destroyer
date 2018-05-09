// Created by Julian Dunskus

import Foundation

struct MainTransform {
	/// the minimum length that `Transform.transform` is called with, to avoid an awkward rest of data nobody knows what to do with
	static let minLength = 256
	
	/// the different `Transform`s that can be applied to the sound
	let transforms: [Transform] = [
		AmplitudeRounding(),
		TimeRounding(),
		SlowDown(),
		SpeedUp()
	]
	
	/// some helpful metadata like e.g. the sample rate
	let common: Common
	
	private let input: SampleFrames
	private var position: SampleFrames.Index
	private var output = SampleFrames()
	
	init(transforming frames: SampleFrames, accordingTo common: Common) {
		self.common = common
		self.input = frames
		self.position = frames.startIndex
	}
	
	/**
	Randomly applies transforms to chunks of the sound of random lengths, until the end is reached.
	Calling this method a second time won't do anything.
	- returns: the transformed sound data
	*/
	mutating func transform() -> SampleFrames {
		let lengthRange = (Int(0.5 * common.sampleRate),
						   Int(2.0 * common.sampleRate))
		while position < input.endIndex {
			let length = min(.randomValue(in: lengthRange), input.endIndex - position)
			guard length >= MainTransform.minLength else {
				self += read(length)
				break
			}
			let transform = transforms.randomElement()
			transform.transform(modifying: &self, maximumLength: length)
		}
		assert(position == input.endIndex)
		return output
	}
	
	/// - returns: whether or not there are `count` frames available to read
	func canRead(_ count: Int) -> Bool {
		return position + count <= input.endIndex
	}
	
	/// reads a single frame and returns it
	mutating func read() -> SampleFrame {
		precondition(position + 1 <= input.endIndex)
		defer { position += 1 }
		return input[position]
	}
	
	/// reads `length` frames and returns them
	mutating func read(_ length: Int) -> ArraySlice<SampleFrame> {
		precondition(position + length <= input.endIndex)
		defer { position += length }
		return input[position..<position + length]
	}
	
	/// skips `count` frames with no reading overhead
	mutating func skip(_ count: Int) {
		precondition(position + count <= input.endIndex)
		position += count
	}
	
	/// writes a single frame to the output
	mutating func write(_ frame: SampleFrame) {
		output.append(frame)
	}
	
	/// writes multiple frames to the output
	static func += <Frames> (mainTransform: inout MainTransform, newFrames: Frames) where Frames: Sequence, Frames.Element == SampleFrame {
		mainTransform.output += newFrames
	}
}
