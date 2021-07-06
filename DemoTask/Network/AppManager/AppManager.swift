//
//  AppManager.swift
//  FortuneToken
//
//  Created by Vishwajeet on 5/22/21.
//

import Foundation

typealias handler = (_ responseData: Data?, _ status: StatusCode, _ error: Error?) -> Void

class AppManager {
        
    static func fetchBreeds(searchText: String, _ handler: @escaping handler) {
        ConnectionManager.shared.request(.GET,
                                         API.searchBreeds,
                                         RequestManager.searchBreeds(searchText)) { (data, status, error) in
            handler(data, status, error)
        }
    }
    
    static func fetchImages(breedId: String, pageNum: Int, limit: Int, _ handler: @escaping handler) {
        ConnectionManager.shared.request(.GET,
                                         API.fetchImages,
                                         RequestManager.fetchImages(breedId,
                                                                    pageNum: pageNum,
                                                                    limit: limit)) { (data, status, error) in
            handler(data, status, error)
        }
    }
}

extension AppManager {
    
    static func convertDictToData(_ dict: [String : Any]) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            return jsonData
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func convertArrayToData(_ array: [Any]) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            return jsonData
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func convertObjectToData(param : Any) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
            return jsonData
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func getJsonObject(fromData data: Data, parseHandler: @escaping(_ json: Any?,  _ error: Error?)-> Void )  {
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                parseHandler(jsonDict,nil)
            } else if let jsonArray = try JSONSerialization.jsonObject(with:data, options: [.mutableContainers, .allowFragments]) as? Array<Any> {
                parseHandler(jsonArray,nil)
            }
        }
        catch let error {
            parseHandler(nil,error)
        }
    }
    
    static func decodeData<T: Decodable>(raw data: Data, withType type:T.Type, processComplete: @escaping(_ model:T?,  _ error: Error?)->Void) {
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            processComplete(model, nil) }
        catch let error {
            processComplete(nil, error)
            print(error)
        }
    }
}
