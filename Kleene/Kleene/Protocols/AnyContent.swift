//
//  AnyContent.swift
//  Kleene
//
//  Defines any piece of content in the application
//
//  Created on 5/8/19.
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

import UIKit
import Essentials

protocol AnyContent {

	var identity: String { get }
	var name: String { get }
	var artistName: String? { get }
	var kind: ContentKind { get }
	var service: MusicService { get }

	func handleArtwork(with handler: Handler<UIImage?>)

}

enum ContentKind: String, Codable {

	case album
	case artist
	case playlist
	case service
	case song

}

extension AnyContent {

	var detail: String? {
		var detail = service.rawValue

		if let artistName = artistName {
			detail.insert(contentsOf: artistName + " • ", at: detail.startIndex)
		}

		return detail
	}

	static func == (lhs: AnyContent, rhs: AnyContent) -> Bool {
		return lhs.service == rhs.service && lhs.identity == rhs.identity
	}

}
