//
//  MovieTableViewCell.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import SDWebImage

class MovieTableViewCellViewModel: BaseTableViewCellViewModel {
    var movie: MovieModel
    
    init(movie: MovieModel)
    {
        self.movie = movie
        super.init()
        let cellClass = MovieTableViewCell.self
        self.item = BaseTableViewItem.init(cellIdentifier: String(describing: cellClass), cellType: cellClass, size: calculateSize(movie: movie))
    }
    func recalculateSizeAsync(_ onCompletion: @escaping (()->()))
    {
        let movieRef = ThreadSafeReference(to: movie)
        DispatchQueue.global(qos: .background).async {
            let realm = try! Realm()
            guard let movieSafe = realm.resolve(movieRef) else { return; }
            self.item.size = self.calculateSize(movie: movieSafe)
            onCompletion()
        }
    }
    private func calculateSize(movie: MovieModel) -> CGSize
    {
        let maxWidth = UIScreen.main.bounds.size.width - 148
        let titleFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        let dateFont = UIFont.systemFont(ofSize: 13)
        let messageFont = UIFont.systemFont(ofSize: 15)
        let titleSize = movie.title.height(withConstrainedWidth: maxWidth, font: titleFont)
        let dateSize = movie.release_date.dateString.height(withConstrainedWidth: maxWidth, font: dateFont)
        let messageSize = movie.overview.height(withConstrainedWidth: maxWidth, font: messageFont)
        let finalHeight = titleSize + 2 + dateSize + 4 + messageSize + 16
        if finalHeight > 156 {
            return CGSize(width: UIScreen.main.bounds.size.width, height: finalHeight)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width, height: 156)
        }
    }
}

class MovieTableViewCell: UITableViewCell {
    let previewImageView = UIImageView()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let messageLabel = UILabel()
    var viewModel: MovieTableViewCellViewModel!
    static var cellIdentifier: String {
        get {
            return String(describing: MovieTableViewCell.self)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.viewModel = nil
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        adjustUI()
        configureConstraints()
    }
    
    func configure(with viewModel: MovieTableViewCellViewModel)
    {
        self.viewModel = viewModel
        titleLabel.text = viewModel.movie.title
        dateLabel.text = viewModel.movie.release_date.dateString
        messageLabel.text = viewModel.movie.overview
        previewImageView.sd_setImage(with: viewModel.movie.previewURL, completed: nil)
    }
    
    func adjustUI()
    {
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(messageLabel)
        addSubview(previewImageView)
        previewImageView.contentMode = .scaleAspectFit
        titleLabel.numberOfLines = 0
        messageLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .black
        dateLabel.textColor = .lightGray
        messageLabel.textColor = .darkGray
        translatesAutoresizingMaskIntoConstraints = true
    }
    
    func configureConstraints()
    {
        previewImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(100)
            make.height.equalTo(140)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(previewImageView.snp.trailing).offset(16)
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(previewImageView.snp.trailing).offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.trailing.equalToSuperview().offset(-16)
        }
        messageLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(previewImageView.snp.trailing).offset(16)
            make.top.equalTo(dateLabel.snp.bottom).offset(2)
            make.trailing.equalToSuperview().offset(-16)
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
