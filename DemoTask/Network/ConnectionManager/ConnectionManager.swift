//
//  ConnectionManager.swift
//
//  Created by Surjeet on 5/12/21.
//

import UIKit

public enum MethodType: String {
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

public enum StatusCode: Int {
    case success = 200
    case failed
    case invalidToken
    case networkNotAvailable
    case unknown
}

public enum Type: Int {
    case png
    case jpeg
    case video
}

typealias responseHandler = (_ responseData: Data?, _ status: StatusCode, _ error: Error?) -> Void

public class ConnectionManager: NSObject {
    
    static let shared = ConnectionManager()
    
    //MARK:  Send Request
    func request(_ method: MethodType = .POST, _ urlString: String, _ parameters: [String: Any]? = nil, _ authentication: Bool = false, _ completionHandler: @escaping responseHandler) {
        
        if isInternetReachable() {
            if let urlRequest = createRequest(method, urlString, parameters) {
                print("Final URL: \(urlRequest.url)")
                print("Final HEADERS: \(urlRequest.allHTTPHeaderFields)")
                let task = createSession(authentication).dataTask(with: urlRequest, completionHandler: {data, response, error -> Void in
                    self.handleResponse(data, response, error, completionHandler)
                })
                task.resume()
            }
        }
        else {
            completionHandler(nil, .networkNotAvailable, nil)
        }
    }
    
    //MARK:  Send Request With Multipart
    func requestWithMultipart(_ method: MethodType = .POST, _ urlString: String, _ parameters: [String: Any]? = nil, _ authentication: Bool = false, _ imagesData: [Any]? = nil, _ type: Type = .jpeg, _ completionHandler: @escaping responseHandler) {
        if isInternetReachable() {
            if let urlRequest = createRequest(method, urlString, parameters, true, imagesData, type) {
                let task = createSession(authentication).dataTask(with: urlRequest, completionHandler: {data, response, error -> Void in
                    self.handleResponse(data, response, error, completionHandler)
                })
                task.resume()
            }
        }
        else {
            completionHandler(nil, .networkNotAvailable, nil)
        }
    }
    
    //MARK:  Private Methods
    private func createSession(_ authentication: Bool = false) -> URLSession {
        if authentication {
            let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
            return URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        }
        else {
            return URLSession.shared
        }
    }
    
    private func jsonRequest(_ urlString: String, _ parameters: [String: Any]? = nil) {
        do {
            if let requestParameter = parameters {
                let jsonData = try JSONSerialization.data(withJSONObject: requestParameter , options: JSONSerialization.WritingOptions.prettyPrinted)
                
                if let jsonRequest = NSString(data: jsonData,
                                              encoding: String.Encoding.utf8.rawValue) {
                    print("JSON Request: \(jsonRequest)")
                }
            }
            print("URL : \(urlString)")
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    private func createRequest(_ method: MethodType = .POST, _ urlString: String, _ parameters: [String: Any]? = nil, _ isMultipartRequest: Bool = false, _ imagesData: [Any]? = nil, _ type: Type = .jpeg) -> URLRequest? {
        jsonRequest(urlString, parameters)
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue
        do {
            let boundary = self.generateBoundaryString()
            
            if method == .GET, let params = parameters {
                var urlComps = URLComponents(string: urlString)!
                var queryItems:[URLQueryItem] = [URLQueryItem]()
                for key in params.keys {
                    if let value = params[key] {
                        let val = value as? String ?? "\(value)"
                        let newItem = URLQueryItem(name: key, value: val)
                        queryItems.append(newItem)
                    }
                }
                if let _ = urlComps.queryItems {
                    urlComps.queryItems?.append(contentsOf: queryItems)
                } else {
                    urlComps.queryItems = queryItems
                }
                if let geturl = urlComps.url {
                    request = NSMutableURLRequest(url: geturl)
                }
            }
            else if let params = parameters {
                var postData: Data? = nil
                if isMultipartRequest {
                    postData =  createBodyWithParameters(params, imagesData, type, boundary)
                }
                else {
                    postData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
                }
                if let data = postData {
                    let postLength = NSString(format: "%ld", (data.count))
                    request.httpBody = data
                    request.addValue(postLength as String, forHTTPHeaderField: "Content-Length")
                }
            }
//            request.addValue(isMultipartRequest ? "multipart/form-data; boundary=\(boundary)" : "application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(Config.apiKey, forHTTPHeaderField: "x-api-key")
            
            request.timeoutInterval = 120.0
            return request as URLRequest
        }
        catch {
            let encodingError = error as NSError
            print("Error could not parse JSON: \(encodingError)")
        }
        return nil
    }
    
    private func handleResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ completionHandler: @escaping responseHandler) {
        
        DispatchQueue.main.async {
            guard error == nil else {
                completionHandler(nil, .failed, error)
                return
            }
                
            guard let httpResponse = (response as? HTTPURLResponse), (httpResponse.statusCode == StatusCode.success.rawValue) else {
                if let httpResponse = (response as? HTTPURLResponse), httpResponse.statusCode == StatusCode.invalidToken.rawValue {
                    completionHandler(nil, .invalidToken, error)
                }
                completionHandler(nil, .failed, error)
                return
            }
            guard let responseData = data else {
                completionHandler(nil, .failed, error)
                return
            }
            completionHandler(responseData, .success , nil)
        }
    }
    
    private func convertKeyValue(_ jsonString: String) -> [String : Any]? {
        if let data = jsonString.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func createBodyWithParameters(_ parameters: [String: Any]?,_ imagesData: [Any]?,_ type: Type, _ boundary: String) -> Data {
        
        let body = NSMutableData()
        if let requestParameter = parameters {
            for (key, value) in requestParameter {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        if let datas = imagesData {
            for imageData in  datas {
                if let imageDatas = imageData as? [String: Data] {
                    for (key, data) in imageDatas {
                        let type = type == .jpeg ? "jpeg" : type == .png ? "png" : "mov"
                        let filename = "\(key).\(type)"
                        let mimetype = "application/\(type)"
                        body.appendString("--\(boundary)\r\n")
                        body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
                        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                        body.append(data)
                        body.appendString("\r\n")
                    }
                }
            }
        }
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    private func isInternetReachable() -> Bool {
        return true // to check internet connectivity
    }
}


extension ConnectionManager: URLSessionDelegate {
    
    //MARK:  URLSession delegate
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        if challenge.previousFailureCount > 0 {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
        else {
            // Set username and password for authentication
            let credential = URLCredential(user:"", password:"", persistence: .forSession)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,credential)
        }
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let err = error {
            print("Error: \(err.localizedDescription)")
        } else {
            print("Error. Giving up")
        }
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}
