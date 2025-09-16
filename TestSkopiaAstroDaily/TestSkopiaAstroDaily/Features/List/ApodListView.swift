import SwiftUI

struct ApodListView: View {
    @State private var viewModel = ApodListViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading { ProgressView("Carregando…") }
            else if let err = viewModel.error { ErrorView(message: err) { Task { await viewModel.load() } } }
            else { list }
        }
        .navigationTitle("Últimos dias")
        .task { await viewModel.load() }
    }

    private var list: some View {
        List(viewModel.items) { item in
            NavigationLink(value: item) {
                HStack(spacing: 12) {
                    AsyncImage(url: item.displayImageURL) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { Color.gray.opacity(0.2) }
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title).font(.headline).lineLimit(2)
                        Text(item.date).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationDestination(for: ApodItem.self) { ApodDetailView(item: $0) }
    }
}

