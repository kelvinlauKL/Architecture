import Foundation
import Combine

open class StateStoreV1<State: Equatable, Effect: Equatable, Intent: Equatable, Result: Equatable> {
    private var stateCache: State {
        didSet {
            stateSubject.send(stateCache)
        }
    }

    private let stateSubject: PassthroughSubject<State, Never> = .init()
    private let intentSubject: PassthroughSubject<Intent, Never> = .init()
    private let effectSubject: PassthroughSubject<Effect, Never> = .init()
    private var cancellables: Set<AnyCancellable> = .init()

    public var state: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    public var effect: AnyPublisher<Effect, Never> { effectSubject.eraseToAnyPublisher() }

    public init(initialStateValue: State) {
        self.stateCache = initialStateValue
        setup(initialStateValue: initialStateValue)
    }

    open func map(_ intent: Intent, withState state: State) -> AnyPublisher<Result, Never> {
        Empty().eraseToAnyPublisher()
    }

    open func map(_ result: Result, withState state: State) -> ReducerResult<State, Effect> {
        fatalError()
    }

    public final func process(intent: Intent) {
        intentSubject.send(intent)
    }
}

extension StateStoreV1 {
    public enum ReducerResult<State: Equatable, Effect: Equatable> {
        case stateChanged(State)
        case newEffect(Effect)
    }
}

extension StateStoreV1 {
    private func setup(initialStateValue: State) {
        intentSubject.flatMap { [weak self] intent -> AnyPublisher<Result, Never> in
            guard let self = self else { return Empty().eraseToAnyPublisher() }
            return self.map(intent, withState: self.stateCache)
        }
        .subscribe(on: DispatchQueue.main)
        .compactMap { [weak self] result -> ReducerResult<State, Effect>? in
            guard let self = self else { return nil }
            return self.map(result, withState: self.stateCache)
        }
        .sink { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .stateChanged(newState):
                self.stateCache = newState
            case let .newEffect(effect):
                self.effectSubject.send(effect)
            }
        }
        .store(in: &cancellables)
    }
}
