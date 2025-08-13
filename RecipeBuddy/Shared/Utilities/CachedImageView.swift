import Foundation
import SwiftUI
import UIKit

final class ImageLoader: ObservableObject {
    static let sharedCache = NSCache<NSURL, UIImage>()

    @Published var image: UIImage?
    private var task: URLSessionDataTask?

    func load(from url: URL) {
        if let cached = ImageLoader.sharedCache.object(forKey: url as NSURL) {
            self.image = cached
            return
        }
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        task = URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            ImageLoader.sharedCache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async { self.image = image }
        }
        task?.resume()
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}

struct CachedImageView: View {
    let urlString: String
    @StateObject private var loader = ImageLoader()

    var body: some View {
        Group {
            if let url = URL(string: urlString) {
                if let ui = loader.image {
                    Image(uiImage: ui).resizable().scaledToFill()
                } else {
                    Rectangle().fill(Theme.Colors.surfaceSecondary)
                        .onAppear { loader.load(from: url) }
                        .onDisappear { loader.cancel() }
                }
            } else {
                Rectangle().fill(Theme.Colors.surfaceSecondary)
            }
        }
    }
}


