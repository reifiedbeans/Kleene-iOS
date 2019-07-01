//
//  TransferDetailViewController.swift
//  Kleene
//
//  View controller used to display and control the details view for transfers
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

import Essentials
import UIKit

class TransferDetailViewController: UITableViewController {

	private let results: TransferResults
	private lazy var control: UISegmentedControl = {
		let items = ["Succeeded", "Failed"]
		let control = UISegmentedControl(items: items)

		control.selectedSegmentIndex = 0
		control.addTarget(self, action: #selector(controlValueChanged), for: .valueChanged)

		return control
	}()

	init(_ transfer: TransferResults) {
		self.results = transfer
		super.init(nibName: nil, bundle: nil)

		title = results.dateString
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("Not implemented...")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = colors.background

		tableView.tableHeaderView = control
		tableView.tableFooterView = UIView(frame: .zero)
		tableView.register(SubtitleTableViewCell.self)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = false
	}

	@objc private func controlValueChanged() {
		tableView.reloadData()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch control.selectedSegmentIndex {
		case 0:
			return results.successful.count

		case 1:
			return results.failed.count

		default:
			assertionFailure()
			return 0
		}
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(ofType: SubtitleTableViewCell.self, for: indexPath)
		let content: AnyContent

		switch control.selectedSegmentIndex {
		case 0:
			content = results.successful[indexPath.row]

		case 1:
			content = results.failed[indexPath.row]

		default:
			assertionFailure()
			return cell
		}

		cell.backgroundColor = .clear
		cell.textLabel?.textColor = colors.text
		cell.textLabel?.text = content.name
		cell.detailTextLabel?.textColor = colors.detailText
		cell.detailTextLabel?.text = content.detail

		content.handleArtwork(with: Handler { image in
			let size = CGSize(square: 44)
			let copy = image?.af_imageScaled(to: size).af_imageRounded(withCornerRadius: 4)

			cell.imageView?.image = copy
			cell.setNeedsLayout()
		})

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

}
