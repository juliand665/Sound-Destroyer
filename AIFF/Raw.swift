// Created by Julian Dunskus

import Foundation

enum ID: Equatable, CustomStringConvertible {
	case form, common, soundData
	case unknown(String)
	
	init(_ rawID: String) {
		switch rawID {
		case "FORM":
			self = .form
		case "COMM":
			self = .common
		case "SSND":
			self = .soundData
		default:
			self = .unknown(rawID)
		}
	}
	
	var rawID: String {
		switch self {
		case .form:
			return "FORM"
		case .common:
			return "COMM"
		case .soundData:
			return "SSND"
		case .unknown(let raw):
			return raw
		}
	}
	
	var description: String {
		return rawID
	}
	
	static func == (lhs: ID, rhs: ID) -> Bool {
		return lhs.rawID == rhs.rawID
	}
}

struct RawChunk {
	var id: ID
	var data: Data // preceded by UInt32 length
	
	init(id: ID, data: Data) {
		self.id = id
		self.data = data
	}
	
	init(from decoder: AIFFDecoder) {
		let rawID = decoder.readString(length: 4)
		self.id = ID(rawID)
		let size = Int(decoder.read() as UInt32)
		self.data = decoder.readBytes(size)
		decoder.padIfNecessary()
		print("Read chunk of type \(id) with \(size) bytes")
	}
	
	func encode(to encoder: AIFFEncoder) {
		encoder.writeString(id.rawID)
		encoder.write(UInt32(data.count))
		encoder.writeBytes(data)
		encoder.padIfNecessary()
		print("Wrote chunk of type \(id) with \(data.count) bytes")
	}
	
	func decodeContent<T: Chunk>(as type: T.Type = T.self) -> T {
		return T(from: AIFFDecoder(for: data))
	}
}
