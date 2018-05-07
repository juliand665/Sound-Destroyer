// Created by Julian Dunskus

import Foundation

protocol Transform {
	// TODO find a solution for slowdown being really long and speedup really short
	
	init(using common: Common)
	
	func transform(_ frames: [SampleFrame]) -> [SampleFrame]
}

struct MainTransform: Transform {
	let transforms: [Transform]
	
	let common: Common
	let lengthRange: (Int, Int)
	
	init(using common: Common) {
		self.common = common
		transforms = [
			AmplitudeRounding(using: common),
			TimeRounding(using: common),
			SlowDown(using: common),
			SpeedUp(using: common),
		]
		lengthRange = (Int(0.5 * common.sampleRate),
					   Int(2.0 * common.sampleRate))
	}
	
	func transform(_ frames: [SampleFrame]) -> [SampleFrame] {
		var transformed: [SampleFrame] = []
		var position = frames.startIndex
		while position < frames.endIndex {
			let length = min(Int.randomValue(in: lengthRange), frames.endIndex - position)
			let transform = transforms[.randomValue(lessThan: transforms.count)]
			let toTransform = frames[position..<position + length]
			transformed += transform.transform(Array(toTransform)) // TODO maybe avoid copying
			position += length
		}
		return transformed
	}
}

struct AmplitudeRounding: Transform {
	let strengthRange = (128, 1024)
	
	init(using common: Common) {}
	
	func transform(_ frames: [SampleFrame]) -> [SampleFrame] {
		let strength = Float(.randomValue(in: strengthRange))
		return frames.map { frame in
			frame.map {
				Sample(round(Float($0) / strength) * strength)
			}
		}
	}
}

// basically SpeedUp • SlowDown
struct TimeRounding: Transform {
	let lengthRange: (Int, Int)
	
	init(using common: Common) {
		lengthRange = (Int(0.0001 * common.sampleRate),
					   Int(0.001  * common.sampleRate))
	}
	
	func transform(_ frames: [SampleFrame]) -> [SampleFrame] {
		let length = Int.randomValue(in: lengthRange)
		return frames
			.lazy
			.enumerated()
			.filter { $0.offset % length == 0 }
			.flatMap { repeatElement($0.element, count: length) }
	}
}

struct SlowDown: Transform {
	let factorRange = (2, 8)
	
	init(using common: Common) {}
	
	func transform(_ frames: [SampleFrame]) -> [SampleFrame] {
		let factor = Int.randomValue(in: factorRange)
		return frames.flatMap { repeatElement($0, count: factor) }
	}
}

struct SpeedUp: Transform {
	let factorRange = (2, 8)
	
	init(using common: Common) {}
	
	func transform(_ frames: [SampleFrame]) -> [SampleFrame] {
		let factor = Int.randomValue(in: factorRange)
		return frames
			.lazy
			.enumerated()
			.filter { $0.offset % factor == 0 }
			.map { $0.element }
	}
}
