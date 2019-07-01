//
//  User.swift
//  Kleene
//
//  Includes data and settings for the user
//
//  Created on 2/17/19.
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
import AppleMusic
import Deezer
import Essentials
import Spotify

final class User {

	private(set) static var songs = [AnySong]()
	private(set) static var albums = [AnyGroup]()
	private(set) static var artists = [AnyGroup]()
	private(set) static var playlists = [AnyGroup]()
	static var services: [MusicService] {
		var services = [MusicService]()

		if AppleMusic.isAuthorized {
			services.append(.appleMusic)
		}
		if Deezer.isConnected {
			services.append(.deezer)
		}
		if Spotify.isSignedIn {
			services.append(.spotify)
		}

		return services
	}
	private(set) static var recentTransfers = [TransferResults]()
	private static let maxRecentTransfers = 25

	private static var simpleSet = Set<Simple>()

	private static let dispatchGroup: DispatchGroup = {
		let group = DispatchGroup()

		group.enter()
		group.notify(queue: .global(qos: .background), execute: {
			do {
				try store()
			}
			catch {
				debugPrint(error)
			}
		})

		return group
	}()

	static func load() {
		if !User.didRestore {
			User.restore()
		}

		if !AppleMusic.isAuthorized {
			removeContent(from: .appleMusic)
		}

		loadAppleMusic()
		loadDeezer()
		loadSpotify()

		dispatchGroup.leave()
	}

	static func loadAppleMusic() {
		assert(didRestore)

		guard AppleMusic.isAuthorized else {
			return
		}

		if let songs = AppleMusic.songs {
			insert(songs: songs)
		}
		if let albums = AppleMusic.albums {
			insert(albums: albums)
		}
		if let artists = AppleMusic.artists {
			insert(artists: artists)
		}
		if let playlists = AppleMusic.playlists {
			insert(playlists: playlists)
		}
	}
	static func loadDeezer() {
		assert(didRestore)

		guard Deezer.isConnected else {
			return
		}

		for _ in 0..<4 {
			dispatchGroup.enter()
		}

		Deezer.handleTracks(with: Handler { result in
			switch result {
			case .failure(let error):
				debugPrint(error)

			case .success(let tracks):
				insert(songs: tracks)
			}

			dispatchGroup.leave()
		})
		Deezer.handleAlbums(with: Handler { result in
			switch result {
			case .failure(let error):
				debugPrint(error)

			case .success(let albums):
				insert(albums: albums)
			}

			dispatchGroup.leave()
		})
		Deezer.handleArtists(with: Handler { result in
			switch result {
			case .failure(let error):
				debugPrint(error)

			case .success(let artists):
				insert(artists: artists)
			}

			dispatchGroup.leave()
		})
		Deezer.handlePlaylists(with: Handler { result in
			switch result {
			case .failure(let error):
				debugPrint(error)

			case .success(let playlists):
				insert(playlists: playlists)
			}

			dispatchGroup.leave()
		})
	}
	static func loadSpotify() {
		assert(didRestore)

		guard Spotify.isSignedIn else {
			return
		}

		dispatchGroup.enter()
		dispatchGroup.enter()

		Spotify.handleTracks(with: Handler { result in
			switch result {
			case .failure(let error):
				debugPrint(error)

			case .success(let tracks):
				insert(songs: tracks)

				let albums = tracks.map({ $0.album })
				let artists = Array(tracks.map({ $0.artists }).joined())

				insert(albums: albums)
				insert(artists: artists)
			}

			dispatchGroup.leave()
		})
		Spotify.handlePlaylists(with: Handler { result in
			switch result {
			case .failure(let error):
				debugPrint(error)

			case .success(let playlists):
				insert(playlists: playlists)
			}

			dispatchGroup.leave()
		})
	}

	private static func insert(songs newSongs: [AnySong]) {
		for song in newSongs {
			let simple = Simple(anySong: song)

			if !simpleSet.contains(simple) {
				simpleSet.insert(simple)
				songs.append(song)
			}
		}

		songs.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
	}
	private static func insert(albums newAlbums: [AnyGroup]) {
		for album in newAlbums {
			let simple = Simple(anyGroup: album)

			if !simpleSet.contains(simple) {
				simpleSet.insert(simple)
				albums.append(album)
			}
		}

		albums.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
	}
	private static func insert(artists newArtists: [AnyGroup]) {
		for artist in newArtists {
			let simple = Simple(anyGroup: artist)

			if !simpleSet.contains(simple) {
				var artistHasSong: Bool = false

				for song in songs {
					if song.service == artist.service && song.artistID == artist.identity {
						artistHasSong = true
						break
					}
				}
				if artistHasSong {
					simpleSet.insert(simple)
					artists.append(artist)
				}
			}
		}

		artists.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
	}
	private static func insert(playlists newPlaylists: [AnyGroup]) {
		for playlist in newPlaylists {
			let simple = Simple(anyGroup: playlist)

			if !simpleSet.contains(simple) {
				simpleSet.insert(simple)
				playlists.append(playlist)
			}
		}

		playlists.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
	}

	static func insert(transfer: TransferResults) {
		recentTransfers.insert(transfer, at: 0)

		if recentTransfers.count > maxRecentTransfers {
			recentTransfers.removeLast()
		}
	}

	static func removeContent(from service: MusicService) {
		songs.removeAll(where: { $0.service == service })
		albums.removeAll(where: { $0.service == service })
		artists.removeAll(where: { $0.service == service })
		playlists.removeAll(where: { $0.service == service })

		do {
			try store()
		}
		catch {
			debugPrint(error)
		}
	}

