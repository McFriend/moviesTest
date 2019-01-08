//
//  ApiParser.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import Foundation
import SwiftyJSON

class ApiParser {
    
    class func parseMovies(json: JSON) -> Array<MovieModel>
    {
        var movies = Array<MovieModel>()
        for movieJSON in json.arrayValue
        {
            movies.append(parseMovie(json: movieJSON))
        }
        return movies
    }
    
    class func parseMovie(json: JSON) -> MovieModel
    {
        let movie = MovieModel()
        movie.id = json["id"].intValue
        movie.vote_average = json["vote_average"].doubleValue
        movie.vote_count = json["vote_count"].intValue
        movie.video = json["video"].boolValue
        movie.media_type = json["media_type"].stringValue
        movie.title = json["title"].stringValue
        movie.popularity = json["popularity"].doubleValue
        movie.poster_path = json["poster_path"].stringValue
        movie.backdrop_path = json["backdrop_path"].stringValue
        movie.original_language = json["original_language"].stringValue
        movie.original_title = json["original_title"].stringValue
        movie.adult = json["adult"].boolValue
        movie.overview = json["overview"].stringValue
        let dateString = json["release_date"].stringValue
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        movie.release_date = formatter.date(from: dateString) ?? Date()
        movie.genre_ids.removeAll()
        for genre_id in json["genre_ids"].arrayValue
        {
            movie.genre_ids.append(genre_id.intValue)
        }
        return movie
    }
}
