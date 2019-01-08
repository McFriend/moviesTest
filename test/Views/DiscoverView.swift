//
//  DiscoverTableHeaderView.swift
//  test
//
//  Created by Георгий Сабанов on 24/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Realm
import Alamofire

class DiscoverViewModel: BaseViewModel {
    var items = Variable<[BaseCollectionViewCellViewModel]>([])
    var page = Variable<Page>(Page.none)
    var apiManager = ApiManager()
    var selectedMovie = Variable<MovieModel?>(nil)
    var error = Variable<Error?>(nil)

    override init() {
        super.init()
        refreshAction()
    }
    
    
    @objc func refreshAction()
    {
        self.page.value = Page.none
        apiManager.discoverMovies(page: 1).subscribe(onNext: { (success, page, movies, error) in
            self.error.value = error
            guard error == nil, movies != nil else { return }
            self.page.value = page
            DispatchQueue.global(qos: .userInitiated).async {
                self.items.value = movies?.generateCollectionViewPreviewCells() ?? []
            }
        }, onError: { (error) in
            self.error.value = error
        }, onCompleted: nil, onDisposed: nil).disposed(by: apiManager.disposeBag)
        
    }
    
    func loadNextPage()
    {
        let maxPageIndex = self.page.value.totalPages - 1
        guard self.page.value.currentPage < maxPageIndex else { return }
        apiManager.discoverMovies(page: self.page.value.currentPage + 1)
            .subscribe(onNext: { (success, page, movies, error) in
            self.error.value = error
            guard error == nil, movies != nil else { return }
            self.page.value = page
            DispatchQueue.global(qos: .userInitiated).async {
                self.items.value.append(contentsOf: movies?.generateCollectionViewPreviewCells() ?? [])
            }
        }, onError: { (error) in
            self.error.value = error
        }, onCompleted: nil, onDisposed: nil).disposed(by: apiManager.disposeBag)
    }
}

class DiscoverView: UIView {
    var viewModel: DiscoverViewModel
    var collectionView: UICollectionView!
    var disposeBag = DisposeBag()
    
    init (viewModel: DiscoverViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        adjustUI()
        configureConstraints()
        configureViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func adjustUI() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.register(MoviePreviewCell.self, forCellWithReuseIdentifier: MoviePreviewCell.cellIdentifier)
        collectionView.rx.modelSelected(MoviePreviewCellViewModel.self)
            .subscribe { (event) in
                if let item = event.element {
                    self.viewModel.selectedMovie.value = item.movie
                }
            }.disposed(by: viewModel.disposeBag)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 140)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func configureConstraints() {
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func configureViewModel() {
        viewModel.items.asObservable().observeOn(MainScheduler.instance).bind(to: collectionView.rx.items(cellIdentifier: MoviePreviewCell.cellIdentifier)) { (index, item, cell) in
            DispatchQueue.main.async {
                guard let cell = cell as? MoviePreviewCell, let movieItem = item as? MoviePreviewCellViewModel else { return }
                cell.configure(with: movieItem)
            }
            }.disposed(by: viewModel.disposeBag)
    }
}

extension DiscoverView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.items.value.count - 1 {
            viewModel.loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
