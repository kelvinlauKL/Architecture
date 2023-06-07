import SwiftUI

struct PersonRow {
    enum BioState: Equatable {
        case closed
        case loading
        case loaded(Bio)
    }
    let person: Person
    let bioState: BioState
}

// MARK: - View
extension PersonRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(person.name)
                    .font(.title)
                Spacer()
                Image(systemName: bioState != .closed ? "chevron.up" : "chevron.down")
            }
            switch bioState {
            case .closed:
                EmptyView()
            case let .loaded(bio):
                Text(bio.description)
            case .loading:
                ProgressView()
            }
        }
        .padding()
    }
}

struct PersonRow_Previews: PreviewProvider {
    static var previews: some View {
        PersonRow(person: .init(id: 0, name: "Apoorva Mehta"), bioState: .loaded(.init(description: "HELLO")))
            .background(Color.gray)
            .previewLayout(.sizeThatFits)
    }
}

