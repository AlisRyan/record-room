//
//  HomeView.swift
//  RecordRoom
//
//  Created by Alison Ryan on 7/5/23.
//

import SwiftUI
import CoreData


struct HomeView: View {
    @ObservedObject var vm: CoreDataViewModel
    var svm: SearchViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.albums, id: \.self) { albumEntity in
                    AlbumRow(albumEntity: albumEntity, vm: vm, svm: svm)
                }
                .onDelete(perform: vm.deleteAlbums) // Add onDelete modifier
            }
            .listStyle(.plain)
            .navigationBarTitle("Rated Albums")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                vm.getAlbums()
            }
        }
    }
}


struct AlbumRow: View {
    let albumEntity: AlbumEntity
    @ObservedObject var vm: CoreDataViewModel
    var svm: SearchViewModel

    @State private var album: Album?

    var body: some View {
        Group {
            if let album = album {
                NavigationLink(destination: AlbumDetailView(vm: vm, album: album)) {
                    AlbumRowView(album: album)
                }
            } else {
                ProgressView()
                    .onAppear {
                        vm.toAlbum(entity: albumEntity) { album in
                            self.album = album
                        }
                    }
            }
        }
        .id(albumEntity) // Add an identifier to the view to trigger the update
    }
}


struct AlbumRowView: View {
    let album: Album

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: album.images[0].url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            } placeholder: {
                ProgressView()
            }

            VStack(alignment: .leading) {
                Text(album.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(album.artists[0].name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
enum AlbumStatus {
    case loading
    case loaded(Album)
}
class CoreDataViewModel: ObservableObject {
    let manager = CoreDataManager.instance
    @Published var albums: [AlbumEntity] = []
    @Published var albumStatus: [AlbumEntity: AlbumStatus] = [:] // Track fetched status for each album entity
    var svm: SearchViewModel

    init(svm: SearchViewModel) {
        self.svm = svm
        getAlbums()
    }
  
  func getRating(for album: Album) -> Double {
      guard let entity = albums.first(where: { $0.name == album.name }) else {
          return 0.0 // Return a default rating if album not found
      }
      return entity.rating
  }

  func deleteAlbums(at offsets: IndexSet) {
      offsets.forEach { index in
          let albumEntity = albums[index]
          manager.context.delete(albumEntity)
          albums.remove(at: index)
      }
      save()
  }

    func getAlbums() {
        let request =  NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
        do {
            albums = try manager.context.fetch(request)
            albumStatus = [:] // Reset the album status dictionary
        } catch {
            print("Error fetching albums")
        }
    }

    func save() {
        do {
            try manager.context.save()
            print("Saved successfully")
        } catch {
            print("Error saving context")
        }
    }

  func toAlbum(entity: AlbumEntity, completion: @escaping (Album?) -> Void) {
      // Check if the album is already fetched
      if let status = albumStatus[entity] {
          switch status {
          case .loading:
              // Already loading, skip the fetch
              return
          case .loaded(let album):
              // Album already loaded, return it
              completion(album)
              return
          }
      }

      // Update the status to loading
      albumStatus[entity] = .loading

      var searchText = ""
      searchText += entity.name ?? ""
      searchText += " "

      if let artistsSet = entity.artists as? Set<ArtistEntity> {
          for artist in artistsSet {
              searchText += artist.name ?? ""
          }
      }

      if let albumId = entity.id {
          let specificEntity = entity // Create a new variable with a more specific type
          self.svm.searchAlbumsId(id: albumId) { result in
              switch result {
              case .success(let album):
                  self.albumStatus[specificEntity] = .loaded(album)
                  completion(album)
              case .failure:
                  self.svm.searchAlbums(searchText: searchText) { albums in
                      if let firstAlbum = albums.first {
                          self.albumStatus[specificEntity] = .loaded(firstAlbum)
                          completion(firstAlbum)
                      }
                  }
              }
          }
      } else {
          self.svm.searchAlbums(searchText: searchText) { albums in
              if let firstAlbum = albums.first {
                  self.albumStatus[entity] = .loaded(firstAlbum)
                  completion(firstAlbum)
              }
          }
      }
  }


    // Method to add the rated album to Core Data with rating
  func addAlbumWithRating(album: Album, rating: Double) {
      guard let existingAlbum = albums.first(where: { $0.name == album.name }) else {
          // Create a new AlbumEntity if it doesn't exist in Core Data
          let newAlbum = AlbumEntity(context: manager.context)
          newAlbum.name = album.name
          newAlbum.rating = rating // Set the rating property of AlbumEntity
        newAlbum.id = album.id

          // Set the artists property of AlbumEntity
          let artistEntities = album.artists.map { artist in
              let artistEntity = ArtistEntity(context: manager.context)
              artistEntity.name = artist.name
              return artistEntity
          }
          newAlbum.artists = NSSet(array: artistEntities)

          // Set other properties as per your requirement

          albums.append(newAlbum)

          save()
          return
      }

      // Update the existing AlbumEntity with the new rating
      existingAlbum.rating = rating
      save()
  }


}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let svm = SearchViewModel()
        let viewModel = CoreDataViewModel(svm: svm)
        return HomeView(vm: viewModel, svm: svm)
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
//}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
