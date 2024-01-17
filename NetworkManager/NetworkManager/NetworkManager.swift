//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by siheo on 1/4/24.
//

import Foundation
import RxSwift

public class NetworkManager {
    
    public static var shared = NetworkManager(requestProvider: AlamofireNetwork.shared, responseProvider: AlamofireNetwork.shared)
    
    private var requestProvider: NetworkRequestProtocol
    private var responseProvider: NetworkResponseProtocol
    
    internal init(requestProvider: NetworkRequestProtocol, responseProvider: NetworkResponseProtocol) {
        self.requestProvider = requestProvider
        self.responseProvider = responseProvider
    }
    
    public func getMethod(_ url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse? {
        guard let request = createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: .get) else { return nil }
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func patchMethod(_ url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse?{
        guard let request = createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: .patch) else { return nil }
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func postMethod(_ url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse? {
        guard let request = createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: .post) else { return nil }
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    public func deleteMethod(_ url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]? = nil, parameters: Encodable? = nil, encoding: ParameterEncoding = .url) -> NetworkResponse? {
        guard let request = createURLRequest(url: url, headers: headers, parameters: parameters, encoding: encoding, method: .delete) else { return nil }
        return NetworkResponse(request: request, provider: responseProvider)
    }
    
    private func createURLRequest(url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]?, parameters: Encodable?, encoding: ParameterEncoding, method: NetworkRequestMethod) -> URLRequest? {
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

public enum HTTPRequestHeaderKey: String {
    case contentType = "Content-Type"
}

public enum HTTPRequestHeaderValue: String {
    case applicationJson = "application/json"
}

internal enum NetworkRequestMethod {
    case get
    case post
    case patch
    case delete
}

internal protocol NetworkRequestProtocol {
    func createURLRequest(url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]?, method: NetworkRequestMethod) -> URLRequest?
    func createURLRequest<T>(url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]?, parameters: T, encoding: ParameterEncoding, method: NetworkRequestMethod) -> URLRequest? where T: Encodable
}

internal protocol NetworkResponseProtocol {
    func response(_ request: URLRequest) -> Observable<Data?>
    func decodableResponse<T>(_ request: URLRequest, of type: T.Type) -> Observable<T> where T: Decodable
}

public struct NetworkResponse {
    private let request: URLRequest
    private let responseProvider: NetworkResponseProtocol
    
    internal init(request: URLRequest, provider: NetworkResponseProtocol) {
        self.request = request
        self.responseProvider = provider
    }
    
    public func response() -> Observable<Data?> {
        return responseProvider.response(request)
    }
    
    public func decodableResponse<T>(of type: T.Type) -> Observable<T> where T: Decodable {
        return responseProvider.decodableResponse(request, of: type)
    }
}
