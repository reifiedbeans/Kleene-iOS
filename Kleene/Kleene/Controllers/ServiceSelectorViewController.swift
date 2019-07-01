//
//  ServiceSelectorViewController.swift
//  Kleene
//
//  View controller used to display and control service selection for destination
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

class ServiceSelectorViewController: UITableViewController {

	override func loadView() {
		super.loadView()

		tableView.tableFooterView = UIView(frame: .zero)
		tableView.register(UITableViewCell.self)
	}
	override func viewDidLoad() {
		super.viewDidLoad()

        navigationItem.title = "Destination"
		view.backgroundColor = colors.background
	}

	weak var delegate: ServiceSelectorViewControllerDelegate?
	private lazy var services = User.services

	// MARK: TableView
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return services.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(ofType: UITableViewCell.self, for: indexPath)
		let service = services[indexPath.row]

		cell.backgroundColor = .clear
		cell.textLabel?.text = service.name
		cell.textLabel?.textColor = colors.text

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let service = services[indexPath.row]

		delegate?.didSelect(service: service)
		tableView.deselectRow(at: indexPath, animated: true)
	}

}

protocol ServiceSelectorViewControllerDelegate: class {

	func didSelect(service: MusicService)

}
