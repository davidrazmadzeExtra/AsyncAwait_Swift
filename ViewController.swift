//
//  ViewController.swift
//  AsyncAwaitDemo
//
//  Created by David Razmadze on 5/8/22.
//

import UIKit

struct MovieResponse: Decodable {
  let title: String
  let description: String
}

enum MovieError: Error {
  case badURL
  case noData
  case cantDecode
  case serverError
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .darkGray
    
    // Closure Method
    getMovieData { result in
      switch result {
      case .success(let movieResponse):
        print(movieResponse.title)
        print(movieResponse.description)
      case .failure(let error):
        print(error)
      }
    }
    
    // Async/Await Method
    Task {
      do {
        let movieData = try await fetchMovieData()
        print(movieData.title)
        print(movieData.description)
      } catch {
        print(error)
      }
    }
  }
  
  private func getMovieData(completion: @escaping(Result<MovieResponse, MovieError>) -> Void) {
    guard let url = URL(string: "https://reactnative.dev/movies.json") else {
      completion(.failure(.badURL))
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else {
        completion(.failure(.noData))
        return
      }
      
      guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        completion(.failure(.serverError))
        return
      }
      
      guard let movieResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) else {
        completion(.failure(.cantDecode))
        return
      }
      
      completion(.success(movieResponse))
    }.resume()
  }

  private func fetchMovieData() async throws -> MovieResponse {
    guard let url = URL(string: "https://reactnative.dev/movies.json") else {
      throw MovieError.badURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw MovieError.serverError
    }
    
    guard let movieResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) else {
      throw MovieError.cantDecode
    }
    
    return movieResponse
  }
  
}

