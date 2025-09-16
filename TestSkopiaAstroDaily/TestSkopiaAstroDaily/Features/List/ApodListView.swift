import SwiftUI

struct ApodListView: View {
    @State private var viewModel = ApodListViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading { 
                VStack(spacing: 16) {
                    ProgressView(Strings.loading)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                    Text(Strings.listLoading)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }
            else if let err = viewModel.error { 
                ErrorView(message: err) { Task { await viewModel.load() } } 
            }
            else { list }
        }
        .background(Color.black)
        .navigationTitle(Strings.listTitle)
        .task { await viewModel.load() }
    }

    private var list: some View {
        List(viewModel.items) { item in
            NavigationLink(value: item) {
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
        }
        .listStyle(PlainListStyle())
        .background(Color.black)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: ApodItem.self) { ApodDetailView(item: $0) }
    }
}

