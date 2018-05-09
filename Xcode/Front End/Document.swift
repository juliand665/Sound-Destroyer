// Created by Julian Dunskus

import Cocoa

class Document: NSDocument {
	var mainChunk: Main!
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
		var mainTransform = MainTransform(transforming: sampleFrames, accordingTo: mainChunk.common)
		sampleFrames = mainTransform.transform()
		updateChangeCount(.changeDone) // TODO do i need to update this back when saving?
	}
	
	func revert() {
		guard let old = old else {
			Swift.print("No data to revert to!")
			return
		}
		read(from: old)
		updateChangeCount(.changeCleared)
	}
	
	func read(from data: Data) {
		let decoder = AIFFDecoder(for: data)
		mainChunk = decoder.decode()
		sampleFrames = mainChunk.decodeSoundData()
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
