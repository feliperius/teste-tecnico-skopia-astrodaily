import SwiftUI
import AVKit
import Kingfisher

struct ApodDetailView: View {
    @State private var viewModel: ApodDetailViewModel
    init(item: ApodItem) { _viewModel = State(initialValue: ApodDetailViewModel(item: item)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = viewModel.item.displayImageURL, viewModel.item.mediaTypeEnum == .image {
                    KFImage.url(url)
                        .placeholder {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .overlay {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                } else if viewModel.item.mediaTypeEnum == .video {
                    if let raw = viewModel.item.url, let videoURL = URL(string: raw), ["mp4", "mov", "m3u8"].contains(videoURL.pathExtension.lowercased()) {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 320)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    } else {
                        if let thumb = viewModel.item.displayImageURL {
                            KFImage.url(thumb)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
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

                        if let raw = viewModel.item.url, let videoURL = URL(string: raw) {
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
                                Text(Strings.detailNoMedia)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(formatDate(viewModel.item.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let copyright = viewModel.item.copyright {
                        Text("\(Strings.copyright) \(copyright)")
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
        .navigationTitle(Strings.detailTitle)
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
