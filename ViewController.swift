//
//  ViewController.swift
//  AsyncAwaitDemo
//
//  Created by David Razmadze on 5/7/22.
//

import UIKit

struct MovieResponse: Decodable {
  let title: String
  let description: String
}

enum CustomError: Error {
  case badURL
  case noData
  case cantDecode
  // ... etc
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    getMovies { result in
      switch result {
      case .success(let movieReponse):
        print(movieReponse)
      case .failure(let error):
        print(error)
      }
    }
    
    async {
      do {
        let movies = try await fetchMovies()
        print(movies)
      } catch {
        print(error)
      }
    }
    
    view.backgroundColor = .gray
  }

  /// Old way - using completion blocks and closures
  private func getMovies(completion: @escaping (Result<MovieResponse, CustomError>) -> Void) {
    
    guard let url = URL(string: "https://reactnative.dev/movies.json") else {
      completion(.failure(.badURL))
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      // ❌ Get for errors and make sure data is safely unwrapped
      guard let data = data, error == nil else {
        completion(.failure(.noData))
        return
      }
      
      guard let movieResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) else {
        completion(.failure(.cantDecode))
        return
      }
      completion(.success(movieResponse))
    }.resume()
    
  }
  
  private func fetchMovies() async throws -> MovieResponse? {
    guard let url = URL(string: "https://reactnative.dev/movies.json") else {
      throw CustomError.badURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let movieResponse = try? JSONDecoder().decode(MovieResponse.self, from: data)
    return movieResponse
  }

}

