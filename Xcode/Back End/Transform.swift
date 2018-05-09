// Created by Julian Dunskus

import Foundation

/// `Transform`s should not persist data across runs, but who am I to tell you what you can and can't do?
protocol Transform {
	/**
	Applies the transformation to the data in `main`.
	- precondition: `main` must have at least `maximumLength` sample frames available to read.
	- parameter main: provides a unified I/O point for the sound data, along with some metadata in `common`
	- parameter maximumLength: the maximum amount of frames that should be input or output by the transform
	*/
	func transform(modifying main: inout MainTransform, maximumLength: Int)
}

/// Individually rounds the amplitude of each channel in each frame, with a random overall strength.
struct AmplitudeRounding: Transform {
	func transform(modifying main: inout MainTransform, maximumLength: Int) {
		let strength = Float.randomValue(in: (128, 1024))
		main += main.read(maximumLength).map { frame in
			frame.map {
				Sample(round(Float($0) / strength) * strength)
			}
		}
	}
}

// basically SpeedUp • SlowDown
/// Repeats every `n`th frame multiple times, overriding subsequent frames.
struct TimeRounding: Transform {
	func transform(modifying main: inout MainTransform, maximumLength: Int) {
		let factorRange = (Int(0.0001 * main.common.sampleRate),
						   Int(0.0010 * main.common.sampleRate))
		let factor = Int.randomValue(in: factorRange)
		for _ in 1...maximumLength / factor {
			main += repeatElement(main.read(), count: factor)
			main.skip(factor - 1)
		}
	}
}

/// Repeats every frame multiple times, so as to slow down the overall sound.
struct SlowDown: Transform {
	func transform(modifying main: inout MainTransform, maximumLength: Int) {
		let factor = Int.randomValue(in: (2, 8))
		for _ in 1...maximumLength / factor {
			main += repeatElement(main.read(), count: factor)
		}
	}
}

/// Skips frames in regular intervals, so as to speed up the overall sound.
struct SpeedUp: Transform {
	func transform(modifying main: inout MainTransform, maximumLength: Int) {
		let factor = Int.randomValue(in: (2, 8))
		for _ in 1...maximumLength / factor {
			main.write(main.read())
			main.skip(factor - 1)
		}
	}
}
