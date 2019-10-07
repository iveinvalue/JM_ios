//
//  requestHTTP.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

func RequestHTTP(url:String, completion: @escaping (String)->()){
    let url3 = URL(string: url)
    let taskk2 = URLSession.shared.dataTask(with: url3! as URL) { data, response, error in
        guard let data = data, error == nil else { return }
        let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        completion(result)
    }
    taskk2.resume()
}
