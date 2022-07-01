
import Foundation
struct Message : Codable {
	let accessToken : String?
	let refreshToken : String?
	let expiresIn : Int?
	let expiresUnit : String?
	let requiredPasswordUpdate : Bool?

	enum CodingKeys: String, CodingKey {

		case accessToken = "accessToken"
		case refreshToken = "refreshToken"
		case expiresIn = "expiresIn"
		case expiresUnit = "expiresUnit"
		case requiredPasswordUpdate = "requiredPasswordUpdate"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		accessToken = try values.decodeIfPresent(String.self, forKey: .accessToken)
		refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
		expiresIn = try values.decodeIfPresent(Int.self, forKey: .expiresIn)
		expiresUnit = try values.decodeIfPresent(String.self, forKey: .expiresUnit)
		requiredPasswordUpdate = try values.decodeIfPresent(Bool.self, forKey: .requiredPasswordUpdate)
	}

}
