import SwiftUI

struct ApodDetailView: View {
    @State private var viewModel: ApodDetailViewModel
    init(item: ApodItem) { _viewModel = State(initialValue: ApodDetailViewModel(item: item)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Imagem ou vídeo
                if let url = viewModel.item.displayImageURL, viewModel.item.mediaTypeEnum == .image {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .overlay {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(16)
                                .shadow(radius: 4)
                        case .failure(_):
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .overlay {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.largeTitle)
                                        .foregroundColor(.orange)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxHeight: 500)
                } else if let url = viewModel.item.displayImageURL {
                    WebView(url: url)
                        .frame(height: 320)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.exclamationmark")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("Sem mídia disponível")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                }

                // Conteúdo textual
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(formatDate(viewModel.item.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let copyright = viewModel.item.copyright {
                        Text("© \(copyright)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    
                    Text(viewModel.item.explanation)
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.black)
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { viewModel.toggleFavorite() }) {
                Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                    .foregroundColor(viewModel.isFavorite ? .yellow : .white)
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.locale = Locale(identifier: "pt_BR")
            formatter.dateStyle = .full
            return formatter.string(from: date)
        }
        
        return dateString
    }
}
