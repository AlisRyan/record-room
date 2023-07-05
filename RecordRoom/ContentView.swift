//
//  ContentView.swift
//  RecordRoom
//
//  Created by Alison Ryan on 6/29/23.
//
//

import SwiftUI

struct ContentView: View {
    @State private var authKey: String = ""
    @State private var searchText: String = ""
    @State private var searchResults: [Album] = []
    @State private var showDetailView: Bool = false
    @State private var selectedAlbum: Album?

  var body: some View {
//    TabView {
//      HomeView()
//        .tabItem {
//          Image(systemName: "house")
//          Text("Home")
//        }
      NavigationView {
        VStack {
          if !authKey.isEmpty {
            SearchView(searchText: $searchText, searchResults: $searchResults, authKey: authKey)
              .padding(.horizontal)
          }

          List(searchResults, id: \.id) { album in
            NavigationLink(destination: AlbumDetailView(album: album, authKey: authKey)) {
              HStack(spacing: 16) {
                AsyncImage(url: URL(string: album.images[0].url)) { image in
                  image.resizable()
                    .aspectRatio(contentMode: .fit)
                } placeholder: {
                  ProgressView()
                }
                .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 4) {
                  Text(album.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                  Text(album.artists[0].name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
              }
              .padding(.vertical, 8)
            }
          }
          .listStyle(.plain)
          .padding(.horizontal)
        }
        .onAppear {
          fetchAuthenticationKey()
        }
        .navigationTitle("Albums")
        .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: HomeView()) {
                                Image(systemName: "house")
                                    .imageScale(.large)
                            }
                        }
                    }
      }
    }

    func fetchAuthenticationKey() {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
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
                return
            }

            if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.authKey = authResponse.access_token
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
