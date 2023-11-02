import SwiftUI

struct PeopleListView {
    @ObservedObject private(set) var viewModel: PeopleListViewModelV3

    init(viewModel: PeopleListViewModelV3) {
        self.viewModel = viewModel
    }
}

// MARK: - View
extension PeopleListView: View {
    var body: some View {
        if viewModel.state.isLoading {
            ProgressView()
                .onLoad {
                    Task {
                        await viewModel.fetchInitial()
                    }
                }
        } else {
            List(viewModel.state.people) { person in
                PersonRow(person: person, bioState: viewModel.biosState(for: person))
                    .onTapGesture {
                        Task {
                            await viewModel.personTapped(person: person)
                        }
                    }
            }
            .listStyle(.plain)
        }
    }
}

struct PeopleListView_Previews: PreviewProvider {
    static var previews: some View {
        PeopleListView(viewModel: .init(personService: MockPersonService(delay: 0), bioService: MockBioService()))
            .previewDisplayName("Loaded")
        PeopleListView(viewModel: .init(personService: MockPersonService(delay: 2), bioService: MockBioService()))
            .previewDisplayName("Loading")
    }
}

// 1. Action sheet
// 2. As you type disable/enable views
// 3. Analytics collector
