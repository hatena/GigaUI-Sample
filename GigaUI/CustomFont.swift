//
//  CustomFont.swift
//  GigaUI
//
//  Created by Kouki Saito on 2022/05/15.
//

import SwiftUI

// MARK: - CustomFont

struct CustomFont: ViewModifier {
    let size: CGFloat
    let style: UIFont.TextStyle
    let weight: Font.Weight

    @Environment(\.sizeCategory) private var sizeCategory

    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics(forTextStyle: style)
            .scaledValue(
                for: size,
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: sizeCategory.uiContentSizeCategory
                )
            )
        return content.font(.system(size: scaledSize).weight(weight))
    }

    func uiFont(for sizeCategory: ContentSizeCategory) -> UIFont {
        let scaledSize = UIFontMetrics(forTextStyle: style)
            .scaledValue(
                for: size,
                compatibleWith: UITraitCollection(
                    preferredContentSizeCategory: sizeCategory.uiContentSizeCategory
                )
            )
        return .systemFont(ofSize: scaledSize, weight: weight.uiFontWeight)
    }
}

extension View {
    func customFont(_ typography: CustomTypography) -> some View {
        modifier(typography.font)
    }
}

enum CustomTypography {
    /// title1 size: 21, weight: .bold
    case title1
    /// title2 size: 19, weight: .bold
    case title2
    /// subtitle1 size: 17, weight: .regular
    case subtitle1
    /// subtitle2 size: 13, weight: .bold
    case subtitle2
    /// body1 size: 15, weight: .regular
    case body1
    /// body2 size: 13, weight: .regular
    case body2
    /// button size: 15, weight: .regular
    case button
    /// caption size: 13, weight: .regular
    case caption

    var font: CustomFont {
        switch self {
        case .title1:
            return CustomFont(size: 21, style: .title1, weight: .bold)
        case .title2:
            return CustomFont(size: 19, style: .title2, weight: .bold)
        case .subtitle1:
            return CustomFont(size: 17, style: .title3, weight: .regular)
        case .subtitle2:
            return CustomFont(size: 13, style: .headline, weight: .bold)
        case .body1:
            return CustomFont(size: 15, style: .subheadline, weight: .regular)
        case .body2:
            return CustomFont(size: 13, style: .body, weight: .regular)
        case .button:
            return CustomFont(size: 15, style: .body, weight: .regular)
        case .caption:
            return CustomFont(size: 13, style: .caption1, weight: .regular)
        }
    }
}

// MARK: - SwiftUI - UIKit Bridge

extension ContentSizeCategory {
    var uiContentSizeCategory: UIContentSizeCategory {
        switch self {
        case .extraSmall:
            return .extraSmall
        case .small:
            return .small
        case .medium:
            return .medium
        case .large:
            return .large
        case .extraLarge:
            return .extraLarge
        case .extraExtraLarge:
            return .extraExtraLarge
        case .extraExtraExtraLarge:
            return .extraExtraExtraLarge
        case .accessibilityMedium:
            return .accessibilityMedium
        case .accessibilityLarge:
            return .accessibilityLarge
        case .accessibilityExtraLarge:
            return .accessibilityExtraLarge
        case .accessibilityExtraExtraLarge:
            return .accessibilityExtraExtraLarge
        case .accessibilityExtraExtraExtraLarge:
            return .accessibilityExtraExtraExtraLarge
        @unknown default:
            return .large
        }
    }
}

extension Font.Weight {
    var uiFontWeight: UIFont.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        default:
            return .regular
        }
    }
}


// MARK: - Screen

struct CustomFontScreen: View {
    var body: some View {
        VStack {
            Text("Title 1")
                .customFont(.title1)
            Text("Title 2")
                .customFont(.title2)
            Text("Subtitle 1")
                .customFont(.subtitle1)
            Text("Subtitle 2")
                .customFont(.subtitle2)
            Text("Body 1")
                .customFont(.body1)
            Text("Body 2")
                .customFont(.body2)
            Text("Caption")
                .customFont(.caption)
            Button("Button") {}
                .customFont(.button)
        }
        .tabItem {
            Label("Font", systemImage: "textformat")
        }
    }
}

struct CustomFont_Previews: PreviewProvider {
    static var previews: some View {
        CustomFontScreen()
    }
}
