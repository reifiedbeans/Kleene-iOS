//
//  TransferViewController.swift
//  Kleene
//
//  View controller used to display and control transferring songs
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

import Essentials
import UIKit

class TransferViewController: UITableViewController {

	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "Transfer"
		tabBarItem.image = UIImage(named: "repeat")!.af_imageScaled(to: CGSize(square: 30))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	private lazy var progressView: UIProgressView = {
		let progress = UIProgressView(progressViewStyle: .bar)

		progress.progressTintColor = colors.accent

		return progress
	}()
	private lazy var musicViewController: MusicViewController = {
		let music = MusicViewController()

		music.contentSelectingDelegate = self

		return music
	}()

	private func setupProgressLayout() {
		view.addSubview(progressView)

		progressView.translatesAutoresizingMaskIntoConstraints = false

		let safeArea = view.safeAreaLayoutGuide

		NSLayoutConstraint.activate([
			progressView.heightAnchor.constraint(equalToConstant: 32),
			progressView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			progressView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			progressView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
		])
	}
	private func reset() {
		self.selectedService = nil
		self.musicViewController.clearSelection()
		self.music.removeAll()

		DispatchQueue.main.async { [weak self] in
			self?.progressView.progress = 0
			self?.tableView.reloadSections([0, 1], with: .automatic)
		}
	}

	override func loadView() {
		view = UITableView(frame: .zero, style: .grouped)

		tableView.accessibilityIdentifier = "TransferTableView"
		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableFooterView = UIView(frame: .zero)
		tableView.register(SubtitleTableViewCell.self)
	}
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = colors.menuBackground

		let imageSize = CGSize(square: 30)
		let transferImage = UIImage(named: "transfer")!.af_imageScaled(to: imageSize)
		let transferItem = UIBarButtonItem(image: transferImage, style: .plain, target: self, action: #selector(transferItemAction))

		transferItem.isEnabled = false

		navigationItem.setRightBarButton(transferItem, animated: false)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
	}

	@objc private func transferItemAction() {
		guard let selectedService = selectedService else {
			assertionFailure("The user should not have been able to select the transfer bar button item.")
			return
		}

        let transfer = Transfer(destination: selectedService, payload: self.music)

		setupProgressLayout()
		progressView.observedProgress = transfer.progress

		failedTransfers = [AnySong]()

		transfer.fire(completion: { [weak self] in
			let results = TransferResults(transfer: transfer)

			User.insert(transfer: results)
			self?.reset()
		})
	}

	private var selectedService: MusicService? {
		didSet {
			navigationItem.rightBarButtonItem?.isEnabled = selectedService != nil && !music.isEmpty
		}
	}
	private var music = [AnyContent]() {
		didSet {
			navigationItem.rightBarButtonItem?.isEnabled = selectedService != nil && !music.isEmpty
		}
	}
	private var failedTransfers: [AnySong]?

	// MARK: TableView
	private lazy var sectionTitles = ["Destination", "Payload"]
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sectionTitles.count
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1

		case 1:
			return music.count + 1

		default:
			assertionFailure()
			return 0
		}
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionTitles[section]
	}
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Select the music service that you would like to transfer the payload to."

		case 1:
			return "Select the music that you would like to transfer to the destination."

		default:
			assertionFailure()
			return nil
		}
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(ofType: SubtitleTableViewCell.self, for: indexPath)

		// Reset cell
		cell.accessoryType = .none
		cell.backgroundColor = colors.settingsCell
		cell.textLabel?.text = nil
		cell.textLabel?.textColor = colors.text
		cell.detailTextLabel?.text = nil
		cell.detailTextLabel?.textColor = colors.detailText
		cell.imageView?.image = nil

		switch indexPath.section {
		case 0:
			cell.textLabel?.text = selectedService?.name ?? "Select"
			cell.accessoryType = .disclosureIndicator

		case 1:
			if indexPath.row < music.count {
				let content = music[indexPath.row]

				cell.textLabel?.text = content.name
				cell.detailTextLabel?.text = content.detail

				content.handleArtwork(with: Handler { image in
					let size = CGSize(square: 44)
					let copy = image?.af_imageScaled(to: size).af_imageRounded(withCornerRadius: 4)

					cell.imageView?.image = copy
					cell.setNeedsLayout()
				})
			}
			else {
				assert(indexPath.row == music.count)

				let text = music.isEmpty ? "Add music..." : "Modify payload..."

				cell.accessibilityIdentifier = text
				cell.imageView?.image = UIImage(named: "add")!
				cell.imageView?.tintColor = colors.accent
				cell.textLabel?.text = text
			}

		default:
			assertionFailure()
		}

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			assert(navigationController != nil)

			let serviceSelector = ServiceSelectorViewController()

			serviceSelector.delegate = self
			navigationController?.pushViewController(serviceSelector, animated: true)

		case 1:
			if indexPath.row == music.count {
				musicViewController.contentSelectingDelegate = self
				navigationController?.pushViewController(musicViewController, animated: true)
			}

		default:
			assertionFailure()
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as? UITableViewHeaderFooterView
		header?.textLabel?.textColor = colors.text
	}
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		let header = view as? UITableViewHeaderFooterView
		header?.textLabel?.textColor = colors.text
	}

}

extension TransferViewController: ServiceSelectorViewControllerDelegate {

	func didSelect(service: MusicService) {
		assert(navigationController != nil)

		selectedService = service
		navigationController?.popViewController(animated: true)
		tableView.reloadSections([0], with: .automatic)
	}

}

extension TransferViewController: ContentSelectingDelegate {

	func contentSelecting(provider: ContentSelectingProvider, didSelect content: AnyContent) {
		music.append(content)
		tableView.reloadData()
	}
	func contentSelecting(provider: ContentSelectingProvider, didDeselect content: AnyContent) {
		music.removeAll(where: { candidate in
			return candidate.identity == content.identity && candidate.service == content.service
		})

		tableView.reloadData()
	}

}
