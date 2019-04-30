//
//  FullGifVC.swift
//  gifLoader
//
//  Created by Edgars Baumanis on 25.04.19.
//  Copyright © 2019. g. chili. All rights reserved.
//

import UIKit

class FullGifVC: UIViewController {
    var viewModel: FullGifModel?
    var gifView: UIImageView?
    var spinnerView: SpinnerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        gifView = UIImageView(frame: CGRect(x: view.frame.minX, y: view.frame.midY, width: 0, height: 0 ))
        setupGif()
        makeSpinnerView()
        createTapGesture()
    }

    deinit {
        viewModel?.clearCache()
    }

    private func makeSpinnerView() {
        spinnerView = SpinnerView(frame: CGRect(x: 0, y: 0, width: view.frame.width / 2, height: view.frame.width / 2))
        spinnerView?.center = view.center
        spinnerView?.animate()
        guard let spinnerView = spinnerView else { return }
        view.addSubview(spinnerView)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func imagePressed(_ sender: UIGestureRecognizer) {
        if sender.view as? UIImageView != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func createTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePressed))
        gifView?.addGestureRecognizer(tapGesture)
        gifView?.isUserInteractionEnabled = true
    }

    func setupGif() {
        guard let url = viewModel?.gifURL else { return }
        guard let newUrl = URL(string: url) else { return }
        gifView?.kf.setImage(with: newUrl) { [weak self] result in
            switch result {
            case .success(let value):
                guard let size = self?.getImageSize(image: value.image) else { return }
                self?.gifView?.frame.size = size
                guard let gifView = self?.gifView, let center = self?.view.center else { return }
                self?.gifView?.center = center
                self?.spinnerView?.removeFromSuperview()
                self?.view.addSubview(gifView)
            case .failure(let error):
                print(error)
            }
        }
    }

    private func getImageSize(image: UIImage?) -> CGSize? {
        var size = CGSize(width: 0, height: 0)
        if let image = image {
            let ratio = image.size.height / image.size.width
            if view.frame.width > view.frame.height {
                size = CGSize(width: view.frame.width, height: view.frame.height / ratio)
            } else {
                size = CGSize(width: view.frame.width, height: view.frame.height * ratio)
            }
            if size.height > view.bounds.height {
                size = CGSize(width: view.frame.width, height: view.frame.height)
            }
        }
        return size
    }
}

