//
//  SearchView.swift
//  RecordRoom
//
//  Created by Alison Ryan on 7/1/23.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @Binding var searchResults: [Album]
    var authKey: String

    var body: some View {
      VStack(alignment:.leading) {
          TextField("Search", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .onChange(of: searchText) { text in
              searchAlbums()
            }
        }
    }

    func searchAlbums() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&type=album&limit=10") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }

            if let searchResponse = try? JSONDecoder().decode(SearchResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.searchResults = searchResponse.albums.items
                }
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
