//
//  Colors.swift
//  Kleene
//
//  Includes color palletes and themeing support
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

protocol ColorSet {
    static var background: UIColor { get }
    static var tabBar: UIColor { get }
    static var navigationBar: UIColor { get }
    static var playbackView: UIColor { get }
    static var scrubberBackground: UIColor { get }
    static var menuBackground: UIColor { get }
    static var settingsCell: UIColor { get }
    static var text: UIColor { get }
    static var detailText: UIColor { get }
    static var statusBarStyle: UIStatusBarStyle { get }
}

struct LightTheme: ColorSet {
    static let background = UIColor.white
    static let tabBar = UIColor.white
    static let navigationBar = LightTheme.tabBar
    static let playbackView = UIColor(white: 240 / 255, alpha: 1)
    static let scrubberBackground = LightTheme.detailText
    static let menuBackground = UIColor(white: 225 / 255, alpha: 1)
    static let settingsCell = LightTheme.tabBar
    static let text = UIColor.black
    static let detailText = UIColor.darkText
    static let statusBarStyle = UIStatusBarStyle.default
}

struct DarkTheme: ColorSet {
    static let background = UIColor(white: 55 / 255, alpha: 1)
    static let tabBar = UIColor(white: 0x40 / 255, alpha: 1)
    static let navigationBar = DarkTheme.tabBar
    static let playbackView = UIColor(white: 0x57 / 255, alpha: 1)
    static let scrubberBackground = DarkTheme.detailText
    static let menuBackground = UIColor(white: 50 / 255, alpha: 1)
    static let settingsCell = DarkTheme.tabBar
    static let text = UIColor.white
    static let detailText = UIColor.lightText
    static let statusBarStyle = UIStatusBarStyle.lightContent
}

enum Theme: String, CaseIterable, Codable {
    case light = "Light"
    case dark = "Dark"
}

extension ColorSet {

    static var accent: UIColor {
		return UIColor.orange
    }

}
