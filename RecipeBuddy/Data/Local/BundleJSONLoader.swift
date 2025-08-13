import Foundation

struct BundleJSONLoader {
    enum LoaderError: Error { case fileNotFound, decodingFailed }

    static func load<T: Decodable>(_ type: T.Type, filename: String) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw LoaderError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}


