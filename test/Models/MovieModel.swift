//
//  MovieModel.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

enum MediaType: String {
    case movie
}

class MovieModel: Object {
    @objc dynamic var id = 0
    @objc dynamic var vote_average = 0.0
    @objc dynamic var vote_count = 0
    @objc dynamic var video = false
    @objc dynamic var media_type = ""
    @objc dynamic var title = ""
    @objc dynamic var popularity = 0.0
    @objc dynamic var poster_path = ""
    @objc dynamic var backdrop_path = ""
    @objc dynamic var original_language = ""
    @objc dynamic var original_title = ""
    @objc dynamic var adult = false
    @objc dynamic var overview = ""
    @objc dynamic var release_date = Date()
    let genre_ids = List<Int>()
    var previewURL: URL? {
        return URL(string:ApiManager.imagesBaseURL + self.poster_path)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension List where Element: MovieModel {
    func generateTableViewCells(onCompletion: (([MovieTableViewCellViewModel])->()))
    {
        let array = Array(self)
        var cellViewModels = [MovieTableViewCellViewModel]()
        let semaphore = DispatchSemaphore(value: 0)
        for movie in array {
            let movieVM = MovieTableViewCellViewModel(movie: movie)
            movieVM.recalculateSizeAsync {
                semaphore.signal()
            }
            semaphore.wait()
            cellViewModels.append(movieVM)
        }
        onCompletion(cellViewModels)
    }
    
    func generateCollectionViewPreviewCells() -> [MoviePreviewCellViewModel]
    {
        let array = Array(self)
        var cellViewModels = [MoviePreviewCellViewModel]()
        for movie in array {
            let movieVM = MoviePreviewCellViewModel(movie: movie)
            cellViewModels.append(movieVM)
        }
        return cellViewModels
    }
}
