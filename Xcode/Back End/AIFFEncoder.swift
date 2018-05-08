// Created by Julian Dunskus

import Foundation

class AIFFEncoder {
	var data = Data()
	
	func encode(_ main: Main) {
		let mainEncoder = AIFFEncoder()
		main.encode(to: mainEncoder)
		let topLevel = RawChunk(id: .form, data: mainEncoder.data)
		encode(topLevel)
	}
	
	func encode(_ chunk: Chunk, as type: ID) {
		let encoder = AIFFEncoder()
		chunk.encode(to: encoder)
		encode(RawChunk(id: type, data: encoder.data))
	}
	
	func encode(_ rawChunk: RawChunk) {
		print("Encoding chunk at \(data.count)")
		rawChunk.encode(to: self)
	}
	
	func write<T>(_ object: T, length: Int = MemoryLayout<T>.size) {
		var copy = object
		let bytes = Data(bytes: &copy, count: length)
		data += bytes.reversed()
	}
	
	func writeString(_ string: String) {
		data += string.data(using: .ascii)!
		padIfNecessary()
	}
	
	func writeBytes(_ bytes: Data) {
		data += bytes
	}
	
	func padIfNecessary() {
		if data.count % 2 == 1 {
			data.append(0)
		}
	}
}

protocol AIFFEncodable {
	func encode(to encoder: AIFFEncoder)
}
