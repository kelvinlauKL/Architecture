import AsyncAlgorithms
import Combine
import SwiftUI

@MainActor final class PeopleListViewModelV1: ObservableObject {
    @Published private(set) var viewState: State = .loading
    @Published private(set) var viewEffect: Effect = .none

    private let personService: PersonServiceType
    private let bioService: BioServiceType

    private var openedBios: Set<Person> = []
    private var bios: [Person: Bio] = [:]

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
                    let people = try await personService.fetchAsync()
                    viewState = .loaded(.init(openedBios: openedBios, bios: bios, people: people))
                case .personTapped(let person):
                    guard case let .loaded(viewData) = viewState else { return }
                    if openedBios.contains(person) {
                        openedBios.remove(person)
                    } else {
                        openedBios.insert(person)
                    }

                    viewState = .loaded(viewData.copy(openedBios: openedBios, bios: bios))

                    if bios[person] == nil {
                        bios[person] = try await bioService.fetchAsync(id: person.id)
                    }

                    viewState = .loaded(viewData.copy(openedBios: openedBios, bios: bios))
                }
            } catch {
                viewEffect = .showError(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - MVI
extension PeopleListViewModelV1
{
    struct ViewData: Equatable {
        private let openedBios: Set<Person>
        private let bios: [Person: Bio]
        let people: [Person]

        init(openedBios: Set<Person>, bios: [Person : Bio], people: [Person]) {
            self.openedBios = openedBios
            self.bios = bios
            self.people = people
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

        func copy(openedBios: Set<Person>? = nil,
                  bios: [Person: Bio]? = nil,
                  people: [Person]? = nil) -> ViewData {
            .init(openedBios: openedBios ?? self.openedBios,
                  bios: bios ?? self.bios,
                  people: people ?? self.people)
        }
    }

    enum State: Equatable {
        case loading
        case loaded(ViewData)
    }

    enum Intent: Equatable {
        case initialLoad
        case personTapped(Person)
    }

    enum Effect: Equatable {
        case none
        case showError(message: String)
    }
}
