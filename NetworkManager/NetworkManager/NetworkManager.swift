//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by siheo on 1/4/24.
//

import Foundation

public class NetworkManager {
    
    public static var shared = NetworkManager(provider: AlamofireNetwork())
    
    private var networkProvider: NetworkProtocol!
    
    internal init(provider: NetworkProtocol) {
        self.networkProvider = provider
    }
    
    public func getMethod<T, U>(_ url: String, headers: [String : String]? = nil, parameter: [String : U] = [String : String](), encoding: ParamterEncoding = .url, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
        networkProvider.getMethod(url, headers: headers, parameter: parameter, encoding: encoding, responseDataType: responseDataType, completionHandler: completionHandler)
    }
    
    public func patchMethod<T, U>(_ url: String, headers: [String : String]? = nil, parameter: [String : U] = [String : String](), encoding: ParamterEncoding = .url, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
        networkProvider.patchMethod(url, headers: headers, parameter: parameter, encoding: encoding, responseDataType: responseDataType, completionHandler: completionHandler)
    }
    
    public func postMethod<T, U>(_ url: String, headers: [String : String]? = nil, parameter: [String : U] = [String : String](), encoding: ParamterEncoding = .url, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
        networkProvider.postMethod(url, headers: headers, parameter: parameter, encoding: encoding, responseDataType: responseDataType, completionHandler: completionHandler)
    }
    
    public func deleteMethod<T, U>(_ url: String, headers: [String : String]? = nil, parameter: [String : U] = [String : String](), encoding: ParamterEncoding = .url, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
        networkProvider.deleteMethod(url, headers: headers, parameter: parameter, encoding: encoding, responseDataType: responseDataType, completionHandler: completionHandler)
    }
}

public enum ParamterEncoding {
    case url
    case json
}

public enum HTTPResponse<U> {
    public enum ResponseError: LocalizedError {
        case requestFailed(String)
        
        public var errorDescription: String? {
            switch self {
            case .requestFailed(let string):
                return string
            }
        }
    }
    
    case Success(data: U)
    case Fail(error: ResponseError)
}

internal protocol NetworkProtocol {
    func getMethod<T, U>(_ url: String, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable
    func patchMethod<T, U>(_ url: String, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable
    func postMethod<T, U>(_ url: String, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable
    func deleteMethod<T, U>(_ url: String, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable
}
