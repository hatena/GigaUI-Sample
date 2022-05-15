//
//  ContentView.swift
//  GigaUI
//
//  Created by Kouki Saito on 2022/05/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PageScreen()
            TabMenuScreen()
            CustomFontScreen()
            ScreenStateScreen()
            SwiftUICollectionViewCellScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
