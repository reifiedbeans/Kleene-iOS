//
//  DZRArtist.swift
//  Kleene
//
//  Defines extensions to the Deezer Artist class; used to conform to AnyGroup
//
//  Created on 5/7/19.
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

import Deezer
import Essentials
import Foundation

extension Deezer.ListArtist: AnyGroup {

	var identity: String {
		return "\(id)"
	}
	var artistName: String? {
		return nil
	}
	var service: MusicService {
		return .deezer
	}
	var kind: ContentKind {
		return .artist
	}

	func handleArtwork(with handler: Handler<UIImage?>) {
		if let pictureSmall = pictureSmall, let url = URL(string: pictureSmall) {
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
