import Foundation
#if os(OSX)
import CoreServices
#else
import MobileCoreServices
#endif

public enum AttachmentError: Error {
    // Error thrown with the MIME type for the attachment is not found
    case invalidMimeType(fileExtension: String)
}

public struct Attachment: Equatable {
    // The filename of the attachment, used for display on the web
    public let filename: String
    // The MIME type of the attachmenth
    public let mimeType: String
    // The data from the attachment, read at the time of attachment
    public let data: Data

    // The size of the attachment (based on the data)
    public var size: Int {
        return self.data.count
    }

    public init(url: URL) throws {
        self.init(filename: url.lastPathComponent, mimeType: try getMimeType(for: url.pathExtension),
                  data: try Data(contentsOf: url))
    }

    public init(filename: String, mimeType: String, data: Data) {
        self.filename = filename
        self.mimeType = mimeType
        self.data = data
    }
}

public func == (lhs: Attachment, rhs: Attachment) -> Bool {
    return lhs.filename == rhs.filename && lhs.size == rhs.size && lhs.data == rhs.data
}

private func getMimeType(for fileExtension: String) throws -> String {
    if let identifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                              fileExtension as CFString, nil),
        let mimeType = UTTypeCopyPreferredTagWithClass(identifier.takeRetainedValue(), kUTTagClassMIMEType)
    {
        return mimeType.takeRetainedValue() as String
    }

    throw AttachmentError.invalidMimeType(fileExtension: fileExtension)
}
