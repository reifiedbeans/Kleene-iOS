//
//  MediaPlaylist.swift
//  Apple Music
//
//  Created on 3/11/19.
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
import MediaPlayer

public extension AppleMusic {

	struct MediaPlaylist {

		public let id: String
		public let name: String
		public let image: UIImage?
		public var songIDs: [String]

		init?(mediaCollection: MPMediaItemCollection) {
			guard let name = mediaCollection.value(forProperty: MPMediaPlaylistPropertyName) as? String else {
				return nil
			}

			let mediaItem = mediaCollection.representativeItem

			self.id = "\(mediaCollection.persistentID)"
			self.name = name
			self.image = mediaItem?.artwork?.image(at: CGSize(square: 128))
            self.songIDs = mediaCollection.items.map({ $0.playbackStoreID })
		}

	}

}
