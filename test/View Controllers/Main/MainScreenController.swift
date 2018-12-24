//
//  MainScreenController.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import MBProgressHUD

class MainScreenController: BaseViewController {
    var tableView = UITableView(frame: .zero, style: .plain)
    let discoverView = DiscoverView(viewModel: DiscoverViewModel())
    let searchBar = UISearchBar(frame: .zero)
    var viewModel: MainScreenViewModel
    
    init (viewModel: MainScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.controller = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func adjustUI() {
        super.adjustUI()
        view.addSubview(searchBar)
        searchBar.sizeToFit()
        view.addSubview(discoverView)
        discoverView.viewModel.controller = self
        discoverView.viewModel.selectionHandler = { [weak self] movie in
            self?.showDetailedMovie(movie)
        }
        discoverView.frame.size.height = 156
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.cellIdentifier)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(viewModel, action: #selector(MainScreenViewModel.refreshAction(sender:)), for: .valueChanged)
        tableView.delegate = viewModel
        tableView.tableHeaderView = discoverView
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.keyboardDismissMode = .onDrag
        searchBar.placeholder = "Поиск"
    }
    
    func showDetailedMovie(_ movie: MovieModel)
    {
        let vc = DetailMovieController(viewModel: DetailMovieViewModel(movie: movie))
        self.show(vc, sender: self)
    }
    
    override func configureNavigationController()
    {
        super.configureNavigationController()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
        
    override func configureConstraints() {
        super.configureConstraints()
        searchBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.snp.topMargin)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func configureViewModel() {
        super.configureViewModel()
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: viewModel.disposeBag)
        searchBar.rx.searchButtonClicked.bind {
            self.searchBar.resignFirstResponder()
        }.disposed(by: viewModel.disposeBag)
        viewModel.items.asObservable().bind(to: tableView.rx.items(cellIdentifier: MovieTableViewCell.cellIdentifier)) { (index, item, cell) in
            DispatchQueue.main.async {
                guard let cell = cell as? MovieTableViewCell, let movieItem = item as? MovieTableViewCellViewModel else { return }
                cell.configure(with: movieItem)
            }
            }.disposed(by: viewModel.disposeBag)
        viewModel.title.asObservable().bind(to: self.rx.title).disposed(by: viewModel.disposeBag)
    }
}
