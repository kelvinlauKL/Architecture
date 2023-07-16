import SwiftUI

struct PeopleListViewRedux<Model: PersonListStoreType> {
    @ObservedObject private(set) var viewModel: Model

    init(viewModel: Model) {
        self.viewModel = viewModel

        Task {
            try await Task.sleep(for: .seconds(1))
            viewModel.process(intent: .initialLoad)
        }
    }
}

// MARK: - View
extension PeopleListViewRedux: View {
    var body: some View {
        if viewModel._state.isLoading {
            ProgressView()
        } else {
            List(viewModel._state.people) { person in
                PersonRow(person: person, bioState: viewModel.biosState(for: person, state: viewModel._state))
                    .onTapGesture {
                        viewModel.process(intent: .personTapped(person))
                    }
            }
            .listStyle(.plain)
        }
    }
}

struct PeopleListViewRedux_Previews: PreviewProvider {
    static var previews: some View {
        PeopleListViewRedux(viewModel: PersonListStoreV1(middleware: PersonServiceMiddleware(service: MockPersonService(delay: 2)), initialStateValue: .initial))
            .previewDisplayName("Loaded")
    }
}

// 1. Action sheet
// 2. As you type disable/enable views
// 3. Analytics collector
