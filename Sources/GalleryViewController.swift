//
// GalleryViewController
// LegacyGallery
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

//
// GalleryViewController
// EE Gallery
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
import UIKit

public struct GalleryShareOption {
    var enabled: Bool
    var icon: UIImage?
    var actionHandler: ((Result<GalleryMedia, Error>, UIActivity.ActivityType?) -> Void)?
}

open class GalleryViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, GalleryZoomTransitionDelegate {
    open var closeTitle: String = "Close"
    open var galleryShareOption: GalleryShareOption = GalleryShareOption(enabled: false, icon: nil, actionHandler: nil)
    open var setupAppearance: ((UIViewController) -> Void)?

    private var isShown: Bool = false

    open var transitionController: GalleryZoomTransitionController? {
        didSet {
            transitioningDelegate = transitionController
        }
    }

    init() {
        // let options: [String: Any] = [ UIPageViewControllerOptionInterPageSpacingKey: CGFloat(8) ]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        modalPresentationStyle = .fullScreen
        dataSource = self
        delegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.accessibilityIdentifier = "galleryViewController"
        view.backgroundColor = .black

        currentIndex = initialIndex

        if !items.isEmpty {
            let initialViewController = viewController(for: items[currentIndex], autoplay: true)
            setViewControllers([ initialViewController ], direction: .forward, animated: false, completion: nil)
        }

        setupAppearance?(self)
    }

    override open var prefersStatusBarHidden: Bool { currentViewController.prefersStatusBarHidden }
    override open var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override open var shouldAutorotate: Bool { true }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }

    // MARK: - Models
    var items: [GalleryMedia] = []
    var initialIndex: Int = 0
    private(set) var currentIndex: Int = 0

    private func index(from viewController: UIViewController) -> Int {
        switch viewController {
            case let controller as GalleryImageViewController:
                return controller.image.index
            case let controller as GalleryVideoViewController:
                return controller.video.index
            default:
                fatalError("Controller should be ImageViewController or VideoViewController")
        }
    }

    private func viewController(for item: GalleryMedia, autoplay: Bool) -> UIViewController {
        switch item {
            case .image(let image):
                let controller = GalleryImageViewController()
                controller.closeTitle = closeTitle
                controller.galleryShareOption = galleryShareOption
                controller.setupAppearance = setupAppearance
                controller.closeAction = { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
                controller.presenterInterfaceOrientations = { [weak self] in
                    self?.presentingViewController?.supportedInterfaceOrientations
                }
                controller.image = image
                return controller
            case .video(let video):
                let controller = GalleryVideoViewController()
                controller.closeTitle = closeTitle
                controller.galleryShareOption = galleryShareOption
                controller.setupAppearance = setupAppearance
                controller.closeAction = { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
                controller.presenterInterfaceOrientations = { [weak self] in
                    self?.presentingViewController?.supportedInterfaceOrientations
                }
                controller.autoplay = autoplay
                controller.video = video
                return controller
        }
    }

    private var currentViewController: UIViewController {
        guard let viewControllers = viewControllers else { fatalError("Cannot get view controllers from UIPageViewController") }
        return viewControllers[0]
    }

    // MARK: - Data Source
    open func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        let index = self.index(from: currentViewController) - 1
        guard index >= 0 else { return nil }

        let controller = self.viewController(for: items[index], autoplay: true)
        return controller
    }

    open func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        let index = self.index(from: currentViewController) + 1
        guard index < items.count else { return nil }

        let controller = self.viewController(for: items[index], autoplay: true)
        return controller
    }

    // MARK: - Delegate
    open func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            currentIndex = index(from: currentViewController)
        }
    }

    open func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        .all
    }

    // MARK: - Transition

    open var zoomTransitionAnimatingView: UIView? {
        guard let transitionDelegate = currentViewController as? GalleryZoomTransitionDelegate else { return nil }

        return transitionDelegate.zoomTransitionAnimatingView
    }

    open func zoomTransitionHideViews(hide: Bool) {
        guard let transitionDelegate = currentViewController as? GalleryZoomTransitionDelegate else { return }

        transitionDelegate.zoomTransitionHideViews(hide: hide)
    }

    open func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect {
        guard let transitionDelegate = currentViewController as? GalleryZoomTransitionDelegate else { return .zero }

        return transitionDelegate.zoomTransitionDestinationFrame(for: view, frame: frame)
    }

    open var zoomTransition: GalleryZoomTransition? {
        guard let transitionDelegate = currentViewController as? GalleryZoomTransitionDelegate else { return nil }

        return transitionDelegate.zoomTransition
    }

    open var zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? {
        guard let transitionDelegate = currentViewController as? GalleryZoomTransitionDelegate else { return nil }

        return (transitionDelegate.zoomTransition?.interactive ?? false) ? transitionDelegate.zoomTransition : nil
    }
}
