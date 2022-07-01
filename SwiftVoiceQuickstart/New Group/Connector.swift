//
//  Connector.swift
//
//  Created by Vishal Paliwal on 26/05/22.
//

import UIKit

// Type of web request
enum RequestMethod {
    case get
    case post
    case delete
    case put
}

// HTTP response
struct HTTPResponse {
    var statusCode: Int = 0
    var response: URLResponse?
    var data: Data?
}

class Connector: NSObject {
    
    static let shared = Connector()
    
    // private initializer
    private override init() {
      
    }
    
    // internet connectivity class
    let reachibility: Reachability = Reachability()!
    
    // type aliases to make our code easier to read:
    typealias Percentage = Double
    typealias ProgressHandler = (Percentage) -> Void
    typealias CompletionHandler = (Result<Bool, Error>) -> Void

    private var progressHandlersByTaskID = [Int : ProgressHandler]()

    // MARK: - Request method
    /*
     * Method name: execute
     * Description: get response from web request via an URL Path
     * Parameters: URL String, Request Method, payload, and completion Handler
     * Return: nil
     */
    func execute(_ urlPath: String, _ method: RequestMethod,_ parameter:Dictionary<String, Any?>?, headers: [String: String]?, completion : @escaping ((responseHTTP : HTTPResponse?, error: String?)) -> ()) {
        
        // check network status
        if reachibility.connection == .none {
            return completion((nil, "No Internet Connection"))
        }
        
        //first print the params
        debugPrint(urlPath)
        
        // check for valid URL
        var escapedAddress = urlPath
        escapedAddress = escapedAddress.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        guard let url:URL = URL(string: escapedAddress) else {
            completion((nil, "URL is not valid"))
            return
        }
        
        if let param = parameter {
//            param.printJSONString()
        }
        
        
        //Create the URLRequest with URL
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let headers = headers {
            for key in headers.keys {
                request.addValue(headers[key] ?? "", forHTTPHeaderField: key)
            }
        }
        
        switch method {
        case .get:
            request.httpMethod = "GET"
            break
        case .post:
            request.httpMethod = "POST"
            if let parameter = parameter {
                let jsonData = try? JSONSerialization.data(withJSONObject: parameter)
                request.httpBody = jsonData
            }
            break
        case .delete:
            request.httpMethod = "DELETE"
            break
        case .put:
            request.httpMethod = "PUT"
            if let parameter = parameter {
                let jsonData = try? JSONSerialization.data(withJSONObject: parameter)
                request.httpBody = jsonData
            }
            break
            
        }
        
        // start a request to user
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            if let error = error {
                debugPrint("error \(error.localizedDescription)")
                completion((nil, "error \(error.localizedDescription)"))
            } else {
                // handle HTTP errors here
                if let httpResponse = response as? HTTPURLResponse {
                    
                    // Get status code
                    let statusCode = httpResponse.statusCode
                    let serverResponse = HTTPResponse(statusCode: statusCode, response: response, data: data)
                    completion((serverResponse, nil))
                }
            }
        })
        
        task.resume()
    }

    /*
     * Method name: load
     * Description: download file from url path
     * Parameters: URL String, local storage path url, and completion Handler
     * Return: nil
     */
    func load(url: URL, to localUrl: URL, completion: @escaping CompletionHandler) {
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            let request = URLRequest(url: url)

            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Success: \(statusCode)")
                    }

                    do {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                        completion(.success(true))
                    } catch (let writeError) {
                        print("error writing file \(localUrl) : \(writeError)")
                        completion(.failure(writeError))
                    }

                } else if let error = error {
                    print("Failure: %@", error.localizedDescription);
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    
    /*
     * Method name: uploadFile
     * Description: download file from url path
     * Parameters: URL String, local storage path url, and completion Handler
     * Return: nil
     */
    func uploadFile(
           at fileURL: URL,
           to targetURL: URL,
           progressHandler: @escaping ProgressHandler, completionHandler: @escaping CompletionHandler
       ) {
           var request = URLRequest(
               url: targetURL,
               cachePolicy: .reloadIgnoringLocalCacheData
           )
           
           request.httpMethod = "POST"

           let task = URLSession.shared.uploadTask(
               with: request,
               fromFile: fileURL,
               completionHandler: { data, response, error in
                   // Validate response and call handler
                   // ...
                   if let error = error {
                       completionHandler(.failure(error))
                   } else {
                       completionHandler(.success(true))
                   }
                }
           )
           
           
           progressHandlersByTaskID[task.taskIdentifier] = progressHandler
           task.resume()
       }
}

extension Connector: URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        let handler = progressHandlersByTaskID[task.taskIdentifier]
        handler?(progress)
    }
}
