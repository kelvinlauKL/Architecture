struct PersonListState: Equatable {
    let isLoading: Bool
    let openedBios: Set<Person>
    let bios: [Person: Bio]
    let people: [Person]

    static var initial: Self {
        .init(isLoading: true, openedBios: [], bios: [:], people: [])
    }

    func updating(
        isLoading: Bool? = nil,
        openedBios: Set<Person>? = nil,
        bios: [Person: Bio]? = nil,
        people: [Person]? = nil
    ) -> Self {
        .init(
            isLoading: isLoading ?? self.isLoading,
            openedBios: openedBios ?? self.openedBios,
            bios: bios ?? self.bios,
            people: people ?? self.people
        )
    }
}
