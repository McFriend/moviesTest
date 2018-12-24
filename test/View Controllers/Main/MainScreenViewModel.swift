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
    var currentRequest = Variable<Request?>(nil)
    var controller: MainScreenController?
    
    override init() {
        super.init()
        
        searchText.asObservable().bind { (newValue) in
            print(newValue)
            guard newValue != "" else { return }
            self.refreshAction(sender: nil)
        }.disposed(by: disposeBag)
    }
    
    
    @objc func refreshAction(sender: UIRefreshControl?)
    {
        sender?.beginRefreshing()
        self.page.value = Page.none
        self.currentRequest.value?.cancel()
        self.currentRequest.value = ApiManager.shared.searchMovies(searchText: self.searchText.value, page: 1) { [weak self] (success, page, movies, error) in
            sender?.endRefreshing()
            self?.controller?.handleError(error: error)
            guard error == nil, self != nil, movies != nil else { return }
            self?.page.value = page
            self?.controller?.tableView.scrollRectToVisible(.zero, animated: false)
            movies?.generateTableViewCells(onCompletion: { (movies) in
                self?.items.value = movies
            })
            self?.currentRequest.value = nil
        }
    }
    
    func loadNextPage()
    {
        let maxPageIndex = self.page.value.totalPages - 1
        guard self.page.value.currentPage < maxPageIndex else { return }
        self.currentRequest.value?.cancel()
        
        self.currentRequest.value = ApiManager.shared.searchMovies(searchText: self.searchText.value, page: self.page.value.currentPage + 1) { [weak self] (success, page, movies, error) in
            self?.controller?.handleError(error: error)
            guard error == nil, self != nil, movies != nil else { return }
            self?.page.value = page
            movies?.generateTableViewCells(onCompletion: { (movies) in
                self?.items.value.append(contentsOf: movies)
            })
            self?.currentRequest.value = nil
        }
    }
}

extension MainScreenViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items.value[indexPath.row].item.size.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.value.count - 1 {
            loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = items.value[indexPath.item] as? MovieTableViewCellViewModel {
            controller?.showDetailedMovie(item.movie)
        }
    }
}
