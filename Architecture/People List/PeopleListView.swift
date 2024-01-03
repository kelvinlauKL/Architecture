import SwiftUI

struct PeopleListView {
    @ObservedObject private(set) var viewModel: PeopleListViewModelV0

    init(viewModel: PeopleListViewModelV0) {
        self.viewModel = viewModel
    }
}

// MARK: - View
extension PeopleListView: View {
    var body: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView()
                .onLoad {
                    viewModel.process(intent: .initialLoad)
                }
        case .loaded(let data):
            List(data.people) { person in
                PersonRow(person: person, bioState: data.biosState(for: person))
                    .onTapGesture {
                        viewModel.process(intent: .personTapped(person))
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
