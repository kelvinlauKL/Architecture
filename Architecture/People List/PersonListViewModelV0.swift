import Combine
import SwiftUI

final class PeopleListViewModelV0: ObservableObject {
    @Published private(set) var viewState: State = .loading

    private let effectSubject: PassthroughSubject<Effect, Never> = .init()
    var effectPublisher: AnyPublisher<Effect, Never> {
        effectSubject.eraseToAnyPublisher()
    }

    private let intentSubject: PassthroughSubject<Intent, Never> = .init()
    private var intentPublisher: AnyPublisher<Intent, Never> {
        intentSubject.eraseToAnyPublisher()
    }

    private let personService: PersonServiceType
    private let bioService: BioServiceType

    private var openedBios: Set<Person> = []
    private var bios: [Person: Bio] = [:]

    private var cancellables: Set<AnyCancellable> = .init()

    init(personService: PersonServiceType, bioService: BioServiceType) {
        self.personService = personService
        self.bioService = bioService
        process(intent: .initialLoad)

        intentPublisher
            .filter {
                guard case .initialLoad = $0 else { return false }
                return true
            }
            .flatMap { _ in personService.fetchFuture().retry(2) }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.effectSubject.send(.showError(message: error.localizedDescription))
                case .finished: return
                }
            } receiveValue: { [weak self] people in
                guard let self = self else { return }
                self.viewState = .loaded(.init(openedBios: self.openedBios, bios: self.bios, people: people))
            }
            .store(in: &cancellables)

//        intentPublisher.combineLatest($viewState.eraseToAnyPublisher())
//            .compactMap { intent, viewState -> (Person, [Person])? in
//                guard case let .personTapped(person) = intent else { return nil }
//                return person
//            }
//            .flatMap { person -> AnyPublisher<(Person, Bio), Error> in
//                bioService.fetchFuture(id: person.id)
//                    .map { bio in (person, bio) }
//                    .eraseToAnyPublisher()
//            }
//            .sink { [weak self] completion in
//                guard let self = self else { return }
//                switch completion {
//                case let .failure(error):
//                    self.effectSubject.send(.showError(message: error.localizedDescription))
//                case .finished: return
//                }
//            } receiveValue: { [weak self] (person, bio) in
//                guard let self = self else { return }
//                self.bios[person] = bio
//                self.viewState = .loaded(.init(openedBios: self.openedBios, bios: self.bios, people: people))
//            }
//            .store(in: &cancellables)
    }

    func process(intent: Intent) {
        intentSubject.send(intent)
    }
}

// MARK: - MVI
extension PeopleListViewModelV0 {
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
        case showError(message: String)
    }
}
