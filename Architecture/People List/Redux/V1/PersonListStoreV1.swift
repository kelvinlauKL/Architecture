import Combine
import SwiftUI

protocol PersonListStoreType: ObservableObject {
    var _state: PersonListState { get }
    var _effect: PersonListEffect { get }

    func process(intent: PersonListIntent)
}

extension PersonListStoreType {
    func biosState(for person: Person, state: PersonListState) -> PersonRow.BioState {
        if state.openedBios.contains(person), let bios = state.bios[person] {
            return .loaded(bios)
        } else if state.openedBios.contains(person) {
            return .loading
        } else {
            return .closed
        }
    }
}

enum PersonListViewResult: Equatable {
    case didUpdatePersonList(people: [Person])
    case shouldError(message: String)
}

final class PersonListStoreV1: StateStoreV1<PersonListState, PersonListEffect, PersonListIntent, PersonListViewResult> {
    @Published private(set) var _state: PersonListState = .initial
    @Published private(set) var _effect: PersonListEffect = .none

    private var cancellables: Set<AnyCancellable> = []

    private let personServiceMiddleware: PersonServiceMiddlewareType

    init(middleware: PersonServiceMiddlewareType, initialStateValue: PersonListState) {
        self.personServiceMiddleware = middleware
        super.init(initialStateValue: initialStateValue)

        state.sink { [weak self] state in
            self?._state = state
        }
        .store(in: &cancellables)

        effect.sink { [weak self] effect in
            self?._effect = effect
        }
        .store(in: &cancellables)
    }

    override func map(_ intent: PersonListIntent, withState state: PersonListState) -> AnyPublisher<PersonListViewResult, Never> {
        switch intent {
        case .initialLoad:
            return personServiceMiddleware.execute()
                .catch { error in
                    Just(PersonListViewResult.shouldError(message: error.localizedDescription))
                }
                .eraseToAnyPublisher()
        case .personTapped(_):
            return Empty().eraseToAnyPublisher()
        }
    }

    override func map(_ result: PersonListViewResult, withState state: PersonListState) -> ReducerResult<PersonListState, PersonListEffect> {
        switch result {
        case let .didUpdatePersonList(people):
            return .stateChanged(state.updating(isLoading: false, people: people))
        case let .shouldError(message):
            return .newEffect(.showError(message: message))
        }
    }
}

extension PersonListStoreV1: PersonListStoreType {
}
