//
//  MusicService.swift
//  Kleene
//
//  Defines all music services used in the application
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

import Essentials
import UIKit

enum MusicService: String, Codable, AnyContent {

	case appleMusic = "Apple Music"
	case deezer = "Deezer"
	case spotify = "Spotify"

	var identity: String {
		return rawValue
	}
	var name: String {
		return rawValue
	}
	var artistName: String? {
		return nil
	}
	var service: MusicService {
		return self
	}
	var kind: ContentKind {
		return .service
	}

	func handleArtwork(with handler: Handler<UIImage?>) {
		handler(nil)
	}

}
