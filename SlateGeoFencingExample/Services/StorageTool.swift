//
//  StorageTool.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 23/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import Foundation
import Result

//MARK:- Interface
protocol StorageToolProtocol {
    static func loadLocationPayloadBean(completionHandler: (Result<LocationPayloadBean, NSError>) -> Void)
}

//MARK:- Implementation
extension StorageToolProtocol {
    static func loadLocationPayloadBean(completionHandler: (Result<LocationPayloadBean, NSError>) -> Void) {
        let objString = UserDefaults.standard.object(forKey: String(describing: type(of: LocationPayloadBean.self)))
    
        if objString == nil {
            completionHandler(.failure(NSError(domain: "LocationPayloadBean",
                                               code: 404,
                                               userInfo: [NSLocalizedDescriptionKey : "Data not found"])))
        } else {
            if let jsonData = (objString as? String)?.data(using: .utf8) {
                do {
                    let locationPayloadBean = try JSONDecoder().decode(LocationPayloadBean.self, from: jsonData)
                    completionHandler(.success(locationPayloadBean))
                } catch let error {
                    completionHandler(.failure(error as NSError))
                }
            } else {
                completionHandler(.failure(NSError(domain: "LocationPayloadBean",
                                                   code: 404,
                                                   userInfo: [NSLocalizedDescriptionKey : "Data not found"])))
            }
        }
    }
}

struct StorageTool: StorageToolProtocol {}
