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
    var currentRequest = Variable<Request?>(nil)
    var controller: MainScreenController?
    var selectionHandler: ((MovieModel)->())?
    
    override init() {
        super.init()
        refreshAction()
    }
    
    
    @objc func refreshAction()
    {
        self.page.value = Page.none
        self.currentRequest.value?.cancel()
        self.currentRequest.value = ApiManager.shared.discoverMovies(page: 1) { [weak self] (success, page, movies, error) in
            self?.controller?.handleError(error: error)
            guard error == nil, self != nil, movies != nil else { return }
            self?.page.value = page
            self?.items.value = movies!.generateCollectionViewPreviewCells()
            self?.currentRequest.value = nil
        }
    }
    
    func loadNextPage()
    {
        let maxPageIndex = self.page.value.totalPages - 1
        guard self.page.value.currentPage < maxPageIndex else { return }
        self.currentRequest.value?.cancel()
        self.currentRequest.value = ApiManager.shared.discoverMovies(page: self.page.value.currentPage + 1) { [weak self] (success, page, movies, error) in
            self?.controller?.handleError(error: error)
            guard error == nil, self != nil, movies != nil else { return }
            self?.page.value = page
            self?.items.value.append(contentsOf: movies!.generateCollectionViewPreviewCells())
            self?.currentRequest.value = nil
        }
    }
}

extension DiscoverViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == items.value.count - 1 {
            loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let item = items.value[indexPath.item] as? MoviePreviewCellViewModel {
            selectionHandler?(item.movie)
        }
    }
}

class DiscoverView: UIView {
    var viewModel: DiscoverViewModel
    var collectionView: UICollectionView!
    
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
        collectionView.delegate = viewModel
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
        viewModel.items.asObservable().bind(to: collectionView.rx.items(cellIdentifier: MoviePreviewCell.cellIdentifier)) { (index, item, cell) in
            DispatchQueue.main.async {
                guard let cell = cell as? MoviePreviewCell, let movieItem = item as? MoviePreviewCellViewModel else { return }
                cell.configure(with: movieItem)
            }
            }.disposed(by: viewModel.disposeBag)
    }
}
