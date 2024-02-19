//
//  APIClient.swift
//  FlickrApp
//
//  Created by Ruthwik Nekkanti on 2/19/24.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#endif

public func sdkVersion() -> String {
    return "1.0"
}

public func buildUserAgent() -> String {
    
    let version = sdkVersion()
    let devide = "Device/\(deviceModel())"
#if os(iOS)
    let os = "iOS/\(UIDevice.current.systemVersion)"
#elseif os(watchOS)
    let os = "watchOS/\(UIDevice.current.systemVersion)"
#elseif os(tvOS)
    let os = "tvOS/\(UIDevice.current.systemVersion)"
#elseif os(macOS)
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    let os = "macOS/\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
#endif
    return "FlickrApp/\(version) \(os) \(devide)"
}

internal func deviceModel() -> String {
    var system = utsname()
    uname(&system)
    let model = withUnsafePointer(to: &system.machine.0) { ptr in
        return String(cString: ptr)
    }
    return model
}

public enum ApiError: Error {
    case invalidUrl
    case emptyResponse
    case invalidRequestObject
    case invalidResponseObject
    case invalidClientInfo
    case unparsableResponse
    case invalidToken
    case unsuccessfulResponse(Int)
    case error(Error)
    case badCredentials
    case notFound
    case tooManyRequests
    case invalidMFACode
    case noUserFound
    case custom(String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("Invalid URL", comment: "API failure")
        case .emptyResponse:
            return NSLocalizedString("Empty response", comment: "API failure")
        case .invalidRequestObject:
            return NSLocalizedString("Invalid request object", comment: "API failure")
        case .invalidResponseObject:
            return NSLocalizedString("Invalid response object", comment: "API failure")
        case .invalidClientInfo:
            return NSLocalizedString("Unable to parse client info from response", comment: "API failure")
        case .invalidToken:
            return NSLocalizedString("Invalid JWT token", comment: "API failure")
        case .unparsableResponse:
            return NSLocalizedString("Unable to parse response", comment: "API failure")
        case .unsuccessfulResponse(let statusCode):
            return NSLocalizedString("Unsuccessful response: \(statusCode)", comment: "API failure")
        case .error(let error):
            return error.localizedDescription
        case .badCredentials:
            return NSLocalizedString("Invalid login", comment: "API failure")
        case .notFound:
            return NSLocalizedString("No Data Found", comment: "API failure")
        case .tooManyRequests:
            return NSLocalizedString("Try again in 30 seconds", comment: "API failure")
        case .invalidMFACode:
            return NSLocalizedString("Invalid code", comment: "API failure")
        case .noUserFound:
            return NSLocalizedString("No User Found", comment: "API failure")
        case .custom(let errorMessage):
            return errorMessage
        }
    }
    public var errorDescription: String {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("Invalid URL", comment: "API failure")
        case .emptyResponse:
            return NSLocalizedString("Empty response", comment: "API failure")
        case .invalidRequestObject:
            return NSLocalizedString("Invalid request object", comment: "API failure")
        case .invalidResponseObject:
            return NSLocalizedString("Invalid response object", comment: "API failure")
        case .invalidClientInfo:
            return NSLocalizedString("Unable to parse client info from response", comment: "API failure")
        case .invalidToken:
            return NSLocalizedString("Invalid JWT token", comment: "API failure")
        case .unparsableResponse:
            return NSLocalizedString("Unable to parse response", comment: "API failure")
        case .unsuccessfulResponse(let statusCode):
            return NSLocalizedString("Unsuccessful response: \(statusCode)", comment: "API failure")
        case .error(let error):
            return error.localizedDescription
        case .badCredentials:
            return NSLocalizedString("Invalid login", comment: "API failure")
        case .notFound:
            return NSLocalizedString("Not found", comment: "API failure")
        case .tooManyRequests:
            return NSLocalizedString("Try again in 30 seconds", comment: "API failure")
        case .invalidMFACode:
            return NSLocalizedString("Invalid code", comment: "API failure")
        case .noUserFound:
            return NSLocalizedString("No User Found", comment: "API failure")
        case .custom(let errorMessage):
            return errorMessage
        }
    }
}


public enum ApiResult<S, F> {
    case success(HTTPURLResponse, S)
    case failure(HTTPURLResponse?, F)
}

public enum Endpoint {
    case absoluteUrl(URL) //
    case endpoint(String,[URLQueryItem]? = nil) // Our main api
    //services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=por
    var url: URL? {
        
        let domain = BaseUrl.baseUrl.baseUrlString
        switch self {
        case .endpoint(let endpoint,let queryItems):
            let baseUrl = "\(domain)" //https://
            var url = URL(string: baseUrl + "\(endpoint.hasPrefix("/") ? "" : "/")\(endpoint)")
            if let qis = queryItems {
                var urlComp = URLComponents(string: baseUrl + "\(endpoint.hasPrefix("/") ? "" : "/")\(endpoint)")!
                urlComp.queryItems = qis
                url = urlComp.url
            }
            return url
        case .absoluteUrl(let url):
            return url
        }
    }
    
    var headers: [String: String] {
        
        let header = ["Content-Type": ContentType.applicationJson.rawValue,
                      "UserAgent": buildUserAgent()]
        
        return header
        
    }
}

public enum ContentType: String, Codable {
    case applicationJson = "application/json"
    case applicationXformUrlEncoded = "application/x-www-form-urlencoded"
}

