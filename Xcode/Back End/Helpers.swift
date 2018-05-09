// Created by Julian Dunskus

import Foundation

extension Int {
	/// - returns: random value in `[0, upper)`
	static func randomValue(lessThan upper: Int) -> Int {
		return Int(arc4random_uniform(UInt32(upper)))
	}
	
	/// - returns: random value in `[lower, upper)`
	static func randomValue(in range: (lower: Int, upper: Int)) -> Int {
		return range.lower + randomValue(lessThan: range.upper - range.lower)
	}
}

extension FloatingPoint {
	/// - returns: random value in `[0, 1)`
	static func randomValue() -> Self {
		return Self(arc4random()) / Self(UInt32.max)
	}
	
	/// - returns: random value in `[lower, upper)`
	static func randomValue(in range: (lower: Self, upper: Self)) -> Self {
		return range.lower + (range.upper - range.lower) * randomValue()
	}
}

extension Collection where Index == Int {
	func randomElement() -> Element {
		return self[startIndex + .randomValue(lessThan: endIndex)]
	}
}
