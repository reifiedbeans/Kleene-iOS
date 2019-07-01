//
//  TransferItem.swift
//  Kleene
//
//  Created on 5/14/19.
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

struct TransferItem: Codable, AnyContent {

	let identity: String
	let name: String
	let artistName: String?
	let kind: ContentKind
	let service: MusicService

	init(_ content: AnyContent) {
		self.identity = content.identity
		self.name = content.name
		self.artistName = content.artistName
		self.kind = content.kind
		self.service = content.service

		content.handleArtwork(with: Handler { image in
			if let imageData = image?.pngData() {
				let url = cachesDirectory.appendingPathComponent(content.service.rawValue + " " + content.identity)

				try? imageData.write(to: url)
			}
		})
	}

	func handleArtwork(with handler: Handler<UIImage?>) {
		let url = cachesDirectory.appendingPathComponent(service.rawValue + " " + identity)

		if let imageData = try? Data(contentsOf: url) {
			let image = UIImage(data: imageData)

			handler(image)
		}
		else {
			handler(nil)
		}
	}

}
