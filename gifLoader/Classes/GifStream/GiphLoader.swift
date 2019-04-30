//
//  GiphLoader.swift
//  gifLoader
//
//  Created by Edgars Baumanis on 23.04.19.
//  Copyright © 2019. g. chili. All rights reserved.
//

import UIKit

class GiphyLoader: UIViewController {
    @IBOutlet weak var nothingLabel: UILabel!
    @IBOutlet weak var gifTable: UICollectionView!
    @IBOutlet weak var gifSearch: UISearchBar!

    let viewModel = GiphLoaderModel()
    let throttler = Throttler(minimumDelay: 0.5)
    var cellSide: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.reloadData = { [weak self] in
            self?.gifTable.reloadData()
        }
        viewModel.nothingToShow = { [weak self] in
            self?.nothingLabel.isHidden = false
        }
        viewModel.somethingToShow = { [weak self] in
            self?.nothingLabel.isHidden = true
        }
        gifTable.decelerationRate = .fast
        gifSearch.delegate = self
        gifTable.dataSource = self
        gifTable.delegate = self
        cellSide = view.frame.width / 2.06
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension GiphyLoader: UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellSide = cellSide else { return CGSize(width: 100, height: 100)}
        return CGSize(width: cellSide, height: cellSide)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.gifs[0].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GifCell.self), for: indexPath)
        if let myCell = cell as? GifCell {
            if let cellSide = cellSide {
                cell.layer.cornerRadius = cellSide / 2
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 1
            }
            myCell.displayContent(url: viewModel.gifs[0][indexPath.row])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Full", sender: viewModel.gifs[1][indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Full" {
            guard let vc2 = segue.destination as? FullGifVC else { return }
            if let gifURL = sender as? String {
                vc2.viewModel = FullGifModel(gifURL: gifURL)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GifCell {
            cell.gifImage.kf.cancelDownloadTask()
            viewModel.clearCache()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        throttler.throttle { [weak self] in
            self?.viewModel.searchGif(searchText: searchText, firstTime: true)
            self?.viewModel.clearCache()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if viewModel.gifs[0].isEmpty != true {
            gifTable.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffSet = scrollView.contentOffset.y
        let maxOffSet = scrollView.contentSize.height - scrollView.frame.size.height

        if maxOffSet - currentOffSet <= 100 {
            guard let text = gifSearch.text else { return }
            viewModel.searchGif(searchText: text, firstTime: false)
        }
    }
}
