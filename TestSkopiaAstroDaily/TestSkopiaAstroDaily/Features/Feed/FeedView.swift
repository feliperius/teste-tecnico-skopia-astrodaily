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
                    ErrorView(error: err) {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .background(Color.black)
        }
        .task { await viewModel.loadTodayApod() }
        .refreshable { await viewModel.loadTodayApod() }
    }

    private func content(_ item: ApodItem) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                if let url = item.displayImageURL, item.mediaTypeEnum == .image {
                    RemoteImage(url: url, placeholderHeight: 420, cornerRadius: 0, contentMode: .fill)
                        .frame(maxWidth: .infinity, minHeight: 380, maxHeight: 520)
                        .clipped()
                        .shadow(radius: 6)
                } else if item.mediaTypeEnum == .video {
                    if let raw = item.url, let videoURL = URL(string: raw), ["mp4", "mov", "m3u8"].contains(videoURL.pathExtension.lowercased()) {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 300)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    } else {
                        if let thumb = item.displayImageURL {
                            RemoteImage(url: thumb, placeholderHeight: 220, cornerRadius: 12, contentMode: .fill)
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
                    
                    Text(viewModel.formattedDate())
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
        .padding(.bottom)
        .background(Color.black)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { 
                Task { await viewModel.prevDay() }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            .disabled(viewModel.isLoading)
            
            Button(action: { 
                Task { await viewModel.nextDay() }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(viewModel.isLoading || viewModel.isToday)
            
            Button(action: { 
                Task { await viewModel.toggleFavorite() }
            }) {
                Image(systemName: viewModel.isFavorite() ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(viewModel.isFavorite() ? .yellow : .white)
            }
            .disabled(viewModel.item == nil)
        }
    }
}


