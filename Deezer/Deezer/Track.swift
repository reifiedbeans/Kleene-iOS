//
//  ListTrack.swift
//  Deezer
//
//  Created on 2/22/19.
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

public extension Deezer {

	struct ListTrack: Codable {

		public let id: Int
		public let title: String
		public let album: SimpleAlbum
		public let artist: SimpleArtist

		private enum CodingKeys: String, CodingKey {
			case id
			case title
			case artist
			case album
		}

		public func addToLibrary(with handler: Handler<AddTrackResult>) {
			guard isConnected, let accessToken = accessToken else {
				handler(.failure(DeezerError.notLoggedIn))
				return
			}

			let parameters = [
				"access_token": accessToken,
				"track_id": "\(id)"
			]

			HTTP.request(method: .post, apiURL, endpoint: "user/me/tracks", parameters: parameters, with: { (_, response, error) in
				if let error = error {
					handler(.failure(error))
				}
				if let httpResponse = response as? HTTPURLResponse {
					let code = httpResponse.statusCode

					if code == 200 {
						handler(.success)
					}
					else {
						handler(.failure(AddTrackError.badStatusCode(code)))
					}
				}
				else {
					handler(.failure(DeezerError.nonHTTPResponse))
				}
			})
		}

	}

}

extension Deezer.ListTrack {

	public enum AddTrackResult {
		case success
		case failure(Error)
	}

	public enum AddTrackError: Error {
		case badStatusCode(Int)
	}

}
