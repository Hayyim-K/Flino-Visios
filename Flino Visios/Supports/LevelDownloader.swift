//
//  LevelDownloader.swift

import UIKit
@preconcurrency import WebKit
import Network

class LevelDownloader: UIViewController, WKUIDelegate, WKNavigationDelegate {

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private let alert = UIAlertController(
        title: "Network Error",
        message: "Please connect to the internet to continue.",
        preferredStyle: .alert
    )

    private var serverDataView: WKWebView?
    private var topConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setOrientationLock()
        verionUpdateData()
        setupInternetConnectionMonitor()
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotate(from: fromInterfaceOrientation)
        setNewSize()
    }

    private func setOrientationLock() {
        AppDelegate.orientationLock = .all
        view.backgroundColor = .black
        navigationItem.hidesBackButton = true
    }

    private func verionUpdateData() {
        let webViewConfiguration = createWebViewConfiguration()
        serverDataView = WKWebView(
            frame: view.bounds,
            configuration: webViewConfiguration
        )
        serverDataView?.uiDelegate = self
        serverDataView?.navigationDelegate = self
        serverDataView?.isOpaque = false
        serverDataView?.backgroundColor = .clear
        serverDataView?.scrollView.isScrollEnabled = true
        
        guard let serverDataGuarded = serverDataView else { return }

        serverDataGuarded.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(serverDataGuarded)

        NSLayoutConstraint.activate([
            serverDataGuarded.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            serverDataGuarded.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            serverDataGuarded.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        topConstraint = serverDataGuarded.topAnchor.constraint(equalTo: view.topAnchor)
        topConstraint?.isActive = true
        
        setNewSize()

        loadCheckedVersionUpdate()
    }

    private func createWebViewConfiguration() -> WKWebViewConfiguration {
        let serverConfig = WKWebViewConfiguration()
        serverConfig.preferences = WKPreferences()
        serverConfig.preferences.javaScriptEnabled = true
        serverConfig.preferences.javaScriptCanOpenWindowsAutomatically = true
        serverConfig.websiteDataStore = WKWebsiteDataStore.default()
        
        // Disable autoplay for videos
        if #available(iOS 10.0, *) {
            serverConfig.mediaTypesRequiringUserActionForPlayback = [.all]
        }
        
        if #available(iOS 14.0, *) {
            serverConfig.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        return serverConfig
    }

    private func loadCheckedVersionUpdate() {
        guard let urlString = UserDefaults.standard.string(forKey: "levelds"),
              let url = URL(string: urlString)
        else { return }

        let request = URLRequest(url: url)
        serverDataView?.load(request)
    }

    private func setNewSize() {
        guard let webView = serverDataView
        else { return }
        topConstraint?.isActive = false

        let isPortrait = preferredInterfaceOrientationForPresentation.isPortrait
        let noFrameScreen = (UIScreen.main.bounds.height / UIScreen.main.bounds.width) > 2
        let topConstant: CGFloat = noFrameScreen ? (isPortrait ? 70 : 0) : 0

        topConstraint = webView.topAnchor.constraint(
            equalTo: view.topAnchor,
            constant: topConstant
        )
        topConstraint?.isActive = true
        view.updateConstraintsIfNeeded()
    }

    // MARK: - Internet Connection Monitoring
    private func setupInternetConnectionMonitor() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] pathUpdateHandler in
            
            DispatchQueue.main.async {
                if pathUpdateHandler.status == .satisfied {
                    self?.hideConnectionAlert()
                } else {
                    self?.showConnectionAlert()
                }
            }
        }

        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        monitor.start(queue: queue)
    }

    private func showConnectionAlert() {
        present(alert, animated: true, completion: nil)
    }

    private func hideConnectionAlert() {
        alert.dismiss(animated: true, completion: nil)
    }

    // MARK: - WKUIDelegate Methods
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        let popupWebView = WKWebView(
            frame: webView.bounds,
            configuration: configuration
        )
        popupWebView.uiDelegate = self
        view.addSubview(popupWebView)
        return popupWebView
    }
    
    // MARK: - WKNavigationDelegate Methods
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        print("Failed provisional navigation: \(error.localizedDescription)")
    }
    
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        print("Failed navigation: \(error.localizedDescription)")
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }
}
