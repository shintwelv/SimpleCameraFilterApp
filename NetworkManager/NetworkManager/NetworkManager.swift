//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by siheo on 1/4/24.
//

import Foundation

public class NetworkManager {
    
    public static var shared = NetworkManager(requestProvider: AlamofireNetwork.shared, responseProvider: AlamofireNetwork.shared)
    
    private var requestProvider: NetworkRequestProtocol
    private var responseProvider: NetworkResponseProtocol
    
    internal init(requestProvider: NetworkRequestProtocol, responseProvider: NetworkResponseProtocol) {
        self.requestProvider = requestProvider
        self.responseProvider = responseProvider
    }
    
    public func getMethod(_ url: String, headers: [String : String]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse? {
        let request: URLRequest? = {
            if let parameters = parameters {
                return requestProvider.get(url: url, headers: headers, parameters: parameters, encoding: encoding)
            } else {
                return requestProvider.get(url: url, headers: headers)
            }
        }()
        
        guard let request = request else { return nil }
        
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func patchMethod(_ url: String, headers: [String : String]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse?{
        let request: URLRequest? = {
            if let parameters = parameters {
                return requestProvider.patch(url: url, headers: headers, parameters: parameters, encoding: encoding)
            } else {
                return requestProvider.patch(url: url, headers: headers)
            }
        }()
        
        guard let request = request else { return nil }
        
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func postMethod(_ url: String, headers: [String : String]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse? {
        let request: URLRequest? = {
            if let parameters = parameters {
                return requestProvider.post(url: url, headers: headers, parameters: parameters, encoding: encoding)
            } else {
                return requestProvider.post(url: url, headers: headers)
            }
        }()
        
        guard let request = request else { return nil }
        
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func deleteMethod(_ url: String, headers: [String : String]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse? {
        let request: URLRequest? = {
            if let parameters = parameters {
                return requestProvider.delete(url: url, headers: headers, parameters: parameters, encoding: encoding)
            } else {
                return requestProvider.delete(url: url, headers: headers)
            }
        }()
        
        guard let request = request else { return nil }
        
        return NetworkResponse(request: request, provider: responseProvider)
    }
}

public enum ParameterEncoding {
    case url
    case json
}

public enum HTTPResponse<U> {
    case Success(data: U)
    case Fail(error: Error)
}

internal protocol NetworkRequestProtocol {
    func get(url: String, headers: [String : String]?) -> URLRequest?
    func patch(url: String, headers: [String : String]?) -> URLRequest?
    func post(url: String, headers: [String : String]?) -> URLRequest?
    func delete(url: String, headers: [String : String]?) -> URLRequest?
    
    func get<T>(url: String, headers: [String : String]? , parameters: T, encoding: ParameterEncoding) -> URLRequest? where T: Encodable
    func patch<T>(url: String, headers: [String : String]? , parameters: T, encoding: ParameterEncoding) -> URLRequest? where T: Encodable
    func post<T>(url: String, headers: [String : String]? , parameters: T, encoding: ParameterEncoding) -> URLRequest? where T: Encodable
    func delete<T>(url: String, headers: [String : String]? , parameters: T, encoding: ParameterEncoding) -> URLRequest? where T: Encodable
}

internal protocol NetworkResponseProtocol {
    func response(_ request: URLRequest, completionHandler: NetworkResponseHandler<Data?>?)
    func decodableResponse<T>(_ request: URLRequest, of type: T.Type, completionHandler: NetworkResponseHandler<T>?) where T: Decodable
}

public typealias NetworkResponseHandler<T> = (HTTPResponse<T>) -> Void

public struct NetworkResponse {
    private let request: URLRequest
    private let responseProvider: NetworkResponseProtocol
    
    internal init(request: URLRequest, provider: NetworkResponseProtocol) {
        self.request = request
        self.responseProvider = provider
    }
    
    public func response(completionHandler: NetworkResponseHandler<Data?>?) {
        responseProvider.response(self.request, completionHandler: completionHandler)
    }
    
    public func decodableResponse<T>(of type: T.Type, completionHandler: NetworkResponseHandler<T>?) where T: Decodable {
        responseProvider.decodableResponse(self.request, of: type, completionHandler: completionHandler)
    }
}
