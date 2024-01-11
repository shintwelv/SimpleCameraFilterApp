//
//  AlamofireNetwork.swift
//  NetworkManager
//
//  Created by siheo on 1/4/24.
//

import Foundation
import Alamofire

internal struct AlamofireNetwork: NetworkResponseProtocol, NetworkRequestProtocol {
    
    internal static let shared = AlamofireNetwork()
    
    func response(_ request: URLRequest, completionHandler: NetworkResponseHandler<Data?>?) {
        AF.request(request)
            .responseData { (response: AFDataResponse<Data>) in
                guard let handler = completionHandler else { return }
                
                switch response.result {
                case .success(let data):
                    let httpResponse: HTTPResponse<Data?> = .Success(data: data)
                    handler(httpResponse)
                case .failure(let error):
                    let httpResponse: HTTPResponse<Data?> = .Fail(error: error)
                    handler(httpResponse)
                }
            }
    }
    
    func decodableResponse<T>(_ request: URLRequest, of type: T.Type, completionHandler: NetworkResponseHandler<T>?) where T : Decodable {
        AF.request(request)
            .responseDecodable(of: type) { (response: DataResponse<T, AFError>) in
                guard let handler = completionHandler else { return }
                
                switch response.result {
                case .success(let data):
                    let httpResponse: HTTPResponse<T> = .Success(data: data)
                    handler(httpResponse)
                    break
                case .failure(let error):
                    let httpResponse: HTTPResponse<T> = .Fail(error: error)
                    handler(httpResponse)
                }
            }
    }
    
    func createURLRequest(url: String, headers: [String : String]?, method: NetworkRequestMethod) -> URLRequest? {
        let httpHeaders: HTTPHeaders? = createHTTPHeaders(headers: headers)
        let AFMethod: HTTPMethod = convert(from: method)
        
        return AF.request(url, method: AFMethod, headers: httpHeaders).convertible.urlRequest
    }
    
    func createURLRequest<T>(url: String, headers: [String : String]?, parameters: T, encoding: ParameterEncoding, method: NetworkRequestMethod) -> URLRequest? where T: Encodable {
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
    
    private func createHTTPHeaders(headers: [String : String]?) -> HTTPHeaders? {
        guard let headers = headers else { return nil }
        return HTTPHeaders(headers)
    }
}
