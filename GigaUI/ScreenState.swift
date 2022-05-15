//
//  ScreenState.swift
//  GigaUI
//
//  Created by Kouki Saito on 2022/05/15.
//

import SwiftUI

// MARK: - ScreenState

enum ScreenState<Value, Error: Swift.Error> {
    case loading
    case failed(Error)
    case empty
    case loaded(Value)
}

struct ScreenStateProjector<Value, Error: Swift.Error, OnLoaded: View>: View {
    typealias State = ScreenState<Value, Error>
    typealias RefreshAction = () -> Void

    let state: State

    private let refreshAction: RefreshAction?
    private let onLoading: (() -> AnyView)?
    private let onFailed: ((Error, RefreshAction?) -> AnyView)?
    private let onEmpty: ((RefreshAction?) -> AnyView)?
    private let onLoaded: (Value) -> OnLoaded

    init(
        _ state: ScreenState<Value, Error>,
        refreshAction: (() -> Void)?,
        onLoading: (() -> AnyView)? = nil,
        onFailed: ((Error, RefreshAction?) -> AnyView)? = nil,
        onEmpty: ((RefreshAction?) -> AnyView)? = nil,
        @ViewBuilder onLoaded: @escaping (Value) -> OnLoaded
    ) {
        self.state = state
        self.refreshAction = refreshAction
        self.onLoading = onLoading
        self.onFailed = onFailed
        self.onEmpty = onEmpty
        self.onLoaded = onLoaded
    }

    var body: some View {
        switch state {
        case .loading:
            if let onLoading = onLoading {
                onLoading()
            } else {
                ProgressView()
            }
        case .failed(let error):
            if let onFailed = onFailed {
                onFailed(error, refreshAction)
            } else {
                VStack {
                    Text("Error")
                    Button("Reload") { refreshAction?() }
                }
            }
        case .empty:
            if let onEmpty = onEmpty {
                onEmpty(refreshAction)
            } else {
                VStack {
                    Text("Empty")
                    Button("Reload") { refreshAction?() }
                }
            }
        case .loaded(let value):
            onLoaded(value)
        }
    }
}


// MARK: - Screen

struct ScreenStateScreen: View {
    @State var screenState: ScreenState<String, Error> = .loading

    var body: some View {
        NavigationView {
            ScreenStateProjector(
                screenState,
                refreshAction: refresh,
                onLoaded: { data in
                    Text(data)
                }
            )
            .navigationTitle("Screen State Sample")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                screenState = .empty
            }
        }
        .tabItem {
            Label("State", systemImage: "cloud")
        }
    }

    func refresh() {
        switch screenState {
        case .loading:
            break
        case .empty:
            screenState = .failed(NSError(domain: "", code: 0))
        case .failed:
            screenState = .loaded("Loaded!")
        case .loaded:
            screenState = .loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                screenState = .empty
            }
        }
    }

}

struct ScreenState_Previews: PreviewProvider {
    static var previews: some View {
        ScreenStateScreen()
    }
}
