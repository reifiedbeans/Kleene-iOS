//
//  SPTTrack.swift
//  Kleene
//
//  Defines extensions to the Spotify Track class; used to conform to AnyGroup
//
//  Created on 5/5/19.
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
import Spotify

extension Spotify.Track: AnySong {

	var identity: String {
		return id
	}
	var albumID: String {
		return album.identity
	}
	var artistID: String {
		return artists.first?.identity ?? ""
	}
	var artistName: String? {
		return artists.map({ $0.name }).joined(separator: ", ")
	}
	var albumName: String {
		return album.name
	}
	var kind: ContentKind {
		return .song
	}
	var service: MusicService {
		return .spotify
	}

	func handleArtwork(with handler: Handler<UIImage?>) {
		if let url = album.images.last?.url {
			let request = URLRequest(url: url)

			imageDownloader.download(request, completion: { response in
				handler(response.result.value)
			})
		}
		else {
			handler(nil)
		}
	}

}
