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
                    RemoteImage(url: url, placeholderHeight: 300, cornerRadius: 16, contentMode: .fit)
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
                            RemoteImage(url: thumb, placeholderHeight: 220, cornerRadius: 12, contentMode: .fill)
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
                    
                    Text(viewModel.formattedDate())
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
}
