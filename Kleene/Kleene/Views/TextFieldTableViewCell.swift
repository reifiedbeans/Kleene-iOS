//
//  TextFieldTableViewCell.swift
//  Kleene
//
//  Table cell that includes a text field; used throughout the app
//
//  Created on 2/6/19.
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

class TextFieldTableViewCell: UITableViewCell {

	lazy var textField: UITextField = {
		let field = UITextField()

		field.textColor = colors.text
		field.returnKeyType = .done

		return field
	}()

	private func setupInitialLayout() {
		addSubview(textField)

		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(equalToConstant: textField.intrinsicContentSize.height).isActive = true
		textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
		textField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		setupInitialLayout()
	}
	override func resignFirstResponder() -> Bool {
		return textField.resignFirstResponder()
	}

	static let cellID = "TextFieldTableViewCell"

}
