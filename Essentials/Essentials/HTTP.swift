//
//  HTTP.swift
//  Essentials
//
//  Created on 3/26/19.
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

public class HTTP {

	public typealias Request = URLSessionDataTask

	@discardableResult
	public static func request(method: HTTP.Request.Method = .get, _ baseURL: URL, endpoint: String? = nil, headers: [String: String]? = nil, parameters: URL.Parameters? = nil, body: Data? = nil, with handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTP.Request {
		var url = baseURL

		if let endpoint = endpoint {
			url.appendPathComponent(endpoint)
		}
		if let parameters = parameters {
			url.parameters = parameters
		}

		print(method.rawValue, url)

		var request = URLRequest(url: url)

		request.httpMethod = method.rawValue

		if let headers = headers {
			for (key, value) in headers {
				request.setValue(value, forHTTPHeaderField: key)
			}
		}
		if let body = body {
			request.httpBody = body
		}

		let task = URLSession.shared.dataTask(with: request, completionHandler: handler)

		task.resume()

		return task
	}

}

public extension HTTP.Request {

	enum Method: String {

		case get = "GET"
		case post = "POST"
		case put = "PUT"

	}

}
