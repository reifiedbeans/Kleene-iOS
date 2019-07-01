//
//  Simple.swift
//  Kleene
//
//  Defines a simple version of AnySong; used for encoding and decoding, hashing
//
//  Created on 3/10/19.
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

/// A Simple stores an id and a service.
/// This can be used for keeping track of duplicates or saving memory.
struct Simple: Hashable, Codable {

	let identity: String
	let service: MusicService

	/// Initialize a Simple from an AnySong.
	///
	/// - Parameter anySong: an AnySong
	init(anySong: AnySong) {
		self.identity = anySong.identity
		self.service = anySong.service
	}

	/// Initialize a Simple from an AnyGroup.
	///
	/// - Parameter anyGroup: an AnyGroup
	init(anyGroup: AnyGroup) {
		self.identity = anyGroup.identity
		self.service = anyGroup.service
	}

	init(_ content: AnyContent) {
		self.identity = content.identity
		self.service = content.service
	}

}
