//
//  AlbumDetailView.swift
//  RecordRoom
//
//  Created by Alison Ryan on 7/2/23.
//
//
//import SwiftUI
//
//struct AlbumDetailView: View {
//    let album: Album
//    let authKey: String
//
//    @State private var tracks: [Track] = []
//
//    var body: some View {
//        VStack {
//            if let imageUrl = album.images.first?.url,
//               let url = URL(string: imageUrl),
//               let data = try? Data(contentsOf: url),
//               let uiImage = UIImage(data: data) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 200, height: 200)
//                    .padding()
//            }
//
//            Text(album.name)
//                .font(.title)
//                .padding()
//
//          Text(album.artists[0].name)
//                .font(.headline)
//                .padding()
//
//            if !tracks.isEmpty {
//                List(tracks, id: \.id) { track in
//                    Text(track.name)
//                }
//            } else {
//                Text("Loading tracks...")
//                    .font(.subheadline)
//                    .padding()
//            }
//        }
//        .onAppear {
//            fetchTracks()
//        }
//        .navigationBarTitle(Text(album.name), displayMode: .inline)
//    }
//
//    func fetchTracks() {
//        guard let url = URL(string: "https://api.spotify.com/v1/albums/\(album.id)/tracks") else {
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data else {
//                return
//            }
//
//            if let trackResponse = try? JSONDecoder().decode(TrackResponse.self, from: data) {
//                DispatchQueue.main.async {
//                    self.tracks = trackResponse.tracks
//                }
//            }
//        }.resume()
//    }
//}

import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    let authKey: String

  @State private var rating: Double = 0.0

  var body: some View {
          ZStack {

              VStack(spacing: 16) {
                  AsyncImage(url: URL(string: album.images[0].url)) { image in
                      image
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                  } placeholder: {
                      ProgressView()
                  }
                  .frame(width: 200, height: 200)

                  Text(album.name)
                      .font(.title)
                      .fontWeight(.bold)

                  Text(album.artists[0].name)
                      .font(.headline)

                  Text("Rate this album:")
                      .font(.headline)
                      .padding(.top, 16)

                  RatingView(rating: $rating)
                      .font(.largeTitle)
                      .padding(.bottom, 24)
              }
              .padding()
          }
          .navigationBarTitle(Text(album.name), displayMode: .inline)
      }
  }

struct RatingView: View {
    @Binding var rating: Double

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<5) { index in
                Button(action: {
                    let starValue = Double(index + 1)
                    if rating == starValue - 0.5 {
                        rating = starValue
                    } else {
                        rating = starValue - 0.5
                    }
                }) {
                    Image(systemName: imageName(for: index))
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.yellow)
                }
            }
        }
    }

    private func imageName(for index: Int) -> String {
        let starValue = Double(index + 1)

        if rating >= starValue {
            return "star.fill"
        } else if rating >= starValue - 0.5 {
            return "star.leadinghalf.fill"
        } else {
            return "star"
        }
    }
}





