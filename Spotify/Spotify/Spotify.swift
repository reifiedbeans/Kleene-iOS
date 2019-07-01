//
//  Spotify.swift
//  Spotify
//
//  Created on 2/6/19.
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
import SpotifyiOS

public class Spotify: NSObject, SPTSessionManagerDelegate {

	private static var didRestoreSession = false
    private static let shared = Spotify()

	public static var isSignedIn: Bool {
		if !didRestoreSession {
			restoreSession()
		}

		return shared.sessionManager.session != nil
	}
	static func handleToken(with handler: Handler<String>) {
		guard let session = shared.sessionManager.session else {
			return
		}

		if !session.isExpired {
			handler(session.accessToken)
		}
		else {
			renewCompletions.append(handler)
			shared.sessionManager.renewSession()
		}
	}

    private lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: "a0b460d767fa4227951f7d881b5c5bd1", redirectURL: URL(string: "kleene://spotify-login-callback")!)

        configuration.tokenSwapURL = URL(string: "https://kleene-spotify.herokuapp.com/api/token")!
        configuration.tokenRefreshURL = URL(string: "https://kleene-spotify.herokuapp.com/api/refresh_token")!

        return configuration
    }()
	private lazy var sessionManager = SPTSessionManager(configuration: configuration, delegate: self)

	private static var initiateCompletion: Handler<Error?>?
	private static var renewCompletions: [Handler<String>] = []

	public func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
		Spotify.initiateCompletion?(nil)
		Spotify.initiateCompletion = nil
		Spotify.storeSession()
	}
	public func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
		let token = session.accessToken

		while !Spotify.renewCompletions.isEmpty {
			Spotify.renewCompletions.removeFirst()(token)
		}
	}
	public func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
		Spotify.initiateCompletion?(error)
		Spotify.initiateCompletion = nil
	}

	public static func signIn(completion: Handler<Error?>? = nil) {
		Spotify.initiateCompletion = completion
		shared.sessionManager.initiateSession(with: [.userLibraryRead, .playlistReadPrivate, .appRemoteControl, .userLibraryModify], options: .default)
	}
	public static func signOut() {
		shared.sessionManager.session = nil
		Spotify.storeSession()
	}
	public static func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {
		shared.sessionManager.application(application, open: url, options: options)
	}

	// Session Storing
	private static let sessionPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(".spotifySession").path
	private static func storeSession() {
		let session = shared.sessionManager.session as Any

		NSKeyedArchiver.archiveRootObject(session, toFile: sessionPath)
	}
	private static func restoreSession() {
		if let session = NSKeyedUnarchiver.unarchiveObject(withFile: sessionPath) as? SPTSession {
			shared.sessionManager.session = session
		}

		didRestoreSession = true
	}

	/// https://api.spotify.com
	static let apiURL = URL(string: "https://api.spotify.com")!
	private static let decoder: JSONDecoder = {
		let decoder = JSONDecoder()

		decoder.dateDecodingStrategy = .iso8601

		return decoder
	}()

	public static func handleUser(with handler: Handler<Result<User, Error>>) {
		guard isSignedIn else {
			handler(.failure(SpotifyError.notSignedIn))
			return
		}

		Spotify.handleToken(with: Handler { token in
			let headers = ["Authorization": "Bearer \(token)"]

			HTTP.request(apiURL, endpoint: "/v1/me", headers: headers, with: { (data, _, error) in
				guard let data = data else {
					handler(.failure(error ?? SpotifyError.apiProblem))
					return
				}

				do {
					let user = try decoder.decode(User.self, from: data)

					handler(.success(user))
				}
				catch {
					handler(.failure(error))
				}
			})
		})
	}

	public static func handleTracks(with handler: Handler<Result<[Track], Error>>) {
		guard isSignedIn else {
			handler(.failure(SpotifyError.notSignedIn))
			return
		}

		Spotify.handleToken(with: Handler { token in
			var parameters: [String: Any] = ["limit": "50"]
			let headers = ["Authorization": "Bearer \(token)"]

			var tracks = [Track]()
			var execute = false {
				didSet {
					HTTP.request(apiURL, endpoint: "/v1/me/tracks", headers: headers, parameters: parameters, with: { (data, _, error) in
						guard let data = data else {
							handler(.failure(error ?? SpotifyError.apiProblem))
							return
						}

						do {
							let pagingObject = try decoder.decode(PagingObject<SavedTrack>.self, from: data)
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

	public static func handlePlaylists(with handler: Handler<Result<[Playlist], Error>>) {
		guard isSignedIn else {
			handler(.failure(SpotifyError.notSignedIn))
			return
		}

		Spotify.handleToken(with: Handler { token in
			var parameters: [String: Any] = ["limit": "50"]
			let headers = ["Authorization": "Bearer \(token)"]

			var playlists = [Playlist]()
			var execute = false {
				didSet {
					HTTP.request(apiURL, endpoint: "/v1/me/playlists", headers: headers, parameters: parameters, with: { (data, _, error) in
						guard let data = data else {
							handler(.failure(error ?? SpotifyError.apiProblem))
							return
						}

						do {
							let pagingObject = try decoder.decode(PagingObject<Playlist>.self, from: data)

							playlists.append(contentsOf: pagingObject.items)

							if let next = pagingObject.next, let nextURL = URL(string: next), let newParameters = nextURL.parameters {
								parameters.merge(newParameters, uniquingKeysWith: { return $1 })
								execute = true
							}
							else {
								let group = DispatchGroup()
								let mutex = Mutex()
								var didAlreadyHandle = false

								for (index, playlist) in playlists.enumerated() {
									group.enter()

									playlist.handleTracks(with: Handler { result in
										mutex.lock()

										if !didAlreadyHandle {
											switch result {
											case .failure(let error):
												handler(.failure(error))
												didAlreadyHandle = true
												mutex.unlock()

											case .success(let tracks):
												mutex.unlock()
												playlists[index].songIDs = tracks.map({ $0.id })
											}
										}

										group.leave()
									})
								}

								group.notify(queue: .global(qos: .default), execute: {
									handler(.success(playlists))
								})
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

	/// Searches the Spotify API using the provided query. See Spotify API documentation for information
	/// on how to specify parameters such as artist.
	///
	/// - Parameters:
	///   - query: the string to query the Spotify API with. See Spotify API documentation for information on specifying parameters such as artist
	///   - type: the type of item you would like to search for. Right now, Spotify.Track and Spotify.Playlist are supported.
	///   - limit: the maximum amount of search results. This must be in the range [1, 50].
	///   - handler: a Handler to handle the results of the search
	public static func handleSearch<T: Codable>(query: String, type: T.Type, limit: UInt = 50, with handler: Handler<Result<[T], Error>>) {
		guard isSignedIn else {
			handler(.failure(SpotifyError.notSignedIn))
			return
		}

		var typeDescription: String

		// I wasn't able to get a switch to work.
		if type == Track.self {
			typeDescription = "track"
		}
		else if type == Playlist.self {
			typeDescription = "playlist"
		}
		else {
			handler(.failure(SpotifyError.invalidSearchType))
			return
		}

		Spotify.handleToken(with: Handler { token in
			assert(limit >= 1 && limit <= 50)

			let limit = max(1, min(50, limit))
			let parameters = [
				"q": query,
				"type": typeDescription,
				"limit": "\(limit)"
			]

			HTTP.request(apiURL, endpoint: "/v1/search", headers: ["Authorization": "Bearer \(token)"], parameters: parameters, with: { (data, _, error) in
				guard let data = data else {
					handler(.failure(error ?? SpotifyError.apiProblem))
					return
				}

				typeDescription.append("s")

				do {
					guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any], let pagingObject = dict[typeDescription] else {
						handler(.failure(SpotifyError.invalidSearchResults))
						return
					}

					let pagingData = try JSONSerialization.data(withJSONObject: pagingObject)
					let paging = try decoder.decode(PagingObject<T>.self, from: pagingData)

					handler(.success(paging.items))
				}
				catch {
					handler(.failure(error))
				}
			})
		})
	}

}
