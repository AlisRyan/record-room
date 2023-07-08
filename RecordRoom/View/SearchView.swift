//
//  SearchView.swift
//  RecordRoom
//
//  Created by Alison Ryan on 7/1/23.
//
//

import SwiftUI
import Foundation

struct SearchView: View {
    @Binding var searchText: String
    @Binding var searchResults: [Album]
    var authKey: String

    var body: some View {
        VStack(alignment: .leading) {
//            TextField("Search", text: $searchText)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//                .onChange(of: searchText) { text in
//                    searchAlbums()
//                }
        }
    }

//    private func searchAlbums() {
//        viewModel.searchAlbums(searchText: searchText) { albums in
//            self.searchResults = albums
//        }
//    }
}

class SearchViewModel: ObservableObject {
  @Published var authKey : String = ""
  
  func fetchAuthenticationKey(completion: @escaping (String?) -> Void) {
      guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
          completion(nil)
          return
      }

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      let clientId = Sensitive.clientID
      let clientSecret = Sensitive.clientSecret
      let basicAuthHeader = "\(clientId):\(clientSecret)".data(using: .utf8)?.base64EncodedString() ?? ""
      request.setValue("Basic \(basicAuthHeader)", forHTTPHeaderField: "Authorization")
      request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      request.httpBody = "grant_type=client_credentials".data(using: .utf8)

      URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
              completion(nil)
              return
          }

          if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
              DispatchQueue.main.async {
                  completion(authResponse.access_token)
              }
          } else {
              completion(nil)
          }
      }.resume()
  }

    func searchAlbums(searchText: String, completion: @escaping ([Album]) -> Void) {
        guard !searchText.isEmpty else {
            completion([])
            return
        }

        guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&type=album&limit=10") else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion([])
                return
            }

            if let searchResponse = try? JSONDecoder().decode(SearchResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(searchResponse.albums.items)
                }
            }
        }.resume()
    }

  func searchAlbumsId(id: String, completion: @escaping (Result<Album, Error>) -> Void) {
      guard !id.isEmpty else {
          completion(.failure(NSError(domain: "com.example.spotify", code: 0, userInfo: nil)))
          return
      }

      guard let url = URL(string: "https://api.spotify.com/v1/albums/\(id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)") else {
          completion(.failure(NSError(domain: "com.example.spotify", code: 0, userInfo: nil)))
          return
      }

      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")

      URLSession.shared.dataTask(with: request) { data, response, error in
          if let error = error {
              completion(.failure(error))
              return
          }

          guard let data = data else {
              completion(.failure(NSError(domain: "com.example.spotify", code: 0, userInfo: nil)))
              return
          }

          do {
              let decoder = JSONDecoder()
              decoder.keyDecodingStrategy = .convertFromSnakeCase // Use snake_case decoding strategy
              let album = try decoder.decode(Album.self, from: data)
              completion(.success(album))
          } catch {
              completion(.failure(error))
          }
      }.resume()
  }
  
}

//
//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
