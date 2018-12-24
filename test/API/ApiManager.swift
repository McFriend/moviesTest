//
//  ApiManager.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import Foundation
import SwiftyJSON
import Realm
import RealmSwift
import Alamofire

typealias SuccessResultHandler = (Bool) //Operation completed with success?
typealias MoviesResultHandler = ((Bool, Page, List<MovieModel>?, Error?) -> ()) //Operation completed with success? / Page number / List of movies
typealias RetryResultHandler = (URLRequest?, (()->())?, (()->())?) //URL request, success handler, failure handler

struct Page {
    var currentPage = 0
    var totalPages = 0
    init(_ currentPage: Int, _ totalPages: Int)
    {
        self.currentPage = currentPage
        self.totalPages = totalPages
    }
    
    init(_ json: JSON) {
        self.currentPage = json["page"].intValue
        self.totalPages = json["total_pages"].intValue
    }
    static let none = Page(-1,-1)
}

class ApiManager {
    static let shared = ApiManager()
    static let baseURL = "https://api.themoviedb.org"
    static let imagesBaseURL = "https://image.tmdb.org/t/p/w500"
    static let apiEndpoint = "/3/"
    private static let apiKey = "50c97de568c983d931c1d269481c0870"
    public static let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    let sessionManager = SessionManager()
    init() {
        sessionManager.retrier = RetryHandler()
        
    }
    private func basicParams() -> Parameters {
        return ["api_key":ApiManager.apiKey, "language":"ru-RU"]
    }
    
    func discoverMovies(page: Int, _ completion: @escaping MoviesResultHandler) -> Request
    {
        var params = basicParams()
        params["sort_by"] = "popularity.desc"
        params["include_adult"] = true
        params["page"] = page
        let request = sessionManager.request(ApiEndpoints.discover.urlString + ApiEndpoints.movie.rawValue, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let error = response.error as NSError?, error.code == -999 {
                return //Запрос был отменен, не показываем алерт
            }
            if response.data != nil {
                guard let json = try? JSON(data: response.data!) else { completion(false, Page.none, nil, ParsingFailedError()); return }
                completion(true, Page(json), ApiParser.parseMovies(json: json["results"]), nil)
            } else {
                completion(false, Page.none, nil, response.error)
            }
        }
        return request
    }
    
    func searchMovies(searchText: String, page: Int, _ completion: @escaping MoviesResultHandler) -> Request
    {
        var params = basicParams()
        params["query"] = searchText
        params["include_adult"] = true
        params["page"] = page
        let request = sessionManager.request(ApiEndpoints.searchMovie.urlString, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let error = response.error as NSError?, error.code == -999 {
                return //Запрос был отменен, не показываем алерт
            }
            if response.data != nil {
                guard let json = try? JSON(data: response.data!) else {
                    completion(false, Page.none, nil, ParsingFailedError())
                    return
                }
                completion(true, Page(json), ApiParser.parseMovies(json: json["results"]), nil)
            } else {
                completion(false, Page.none, nil, response.error)
            }
        }
        return request
    }
}

//MARK: Network reachability
extension ApiManager {
    
    class func checkForReachability() {
        networkReachabilityManager?.listener = { status in
            print("Network Status: \(status)")
            switch status {
            case .notReachable: break
            case .reachable(_), .unknown: break
            }
        }
        networkReachabilityManager?.startListening()
    }
}

enum ApiEndpoints: String {
    case movie
    case discover
    case searchMovie = "search/movie"
    
    var urlString: String {
        return ApiManager.baseURL + ApiManager.apiEndpoint + self.rawValue + "/"
    }
    var url: URL {
        return URL(string: urlString)!
    }
}

class RetryHandler: RequestAdapter, RequestRetrier {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let err = error as? URLError, err.code == .notConnectedToInternet {
            ApiManager.networkReachabilityManager?.listener = { status in
                print("Network Status: \(status)")
                switch status {
                case .notReachable: break
                case .reachable(_), .unknown:
                    completion(true, 1.0)
                }
            }
            ApiManager.networkReachabilityManager?.startListening()
        } else {
            completion(false, 0.0) // don't retry
        }
    }
}

