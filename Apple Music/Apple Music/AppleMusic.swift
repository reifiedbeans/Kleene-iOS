//
//  AppleMusic.swift
//  Apple Music
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
import StoreKit
import MediaPlayer
import Essentials

public class AppleMusic {

	static let cloudServiceController = SKCloudServiceController()
	private static let musicPlayerController = MPMusicPlayerController.applicationQueuePlayer

	static var subscribeViewController: SKCloudServiceSetupViewController {
		let controller = SKCloudServiceSetupViewController()

		controller.load(options: [.action: SKCloudServiceSetupAction.subscribe], completionHandler: nil)

		return controller
	}

	public static var isAuthorized: Bool {
		return authorizationStatus == .authorized
	}

	public static var authorizationStatus: SKCloudServiceAuthorizationStatus {
		return SKCloudServiceController.authorizationStatus()
	}

    static var musicPlaybackTime: TimeInterval {
        get {
            return musicPlayerController.currentPlaybackTime
        }
        set {
            musicPlayerController.currentPlaybackTime = newValue
        }
    }

	public static func requestAuthorization(handler: @escaping (SKCloudServiceAuthorizationStatus) -> Void) {
		SKCloudServiceController.requestAuthorization(handler)
	}

	static func handleCapabilities(with completion: @escaping (SKCloudServiceCapability, Swift.Error?) -> Void) {
		guard isAuthorized else {
			return
		}

		cloudServiceController.requestCapabilities(completionHandler: completion)
	}

	public static var songs: [MediaSong]? {
		guard isAuthorized else {
			return nil
		}

		return MPMediaQuery.songs().items?.compactMap(MediaSong.init)
	}
	public static var albums: [MediaAlbum]? {
		guard isAuthorized else {
			return nil
		}

		return MPMediaQuery.albums().items?.compactMap(MediaAlbum.init)
	}
	public static var artists: [MediaArtist]? {
		guard isAuthorized else {
			return nil
		}

		return MPMediaQuery.artists().items?.compactMap(MediaArtist.init)
	}
	public static var playlists: [MediaPlaylist]? {
		guard isAuthorized else {
			return nil
		}

		return MPMediaQuery.playlists().collections?.compactMap(MediaPlaylist.init)
	}

	static let apiURL = URL(string: "https://api.music.apple.com/v1/")!

	public static func handleSearch(term: String, limit: UInt = 25, with handler: Handler<Result<[Song], Swift.Error>>) {
		guard isAuthorized else {
			handler(.failure(Error.notAuthorized))
			return
		}

		cloudServiceController.requestStorefrontCountryCode(completionHandler: { (storefront, error) in
			guard let storefront = storefront else {
				handler(.failure(error ?? Error.storefrontProblem))
				return
			}

			TokenManager.handleDeveloperToken(with: Handler { result in
				switch result {
				case .failure(let error):
					handler(.failure(error))

				case .success(let token):
					let headers = [
						"Authorization": "Bearer \(token)"
					]
					let parameters = [
						"term": term.replacingOccurrences(of: " ", with: "+"),
						"limit": "\(max(1, min(25, limit)))"
					]

					HTTP.request(apiURL, endpoint: "catalog/\(storefront)/search", headers: headers, parameters: parameters, with: { (data, _, error) in
						guard let data = data else {
							handler(.failure(error ?? Error.apiProblem))
							return
						}

						do {
							let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
							let songs = searchResponse.results.songs?.data

							handler(.success(songs ?? []))
						}
						catch {
							handler(.failure(error))
						}
					})
				}
			})
		})
	}

	public static func addToLibrary(song: Song, with handler: Handler<Result<Int, Swift.Error>>) {
		TokenManager.handleTokens(with: Handler { result in
			do {
				let (developerToken, userToken) = try result.get()
				let headers = [
					"Authorization": "Bearer \(developerToken)",
					"Music-User-Token": userToken
				]
				let parameters = ["ids[songs]": song.id]

				HTTP.request(method: .post, apiURL, endpoint: "me/library", headers: headers, parameters: parameters, with: { (_, response, _) in
					if let httpResponse = response as? HTTPURLResponse {
						guard httpResponse.statusCode == 202 else {
							handler(.failure(NSError(domain: "Apple Music", code: httpResponse.statusCode, userInfo: nil)))
							return
						}

						handler(.success(httpResponse.statusCode))
					}
					else {
						handler(.failure(Error.nonHTTPResponse))
					}
				})
			}
			catch {
				handler(.failure(error))
			}
		})
	}

    static func playbackDuration() -> Double {
        return musicPlayerController.nowPlayingItem?.playbackDuration ?? 0
    }

}

extension AppleMusic {

	enum Error: String, Swift.Error {

		case apiProblem = "There was a problem with the Apple Music API."
		case nonHTTPResponse = "The Apple Music API returned a non-HTTP response."
		case notAuthorized = "Kleene is not authorized to view Apple Music content."
		case storefrontProblem = "There was a problem getting the Apple Music storefront."
		case swappingError = "There was an error retrieving an Apple Music Developer token."
		case userTokenError = "There was an error retrieving the user token for Apple Music."

	}

	struct Artwork: Codable {

		let width, height: Int
		let url: String

	}

	enum Kind: String, Codable {

		case song
		case album
		case playlist

	}

	enum ResourceType: String, Codable {

		case libraryAlbums = "library-albums"
		case librarySongs = "library-songs"
		case libraryArtists = "library-artists"
		case libraryPlaylists = "library-playlists"

	}

}
