//
//  NoMusicView.swift
//  Kleene
//
//  View shown when no music services are connected
//
//  Created on 4/7/19.
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

class NoMusicView: UIView {

	private lazy var label: UILabel = {
		let label = UILabel()

		label.accessibilityIdentifier = "NoMusicLabel"
		label.numberOfLines = 0
		label.text = "You are not signed into any music services. You can sign in to music services in Settings."
		label.textColor = colors.text

		return label
	}()

	private func setupInitialLayout() {
		addSubview(label)

		label.translatesAutoresizingMaskIntoConstraints = false

		let spacing = 16 as CGFloat

		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: centerXAnchor),
			label.centerYAnchor.constraint(equalTo: centerYAnchor),
			label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
			label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing)
		])
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		setupInitialLayout()
		backgroundColor = colors.background
	}

}
