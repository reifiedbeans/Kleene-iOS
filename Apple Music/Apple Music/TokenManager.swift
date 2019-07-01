//
//  TokenManager.swift
//  Apple Music
//
//  Created on 4/14/19.
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

extension AppleMusic {

	class TokenManager {

		private static let decoder: JSONDecoder = {
			let decoder = JSONDecoder()

			decoder.dateDecodingStrategy = .iso8601

			return decoder
		}()
		private static let swapURL = URL(string: "https://kleene-apple-music.herokuapp.com/token")!
		private static let accessKey = "accessKey"
		private static let userTokenKey = "userTokenKey"
		private static var access: Access? = {
			if let data = UserDefaults.standard.data(forKey: accessKey) {
				return try? decoder.decode(Access.self, from: data)
			}
			else {
				return nil
			}
		}() {
			didSet {
				guard access != oldValue else {
					assertionFailure()
					return
				}

				userToken = nil

				if let access = access {
					let data = try? JSONEncoder().encode(access)

					UserDefaults.standard.set(data, forKey: accessKey)
				}
				else {
					UserDefaults.standard.set(nil, forKey: accessKey)
				}
			}
		}
		private static var userToken: String? = {
			return UserDefaults.standard.string(forKey: userTokenKey)
		}() {
			didSet {
				UserDefaults.standard.set(userToken, forKey: userTokenKey)
			}
		}

		static func handleDeveloperToken(with handler: Handler<Result<String, Swift.Error>>) {
			if let access = access, !access.isExpired {
				handler(.success(access.token))
			}
			else {
				// The user token has expired if the developer token has.
				TokenManager.userToken = nil

				do {
					/// This is the maximum duration for which an Apple Music token can be valid.
					let maxDuration = 15777000 as UInt
					let tokenRequest = TokenRequest(duration: maxDuration)
					let requestData = try JSONEncoder().encode(tokenRequest)

					HTTP.request(method: .post, swapURL, headers: ["Content-Type": "application/json"], body: requestData, with: { (data, _, error) in
						guard let data = data else {
							handler(.failure(error ?? Error.swappingError))
							return
						}

						do {
							let access = try decoder.decode(Access.self, from: data)

							TokenManager.access = access
							handler(.success(access.token))
						}
						catch {
							handler(.failure(error))
						}
					})
				}
				catch {
					handler(.failure(error))
				}
			}
		}

		static func handleUserToken(with handler: Handler<Result<String, Swift.Error>>) {
			if let access = access, !access.isExpired, let userToken = userToken {
				handler(.success(userToken))
			}
			else {
				handleDeveloperToken(with: Handler { result in
					do {
						let developerToken = try result.get()

						AppleMusic.cloudServiceController.requestUserToken(forDeveloperToken: developerToken, completionHandler: { (token, error) in
							guard let token = token else {
								handler(.failure(error ?? Error.userTokenError))
								return
							}

							TokenManager.userToken = token
							handler(.success(token))
						})
					}
					catch {
						handler(.failure(error))
					}
				})
			}
		}

		static func handleTokens(with handler: Handler<Result<(developer: String, user: String), Swift.Error>>) {
			handleDeveloperToken(with: Handler { result in
				do {
					let developerToken = try result.get()

					handleUserToken(with: Handler { result in
						do {
							let userToken = try result.get()

							handler(.success((developerToken, userToken)))
						}
						catch {
							handler(.failure(error))
						}
					})
				}
				catch {
					handler(.failure(error))
				}
			})
		}

	}

}
