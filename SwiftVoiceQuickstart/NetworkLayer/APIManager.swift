//
//  APIManager.swift
//
//  Created by Vishal Paliwal on 30/05/22.
//

import Foundation

// MARK: - Errors
struct ServiceError: Error, Codable {
    let httpStatus: Int
    let message: String
    let description: String?
}

struct NetworkError: Error {
    let message: String
}

struct UnknownParseError: Error { }

class APIManager: NSObject {
    
    /// generic response data parser
    class func loadApiRequest<T: Codable>(model: T.Type, urlPath: String, method: RequestMethod, params: [String : Any?]?, onCompletion: @escaping(T?, String?) -> ()) {
        
        Connector.shared.execute(urlPath, method, params) { (responseHTTP, error) in
            
            if let error = error {
                onCompletion(nil, error)
                return
            } else if let response = responseHTTP {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

                do {
                    if let body = try? jsonDecoder.decode(model, from: response.data!), response.statusCode == 200 {
                        onCompletion(body, nil)
                        return
                    } else if let errorResponse = try? jsonDecoder.decode(ServiceError.self, from: response.data!) {
                        throw errorResponse
                    } else {
                        throw UnknownParseError()
                    }
                } catch let error as ServiceError {
                    print(error.description ?? "")
                    onCompletion(nil, error.description)
                } catch let error as NetworkError {
                    print(error.message)
                    onCompletion(nil, error.message)
                } catch let error {
                    print(error.localizedDescription)
                    onCompletion(nil, error.localizedDescription)
                }
                
            }
        }
    }
}
