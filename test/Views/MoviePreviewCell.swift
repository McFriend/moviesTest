//
//  MoviePreviewCell.swift
//  test
//
//  Created by Георгий Сабанов on 24/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import SDWebImage

class MoviePreviewCellViewModel: BaseCollectionViewCellViewModel {
    var movie: MovieModel
    
    init(movie: MovieModel)
    {
        self.movie = movie
        super.init()
        let cellClass = MovieTableViewCell.self
        self.item = BaseCollectionViewItem.init(cellIdentifier: String(describing: cellClass), cellType: cellClass)
    }
}

class MoviePreviewCell: UICollectionViewCell {
    let previewImageView = UIImageView()
    var viewModel: MoviePreviewCellViewModel!
    static var cellIdentifier: String {
        get {
            return String(describing: MoviePreviewCell.self)
        }
    }
    
    override init(frame: CGRect) {
        self.viewModel = nil
        super.init(frame: frame)
        adjustUI()
        configureConstraints()
    }
    
    func configure(with viewModel: MoviePreviewCellViewModel)
    {
        self.viewModel = viewModel
        previewImageView.sd_setImage(with: viewModel.movie.previewURL, completed: nil)
    }

    func adjustUI()
    {
        addSubview(previewImageView)
        previewImageView.contentMode = .scaleAspectFit
    }

    func configureConstraints()
    {
        previewImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.sd_cancelCurrentImageLoad()
        previewImageView.image = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
