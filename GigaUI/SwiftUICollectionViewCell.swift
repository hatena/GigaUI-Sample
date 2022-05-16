//
//  SwiftUICollectionViewCell.swift
//  GigaUI
//
//  Created by Kouki Saito on 2022/05/15.
//

import SwiftUI

// MARK: - SwiftUICollectionViewCell

final class SwiftUICollectionViewCell<Content: View>: UICollectionViewCell {
    private var hostingController = UIHostingController<Content?>(rootView: nil, ignoreSafeArea: true)

    override init(frame: CGRect) {
        super.init(frame: frame)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(rootView: Content, parentViewController: UIViewController) {
        hostingController.rootView = rootView
        hostingController.view.invalidateIntrinsicContentSize()

        guard hostingController.parent == nil else { return }

        parentViewController.addChild(hostingController)
        contentView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: hostingController.view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: hostingController.view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: hostingController.view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
        ])
        hostingController.didMove(toParent: parentViewController)
    }
}

/// Adapt this protocol to SwiftUI Views enabling you to call register and dequeue in your collection view
protocol CollectionViewCellWrappable: View {}

extension UICollectionView {
    func register<T: CollectionViewCellWrappable>(_ cellType: T.Type) {
        register(SwiftUICollectionViewCell<T>.self, forCellWithReuseIdentifier: reuseIdentifier(cellType))
    }

    func dequeueReusableCell<T: CollectionViewCellWrappable>(_ cellType: T.Type, for indexPath: IndexPath) -> SwiftUICollectionViewCell<T> {
        dequeueReusableCell(withReuseIdentifier: reuseIdentifier(cellType), for: indexPath) as! SwiftUICollectionViewCell<T>
    }

    private func reuseIdentifier<T: CollectionViewCellWrappable>(_ cellType: T.Type) -> String {
        "CollectionViewCellWrappable-\(String(describing: cellType))"
    }
}

// MARK: - Utility

// https://gist.github.com/steipete/da72299613dcc91e8d729e48b4bb582c
extension UIHostingController {
    convenience init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)

        if ignoreSafeArea {
            disableSafeArea()
        }
    }

    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }

        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        }
        else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }

            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }

            if let method2 = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
                let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
                class_addMethod(viewSubclass, NSSelectorFromString("keyboardWillShowWithNotification:"), imp_implementationWithBlock(keyboardWillShow), method_getTypeEncoding(method2))
            }

            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}

// MARK: - Screen

class CollectionViewController: UICollectionViewController {
    struct Cell: View, CollectionViewCellWrappable {
        let systemName: String

        var body: some View {
            VStack {
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(systemName)
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(Cell.self)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(Cell.self, for: indexPath)
        cell.render(rootView: Cell(systemName: symbols[indexPath.row]), parentViewController: self)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return symbols.count
    }
}

struct CollectionView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UICollectionViewController {
        return CollectionViewController(collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(150)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: size,
                subitem: item,
                count: 3
            )
            group.interItemSpacing = .fixed(8)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            return section
        }))
    }

    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
    }
}


struct SwiftUICollectionViewCellScreen: View {
    var body: some View {
        NavigationView {
            CollectionView()
                .navigationTitle("iPhone symbols")
        }
        .navigationViewStyle(.stack)
        .tabItem {
            Label("Collection", systemImage: "iphone")
        }
    }
}

struct SwiftUICollectionViewCell_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUICollectionViewCellScreen()
    }
}
