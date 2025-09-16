import SwiftUI

struct ApodDetailView: View {
    @State private var viewModel: ApodDetailViewModel
    init(item: ApodItem) { _viewModel = State(initialValue: ApodDetailViewModel(item: item)) }

    var body: some View {
        ScrollView {
            if let url = viewModel.item.displayImageURL, viewModel.item.mediaTypeEnum == .image {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFit().cornerRadius(16)
                    case .failure: Image(systemName: "exclamationmark.triangle").font(.largeTitle)
                    @unknown default: EmptyView()
                    }
                }
            } else if let url = URL(string: viewModel.item.url ?? "") {
                WebView(url: url).frame(height: 320).cornerRadius(16)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.item.title).font(.title2).bold()
                Text(viewModel.item.date).font(.subheadline).foregroundStyle(.secondary)
                Text(viewModel.item.explanation)
            }
            .padding(.top, 8)
        }
        .padding()
        .navigationTitle("Detalhes")
        .toolbar {
            Button(action: { viewModel.toggleFavorite() }) {
                Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
            }
        }
    }
}
