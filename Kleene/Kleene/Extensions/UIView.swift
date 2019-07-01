//
//  UIView.swift
//  Kleene
//
//  Defines extensions to the UIView class
//
//  Created on 3/3/19.
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

extension UIView {

	@inlinable
	func addSubviews(_ subviews: UIView...) {
		for subview in subviews {
			addSubview(subview)
		}
	}

	@inlinable
	func removeSubviews() {
		for subview in subviews {
			subview.removeFromSuperview()
		}
	}

	func disableAndRemoveConstraints() {
		disableConstraints()
		removeConstraints()
	}

	@inlinable
	func disableConstraints() {
		for constraint in constraints {
			constraint.isActive = false
		}
	}

	@inlinable
	func removeConstraints() {
		removeConstraints(constraints)
	}

}
