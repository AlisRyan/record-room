//
//  HomeView.swift
//  RecordRoom
//
//  Created by Alison Ryan on 7/5/23.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [])
    private var albums: FetchedResults<AlbumEntity>

    var body: some View {
        NavigationView {
            List {
//                ForEach(albums) { albumEntity in
//                  var album  = toAlbum(albumEntity)
//                    NavigationLink(destination: AlbumDetailView(album: album)) {
//                        HStack {
//                            AsyncImage(url: URL(string: album.imageURL ?? "")) { image in
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 60, height: 60)
//                            } placeholder: {
//                                ProgressView()
//                            }
//
//                            VStack(alignment: .leading) {
//                                Text(album.name ?? "")
//                                    .font(.headline)
//                                    .foregroundColor(.primary)
//                                Text(album.artist ?? "")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
//                .onDelete(perform: deleteAlbum)
            }
            .listStyle(.plain)
            .navigationBarTitle("Rated Albums")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: addAlbum) {
//                        Image(systemName: "plus")
//                            .imageScale(.large)
//                    }
//                }
//            }
        }
    }

//    private func addAlbum() {
//        let newAlbum = Album(context: viewContext)
//        newAlbum.name = "Sample Album"
//        newAlbum.artist = "Sample Artist"
//        newAlbum.imageURL = "https://example.com/sample_image.jpg"
//        newAlbum.rating = 4.5
//
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error saving album: \(error.localizedDescription)")
//        }
//    }
//
//    private func deleteAlbum(at offsets: IndexSet) {
//        for index in offsets {
//            let album = albums[index]
//            viewContext.delete(album)
//        }
//
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error deleting album: \(error.localizedDescription)")
//        }
//    }
//
//  func searchAlbums(album: AlbumEntity) {
//    var searchText = ""
//    searchText.append(album.name ?? "")
//    if let artists = album.artists?.allObjects as? [ArtistEntity] {
//      ForEach(artists) {
//        artist in
//        searchText.append(artist.name ?? "")
//      }
//    }
//
//      guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&type=album&limit=10") else {
//          return
//      }
//
//      var request = URLRequest(url: url)
//      request.httpMethod = "GET"
//      request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
//
//      URLSession.shared.dataTask(with: request) { data, response, error in
//          guard let data = data else {
//              return
//          }
//
//          if let searchResponse = try? JSONDecoder().decode(SearchResponse.self, from: data) {
//              DispatchQueue.main.async {
//                  self.searchResults = searchResponse.albums.items
//              }
//          }
//      }.resume()
//  }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
