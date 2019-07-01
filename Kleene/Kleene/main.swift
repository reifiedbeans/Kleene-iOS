//
//  main.swift
//  Kleene
//
//  Entry point for the application
//
//  Created on 3/10/19.
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

let fileManager = FileManager.default
let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("kleene", isDirectory: true)

if !fileManager.fileExists(atPath: cachesDirectory.path) {
	try fileManager.createDirectory(at: cachesDirectory, withIntermediateDirectories: true, attributes: nil)
}

private let delegateName = NSStringFromClass(AppDelegate.self) as String

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, delegateName)
