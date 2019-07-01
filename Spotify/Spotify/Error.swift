//
//  Error.swift
//  Spotify
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

enum SpotifyError: String, Error {

	case apiProblem = "There was an error with the Spotify API."
	case invalidSearchResults = "The Spotify search results had an unexpected format."
	case invalidSearchType = "Spotify ssearching performed with an invalid search type."
	case nonHTTPResponse = "The Spotify API returned a non-HTTP response."
	case notSignedIn = "No Spotify user is currently signed in."
	case playerStateError = "There was a problem retrieving the player state for Spotify."

}

enum StatusCodeError: Error {

	case badStatusCode(Int)

}
