//
//  FullGifModel.swift
//  gifLoader
//
//  Created by Edgars Baumanis on 25.04.19.
//  Copyright © 2019. g. chili. All rights reserved.
//

import Foundation
import Kingfisher

class FullGifModel {
    var gifURL: String?

    init(gifURL: String?) {
        self.gifURL = gifURL
    }

    func clearCache() {
        ImageCache.default.clearMemoryCache()
    }
}
