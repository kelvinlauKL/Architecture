import Combine
import Foundation
import RxSwift

protocol PersonServiceType {
    func fetchSingle() -> Single<[Person]>
    func fetchObservable() -> Observable<[Person]>

    func fetchFuture() -> Future<[Person], Error>
    func fetchAnyPublisher() -> AnyPublisher<[Person], Error>

    func fetchAsync() async throws -> [Person]
}

struct MockPersonService: PersonServiceType {
    let delay: Int

    // MARK: - RxSwift

    func fetchSingle() -> RxSwift.Single<[Person]> {
        .just(createMockPeople())
        .delay(.seconds(delay), scheduler: MainScheduler.instance)
    }

    func fetchObservable() -> Observable<[Person]> {
        Observable.just(createMockPeople())
            .delay(.seconds(delay), scheduler: MainScheduler.instance)
    }

    // MARK: - Combine
    func fetchFuture() -> Future<[Person], Error> {
        .init { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(integerLiteral: Int64(delay))) {
                promise(.success(createMockPeople()))
            }
        }
    }

    func fetchAnyPublisher() -> AnyPublisher<[Person], Error> {
        Future<[Person], Error> { promise in
            promise(.success(createMockPeople()))
        }
        .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: - Async/Await
    func fetchAsync() async throws -> [Person] {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(integerLiteral: Int64(delay))) {
                continuation.resume(returning: createMockPeople())
            }
        }
    }

    func createMockPeople() -> [Person] {
        [
            .init(id: 0, name: "James"),
            .init(id: 1, name: "Robert"),
            .init(id: 2, name: "John"),
            .init(id: 3, name: "Michael"),
            .init(id: 4, name: "David"),
            .init(id: 5, name: "William"),
            .init(id: 6, name: "Richard"),
            .init(id: 7, name: "Thomas"),
            .init(id: 8, name: "Christopher")
        ]
    }
}
