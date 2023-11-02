import AsyncAlgorithms
import Combine
import SwiftUI

@MainActor final class PeopleListViewModelV3: ObservableObject {
    private let personService: PersonServiceType
    private let bioService: BioServiceType

    @Published private(set) var state: State = .init()
    @Published private(set) var effect: Effect = .none

    init(personService: PersonServiceType, bioService: BioServiceType) {
        self.personService = personService
        self.bioService = bioService
    }

    func fetchInitial() async {
        do {
            state.people = try await personService.fetchAsync()
            state.isLoading = false
        } catch {
            effect = .showError(error)
        }
    }

    func personTapped(person: Person) async {
        do {
            if state.openedBios.contains(person) {
                state.openedBios.remove(person)
            } else {
                state.openedBios.insert(person)
            }

            if state.bios[person] == nil {
                state.bios[person] = try await bioService.fetchAsync(id: person.id)
            }
        } catch {
            effect = .showError(error)
        }
    }

    func biosState(for person: Person) -> PersonRow.BioState {
        if state.openedBios.contains(person), let bios = state.bios[person] {
            return .loaded(bios)
        } else if state.openedBios.contains(person) {
            return .loading
        } else {
            return .closed
        }
    }
}

extension PeopleListViewModelV3 {
    struct State {
        var isLoading: Bool = true
        var openedBios: Set<Person> = []
        var bios: [Person: Bio] = [:]
        var people: [Person] = []
    }

    enum Effect: Equatable {
        case none
        case showError(Error)

        static func == (lhs: Effect, rhs: Effect) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case let (.showError(lError), .showError(rError)):
                return lError.localizedDescription == rError.localizedDescription
            default: return false
            }
        }
    }
}
