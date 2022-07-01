import Foundation
struct AuthResponse : Codable {
	let success : Bool?
	let message : Message?

	enum CodingKeys: String, CodingKey {
		case success = "success"
		case message = "message"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		success = try values.decodeIfPresent(Bool.self, forKey: .success)
		message = try values.decodeIfPresent(Message.self, forKey: .message)
	}

}
