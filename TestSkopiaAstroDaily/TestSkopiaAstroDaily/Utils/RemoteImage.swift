import SwiftUI
import Kingfisher

struct RemoteImage: View {
    let url: URL?
    let placeholderHeight: CGFloat
    let cornerRadius: CGFloat
    let contentMode: SwiftUI.ContentMode

    init(url: URL?, placeholderHeight: CGFloat = 120, cornerRadius: CGFloat = 12, contentMode: SwiftUI.ContentMode = .fill) {
        self.url = url
        self.placeholderHeight = placeholderHeight
        self.cornerRadius = cornerRadius
        self.contentMode = contentMode
    }

    var body: some View {
        Group {
            if let url = url {
                KFImage.url(url)
                    .placeholder {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: placeholderHeight)
                            .overlay(ProgressView())
                    }
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: UIScreen.main.bounds.width * 2, height: placeholderHeight * 2)))
                    .cacheOriginalImage()
                    .fade(duration: 0.25)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: placeholderHeight)
            }
        }
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: nil)
    }
}
