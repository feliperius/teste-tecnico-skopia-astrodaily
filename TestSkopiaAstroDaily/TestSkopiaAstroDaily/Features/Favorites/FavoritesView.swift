import SwiftUI

struct FavoritesView: View {
    @State private var vm = FavoritesViewModel()

    var body: some View {
        List(vm.items) { item in
            NavigationLink(destination: ApodDetailView(item: item)) {
                HStack(spacing: 12) {
                    AsyncImage(url: item.displayImageURL) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 72, height: 72)
                                .overlay {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure(_):
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 72, height: 72)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                        .font(.title3)
                                }
                        @unknown default:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 72, height: 72)
                        }
                    }

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
        .navigationTitle("Favoritos")
        .toolbar { 
            Button("Atualizar") { 
                vm.reload() 
            }
            .foregroundColor(.white)
        }
        .onAppear { vm.reload() }
        .overlay {
            if vm.items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "star")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Nenhum favorito ainda")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Adicione fotos aos favoritos tocando na estrela")
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

