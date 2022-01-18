// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let green = ColorAsset(name: "green")
    internal static let listRowBackground = ColorAsset(name: "listRowBackground")
    internal static let listSeparator = ColorAsset(name: "listSeparator")
    internal static let overlayBackground = ColorAsset(name: "overlayBackground")
    internal static let primaryBackground = ColorAsset(name: "primaryBackground")
    internal static let primaryBorder = ColorAsset(name: "primaryBorder")
    internal static let red = ColorAsset(name: "red")
    internal static let secondaryButtonBackground = ColorAsset(name: "secondaryButtonBackground")
    internal static let secondaryButtonForeground = ColorAsset(name: "secondaryButtonForeground")
    internal static let secondaryShadow = ColorAsset(name: "secondaryShadow")
  }
  internal enum Images {
    internal static let edit = ImageAsset(name: "edit")
    internal static let logOut = ImageAsset(name: "logOut")
    internal static let iTunesArtwork = ImageAsset(name: "iTunesArtwork")
    internal static let launchIcon = ImageAsset(name: "launchIcon")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  fileprivate let name: String

  internal var color: Color {
    Color(self)
  }

  internal var uiColor: UIColor {
    UIColor(named: self.name)!
  }
}

internal extension Color {
  /// Creates a named color.
  /// - Parameter asset: the color resource to lookup.
  init(_ asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    self.init(asset.name, bundle: bundle)
  }
}

internal struct ImageAsset {
  fileprivate let name: String

  internal var image: Image {
    Image(name)
  }
}

internal extension Image {
  /// Creates a labeled image that you can use as content for controls.
  /// - Parameter asset: the image resource to lookup.
  init(_ asset: ImageAsset) {
    let bundle = Bundle(for: BundleToken.self)
    self.init(asset.name, bundle: bundle)
  }
}

private final class BundleToken {}
