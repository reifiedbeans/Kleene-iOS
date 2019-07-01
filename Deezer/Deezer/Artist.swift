//
//  DZRArtist.swift
//  Deezer
//
//  Created on 2/26/19.
//  Copyright © 2019 The Kleene Authors.
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//		http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.
//

import Foundation

public extension Deezer {

	/// The type used when an artist is used in another type, such as a track.
	struct SimpleArtist: Codable {

		public let id: Int
		public let name: String

		private enum CodingKeys: String, CodingKey {
			case id
			case name
		}

	}

	/// The type used when a list of artists is requested, such as the user's artists.
	struct ListArtist: Codable {

		public let id: Int
		public let name: String
		public let pictureSmall: String?

		private enum CodingKeys: String, CodingKey {
			case id
			case name
			case pictureSmall = "picture_small"
		}

	}

}
