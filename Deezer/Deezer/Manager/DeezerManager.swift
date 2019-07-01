import Foundation
import UIKit
import DeezerSDK
import Essentials

/// DeezerManager manages the request to DeezerSDK
class DeezerManager: NSObject {

	static let shared = DeezerManager()
	private(set) var deezerConnect: DeezerConnect!

	var isConnected: Bool {
		return deezerConnect.isSessionValid()
	}

	private override init() {
		super.init()

		deezerConnect = DeezerConnect(appId: Deezer.appID, andDelegate: self)
		DZRRequestManager.default().dzrConnect = deezerConnect

		retrieveTokenAndExpirationDate()
	}

	/**
	*   Authorizations:
	*      - DeezerConnectPermissionBasicAccess
	*      - DeezerConnectPermissionEmail
	*      - DeezerConnectPermissionOfflineAccess
	*      - DeezerConnectPermissionManageLibrary
	*      - DeezerConnectPermissionDeleteLibrary
	*      - DeezerConnectPermissionListeningHistory
	**/

	private var loginHandlers = [Handler<Deezer.LoginResult>]()
	func login(with handler: Handler<Deezer.LoginResult>? = nil) {
		if let handler = handler {
			loginHandlers.append(handler)
		}

		deezerConnect.authorize([DeezerConnectPermissionOfflineAccess, DeezerConnectPermissionManageLibrary])
	}
	func logout() {
		deezerConnect.logout()
	}

}

extension DeezerManager {

	private func save(token: String, expirationDate: Date, userId: String) {
		KeyChainManager.save(key: DeezerConstant.KeyChain.deezerTokenKey, data: token.data)
		KeyChainManager.save(key: DeezerConstant.KeyChain.deezerExpirationDateKey, data: expirationDate.timeIntervalSince1970.data)
		KeyChainManager.save(key: DeezerConstant.KeyChain.deezerUserIdKey, data: userId.data)
	}

	private func retrieveTokenAndExpirationDate() {
		if let accessToken = String(data: KeyChainManager.load(key: DeezerConstant.KeyChain.deezerTokenKey) ?? Data()),
			let expirationDate = Double(data: KeyChainManager.load(key: DeezerConstant.KeyChain.deezerExpirationDateKey) ?? Data()),
			let userId = String(data: KeyChainManager.load(key: DeezerConstant.KeyChain.deezerUserIdKey) ?? Data()) {
			deezerConnect.accessToken = accessToken
			deezerConnect.expirationDate = Date(timeIntervalSince1970: expirationDate)
			deezerConnect.userId = userId
		}
	}

	private func clearTokenAndExpirationDate() {
		KeyChainManager.delete(key: DeezerConstant.KeyChain.deezerUserIdKey)
		KeyChainManager.delete(key: DeezerConstant.KeyChain.deezerTokenKey)
		KeyChainManager.delete(key: DeezerConstant.KeyChain.deezerExpirationDateKey)
	}

}

extension DeezerManager: DeezerSessionDelegate {

	func deezerDidLogin() {
		save(token: deezerConnect.accessToken, expirationDate: deezerConnect.expirationDate, userId: deezerConnect.userId)

		while !loginHandlers.isEmpty {
			loginHandlers.removeFirst()(.success)
		}
	}

	func deezerDidNotLogin(_ cancelled: Bool) {
		let result: Deezer.LoginResult = cancelled ? .cancelled : .failure(DeezerError.notConnected)

		while !loginHandlers.isEmpty {
			loginHandlers.removeFirst()(result)
		}
	}

	func deezerDidLogout() {
		clearTokenAndExpirationDate()
	}

}
