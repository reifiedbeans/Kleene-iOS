//
//  SettingsViewController.swift
//  Kleene
//
//  View controller used to display and control settings for the app
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
import MessageUI
import AppleMusic
import Deezer
import Essentials
import Spotify

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "Settings"
		tabBarItem.image = UIImage(named: "settings")!.af_imageScaled(to: CGSize(square: 30))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func loadView() {
		// Don't call super.loadView()
		view = UITableView(frame: .zero, style: .grouped)
	}
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = colors.menuBackground

		tableView.accessibilityIdentifier = "SettingsTableView"
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = 44
		tableView.register(DetailTableViewCell.self)
		tableView.register(SwitchTableViewCell.self)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true

		tableView.reloadSections([0, 1, 2], with: .automatic)
	}

	// MARK: TableView
	private lazy var sectionTitles = ["Music Services", "Theme", "Contact Us"]
	private lazy var musicServicesTitles = ["Apple Music", "Deezer", "Spotify"]

	override func numberOfSections(in tableView: UITableView) -> Int {
		return sectionTitles.count
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionTitles[section]
	}
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Sign into your music services to transfer your music content."

		case 1:
            return "Change the theme to better suit your preferences."

		case 2:
            return "Let us know how we're doing! We'd love to hear your feedback."

		default:
			assertionFailure("Currently, all the sections should have a footer.")
			return nil
		}
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return musicServicesTitles.count

		case 1:
			return Theme.allCases.count

		case 2:
			return 1

		default:
			assertionFailure()
			return 0
		}
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(ofType: DetailTableViewCell.self, for: indexPath)

		cell.backgroundColor = colors.settingsCell
        cell.textLabel?.textColor = colors.text
		cell.textLabel?.text = nil
		cell.detailTextLabel?.text = nil
        cell.accessoryType = .none

		switch indexPath.section {
		case 0:
			let name = musicServicesTitles[indexPath.row]

			cell.accessibilityIdentifier = name
			cell.textLabel?.textColor = colors.text
			cell.textLabel?.text = name
			cell.detailTextLabel?.textColor = colors.detailText

			switch indexPath.row {
			case 0:
				switch AppleMusic.authorizationStatus {
				case .authorized:
					cell.detailTextLabel?.text = "Deauthorize"

				case .denied, .notDetermined:
					cell.detailTextLabel?.text = "Authorize"

				case .restricted:
					cell.detailTextLabel?.text = "Restricted"

				@unknown default:
					cell.detailTextLabel?.text = "Unknown"
				}

			case 1:
                cell.detailTextLabel?.text = Deezer.isConnected ? "Sign Out" : "Sign In"

			case 2:
				cell.detailTextLabel?.text = Spotify.isSignedIn ? "Sign Out" : "Sign In"

			default:
				assertionFailure()
            }

		case 1:
            cell.textLabel?.text = Theme.allCases[indexPath.row].rawValue
            cell.textLabel?.textColor = colors.text

            if cell.textLabel?.text == appTheme.rawValue {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }

		case 2:
            cell.textLabel?.textColor = colors.text
            cell.textLabel?.text = "Send Feedback"

		default:
			break
		}

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				manageAppleMusic()

			case 1:
				manageDeezer(path: indexPath)

			case 2:
				manageSpotify(path: indexPath)

			default:
				assertionFailure()
			}

		case 1:
			let theme = Theme.allCases[indexPath.row]

			appTheme = theme
            UserDefaults.standard.set(appTheme.rawValue, forKey: "appTheme")
            alertUser(title: "Theme Change", message: "Please restart the app to use the \(theme.rawValue.lowercased()) theme.")

		case 2:
			if MFMailComposeViewController.canSendMail() {
				let mail = MFMailComposeViewController()

				mail.mailComposeDelegate = self
				mail.setToRecipients(["kleeneapp@gmail.com"])
				mail.setSubject("Kleene Feedback")

				present(mail, animated: true)
			}
			else {
				alertUser(title: "Mail Error", message: "Kleene was unable to open an email composer.")
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

	private func manageAppleMusic() {
		switch AppleMusic.authorizationStatus {
		case .authorized:
			let alert = UIAlertController(title: "Apple Music", message: "To deauthorize Kleene's access to your Apple Music content, open Settings.", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
				let settingsURL = URL(string: UIApplication.openSettingsURLString)!

				if UIApplication.shared.canOpenURL(settingsURL) {
					UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
				}
				else {
					self.alertUser(title: "Error Opening Settings", message: "Kleene was unable to open the Settings app.")
				}
			})

			alert.addAction(cancelAction)
			alert.addAction(openSettingsAction)

			present(alert, animated: true)

		case .denied:
			let alert = UIAlertController(title: "Apple Music", message: "You have denied Kleene access to your Apple Music content. To allow access, open Settings.", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
				let settingsURL = URL(string: UIApplication.openSettingsURLString)!

				if UIApplication.shared.canOpenURL(settingsURL) {
					UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
				}
				else {
					self.alertUser(title: "Error Opening Settings", message: "Kleene was unable to open the Settings app.")
				}
			})

			alert.addAction(cancelAction)
			alert.addAction(openSettingsAction)

			present(alert, animated: true)

		case .restricted:
			self.alertUser(title: "Access Restricted", message: "You are restricted from allowing Kleene to access Apple Music.")

		case .notDetermined:
			requestAppleMusic()

		@unknown default:
			assertionFailure()
		}
	}

	private func requestAppleMusic() {
		AppleMusic.requestAuthorization(handler: { [weak self] status in
			DispatchQueue.main.async {
				let indexPath = IndexPath(row: 0, section: 0)

				self?.tableView.reloadRows(at: [indexPath], with: .automatic)
			}

			switch status {
			case .authorized:
				User.loadAppleMusic()

			case .denied, .restricted:
				self?.manageAppleMusic()

			case .notDetermined:
				assertionFailure()
				fallthrough

			@unknown default:
				self?.alertUser(title: "Error", message: "Unable to determine whether Kleene is authorized to use Apple Music.")
			}
		})
	}

	private func manageDeezer(path: IndexPath) {
		if Deezer.isConnected {
			Deezer.logout()
			User.removeContent(from: .deezer)
			tableView.reloadRows(at: [path], with: .automatic)
		}
		else {
			Deezer.login(with: Handler { [weak self] result in
				switch result {
				case .success:
					DispatchQueue.main.async {
						self?.tableView.reloadRows(at: [path], with: .automatic)
					}

					User.loadDeezer()

				case .cancelled:
					break

				case .failure(let error):
					self?.alertUser(title: "Deezer Authentication Error", message: error.localizedDescription)
				}
			})
		}
	}

	private func manageSpotify(path: IndexPath) {
		if Spotify.isSignedIn {
			Spotify.signOut()

			DispatchQueue.main.async {
				self.tableView.reloadRows(at: [path], with: .automatic)
			}

			User.removeContent(from: .spotify)
		}
		else {
			if let cell = tableView.cellForRow(at: path) {
				cell.detailTextLabel?.text = "Signing In..."
			}
			else {
				assertionFailure()
			}

			Spotify.signIn(completion: Handler { [weak self] error in
				if let error = error {
					self?.alertUser(title: "Spotify Error", message: error.localizedDescription)
				}
				else {
					User.loadSpotify()
				}

				DispatchQueue.main.async {
					self?.tableView.reloadRows(at: [path], with: .automatic)
				}
			})
		}
	}

	// MARK: MFMailComposeViewControllerDelegate
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}

}
