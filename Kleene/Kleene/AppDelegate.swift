//
//  AppDelegate.swift
//  Kleene
//
//  Starts running the application
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

import AppleMusic
import Spotify
import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	private func setupAppearance() {
        if let rawTheme = UserDefaults.standard.string(forKey: "appTheme") {
            appTheme = Theme(rawValue: rawTheme) ?? .dark
        }

        UIButton.appearance().tintColor = colors.accent

        UILabel.appearance().textColor = colors.text

        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: colors.accent]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: colors.accent]
        UINavigationBar.appearance().barTintColor = colors.navigationBar
        UINavigationBar.appearance().tintColor = colors.accent

        UISearchBar.appearance().tintColor = colors.accent

        UISegmentedControl.appearance().tintColor = colors.accent

        UITabBar.appearance().barTintColor = colors.tabBar
        UITabBar.appearance().tintColor = colors.accent
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		setupAppearance()
		User.load()

		let tabBarController = TabBarController()

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		print("applicationWillResignActive...")
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		print("applicationDidEnterBackground...")

		try? User.store()
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		print("applicationWillEnterForeground...")
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		print("applicationDidBecomeActive")
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		print("applicationWillTerminate")
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		Spotify.application(app, open: url, options: options)

		return true
	}

}
