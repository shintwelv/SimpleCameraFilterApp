//
//  AlamofireNetwork.swift
//  NetworkManager
//
//  Created by siheo on 1/4/24.
//

import Foundation
import Alamofire

internal struct AlamofireNetwork: NetworkProtocol {
    func getMethod<T, U>(_ url: String, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
        self.request(url, method: .get, headers: headers, parameter: parameter, encoding: encoding ,responseDataType: responseDataType, completionHandler: completionHandler)
    }
    
    func patchMethod<T, U>(_ url: String, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
        self.request(url, method: .patch, headers: headers, parameter: parameter, encoding: encoding ,responseDataType: responseDataType, completionHandler: completionHandler)
    }
    
    func postMethod<T, U>(_ url: String, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
        self.request(url, method: .post, headers: headers, parameter: parameter, encoding: encoding ,responseDataType: responseDataType, completionHandler: completionHandler)
    }
    
    func deleteMethod<T, U>(_ url: String, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
        self.request(url, method: .delete, headers: headers, parameter: parameter, encoding: encoding ,responseDataType: responseDataType, completionHandler: completionHandler)
    }
    
    private func request<T, U>(_ url: String, method: HTTPMethod, headers: [String : String]?, parameter: [String : U]?, encoding: ParamterEncoding, responseDataType: T.Type, completionHandler: @escaping (HTTPResponse<T>) -> Void) where T: Decodable, U: Encodable {
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
        
        AF.request(url, method: method, parameters: parameter, encoder: parameterEncoder, headers: httpHeaders).responseDecodable(of: responseDataType) { response in
            guard let responseValue = response.value else {
                let result = HTTPResponse<T>.Fail(error: .requestFailed("request failed"))
                completionHandler(result)
                return
            }
            
            let result = HTTPResponse<T>.Success(data: responseValue)
            completionHandler(result)
        }
    }
}
