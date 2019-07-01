//
//  UITableView.swift
//  Kleene
//
//  Defines extensions to the UITableView class
//
//  Created on 4/6/19.
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

extension UITableView {

	@inlinable
	func register<T: UITableViewCell>(_ cellClass: T.Type) {
		register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
	}

	@inlinable
	func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
		// swiftlint:disable:next force_cast
		return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as! T
	}

}