	static func findSong(using simple: Simple) -> AnySong? {
		for song in songs {
			if song.identity == simple.identity && song.service == simple.service {
				return song
			}
		}

		return nil
	}

	private static var didRestore = false

	private static let deezerSongsURL = cachesDirectory.appendingPathComponent("deezerSongs")
	private static let deezerAlbumsURL = cachesDirectory.appendingPathComponent("deezerAlbums")
	private static let deezerArtistsURL = cachesDirectory.appendingPathComponent("deezerArtists")
	private static let deezerPlaylistsURL = cachesDirectory.appendingPathComponent("deezerPlaylists")

	private static let spotifySongsURL = cachesDirectory.appendingPathComponent("spotifySongs")
	private static let spotifyAlbumsURL = cachesDirectory.appendingPathComponent("spotifyAlbums")
	private static let spotifyArtistsURL = cachesDirectory.appendingPathComponent("spotifyArtists")
	private static let spotifyPlaylistsURL = cachesDirectory.appendingPathComponent("spotifyPlaylists")

	private static let recentTransfersURL = cachesDirectory.appendingPathComponent("recentTransfers")

	static func store() throws {
		print("Storing music content...")

		let encoder = JSONEncoder()

		if let deezerSongs = songs.filter({ $0 is Deezer.ListTrack }) as? [Deezer.ListTrack] {
			let data = try encoder.encode(deezerSongs)

			try data.write(to: deezerSongsURL)
		}
		if let deezerAlbums = albums.filter({ $0 is Deezer.ListAlbum }) as? [Deezer.ListAlbum] {
			let data = try encoder.encode(deezerAlbums)

			try data.write(to: deezerAlbumsURL)
		}
		if let deezerArtists = artists.filter({ $0 is Deezer.ListArtist }) as? [Deezer.ListArtist] {
			let data = try encoder.encode(deezerArtists)

			try data.write(to: deezerArtistsURL)
		}
		if let deezerPlaylists = playlists.filter({ $0 is Deezer.ListPlaylist }) as? [Deezer.ListPlaylist] {
			let data = try encoder.encode(deezerPlaylists)

			try data.write(to: deezerPlaylistsURL)
		}

		if let spotifySongs = songs.filter({ $0 is Spotify.Track }) as? [Spotify.Track] {
			let spotifySongsData = try encoder.encode(spotifySongs)

			try spotifySongsData.write(to: spotifySongsURL)
		}
		if let spotifyAlbums = albums.filter({ $0 is Spotify.SimpleAlbum }) as? [Spotify.SimpleAlbum] {
			let albumsData = try encoder.encode(spotifyAlbums)

			try albumsData.write(to: spotifyAlbumsURL)
		}
		if let spotifyArtists = albums.filter({ $0 is Spotify.SimpleArtist }) as? [Spotify.SimpleArtist] {
			let artistsData = try encoder.encode(spotifyArtists)

			try artistsData.write(to: spotifyArtistsURL)
		}
		if let spotifyPlaylists = playlists.filter({ $0 is Spotify.Playlist }) as? [Spotify.Playlist] {
			let playlistsData = try encoder.encode(spotifyPlaylists)

			try playlistsData.write(to: spotifyPlaylistsURL)
		}

		let recentsData = try encoder.encode(recentTransfers)
		try recentsData.write(to: recentTransfersURL)
	}
	static func restore() {
		print("Restoring music content...")

		let decoder = JSONDecoder()

		if let jsonData = fileManager.contents(atPath: deezerSongsURL.path), let deezerSongs = try? decoder.decode([Deezer.ListTrack].self, from: jsonData) {
			insert(songs: deezerSongs)
		}
		if let jsonData = fileManager.contents(atPath: deezerAlbumsURL.path), let deezerAlbums = try? decoder.decode([Deezer.ListAlbum].self, from: jsonData) {
			insert(albums: deezerAlbums)
		}
		if let jsonData = fileManager.contents(atPath: deezerArtistsURL.path), let deezerArtists = try? decoder.decode([Deezer.ListArtist].self, from: jsonData) {
			insert(artists: deezerArtists)
		}
		if let jsonData = fileManager.contents(atPath: deezerPlaylistsURL.path), let deezerPlaylists = try? decoder.decode([Deezer.ListPlaylist].self, from: jsonData) {
			insert(playlists: deezerPlaylists)
		}

		if let jsonData = fileManager.contents(atPath: spotifySongsURL.path), let spotifySongs = try? decoder.decode([Spotify.Track].self, from: jsonData) {
			insert(songs: spotifySongs)
		}
		if let jsonData = fileManager.contents(atPath: spotifyAlbumsURL.path), let spotifyAlbums = try? decoder.decode([Spotify.SimpleAlbum].self, from: jsonData) {
			insert(albums: spotifyAlbums)
		}
		if let jsonData = fileManager.contents(atPath: spotifyArtistsURL.path), let spotifyArtists = try? decoder.decode([Spotify.SimpleArtist].self, from: jsonData) {
			insert(artists: spotifyArtists)
		}
		if let jsonData = fileManager.contents(atPath: spotifyPlaylistsURL.path), let spotifyPlaylists = try? decoder.decode([Spotify.Playlist].self, from: jsonData) {
			insert(playlists: spotifyPlaylists)
		}
		if let jsonData = try? Data(contentsOf: recentTransfersURL), let storedRecents = try? decoder.decode([TransferResults].self, from: jsonData) {
			recentTransfers.append(contentsOf: storedRecents)
		}

		didRestore = true
	}

}
