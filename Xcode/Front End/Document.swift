// Created by Julian Dunskus

import Cocoa

class Document: NSDocument {
	var mainChunk: Main!
	var mainTransform: MainTransform!
	var old: Data!
	var sampleFrames: [SampleFrame]!
	
	override class var autosavesInPlace: Bool {
		return false
	}
	
	override func makeWindowControllers() {
		let storyboard = NSStoryboard(name: .init("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: .init("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
	}
	
	func transmogrify() {
		sampleFrames = mainTransform.transform(sampleFrames)
		updateChangeCount(.changeDone) // TODO do i need to update this back when saving?
	}
	
	func revert() {
		read(from: old)
		updateChangeCount(.changeCleared)
	}
	
	func read(from data: Data) {
		let decoder = AIFFDecoder(for: data)
		mainChunk = decoder.decode()
		sampleFrames = mainChunk.decodeSoundData()
		mainTransform = MainTransform(using: mainChunk.common)
	}
	
	func data() -> Data {
		let encoder = AIFFEncoder()
		mainChunk.encodeSoundData(sampleFrames)
		encoder.encode(mainChunk)
		return encoder.data
	}
	
	override func read(from data: Data, ofType typeName: String) throws {
		old = data
		read(from: data)
	}
	
	override func data(ofType typeName: String) throws -> Data {
		return data()
	}
}

extension Int {
	/// upper bound is excluded
	static func randomValue(lessThan upper: Int) -> Int {
		return Int(arc4random_uniform(UInt32(upper)))
	}
	
	/// upper bound is excluded
	static func randomValue(in range: (lower: Int, upper: Int)) -> Int {
		return range.lower + randomValue(lessThan: range.upper - range.lower)
	}
}
