//
//  CoreDataViewModel.swift
//  RecordRoom
//
//  Created by Alison Ryan on 7/4/23.
//

import SwiftUI
import Foundation
import CoreData

// Album Entity
// Artist Entity
// Image Entity

class CoreDataManager {
  static let instance = CoreDataManager()
  let container: NSPersistentContainer
  let context: NSManagedObjectContext

  init() {
    container = NSPersistentContainer(name: "CoreDataContainer")
    container.loadPersistentStores{ (description, error) in
      if let error = error {
        print("Error loading Core Data. \(error)")
      }
    }
    context = container.viewContext
  }

  func save() {
    do {
      try context.save()
    } catch let error {
      print("Error saving Core Data \(error.localizedDescription)")
    }
  }
}

class CoreDataViewModel: ObservableObject {
  let manager = CoreDataManager.instance
  @Published var albums: [AlbumEntity] = []

  init() {
    getAlbums()
  }

  func getAlbums() {
    let request =  NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
    do {
      albums = try manager.context.fetch(request)
    } catch let error {
      print("Error fetching")
    }
  }

  func addAlbum() {
    let newAlbum = AlbumEntity(context: manager.context)
    newAlbum.name = "Reality"
    save()
  }

  func save() {
    print("saved successfully")
    manager.save()
  }
}

struct SampleView: View {
  @StateObject var vm = CoreDataViewModel()
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          Button(action: {
            vm.addAlbum()
          }, label: {
            Text("Action")
              .foregroundColor(.white)
              .frame(height: 55)
              .frame(maxWidth: .infinity)
              .background(Color.blue.cornerRadius(10))
          })

          ScrollView(.horizontal, showsIndicators: true, content: {
            HStack(alignment: .top) {
              ForEach(vm.albums) {
                album in
                AlbumView(entity: album)
              }
            }
          })
        }
        .padding()
      }
      .navigationTitle("Relationships")
    }
  }
}

struct SampleView_Previews: PreviewProvider {
  static var previews: some View {
    SampleView()
  }
}


struct AlbumView: View {
  let entity: AlbumEntity
  var body: some View {
    VStack(alignment: .leading, spacing: 20, content: {
      Text("Name: \(entity.name ?? "")")
        .bold()
      if let artists = entity.artists?.allObjects as? [ArtistEntity] {
        Text("Artist:")
          .bold()
        ForEach(artists) {
          artist in
          Text(artist.name ?? "")
        }
      }
      Text("Rating: \(entity.rating)")
    })
    .padding()
    .frame(maxWidth: 300)
    .background(Color.gray.opacity(0.5))
    .cornerRadius(10)
    .shadow(radius: 10)
  }
}
