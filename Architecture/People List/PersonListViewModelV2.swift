import AsyncAlgorithms
import Combine
import SwiftUI

@MainActor final class PeopleListViewModelV2: ObservableObject {
    private let personService: PersonServiceType
    private let bioService: BioServiceType

    @Published private(set) var isLoading: Bool = true
    @Published private(set) var openedBios: Set<Person> = []
    @Published private(set) var bios: [Person: Bio] = [:]
    @Published private(set) var people: [Person] = []
    @Published private(set) var viewEffect: Effect = .none

    init(personService: PersonServiceType, bioService: BioServiceType) {
        self.personService = personService
        self.bioService = bioService
        process(intent: .initialLoad)
    }

    func process(intent: Intent) {
        Task {
            do {
                switch intent {
                case .initialLoad:
                    people = try await personService.fetchAsync()
                    isLoading = false
                case .personTapped(let person):
                    if openedBios.contains(person) {
                        openedBios.remove(person)
                    } else {
                        openedBios.insert(person)
                    }

                    if bios[person] == nil {
                        bios[person] = try await bioService.fetchAsync(id: person.id)
                    }
                }
            } catch {
                viewEffect = .showError(message: error.localizedDescription)
            }
        }
    }

    func biosState(for person: Person) -> PersonRow.BioState {
        if openedBios.contains(person), let bios = bios[person] {
            return .loaded(bios)
        } else if openedBios.contains(person) {
            return .loading
        } else {
            return .closed
        }
    }
}

// MARK: - MVI
extension PeopleListViewModelV2 {
    enum Intent: Equatable {
        case initialLoad
        case personTapped(Person)
    }

    enum Effect: Equatable {
        case none
        case showError(message: String)
    }
}
