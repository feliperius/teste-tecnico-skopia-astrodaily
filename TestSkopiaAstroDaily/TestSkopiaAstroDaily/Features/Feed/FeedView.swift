import SwiftUI
import AVKit
import Kingfisher

struct FeedView: View {
    @State private var viewModel = FeedViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text(Strings.feedLoading)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                } else if let err = viewModel.error {
                    ErrorView(message: err) {
                        Task { await viewModel.loadTodayApod() }
                    }
                } else if let item = viewModel.item {
                    content(item)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text(Strings.feedNoPhoto)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(Strings.feedTryAgainLater)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button(Strings.feedReload) {
                            Task { await viewModel.loadTodayApod() }
                        }
                        .buttonStyle(.borderedProminent)
                        .accentColor(.white)
                        .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
            }
            .navigationTitle(Strings.feedTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbar }
            .background(Color.black)
        }
        .task { await viewModel.loadTodayApod() }
        .refreshable {
            await viewModel.loadTodayApod()
        }
    }

    private func content(_ item: ApodItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = item.displayImageURL, item.mediaTypeEnum == .image {
                    KFImage.url(url)
                        .placeholder {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .overlay {
                                    VStack(spacing: 8) {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text(Strings.feedLoadingImage)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                        }
                        .setProcessor(DownsamplingImageProcessor(size: CGSize(width: UIScreen.main.bounds.width * 2, height: 600)))
                        .cacheOriginalImage()
                        .fade(duration: 0.25)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .frame(maxHeight: 500)
                } else if item.mediaTypeEnum == .video {
                    // Tenta reproduzir diretamente se for um arquivo de vídeo (mp4/mov/m3u8)
                    if let raw = item.url, let videoURL = URL(string: raw), ["mp4", "mov", "m3u8"].contains(videoURL.pathExtension.lowercased()) {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 300)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    } else {
                        // Caso não seja um link direto de vídeo (ex.: YouTube), mostra thumbnail e botão para abrir no navegador
                        if let thumb = item.displayImageURL {
                            KFImage.url(thumb)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 220)
                                        .overlay(ProgressView().scaleEffect(1.0))
                                }
                                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: UIScreen.main.bounds.width * 2, height: 440)))
                                .cacheOriginalImage()
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 220)
                                .clipped()
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                        }

                        if let raw = item.url, let videoURL = URL(string: raw) {
                            HStack { Spacer(); Link("Abrir vídeo", destination: videoURL).padding(.top, 8); Spacer() }
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.exclamationmark")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text(Strings.feedNoMedia)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                        }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                    
                    Text(formatDate(item.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let copyright = item.copyright {
                        Text("\(Strings.copyright) \(copyright)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    
                    Text(item.explanation)
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.black)
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

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: viewModel.prevDay) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            .disabled(viewModel.isLoading)
            
            Button(action: viewModel.nextDay) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(viewModel.isLoading || viewModel.isToday)
            
            Button(action: { viewModel.toggleFavorite() }) {
                Image(systemName: viewModel.isFavorite() ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(viewModel.isFavorite() ? .yellow : .white)
            }
            .disabled(viewModel.item == nil)
        }
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(Strings.errorTryAgain)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Button(Strings.errorTryAgain, action: retry)
                .buttonStyle(.borderedProminent)
                .accentColor(.white)
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

