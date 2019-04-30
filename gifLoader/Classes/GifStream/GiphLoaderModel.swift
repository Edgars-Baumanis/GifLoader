//
//  GiphLoaderModel.swift
//  gifLoader
//
//  Created by Edgars Baumanis on 24.04.19.
//  Copyright © 2019. g. chili. All rights reserved.
//

import Foundation
import GiphyCoreSDK
import Kingfisher


class GiphLoaderModel {
    var reloadData: (() -> Void)?
    var nothingToShow: (() -> Void)?
    var somethingToShow: (() -> Void)?
    var gifs: [[String]] = [[],[]]
    private var offset = 0
    private var limit = 50

    init() {
        
        GiphyCore.configure(apiKey: "wyMn8XM8236d9Ox7VfrTfOpwTII2J9tu")
        
        getRandomGifs(firstTime: true)
    }

    func searchGif(searchText: String, firstTime: Bool) {
        if !firstTime {
            offset = limit
            if limit <= 1000 {
                limit += limit
            }
        } else {
            offset = 0
            limit = 50
            gifs = [[],[]]
        }
        GiphyCore.shared.search(searchText, offset: offset, limit: limit, rating: .ratedPG13) { [weak self] (response, error) in
            if let error = error as? NSError {
                print(error)
            }
            if let data = response?.data {
                if !data.isEmpty {
                    DispatchQueue.main.async {
                        self?.somethingToShow?()
                    }
                    for result in data {
                        let sampleURL = result.images?.fixedHeightDownsampled?.gifUrl
                        let fullURL = result.images?.original?.gifUrl
                        guard let newSampleUrl = sampleURL, let newFullUrl = fullURL else { return }
                        self?.gifs[0].append(newSampleUrl)
                        self?.gifs[1].append(newFullUrl)
                        DispatchQueue.main.async {
                            self?.reloadData?()
                        }
                    }
                } else {
                    if searchText.isEmpty {
                            self?.getRandomGifs(firstTime: firstTime)
                    } else {
                        DispatchQueue.main.async {
                            if self?.gifs == [[],[]] {
                                self?.nothingToShow?()
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self?.reloadData?()
                    }
                }
            } else {
                print("No result found")
            }

        }
    }

    private func getRandomGifs(firstTime: Bool) {
        if !firstTime {
            offset = limit
            if limit <= 1000 {
                limit += limit
            }
        } else {
            offset = 0
            limit = 50
            gifs = [[],[]]
        }
        GiphyCore.shared.trending(offset: offset, limit: limit, rating: .ratedPG13) { [weak self] (response, error) in
            if let error = error as? NSError {
                print(error)
            }
            if let data = response?.data {
                if !data.isEmpty {
                    DispatchQueue.main.async {
                        self?.somethingToShow?()
                    }
                    for result in data {
                        let sampleURL = result.images?.fixedHeightDownsampled?.gifUrl
                        let fullURL = result.images?.original?.gifUrl
                        guard let newSampleUrl = sampleURL, let newFullUrl = fullURL else { return }
                        self?.gifs[0].append(newSampleUrl)
                        self?.gifs[1].append(newFullUrl)
                        DispatchQueue.main.async {
                            self?.reloadData?()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.nothingToShow?()
                        self?.reloadData?()
                    }
                }
            } else {
                print("No result found")
            }
        }
    }

    func clearCache() {
        ImageCache.default.clearMemoryCache()
    }
}


