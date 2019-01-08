//
//  MainScreenViewModel.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
class MainScreenViewModel: BaseViewModel {
    let title = BehaviorRelay(value: "Фильмы")
    let searchText = BehaviorRelay(value: "")
    var items = Variable<[BaseTableViewCellViewModel]>([])
    var page = Variable<Page>(Page.none)
    var apiManager = ApiManager()
    var error = Variable<Error?>(nil)

    override init() {
        super.init()
        searchText.asObservable().observeOn(MainScheduler.instance).bind { (newValue) in
            print(newValue)
            guard newValue != "" else { return }
            self.refreshAction(sender: nil)
        }.disposed(by: disposeBag)
    }
    
    
    @objc func refreshAction(sender: UIRefreshControl?)
    {
        sender?.beginRefreshing()
        self.page.value = Page.none
        apiManager.searchMovies(searchText: self.searchText.value, page: 1).observeOn(MainScheduler.instance).subscribe(onNext: { (success, page, movies, error) in
            sender?.endRefreshing()
            self.error.value = error
            guard error == nil, movies != nil else { return }
            self.page.value = page
            DispatchQueue.global(qos: .userInitiated).async {
                self.items.value = movies?.generateTableViewCells() ?? []
            }
        }, onError: { (error) in
            self.error.value = error
        }, onCompleted: nil, onDisposed: nil).disposed(by: apiManager.disposeBag)
    }
    
    func loadNextPage()
    {
        let maxPageIndex = self.page.value.totalPages - 1
        guard self.page.value.currentPage < maxPageIndex else { return }
        apiManager.searchMovies(searchText: self.searchText.value, page: self.page.value.currentPage + 1)
            .subscribe(onNext: { (success, page, movies, error) in
            self.error.value = error
            guard error == nil, movies != nil else { return }
            self.page.value = page
            DispatchQueue.global(qos: .userInitiated).async {
                self.items.value.append(contentsOf: movies?.generateTableViewCells() ?? [])
            }
        }, onError: { (error) in
            self.error.value = error
        }, onCompleted: nil, onDisposed: nil).disposed(by: apiManager.disposeBag)
    }
}
