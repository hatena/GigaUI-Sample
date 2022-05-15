//
//  PageViewController.swift
//  GigaUI
//
//  Created by Kouki Saito on 2022/05/15.
//

import SwiftUI
import WithPrevious

// MARK: - PageViewController

struct PageViewController<Page: View>: UIViewControllerRepresentable {
    private var pages: [Page]
    @Binding @WithPrevious var currentPage: Int

    init(pages: [Page], currentPage: Binding<WithPrevious<Int>>) {
        self.pages = pages
        self._currentPage = currentPage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        let direction: UIPageViewController.NavigationDirection
        if let previousPage = $currentPage.wrappedValue.projectedValue {
            direction = currentPage > previousPage ? .forward : .reverse
        } else {
            direction = .forward
        }

        for (i, page) in pages.enumerated() {
            if i < context.coordinator.controllers.endIndex {
                (context.coordinator.controllers[i] as? UIHostingController<Page>)?.rootView = page
            } else {
                let newController = UIHostingController<Page>(rootView: page)
                context.coordinator.controllers.append(newController)
            }
        }

        context.coordinator.controllers.removeLast(max(context.coordinator.controllers.count - pages.count, 0))

        pageViewController.setViewControllers(
            [context.coordinator.controllers[currentPage]], direction: direction, animated: true
        )
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController
        var controllers = [UIViewController]()

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
            self.controllers = parent.pages.map { UIHostingController(rootView: $0) }
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return controllers.last
            }
            return controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == controllers.count {
                return controllers.first
            }
            return controllers[index + 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = controllers.firstIndex(of: visibleViewController)
            {
                parent.currentPage = index
            }
        }
    }
}

// MARK: - Screen

struct PageScreen: View {
    @State @WithPrevious var page = 0

    var body: some View {
        PageViewController(
            pages: [
                Text("Page1"),
                Text("Page2"),
                Text("Page3"),
            ],
            currentPage: $page
        )
        .tabItem {
            Label("Page", systemImage: "scroll")
        }
    }
}

struct PageViewController_Previews: PreviewProvider {
    static var previews: some View {
        PageScreen()
    }
}
