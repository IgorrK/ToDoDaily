// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum APIErrors {
    internal enum User {
      /// Failed to update user
      internal static let description = L10n.tr("APIErrors", "user.description")
      internal enum ChangeRequest {
        /// Internal error
        internal static let failureReason = L10n.tr("APIErrors", "user.changeRequest.failureReason")
        /// Please try again later
        internal static let recoverySuggestion = L10n.tr("APIErrors", "user.changeRequest.recoverySuggestion")
      }
      internal enum Commit {
        /// Server error
        internal static let failureReason = L10n.tr("APIErrors", "user.commit.failureReason")
        /// Please try again later
        internal static let recoverySuggestion = L10n.tr("APIErrors", "user.commit.recoverySuggestion")
      }
    }
  }
  internal enum Application {
    /// Done
    internal static let done = L10n.tr("Application", "done")
    /// ToDo Daily
    internal static let name = L10n.tr("Application", "name")
    /// OK
    internal static let ok = L10n.tr("Application", "ok")
  }
  internal enum InfoPlist {
    /// Application needs access to camera
    internal static let nsCameraUsageDescription = L10n.tr("InfoPlist", "NSCameraUsageDescription")
    /// Application needs access to your photo library
    internal static let nsPhotoLibraryUsageDescription = L10n.tr("InfoPlist", "NSPhotoLibraryUsageDescription")
  }
  internal enum Login {
    /// Go Offline
    internal static let goOffline = L10n.tr("Login", "goOffline")
    /// OR
    internal static let or = L10n.tr("Login", "or")
    internal enum AuthError {
      /// Failed to log in
      internal static let description = L10n.tr("Login", "authError.description")
      /// It's not your fault, but a server error
      internal static let failureReason = L10n.tr("Login", "authError.failureReason")
      /// Please try again later
      internal static let recoverySuggestion = L10n.tr("Login", "authError.recoverySuggestion")
    }
  }
  internal enum Profile {
    /// Your Profile
    internal static let title = L10n.tr("Profile", "title")
    internal enum Name {
      /// Your name:
      internal static let header = L10n.tr("Profile", "name.header")
      /// Name:
      internal static let placeholder = L10n.tr("Profile", "name.placeholder")
      /// Name cannot be empty
      internal static let validation = L10n.tr("Profile", "name.validation")
    }
  }
  internal enum Settings {
    /// Edit Profile
    internal static let editProfile = L10n.tr("Settings", "editProfile")
    /// Log Out
    internal static let logOut = L10n.tr("Settings", "logOut")
    /// Settings
    internal static let title = L10n.tr("Settings", "title")
  }
  internal enum Storage {
    internal enum ImageUploadError {
      /// Failed to upload the image
      internal static let description = L10n.tr("Storage", "imageUploadError.description")
      internal enum Compression {
        /// Error processing the image
        internal static let failureReason = L10n.tr("Storage", "imageUploadError.compression.failureReason")
        /// Please select another image
        internal static let recoverySuggestion = L10n.tr("Storage", "imageUploadError.compression.recoverySuggestion")
      }
      internal enum Upload {
        /// Error uploading the image
        internal static let failureReason = L10n.tr("Storage", "imageUploadError.upload.failureReason")
        /// Please try again later or select another image
        internal static let recoverySuggestion = L10n.tr("Storage", "imageUploadError.upload.recoverySuggestion")
      }
      internal enum UrlReference {
        /// Server error
        internal static let failureReason = L10n.tr("Storage", "imageUploadError.urlReference.failureReason")
        /// Please try again later
        internal static let recoverySuggestion = L10n.tr("Storage", "imageUploadError.urlReference.recoverySuggestion")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
