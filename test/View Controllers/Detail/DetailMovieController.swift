//
//  DetailMovieController.swift
//  test
//
//  Created by Георгий Сабанов on 23/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import MBProgressHUD

class DetailMovieController: BaseViewController {
    let previewImageView = UIImageView()
    let infoTextView = UITextView(frame: .zero)
    var viewModel: DetailMovieViewModel
    
    init (viewModel: DetailMovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.controller = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func adjustUI() {
        super.adjustUI()
        view.addSubview(previewImageView)
        view.addSubview(infoTextView)
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.sd_setImage(with: viewModel.movie.value?.previewURL, completed: nil)
        infoTextView.isEditable = false
        infoTextView.isSelectable = false
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        previewImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.topMargin)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(280)
        }
        infoTextView.snp.makeConstraints { (make) in
            make.top.equalTo(previewImageView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
    }
    
    override func configureViewModel() {
        super.configureViewModel()
        viewModel.title.asObservable().bind(to: self.rx.title).disposed(by: viewModel.disposeBag)
        viewModel.movie.asObservable().bind { (movie) in
            guard let movie = movie else { return }
            var infoText = ""
            infoText += "Название: \(movie.title)\n"
            infoText += "Год выпуска: \(movie.release_date.dateString)\n"
            infoText += "Рейтинг: \(movie.vote_average)\n"
            infoText += "Описание:\n\(movie.overview)"
            self.infoTextView.text = infoText
            }.disposed(by: viewModel.disposeBag)
    }
    
    deinit {
        previewImageView.sd_cancelCurrentImageLoad()
    }
}

