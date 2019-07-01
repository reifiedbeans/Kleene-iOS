//
//  Track.swift
//  Spotify
//
//  Created on 2/21/19.
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
import Essentials

public extension Spotify {

	struct SavedTrack: Codable {

		let addedAt: Date
		let track: Track

		private enum CodingKeys: String, CodingKey {
			case addedAt = "added_at"
			case track
		}

	}

	struct Track: Codable {

		public let album: SimpleAlbum
		public let artists: [SimpleArtist]
		public let id: String
		public let name: String

		private enum CodingKeys: String, CodingKey {
			case album
			case artists
			case id
			case name
		}

		/// Adds this track to the user's Spotify library.
		///
		/// - Parameter handler: a Result Handler that is passed an error if one occurs. If the operation succeeds, handler is called with nil.
		public func addToLibrary(with handler: Handler<Error?>) {
			guard isSignedIn else {
				handler(SpotifyError.notSignedIn)
				return
			}

			Spotify.handleToken(with: Handler { token in
				HTTP.request(method: .put, apiURL, endpoint: "/v1/me/tracks", headers: ["Authorization": "Bearer \(token)"], parameters: ["ids": self.id], with: { (_, response, error) in
					if let error = error {
						handler(error)
					}
					else if let httpResponse = response as? HTTPURLResponse {
						let statusCode = httpResponse.statusCode

						if statusCode == 200 {
							handler(nil)
						}
						else {
							handler(StatusCodeError.badStatusCode(statusCode))
						}
					}
					else {
						handler(SpotifyError.nonHTTPResponse)
					}
				})
			})
		}

	}

	struct SimpleAlbum: Codable, Hashable {

		public let artists: [SimpleArtist]
		public let id: String
		public let images: [Image]
		public let name: String

		private enum CodingKeys: String, CodingKey {
			case artists
			case id
			case images
			case name
		}

	}

	struct SimpleArtist: Codable, Hashable {

		public let id: String
		public let name: String

		private enum CodingKeys: String, CodingKey {
			case id
			case name
		}

	}

}
