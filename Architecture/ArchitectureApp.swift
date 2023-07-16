//
//  ArchitectureApp.swift
//  Architecture
//
//  Created by Kelvin Lau on 5/19/23.
//

import SwiftUI

@main
struct ArchitectureApp: App {
    var body: some Scene {
        WindowGroup {
//            PeopleListView(viewModel: .init(personService: MockPersonService(delay: 2), bioService: MockBioService()))
            PeopleListViewRedux(viewModel: PersonListStoreV1(middleware: PersonServiceMiddleware(service: MockPersonService(delay: 2)), initialStateValue: .initial))
        }
    }
}
