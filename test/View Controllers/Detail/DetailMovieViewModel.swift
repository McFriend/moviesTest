//
//  DetailMovieViewModel.swift
//  test
//
//  Created by Георгий Сабанов on 23/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
class DetailMovieViewModel: BaseViewModel {
    var movie = Variable<MovieModel?>(nil)
    let title = Variable<String>("")
    var controller: DetailMovieController?
    
    init(movie: MovieModel) {
        super.init()
        self.movie.value = movie
        title.value = movie.title
    }
}
