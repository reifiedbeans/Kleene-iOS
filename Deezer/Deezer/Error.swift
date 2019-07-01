//
//  DeezerError.swift
//  Deezer
//
//  Created on 4/11/19.
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

enum DeezerError: String, Error {

	case apiProblem = "There was an error with the Deezer API."
	case loginCancelled = "The login sequence was cancelled."
	case nonHTTPResponse = "Deezer received a non-HTTP response."
	case notConnected = "Deezer is not connected or was unable to retrieve the access token."
	case notLoggedIn = "No Deezer user is currently logged in."

}
