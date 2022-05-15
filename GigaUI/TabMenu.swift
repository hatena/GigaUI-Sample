//
//  TabMenu.swift
//  GigaUI
//
//  Created by Kouki Saito on 2022/05/15.
//

import SwiftUI
import WithPrevious

// MARK: - TabMenu

struct TabMenuAnchorKey: PreferenceKey {
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

struct TabMenuIndicatorOverlay: View {
    static let height: CGFloat = 3

    let bounds: Anchor<CGRect>?

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(Color.gray)
                .frame(height: Self.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            if let bounds = bounds {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: proxy[bounds].width, height: Self.height)
                    .offset(x: proxy[bounds].minX)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
    }
}

extension View {
    /// An anchorPreference modifier which is attached to each button in the tab menu
    func tabMenuAnchorPreference(isSelected: Bool) -> some View {
        anchorPreference(
            key: TabMenuAnchorKey.self,
            value: .bounds,
            transform: { isSelected ? $0 : nil }
        )
    }

    /// An overlayPreferenceValue modifier which is attached to the entire tab menu
    func tabMenuIndicatorOverlay() -> some View {
        overlayPreferenceValue(TabMenuAnchorKey.self) { value in
            TabMenuIndicatorOverlay(bounds: value)
        }
        .padding(.bottom, TabMenuIndicatorOverlay.height)
    }
}


// MARK: - Screen

struct TabMenuScreen: View {
    let tabs = [
        "Tab1",
        "Tab2",
        "Tab3",
    ]

    @State @WithPrevious var selection = 0

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        withAnimation {
                            selection = index
                        }
                    } label: {
                        Text(tab)
                            .foregroundColor(index == selection ? Color.blue : Color.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .tabMenuAnchorPreference(isSelected: index == selection)
                }
            }
            .tabMenuIndicatorOverlay()
            PageViewController(
                pages: tabs.map { Text($0) },
                currentPage: $selection.animation()
            )
        }
        .tabItem {
            Label("TabMenu", systemImage: "menubar.dock.rectangle")
        }
    }
}

struct TabMenu_Previews: PreviewProvider {
    static var previews: some View {
        TabMenuScreen()
    }
}
