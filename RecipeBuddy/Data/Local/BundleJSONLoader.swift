import Foundation

struct BundleJSONLoader {
    enum LoaderError: Error { case fileNotFound, decodingFailed }

    static func load<T: Decodable>(_ type: T.Type, filename: String) throws -> T {
        let bundles = [Bundle.main] + Bundle.allBundles + Bundle.allFrameworks
        guard let url = bundles.compactMap({ $0.url(forResource: filename, withExtension: nil) }).first else { throw LoaderError.fileNotFound }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}


