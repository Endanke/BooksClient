//
//  BookApi.swift
//  BooksClient
//
//  Created by Daniel Eke on 2019. 03. 21..
//  Copyright © 2019. Daniel Eke. All rights reserved.
//

import Foundation
import RxSwift

class BookApi {
    
    // I'm aware that the api key should not be included in the source directly
    // This is just here for easier demonstration
    private struct Constants {
        static let apiKey = "AIzaSyBcmhF9nPV2q7AgFuq5g2PSHekQZAybwJA"
        static let baseURL = "https://www.googleapis.com/books/v1/"
    }
    
    func search(title: String) -> Observable<[Book]> {
        return Observable.create { observer in
            let encodedTitle = title.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: "\(Constants.baseURL)volumes?q=\(encodedTitle)&key=\(Constants.apiKey)")!
            
            var request = URLRequest(url: url)
            
            // API key is limited to the iOS bundle id, so add it it the header
            request.addValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else { return }
                guard let data = data else { return }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        var books = [] as [Book]
                        if json["items"] != nil {
                            for item in json["items"] as! NSArray {
                                books.append(Book(item: item as! [String: Any]))
                            }
                        }
                        observer.on(.next(books))
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            
            task.resume()
            
            return Disposables.create(with: task.cancel)
        }
    }
}
