import SwiftUI

struct FeedView: View {
    @State private var vm = FeedViewModel()

    var body: some View {
        Group {
            if vm.isLoading { ProgressView("Carregando…") }
            else if let err = vm.error { ErrorView(message: err) { Task { await vm.load() } } }
            else if let item = vm.item { content(item) }
            else { EmptyView() }
        }
        .padding()
        .navigationTitle("Foto do Dia")
        .toolbar { toolbar }
        .task { await vm.load() }
    }

    private func content(_ item: ApodItem) -> some View {
        ScrollView {
            if let url = item.displayImageURL, item.mediaTypeEnum == .image {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFit().cornerRadius(16)
                    case .failure: Image(systemName: "exclamationmark.triangle").font(.largeTitle)
                    @unknown default: EmptyView()
                    }
                }
            } else if let url = item.displayImageURL {
                WebView(url: url).frame(height: 280).cornerRadius(16)
            } else {
                Text("Sem mídia disponível para esta data.").foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title).font(.title2).bold()
                Text(item.date).font(.subheadline).foregroundStyle(.secondary)
                Text(item.explanation)
            }
            .padding(.top, 8)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(action: vm.prevDay) { Image(systemName: "chevron.left") }
            Button(action: vm.nextDay) { Image(systemName: "chevron.right") }
            Button(action: { vm.toggleFavorite() }) {
                Image(systemName: vm.isFavorite() ? "star.fill" : "star")
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark").font(.largeTitle)
            Text(message).multilineTextAlignment(.center)
            Button("Tentar novamente", action: retry)
        }
        .padding()
    }
}

