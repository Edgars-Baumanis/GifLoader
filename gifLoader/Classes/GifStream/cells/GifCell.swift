//
//  GifCell.swift
//  gifLoader
//
//  Created by Edgars Baumanis on 23.04.19.
//  Copyright © 2019. g. chili. All rights reserved.
//

import UIKit
import Kingfisher

class GifCell: UICollectionViewCell {
    @IBOutlet weak var gifImage: AnimatedImageView!

    func displayContent(url: String?) {
        guard let url = url else { return }
        guard let newUrl = URL(string: url) else { return }
        gifImage.kf.setImage(with: newUrl)
    }
}
