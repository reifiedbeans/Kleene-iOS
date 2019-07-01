//
//  Handler.swift
//  Essentials
//
//  Created on 4/2/19.
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

import Foundation

/// Handler is a class that takes in a closure and checks that
/// the closure is executed exactly once using assert calls.
@dynamicCallable
public class Handler<T> {

	private let closure: (T) -> Void
	private var didExecute = false
	private let semaphore = DispatchSemaphore(value: 1)

	public init(_ closure: @escaping (T) -> Void) {
		self.closure = closure
	}

	deinit {
		assert(didExecute)
	}

	public func execute(with result: T) {
		semaphore.wait()
		assert(!didExecute)

		if !didExecute {
			closure(result)
		}

		didExecute = true
		semaphore.signal()
	}

	public func dynamicallyCall(withArguments arguments: [T]) {
		assert(arguments.count == 1)

		if let first = arguments.first {
			execute(with: first)
		}
	}

}
