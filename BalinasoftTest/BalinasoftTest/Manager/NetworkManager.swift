//
//  NetworkManager.swift
//  BalinasoftTest
//
//  Created by admin on 24.09.2023.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init(){}
    
    func getRequest(by page: Int = 0, path: Path = .get, completion: @escaping (Result<ListModel, Error>) -> Void) {
        let url = URLFactory.url(paramPage: page, path: path.rawValue).absoluteString
        baseRequest(for: url, completion: completion)
    }
    
    func postRequest(with contentModel: ContentDTO, path: Path = .post, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URLFactory.url(path: path.rawValue).absoluteString
        postRequest(for: url, contentModel: contentModel, completion: completion)
    }
    
    private func baseRequest<T: Decodable>(for url: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: url) else { print("Not Url"); return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else { return }
            do {
                let json = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(json))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        } .resume()
    }
    
    private func postRequest(for url: String, contentModel: ContentDTO, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: url) else { print("Not Url"); return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(contentModel.name)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(contentModel.id)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(contentModel.image!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: invalid response")
                return
            }
            
            guard let data = data else {
                print("Not data")
                return }
            
            if httpResponse.statusCode == 200 {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let id = json?["id"] as? String {
                        print("Successfully uploaded with ID: \(id)")
                        DispatchQueue.main.async {
                            completion(.success(id))
                        }
                    } else {
                        print("Error: invalid response")
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } else {
                print("Error: invalid response")
            }
        }.resume()
        
    }
  
//MARK: - downloadImage
    func getImageFrom(url: String, completion: @escaping (Data) -> ()) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(data)
            }
        }.resume()
    }
}
