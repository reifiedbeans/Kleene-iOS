//
//  MusicViewController.swift
//  Kleene
//
//  View Controller used to display and control different sections of the user's library
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
import AppleMusic
import Deezer
import Spotify

final class MusicViewController: UITableViewController, ContentSelectingProvider, ContentSelectingDelegate {

	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "Music"
		tabBarItem.image = UIImage(named: "music-library-icon")!
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	private lazy var servicesViewController = ContentsViewController()
	private lazy var playlistsViewController = ContentsViewController()
	private lazy var artistsViewController = ContentsViewController()
	private lazy var albumsViewController = ContentsViewController()
	private lazy var songsViewController = ContentsViewController()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = colors.background

		for controller in [servicesViewController, playlistsViewController, artistsViewController, albumsViewController, songsViewController] {
			controller.contentSelectingDelegate = self
		}

		tableView.tableFooterView = UIView(frame: .zero)
		tableView.register(UITableViewCell.self)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true

		if User.services.count > 0 {
			if let saved = savedTableView {
				view = saved
				savedTableView = nil
			}
		}
		else {
			savedTableView = tableView
			view = NoMusicView()
		}
	}

	/// If the NoMusicView is shown, the original tableView is saved here.
	private var savedTableView: UITableView?
	weak var contentSelectingDelegate: ContentSelectingDelegate?

	func clearSelection() {
		for controller in [servicesViewController, playlistsViewController, artistsViewController, albumsViewController, songsViewController] {
			controller.clearSelection()
		}
	}

	// Table view
	private lazy var cellLabels = ["Services", "Playlists", "Artists", "Albums", "Songs"]

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cellLabels.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(ofType: UITableViewCell.self, for: indexPath)
		let label = cellLabels[indexPath.row]

		cell.accessibilityIdentifier = label
		cell.textLabel?.text = label
		cell.textLabel?.textColor = colors.text
		cell.backgroundColor = colors.background
		cell.accessoryType = .disclosureIndicator

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		assert(indexPath.section == 0)

		weak var viewController: UIViewController?

		switch indexPath.row {
		case 0:
			viewController = servicesViewController
			servicesViewController.contents = User.services
            servicesViewController.title = "Services"

		case 1:
			viewController = playlistsViewController
			playlistsViewController.contents = User.playlists
            playlistsViewController.title = "Playlists"

		case 2:
			viewController = artistsViewController
			artistsViewController.contents = User.artists
            artistsViewController.title = "Artists"

		case 3:
			viewController = albumsViewController
			albumsViewController.contents = User.albums
            albumsViewController.title = "Albums"

		case 4:
			viewController = songsViewController
			songsViewController.contents = User.songs
			songsViewController.title = "Songs"

		default:
			assertionFailure()
		}

		if let viewController = viewController {
			navigationController?.pushViewController(viewController, animated: true)
		}
		else {
			assertionFailure()
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}

	func contentSelecting(provider: ContentSelectingProvider, didSelect content: AnyContent) {
		contentSelectingDelegate?.contentSelecting(provider: provider, didSelect: content)
	}
	func contentSelecting(provider: ContentSelectingProvider, didDeselect content: AnyContent) {
		contentSelectingDelegate?.contentSelecting(provider: provider, didDeselect: content)
	}

}
