//
//  RecordRoomApp.swift
//  RecordRoom
//
//  Created by Alison Ryan on 6/29/23.
//

import SwiftUI

@main
struct RecordRoomApp: App {
    var body: some Scene {
      let svm = SearchViewModel()
      let vm = CoreDataViewModel(svm: svm)
        WindowGroup {
          ContentView(vm: vm, svm: svm)
//          SampleView()
        }
    }
}
