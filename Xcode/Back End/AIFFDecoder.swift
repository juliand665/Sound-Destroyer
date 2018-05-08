// Created by Julian Dunskus

import Foundation

class AIFFDecoder {
	var data: Data
	var position: Data.Index
	
	var isAtEnd: Bool {
		return position == data.endIndex
	}
	
	init(for data: Data) {
		self.data = data
		self.position = data.startIndex
	}
	
	func decode() -> Main {
		let topLevel = decodeRawChunk()
		assert(topLevel.id == .form)
		let mainDecoder = AIFFDecoder(for: topLevel.data)
		return Main(from: mainDecoder)
	}
	
	func decodeRawChunk() -> RawChunk {
		print("Decoding chunk at \(position)")
		return RawChunk(from: self)
	}
	
	func read<T>(length: Int = MemoryLayout<T>.size) -> T {
		return readBytes(length).unsafeCast()
	}
	
	func readString(length: Int) -> String {
		defer { padIfNecessary() }
		return String(bytes: readBytes(length), encoding: .ascii)!
	}
	
	func readBytes(_ count: Int) -> Data {
		precondition(position + count <= data.endIndex)
		defer { position += count }
		return data[position..<position + count]
	}
	
	func padIfNecessary() {
		if (position - data.startIndex) % 2 == 1 {
			position += 1
		}
	}
}

extension Data {
	func unsafeCast<T>(to type: T.Type = T.self) -> T {
		return Data(reversed()).withUnsafeBytes { $0.pointee }
	}
}

protocol AIFFDecodable {
	init(from decoder: AIFFDecoder)
}
