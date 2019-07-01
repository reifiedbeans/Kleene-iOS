//
//  TransferResults.swift
//  Kleene
//
//  Created on 5/13/19.
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

private let dateFormat: DateFormatter = {
	let format = DateFormatter()

	format.dateFormat = "MMM dd, yyyy @ HH:mm"

	return format
}()

class TransferResults: Codable {

	let name: String
	let destination: MusicService
	let date: Date
	let successful: [TransferItem]
	let failed: [TransferItem]

	init(transfer: Transfer) {
		self.date = Date()
		self.name = dateFormat.string(from: date)
		self.destination = transfer.destination
		self.successful = transfer.successfulTransfers.map(TransferItem.init)
		self.failed = transfer.failedTransfers.map(TransferItem.init)
	}

	var dateString: String {
		return dateFormat.string(from: date)
	}

}
