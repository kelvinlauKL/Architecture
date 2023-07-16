import Combine

protocol PersonServiceMiddlewareType {
    func execute() -> AnyPublisher<PersonListViewResult, Error>
}

final class PersonServiceMiddleware: PersonServiceMiddlewareType {
    private let service: PersonServiceType

    init(service: PersonServiceType) {
        self.service = service
    }

    func execute() -> AnyPublisher<PersonListViewResult, Error> {
        service.fetchAnyPublisher()
            .map { PersonListViewResult.didUpdatePersonList(people: $0) }
            .eraseToAnyPublisher()
    }
}