public enum Method: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
}
class ApiClient {
    static var dataTask: URLSessionDataTask!

    
    static func performCall<IN:Encodable>(
        endpoint: Endpoint,
        method: Method,
        requestObject: IN,
        completion: @escaping ((ApiResult<Data?, ApiError>) -> Void)
    ) {
        guard
            let data = (try? ApiClient.encode(requestObject))
        else {
            completion(.failure(nil, .invalidRequestObject))
            return
        }
        
        performCall(
            endpoint: endpoint,
            method: method,
            data: data,
            completion: completion
        )
    }
    
    static func performCall<OUT:Codable>(
        endpoint: Endpoint,
        method: Method = .get,
        data: Data? = nil,
        responseType: OUT.Type,
        completion: @escaping ((ApiResult<OUT, ApiError>) -> Void)
    ) {
        performCall(
            endpoint: endpoint,
            method: method,
            data: data
        ) { result in
            switch result {
            case .failure(let response, let error):
                completion(.failure(response, error))
            case .success(let response, let data):
                guard let data = data else {
                    completion(.failure(response, .emptyResponse))
                    return
                }
                do {
                    let object = try ApiClient.decode(OUT.self, from: data)
                    completion(.success(response, object))
                    
                } catch DecodingError.dataCorrupted(let context) {
                    print(context)
                    completion(.failure(response, ApiError.custom(context.debugDescription)))
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(response, ApiError.custom(context.debugDescription)))
                } catch DecodingError.valueNotFound(let value, let context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(response, ApiError.custom(context.debugDescription)))
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(response, ApiError.custom(context.debugDescription)))
                } catch {
                    completion(.failure(response, .error(error)))
                }
            }
        }
    }
    
    static func performCall<IN:Encodable, OUT:Codable>(
        endpoint: Endpoint,
        method: Method,
        requestObject: IN,
        responseType: OUT.Type,
        isDefaultObject: Bool = true,
        completion: @escaping ((ApiResult<OUT, ApiError>) -> Void)
    ) {
        guard
            let data = (try? ApiClient.encode(requestObject))
        else {
            completion(.failure(nil, .invalidRequestObject))
            return
        }
        
        performCall(
            endpoint: endpoint,
            method: method,
            data: data
        ) { result in
            switch result {
            case .failure(let response, let error):
                completion(.failure(response, error))
            case .success(let response, let data):
                guard let data = data else {
                    completion(.failure(response, .emptyResponse))
                    return
                }
                do {
                    let object = try ApiClient.decode(OUT.self, from: data)
                    completion(.success(response, object))
                } catch DecodingError.dataCorrupted(let context) {
                    print(context)
                    completion(.failure(response, ApiError.custom(context.debugDescription)))
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(response, ApiError.custom(context.debugDescription)))
                } catch DecodingError.valueNotFound(let value, let context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(response, ApiError.custom(context.debugDescription)))
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(response, ApiError.custom(context.debugDescription)))
                } catch {
                    completion(.failure(response, .error(error)))
                }
            }
        }
    }
    static func performCall(
        endpoint: Endpoint,
        method: Method,
        data: Data? = nil,
        requireAuth: Bool = true,
        completion: @escaping ((ApiResult<Data?, ApiError>) -> Void)
    ) {
        self.performCall(endpoint: endpoint, method: method, data: data) { result in
            switch result {
            case .failure(let response, let error):
                completion(.failure(response, error))
            case .success:
                completion(result)
            }
        }
    }
    
    private static func performCall(
        endpoint: Endpoint,
        method: Method,
        data: Data?,
        completion: @escaping ((ApiResult<Data?, ApiError>) -> Void)
    ) {
        guard let url = endpoint.url else {
            completion(.failure(nil, .invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.allowsCellularAccess = true
        request.networkServiceType = .responsiveData
        request.httpMethod = method.rawValue
        request.httpBody = data
        request.timeoutInterval = 120
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        for (header, value) in endpoint.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        
        URLSession.shared.dataTask(with: request) { responseData, response, error in
#if DEBUG
            var strLog = "HTTP URL :: \(url.absoluteString)"
            strLog = strLog + "\nHTTP Method :: \(request.httpMethod ?? "")"
            strLog = strLog + "\nHTTP Header Fields :: \(request.allHTTPHeaderFields ?? [:])"
            if let finalData = data, let requestData = String(data: finalData, encoding: String.Encoding.utf8) {
                strLog = strLog + "\nHTTP Request Data :: \(requestData)"
            }
            
            if let finalData = responseData, let respData = String(data: finalData, encoding: String.Encoding.utf8) {
                strLog = strLog + "\nHTTP Response Data :: \(respData)"
            }
            print(strLog)
#endif
            guard let response = response as? HTTPURLResponse, let finalData = responseData else {
                if let error = error {
                    print("API Error::\n",error)
                    completion(.failure(nil, .error(error)))
                } else {
                    completion(.failure(nil, .invalidResponseObject))
                }
                return
            }
            completion(.success(response, finalData))
        }.resume()
    }
}

// MARK: - JSON Coding
extension ApiClient {
    private static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return encoder
    }
    
    private static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return decoder
    }
    
    static func encode<T>(_ value: T) throws -> Data where T: Encodable {
        return try jsonEncoder.encode(value)
    }
    
    static func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        return try jsonDecoder.decode(T.self, from: data)
    }
}
