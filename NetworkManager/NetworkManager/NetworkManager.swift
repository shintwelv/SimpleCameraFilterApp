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
        guard let request = createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: .get) else { return nil }
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func patchMethod(_ url: String, headers: [String : String]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse?{
        guard let request = createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: .patch) else { return nil }
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func postMethod(_ url: String, headers: [String : String]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse? {
        guard let request = createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: .post) else { return nil }
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func deleteMethod(_ url: String, headers: [String : String]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse? {
        guard let request = createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: .delete) else { return nil }
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    private func createURLRequest(url: String, headers: [String : String]?, parameters: Encodable?, encoding: ParameterEncoding, method: NetworkRequestMethod) -> URLRequest? {
        if let parameters = parameters {
            return requestProvider.createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: method)
        } else {
            return requestProvider.createURLRequest(url: url, headers: headers, method: method)
        }
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

internal enum NetworkRequestMethod {
    case get
    case post
    case patch
    case delete
}

internal protocol NetworkRequestProtocol {
    func createURLRequest(url: String, headers: [String : String]?, method: NetworkRequestMethod) -> URLRequest?
    func createURLRequest<T>(url: String, headers: [String : String]?, parameters: T, encoding: ParameterEncoding, method: NetworkRequestMethod) -> URLRequest? where T: Encodable
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
