//
//  HistoryViewController.swift
//  Kleene
//
//  View controller used to display and control history for transfers
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

import UIKit

class HistoryViewController: UITableViewController {

	private var history = User.recentTransfers

	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "History"
		tabBarItem.image = UIImage(named: "history-icon")!.af_imageScaled(to: CGSize(square: 30))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = colors.background
		tableView.tableFooterView = UIView(frame: .zero)
		tableView.register(SubtitleTableViewCell.self)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		history = User.recentTransfers
		tableView.reloadData()

		navigationController?.navigationBar.prefersLargeTitles = true
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return history.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(ofType: SubtitleTableViewCell.self, for: indexPath)
		let transfer = history[indexPath.row]

		cell.backgroundColor = .clear
		cell.textLabel?.textColor = colors.text
		cell.textLabel?.text = transfer.dateString
		cell.detailTextLabel?.textColor = colors.detailText
		cell.detailTextLabel?.text = transfer.destination.name

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let transfer = history[indexPath.row]
		let detailView = TransferDetailViewController(transfer)

		navigationController?.pushViewController(detailView, animated: true)
	}

}
