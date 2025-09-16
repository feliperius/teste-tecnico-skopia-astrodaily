import SwiftUI
import AVKit
import Kingfisher

struct MediaView: View {
    let item: ApodItem
    let maxHeight: CGFloat?

    init(item: ApodItem, maxHeight: CGFloat? = 320) {
        self.item = item
        self.maxHeight = maxHeight
    }

    var body: some View {
        Group {
            if item.isVideo {
                if item.isDirectVideo, let v = item.videoURL {
                    VideoPlayer(player: AVPlayer(url: v))
                        .frame(height: maxHeight)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    VStack(spacing: 8) {
                        if let thumb = item.imageURL {
                            RemoteImage(url: thumb, placeholderHeight: maxHeight ?? 220, cornerRadius: 12, contentMode: .fill)
                                .frame(height: maxHeight ?? 220)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)).frame(height: maxHeight ?? 220)
                        }

                        if let raw = item.url, let link = URL(string: raw) {
                            Link("Abrir vídeo", destination: link)
                                .padding(.top, 6)
                        }
                    }
                }
            } else {
                // image
                if let url = item.imageURL {
                    RemoteImage(url: url, placeholderHeight: maxHeight ?? 300, cornerRadius: 12, contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .frame(maxHeight: maxHeight)
                } else {
                    RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)).frame(height: maxHeight ?? 300)
                }
            }
        }
    }
}

struct MediaView_Previews: PreviewProvider {
    static var previews: some View {
        Text("MediaView preview")
    }
}
