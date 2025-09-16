import SwiftUI

struct FavoritesView: View {
    @State private var vm = FavoritesViewModel()

    var body: some View {
        List(vm.items) { item in
            NavigationLink(destination: ApodDetailView(item: item)) {
                HStack(spacing: 12) {
                    AsyncImage(url: item.displayImageURL) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { Color.gray.opacity(0.2) }
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading) {
                        Text(item.title).font(.headline).lineLimit(2)
                        Text(item.date).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Favoritos")
        .toolbar { Button("Atualizar") { vm.reload() } }
        .onAppear { vm.reload() }
    }
}

