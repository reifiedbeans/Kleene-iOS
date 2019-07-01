//
//  Transfer.swift
//  Kleene
//
//  Defines a transfer used for moving songs from one service to another
//
//  Created on 4/11/19.
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
import Essentials
import AppleMusic
import Deezer
import Spotify

final class Transfer: NSObject, ProgressReporting {

	let destination: MusicService
    let payload: [AnyContent]
    private(set) var successfulTransfers = [AnySong]()
    private(set) var failedTransfers = [AnySong]()

	var progress = Progress(totalUnitCount: 1)
    private let group = DispatchGroup()

    /// Creates a new Transfer object.
    ///
    /// - Parameters:
    ///     - destination: The destination music service
    ///     - payload: An array of music content to be transferred
    init(destination: MusicService, payload: [AnyContent]) {
		self.destination = destination
        self.payload = payload
	}

	/// Begins transferring the payload to the destination. This function is run on a background
	/// queue and automatically updates the progress of this Transfer.
	///
    /// - Parameters:
    ///     - completion: A closure to be executed when the transfer has started.
	func fire(completion: (() -> Void)? = nil) {
		DispatchQueue.global(qos: .background).async {
			self.group.enter()

			if let completion = completion {
				self.group.notify(queue: .global(qos: .default), execute: completion)
			}

			self.transfer()
			self.group.leave()
		}
	}

	private func transfer() {
		var anySongs = [AnySong]()

		for content in payload {
            switch content.kind {
            case .song:
                if let anySong = content as? AnySong {
                    anySongs.append(anySong)
                }
                else {
                    assertionFailure()
                }

            case .album:
                anySongs.append(contentsOf: User.songs.filter({ $0.service == content.service && $0.albumID == content.identity }))

            case .artist:
                anySongs.append(contentsOf: User.songs.filter({ $0.service == content.service && $0.artistID == content.identity }))

            case .playlist:
                if let playlist = group as? AnyPlaylist {
                    anySongs.append(contentsOf: playlist.songIDs.compactMap({ id in
                        return User.songs.first(where: { song in
                            return playlist.service == song.service && id == song.identity
                        })
                    }))
                }
                else {
                    assertionFailure()
                }

            case .service:
                anySongs.append(contentsOf: User.songs.filter({ $0.service == content.service }))
            }
        }

		progress.completedUnitCount = 0
		progress.totalUnitCount = Int64(anySongs.count)

		for anySong in anySongs {
			guard anySong.service != self.destination else {
				continue
			}

			group.enter()
			send(song: anySong)
		}
	}

	private func send(song: AnySong) {
		guard let artistName = song.artistName else {
			assertionFailure()
			return
		}

		switch destination {
		case .appleMusic:
			AppleMusic.handleSearch(term: "\(song.name) \(song.albumName) \(artistName)", limit: 1, with: Handler { result in
				switch result {
				case .failure:
                    self.failedTransfers.append(song)
					self.progress.completedUnitCount += 1
					self.group.leave()

				case .success(let appleMusicSongs):
					guard let appleMusicSong = appleMusicSongs.first else {
                        self.failedTransfers.append(song)
						self.progress.completedUnitCount += 1
						self.group.leave()
						return
					}

					appleMusicSong.addToLibrary(with: Handler { error in
						if error != nil {
							self.failedTransfers.append(song)
						}
						else {
							self.successfulTransfers.append(song)
						}

						self.progress.completedUnitCount += 1
						self.group.leave()
					})
				}
			})

		case .deezer:
			Deezer.handleSearch(query: "track:\"\(song.name)\" album:\"\(song.albumName)\" artist:\"\(artistName)\"", with: Handler { result in
				switch result {
				case .failure:
					self.failedTransfers.append(song)
					self.progress.completedUnitCount += 1
					self.group.leave()

				case .success(let tracks):
					if let track = tracks.first {
						track.addToLibrary(with: Handler { result in
							switch result {
							case .failure:
								self.failedTransfers.append(song)

							case .success:
								self.successfulTransfers.append(song)
							}

							self.progress.completedUnitCount += 1
							self.group.leave()
						})
					}
					else {
						self.failedTransfers.append(song)
						self.progress.completedUnitCount += 1
						self.group.leave()
					}
				}
			})

		case .spotify:
			Spotify.handleSearch(query: #""\#(song.name)" album:"\#(song.albumName)" artist:"\#(artistName)""#, type: Spotify.Track.self, limit: 1, with: Handler { result in
				switch result {
				case .failure:
                    self.failedTransfers.append(song)
                    self.progress.completedUnitCount += 1
                    self.group.leave()

				case .success(let tracks):
                    guard let track = tracks.first else {
                        self.successfulTransfers.append(song)
                        self.progress.completedUnitCount += 1
                        self.group.leave()
                        return
                    }

                    track.addToLibrary(with: Handler { error in
                        if error != nil {
                            self.failedTransfers.append(song)
                        }
                        else {
                            self.successfulTransfers.append(song)
                        }

                        self.progress.completedUnitCount += 1
                        self.group.leave()
                    })
                }
			})
		}
	}

}
