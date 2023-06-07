import Combine
import Foundation
import RxSwift

protocol BioServiceType {
    func fetchSingle(id: Int) -> Single<Bio>
    func fetchObservable(id: Int) -> Observable<Bio>

    func fetchFuture(id: Int) -> Future<Bio, Error>
    func fetchAnyPublisher(id: Int) -> AnyPublisher<Bio, Error>

    func fetchAsync(id: Int) async throws -> Bio
}

struct MockBioService: BioServiceType {
    // MARK: - RxSwift

    func fetchSingle(id: Int) -> Single<Bio> {
        .just(createMockBio(id: id))
        .delay(.seconds(2), scheduler: MainScheduler.instance)
    }

    func fetchObservable(id: Int) -> Observable<Bio> {
        Observable.just(createMockBio(id: id))
            .delay(.seconds(2), scheduler: MainScheduler.instance)
    }

    // MARK: - Combine
    func fetchFuture(id: Int) -> Future<Bio, Error> {
        .init { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(.success(createMockBio(id: id)))
            }
        }
    }

    func fetchAnyPublisher(id: Int) -> AnyPublisher<Bio, Error> {
        Future<Bio, Error> { promise in
            promise(.success(createMockBio(id: id)))
        }
        .delay(for: .seconds(2), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: - Async/Await
    func fetchAsync(id: Int) async throws -> Bio {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                continuation.resume(returning: createMockBio(id: id))
            }
        }
    }

    func createMockBio(id: Int) -> Bio {
        .init(description: "id: \(id) \(UUID().uuidString)")
    }
}
