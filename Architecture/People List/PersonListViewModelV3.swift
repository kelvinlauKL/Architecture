//import AsyncAlgorithms
//import Combine
//import Observation
//import SwiftUI
//
//@MainActor @Observable final class PeopleListViewModelV3 {
//    private let personService: PersonServiceType
//    private let bioService: BioServiceType
//
//    private(set) var isLoading: Bool = true
//    private(set) var openedBios: Set<Person> = []
//    private(set) var bios: [Person: Bio] = [:]
//    private(set) var people: [Person] = []
//    private(set) var viewEffect: Effect = .none
//
//    init(personService: PersonServiceType, bioService: BioServiceType) {
//        self.personService = personService
//        self.bioService = bioService
//        process(intent: .initialLoad)
//    }
//
//    func process(intent: Intent) {
//        Task {
//            do {
//                switch intent {
//                case .initialLoad:
//                    people = try await personService.fetchAsync()
//                    isLoading = false
//                case .personTapped(let person):
//                    if openedBios.contains(person) {
//                        openedBios.remove(person)
//                    } else {
//                        openedBios.insert(person)
//                    }
//
//                    if bios[person] == nil {
//                        bios[person] = try await bioService.fetchAsync(id: person.id)
//                    }
//                }
//            } catch {
//                viewEffect = .showError(message: error.localizedDescription)
//            }
//        }
//    }
//
//    func biosState(for person: Person) -> PersonRow.BioState {
//        if openedBios.contains(person), let bios = bios[person] {
//            return .loaded(bios)
//        } else if openedBios.contains(person) {
//            return .loading
//        } else {
//            return .closed
//        }
//    }
//}
//
//// MARK: - MVI
//extension PeopleListViewModelV3 {
//    enum Intent: Equatable {
//        case initialLoad
//        case personTapped(Person)
//    }
//
//    enum Effect: Equatable {
//        case none
//        case showError(message: String)
//    }
//}
