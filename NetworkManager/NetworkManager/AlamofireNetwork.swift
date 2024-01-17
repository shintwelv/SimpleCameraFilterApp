//
//  AlamofireNetwork.swift
//  NetworkManager
//
//  Created by siheo on 1/4/24.
//

import Foundation
import Alamofire
import RxSwift

internal struct AlamofireNetwork: NetworkResponseProtocol, NetworkRequestProtocol {
    
    internal static let shared = AlamofireNetwork()
    
    func response(_ request: URLRequest) -> Observable<Data?> {
        return Observable<Data?>.create { observer in
            
            AF.request(request)
                .responseData { (response: AFDataResponse<Data>) in
                    
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            
            return Disposables.create()
        }
    }
    
    func decodableResponse<T>(_ request: URLRequest, of type: T.Type) -> Observable<T> where T : Decodable {
        return Observable<T>.create { observer in
            
            AF.request(request)
                .responseDecodable(of: type) { (response: DataResponse<T, AFError>) in
                    
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func createURLRequest(url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]?, method: NetworkRequestMethod) -> URLRequest? {
        let httpHeaders: HTTPHeaders? = createHTTPHeaders(headers: headers)
        let AFMethod: HTTPMethod = convert(from: method)
        
        return AF.request(url, method: AFMethod, headers: httpHeaders).convertible.urlRequest
    }
    
    func createURLRequest<T>(url: String, headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]?, parameters: T, encoding: ParameterEncoding, method: NetworkRequestMethod) -> URLRequest? where T: Encodable {
        let httpHeaders: HTTPHeaders? = createHTTPHeaders(headers: headers)
        let AFMethod: HTTPMethod = convert(from: method)
        let parameterEncoder: ParameterEncoder = convert(from: encoding)
        
        return AF.request(url, method: AFMethod, parameters: parameters, encoder: parameterEncoder, headers: httpHeaders).convertible.urlRequest
    }
    
    private func convert(from encoding: ParameterEncoding) -> ParameterEncoder {
        switch encoding {
        case .url:
            return URLEncodedFormParameterEncoder.default
        case .json:
            return JSONParameterEncoder.default
        }
    }
    
    private func convert(from method: NetworkRequestMethod) -> HTTPMethod {
        switch method {
        case .get:
            return .get
        case .post:
            return .post
        case .patch:
            return .patch
        case .delete:
            return .delete
        }
    }
    
    private func createHTTPHeaders(headers: [HTTPRequestHeaderKey : HTTPRequestHeaderValue]?) -> HTTPHeaders? {
        guard let headers = headers else { return nil }
        
        var AFHeaders: HTTPHeaders = [:]
        
        for (key, value) in headers {
            AFHeaders.add(HTTPHeader(name: key.rawValue, value: value.rawValue))
        }
        
        return AFHeaders
    }
}
