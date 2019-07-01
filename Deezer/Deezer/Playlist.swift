//
//  DZRPlaylist.swift
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

	/// The type used with a list of playlists is requested, such as the user's playlists.
	struct ListPlaylist: Codable {

		public let id: Int
		public let title: String
		public let pictureSmall: String?
		public let tracklist: URL
		public let creator: Creator?
		public internal(set) var songIDs = [String]()

		private enum CodingKeys: String, CodingKey {
			case id
			case title
			case pictureSmall = "picture_small"
			case tracklist
			case creator
		}

	}

	struct Creator: Codable {
		public let name: String
	}

}
