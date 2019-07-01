//
//  Song.swift
//  Apple Music
//
//  Created on 4/13/19.
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

import Essentials
import Foundation

public extension AppleMusic {

	struct Song: Codable {

		let attributes: Attributes
		let id: String
		let type: String

		public func addToLibrary(with handler: Handler<Swift.Error?>) {
			TokenManager.handleTokens(with: Handler { result in
				do {
					let (developerToken, userToken) = try result.get()
					let headers = [
						"Authorization": "Bearer \(developerToken)",
						"Music-User-Token": userToken
					]
					let parameters = ["ids[songs]": self.id]

					HTTP.request(method: .post, apiURL, endpoint: "me/library", headers: headers, parameters: parameters, with: { (_, response, _) in
						if let httpResponse = response as? HTTPURLResponse {
							let code = httpResponse.statusCode

							if code == 202 {
								handler(nil)
							}
							else {
								handler(NSError(domain: "Apple Music", code: code, userInfo: nil))
							}
						}
						else {
							handler(Error.nonHTTPResponse)
						}
					})
				}
				catch {
					handler(error)
				}
			})
		}

	}

}

extension AppleMusic.Song {

	struct Attributes: Codable {

		let albumName: String
		let artistName: String
		let name: String

	}

}
