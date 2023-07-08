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
  var vm : CoreDataViewModel
  var svm : SearchViewModel
  init(vm: CoreDataViewModel, svm: SearchViewModel) {
    self.vm = vm
    self.svm = svm

  }

  var body: some View {
      NavigationView {
        VStack {

          VStack(alignment: .leading) {
              TextField("Search", text: $searchText)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .padding()
                  .onChange(of: searchText) { text in
                      searchAlbums()
                  }
          }
          List(searchResults, id: \.id) { album in
            NavigationLink(destination: AlbumDetailView(vm: vm, album: album)) {
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
            svm.fetchAuthenticationKey { key in
                if let key = key {
                    DispatchQueue.main.async {
                        svm.authKey = key
                    }
                }
            }
        }
        .navigationTitle("Albums")
        .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                          NavigationLink(destination: HomeView(vm: vm, svm: svm)) {
                                Image(systemName: "house")
                                    .imageScale(.large)
                            }
                        }
                    }
      }
    }
  private func searchAlbums() {
      svm.searchAlbums(searchText: searchText) { albums in
          self.searchResults = albums
      }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      let svm = SearchViewModel()
      ContentView(vm: CoreDataViewModel(svm: svm), svm: svm)
    }
}
