//
//  MovieModel.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import Foundation

enum MediaType: String {
    case movie
}

class MovieModel {
    var id = 0
    var vote_average = 0.0
    var vote_count = 0
    var video = false
    var media_type = ""
    var title = ""
    var popularity = 0.0
    var poster_path = ""
    var backdrop_path = ""
    var original_language = ""
    var original_title = ""
    var adult = false
    var overview = ""
    var release_date = Date()
    var genre_ids = Array<Int>()
    var previewURL: URL? {
        return URL(string:ApiManager.imagesBaseURL + self.poster_path)
    }
    
}

extension Array where Element: MovieModel {
    func generateTableViewCells() -> [MovieTableViewCellViewModel]
    {
        let array = Array(self)
        var cellViewModels = [MovieTableViewCellViewModel]()
        for movie in array {
            let movieVM = MovieTableViewCellViewModel(movie: movie)
            movieVM.recalculateSize()
            cellViewModels.append(movieVM)
        }
        return cellViewModels
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
