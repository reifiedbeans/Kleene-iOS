//
//  Deezer.swift
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
import DeezerSDK

public final class Deezer: NSObject {

	static let appID = "329902"
	public static var isConnected: Bool {
		return DeezerManager.shared.isConnected
	}
	static var accessToken: String? {
		return DeezerManager.shared.deezerConnect?.accessToken
	}

	public static func login(with handler: Handler<LoginResult>) {
		DeezerManager.shared.login(with: handler)
	}
	public static func logout() {
		DeezerManager.shared.logout()
	}

	static let apiURL = URL(string: "https://api.deezer.com/")!

	static let jsonDecoder: JSONDecoder = {
		let decoder = JSONDecoder()

		decoder.dateDecodingStrategy = .custom({ decoder in
			let container = try decoder.singleValueContainer()

			if let milliseconds = try? container.decode(Int.self) {
				return Date(timeIntervalSince1970: Double(milliseconds))
			}
			else {
				let string = try container.decode(String.self)
				let format = DateFormatter()

				if string.contains(" ") {
					format.dateFormat = "yyyy-MM-dd HH:mm:ss"
				}
				else {
					format.dateFormat = "yyyy-MM-dd"
				}

				if let date = format.date(from: string) {
					return date
				}
				else {
					let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unable to interpret this Date.")

					throw DecodingError.typeMismatch(Date.self, context)
				}
			}
		})

		return decoder
	}()

	private static func handle<T: Codable>(_ url: URL = apiURL, endpoint: String? = nil, parameters: [String: String]? = nil, with handler: Handler<Result<[T], Error>>) {
		guard isConnected, let accessToken = accessToken else {
			handler(.failure(DeezerError.notLoggedIn))
			return
		}

		var params = ["access_token": accessToken]

		if let additionalParams = parameters {
			params.merge(additionalParams, uniquingKeysWith: { $1 })
		}

		HTTP.request(url, endpoint: endpoint, parameters: params, with: { (data, response, error) in
			guard let data = data else {
				handler(.failure(error ?? DeezerError.apiProblem))
				return
			}

			do {
				let response = try jsonDecoder.decode(Response<T>.self, from: data)

				handler(.success(response.data))
			}
			catch {
				handler(.failure(error))
			}
		})
	}

	public static func handleTracks(with handler: Handler<Result<[ListTrack], Error>>) {
		handle(endpoint: "user/me/tracks", with: handler)
	}

	public static func handleAlbums(with handler: Handler<Result<[ListAlbum], Error>>) {
		handle(endpoint: "user/me/albums", with: handler)
	}

	public static func handleArtists(with handler: Handler<Result<[ListArtist], Error>>) {
		handle(endpoint: "user/me/artists", with: handler)
	}

	public static func handlePlaylists(with handler: Handler<Result<[ListPlaylist], Error>>) {
		handle(endpoint: "user/me/playlists", with: Handler<Result<[ListPlaylist], Error>> { result in
			switch result {
			case .failure(let error):
				handler(.failure(error))

			case .success(var playlists):
				let mutex = Mutex()
				let group = DispatchGroup()
				var didHandle = false

				for (index, playlist) in playlists.enumerated() {
					group.enter()

					handle(playlist.tracklist, with: Handler<Result<[ListTrack], Error>> { result in
						mutex.lock()

						if !didHandle {
							switch result {
							case .failure(let error):
								handler(.failure(error))
								didHandle = true
								mutex.unlock()

							case .success(let tracks):
								mutex.unlock()
								let songIDs = tracks.map({ "\($0.id)" })

								playlists[index].songIDs.append(contentsOf: songIDs)
							}
						}

						group.leave()
					})
				}

				group.notify(queue: .global(qos: .default), execute: {
					handler(.success(playlists))
				})
			}
		})
	}

	public static func handleSearch(query: String, with handler: Handler<Result<[ListTrack], Error>>) {
		handle(endpoint: "search", parameters: ["q": query], with: handler)
	}

}
