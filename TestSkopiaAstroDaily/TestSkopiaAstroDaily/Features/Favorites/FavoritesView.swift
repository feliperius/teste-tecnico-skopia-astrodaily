import SwiftUI
import Kingfisher

struct FavoritesView: View {
    @State private var viewModel = FavoritesViewModel()

    var body: some View {
        List(viewModel.items) { item in
            NavigationLink(destination: ApodDetailView(item: item)) {
                HStack(spacing: 12) {
                    RemoteImage(url: item.displayImageURL, placeholderHeight: 72, cornerRadius: 12, contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                            .lineLimit(2)
                            .foregroundColor(.white)
                        Text(item.date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }.listStyle(PlainListStyle())
        .background(Color.black)
        .scrollContentBackground(.hidden)
        .navigationTitle(Strings.favoritesTitle)
        .toolbar { 
            Button(Strings.favoritesUpdate) { 
                viewModel.reload()
            }
            .foregroundColor(.white)
        }
        .onAppear { viewModel.reload() }
        .overlay {
            if viewModel.items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "star")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text(Strings.favoritesNoFavorites)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(Strings.favoritesAddTip)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.black)
            }
        }
    }
}

