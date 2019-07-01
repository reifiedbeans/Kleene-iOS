//
//  URL.swift
//  Essentials
//
//  Created on 2/24/19.
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

public extension URL {

	typealias Parameters = [String: Any]

	var parameters: Parameters? {
		get {
			if let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems {
				var parameters = Parameters()

				for queryItem in queryItems {
					parameters[queryItem.name] = queryItem.value
				}

				return parameters
			}
			else {
				return nil
			}
		}
		set {
			if var components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
				components.queryItems = newValue?.map({ URLQueryItem(name: $0.key, value: $0.value as? String) })

				if let newURL = components.url {
					self = newURL
				}
			}
		}
	}

}
