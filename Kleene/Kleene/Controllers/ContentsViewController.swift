//
//  ContentsViewController.swift
//  Kleene
//
//  View Controller used to display and control songs and groups
//
//  Created on 5/8/19.
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

import AlamofireImage
import Essentials
import UIKit

private let maxElementsForScroller = 20

class ContentsViewController: UITableViewController, ContentSelectingProvider, UISearchResultsUpdating {

	private lazy var searchController: UISearchController = {
		let controller = UISearchController(searchResultsController: nil)

		controller.searchResultsUpdater = self
		controller.dimsBackgroundDuringPresentation = false
		controller.obscuresBackgroundDuringPresentation = false
		controller.searchBar.searchBarStyle = .minimal
		controller.searchBar.barStyle = appTheme == .dark ? .black : .default

		return controller
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = colors.background

		tableView.sectionIndexColor = colors.accent
		tableView.tableFooterView = UIView(frame: .zero)
		tableView.register(SubtitleTableViewCell.self)

		definesPresentationContext = true
		navigationItem.searchController = searchController
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true

		if let title = self.title {
			searchController.searchBar.placeholder = "Search \(title)"
		}
	}

	var contents = [AnyContent]() {
		didSet {
			if contents.count > maxElementsForScroller {
				scrollerIsOn = true
				sectionsDictionary.removeAll()

				for content in contents {
					let key = String(content.name.prefix(1).uppercased())

					sectionsDictionary[key] = (sectionsDictionary[key] ?? []) + [content]
				}

				sectionTitles = [String](sectionsDictionary.keys).sorted(by: <)
			}
			else {
				scrollerIsOn = false
			}

			tableView.reloadData()
		}
	}

	private lazy var selections = Set<Simple>()
	private var filteredResults = [AnyContent]()

	weak var contentSelectingDelegate: ContentSelectingDelegate?

	func clearSelection() {
		selections.removeAll()
	}

	private var sectionsDictionary = [String: [AnyContent]]()
	private var sectionTitles = [String]()
	private var scrollerIsOn = true

	private var searchingIsActive: Bool {
		return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
	}

	private func getContent(at indexPath: IndexPath) -> AnyContent {
		if searchingIsActive {
			return filteredResults[indexPath.row]
		}
		else if scrollerIsOn {
			let key = sectionTitles[indexPath.section]
			let songs = sectionsDictionary[key]!
			// The above force unwrap is justified because a major logic error would be necessary to cause problems.
			// Disappointingly, the linter isn't catching it.

			return songs[indexPath.row]
		}
		else {
			return contents[indexPath.row]
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		if searchingIsActive || !scrollerIsOn {
			return 1
		}
		else {
			return sectionTitles.count
		}
	}
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		if scrollerIsOn, !searchingIsActive {
			return sectionTitles
		}
		else {
			return nil
		}
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchingIsActive {
			return filteredResults.count
		}
		else if scrollerIsOn {
			let songKey = sectionTitles[section]

			if let songValues = sectionsDictionary[songKey] {
				return songValues.count
			}
			else {
				assertionFailure()
				return 0
			}
		}
		else {
			return contents.count
		}
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if searchingIsActive || !scrollerIsOn {
			return nil
		}
		else {
			return sectionTitles[section]
		}
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(ofType: SubtitleTableViewCell.self, for: indexPath)
		let content = getContent(at: indexPath)
		let simple = Simple(content)

		cell.backgroundColor = .clear
		cell.textLabel?.textColor = colors.text
		cell.textLabel?.text = content.name
		cell.detailTextLabel?.textColor = colors.detailText
		cell.detailTextLabel?.text = content.detail
		cell.accessoryType = selections.contains(simple) ? .checkmark : .none

		content.handleArtwork(with: Handler { image in
			let size = CGSize(square: 44)
			let copy = image?.af_imageScaled(to: size).af_imageRounded(withCornerRadius: 4)

			cell.imageView?.image = copy
			cell.setNeedsLayout()
		})

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let content = getContent(at: indexPath)
		let simple = Simple(content)

		if let cell = tableView.cellForRow(at: indexPath) {
			switch cell.accessoryType {
			case .checkmark:
				assert(selections.contains(simple))
				cell.accessoryType = .none
				selections.remove(simple)
				contentSelectingDelegate?.contentSelecting(provider: self, didDeselect: content)

			case .none:
				assert(!selections.contains(simple))
				cell.accessoryType = .checkmark
				selections.insert(simple)
				contentSelectingDelegate?.contentSelecting(provider: self, didSelect: content)

			default:
				assertionFailure()
			}
		}
		else {
			assertionFailure()
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}

	func updateSearchResults(for searchController: UISearchController) {
		if let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty {
			filteredResults = contents.filter({ content in
				let nameMatch = content.name.lowercased().contains(searchText)
				let artistNameMatch = content.artistName?.lowercased().contains(searchText) ?? false

				return nameMatch || artistNameMatch
			})
		}
		else {
			filteredResults = contents
		}

		tableView.reloadData()
	}

}
