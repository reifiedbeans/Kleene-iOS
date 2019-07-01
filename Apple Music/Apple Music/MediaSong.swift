//
//  MediaSong.swift
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

	struct MediaSong {

		public let id: String
		public let albumID: String
		public let artistID: String
		public let name: String
		public let artistName: String?
		public let albumName: String
		public let image: UIImage

		init?(mediaItem: MPMediaItem) {
			guard let title = mediaItem.title, let artwork = mediaItem.artwork, let albumTitle = mediaItem.albumTitle, let image = artwork.image(at: CGSize(width: 48, height: 48)) else {
				return nil
			}

			self.id = mediaItem.playbackStoreID
			self.albumID = "\(mediaItem.albumPersistentID)"
			self.artistID = "\(mediaItem.artistPersistentID)"
			self.name = title
			self.artistName = mediaItem.artist
			self.albumName = albumTitle
			self.image = image
		}

	}

}
