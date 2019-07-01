//
//  Playlist.swift
//  Spotify
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
import Essentials

public extension Spotify {

	struct Playlist: Codable {

		public let id: String
		public let images: [Image]
		public let name: String
		public let owner: Owner?
		public internal(set) var songIDs = [String]()

		private enum CodingKeys: String, CodingKey {
			case id
			case images
			case name
			case owner
		}

		func handleTracks(with handler: Handler<Result<[Spotify.Track], Error>>) {
			guard Spotify.isSignedIn else {
				handler(.failure(SpotifyError.notSignedIn))
				return
			}

			Spotify.handleToken(with: Handler { token in
				let headers = ["Authorization": "Bearer \(token)"]
				var parameters: [String: Any] = ["limit": "50"]
				var tracks = [Spotify.Track]()

				var execute = false {
					didSet {
						HTTP.request(apiURL, endpoint: "/v1/playlists/\(self.id)/tracks", headers: headers, parameters: parameters, with: { (data, _, error) in
							guard let data = data else {
								handler(.failure(error ?? SpotifyError.apiProblem))
								return
							}

							do {
								let decoder = JSONDecoder()
								let pagingObject = try decoder.decode(PagingObject<Playlist.Track>.self, from: data)
								let newTracks = pagingObject.items.map({ return $0.track })

								tracks.append(contentsOf: newTracks)

								if let next = pagingObject.next, let nextURL = URL(string: next), let newParameters = nextURL.parameters {
									parameters.merge(newParameters, uniquingKeysWith: { $1 })
									execute = true
								}
								else {
									handler(.success(tracks))
								}
							}
							catch {
								handler(.failure(error))
							}
						})
					}
				}

				execute = true
			})
		}

	}

	struct Owner: Codable {

		public let displayName: String

		private enum CodingKeys: String, CodingKey {
			case displayName = "display_name"
		}

	}

}

extension Spotify.Playlist {

	struct Track: Codable {

		let track: Spotify.Track

		private enum CodingKeys: String, CodingKey {
			case track
		}

	}

}
