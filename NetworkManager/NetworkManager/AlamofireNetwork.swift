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
    
    func get(url: String, headers: [String : String]?) -> URLRequest? {
        return request(url, method: .get, headers: headers)
    }
    
    func patch(url: String, headers: [String : String]?) -> URLRequest? {
        return request(url, method: .patch, headers: headers)
    }
    
    func post(url: String, headers: [String : String]?) -> URLRequest? {
        return request(url, method: .post, headers: headers)
    }
    
    func delete(url: String, headers: [String : String]?) -> URLRequest? {
        return request(url, method: .delete, headers: headers)
    }
    
    func get<T>(url: String, headers: [String : String]?, parameters: T, encoding: ParameterEncoding) -> URLRequest? where T : Encodable {
        return request(url, method: .get, headers: headers, parameter: parameters, encoding: encoding)
    }
    
    func patch<T>(url: String, headers: [String : String]?, parameters: T, encoding: ParameterEncoding) -> URLRequest? where T : Encodable {
        return request(url, method: .patch, headers: headers, parameter: parameters, encoding: encoding)
    }
    
    func post<T>(url: String, headers: [String : String]?, parameters: T, encoding: ParameterEncoding) -> URLRequest? where T : Encodable {
        return request(url, method: .post, headers: headers, parameter: parameters, encoding: encoding)
    }
    
    func delete<T>(url: String, headers: [String : String]?, parameters: T, encoding: ParameterEncoding) -> URLRequest? where T : Encodable {
        return request(url, method: .delete, headers: headers, parameter: parameters, encoding: encoding)
    }
    
    private func request(_ url:String, method: HTTPMethod, headers: [String : String]?) -> URLRequest? {
        let httpHeaders: HTTPHeaders? = {
            guard let headers = headers else { return nil }
            return HTTPHeaders(headers)
        }()
        
        return AF.request(url, method: method, headers: httpHeaders).convertible.urlRequest
    }
    
    private func request<T>(_ url: String, method: HTTPMethod, headers: [String : String]?, parameter: T?, encoding: ParameterEncoding) -> URLRequest? where T: Encodable {
        let httpHeaders: HTTPHeaders? = {
            guard let headers = headers else { return nil }
            return HTTPHeaders(headers)
        }()
        
        let parameterEncoder: ParameterEncoder = {
            switch encoding {
            case .url:
                return URLEncodedFormParameterEncoder.default
            case .json:
                return JSONParameterEncoder.default
            }
        }()
        
        return AF.request(url, method: method, parameters: parameter, encoder: parameterEncoder, headers: httpHeaders).convertible.urlRequest
    }
}
