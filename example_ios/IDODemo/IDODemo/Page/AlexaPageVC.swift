//
//  AlexaPageVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/23.
//

import Foundation

import protocol_channel
import RxSwift
import SVProgressHUD
import WebKit

class AlexaPageVC: UIViewController {
    private let disposeBag = DisposeBag()
    private var cancellable: IDOCancellable?
    private lazy var loginState: IDOAlexaLoginState = sdk.alexa.isLogin ? .logined : .logout
    private lazy var btnLogin: UIButton = {
        let btn = UIButton.createNormalButton(title: "Login")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._onClick()
        }).disposed(by: disposeBag)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Alexa"

        view.addSubview(btnLogin)
        btnLogin.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
        }

        sdk.alexa.onLoginStateChanged { [weak self] state in
            self?._refreshUI(state)
        }
        _refreshUI(loginState)
    }
}

extension AlexaPageVC {
    private func _onClick() {
        switch loginState {
        case .logging:
            _stopLogin()
        case .logined:
            _logout()
        case .logout:
            _login()
        @unknown default:
            fatalError()
        }
    }

    private func _refreshUI(_ state: IDOAlexaLoginState) {
        switch state {
        case .logging:
            btnLogin.setTitle("Login...", for: .normal)
            btnLogin.setTitleColor(.gray, for: .normal)
        case .logined:
            btnLogin.setTitle("Logout", for: .normal)
            btnLogin.setTitleColor(.red, for: .normal)
        case .logout:
            btnLogin.setTitle("Login", for: .normal)
            btnLogin.setTitleColor(.white, for: .normal)
        @unknown default:
            fatalError()
        }
    }

    private func _login() {
        // 定制 ColorFit_Pro_3_Alpha
        // IDW01、ID208_BT、IDW05、id206、GT01_Pro、GT01_Pro_Beta
        // ：Ks2_Beta
        SVProgressHUD.show()
        cancellable = sdk.alexa.authorizeRequest(productId: "GT01_Pro") { [weak self] verificationUri, pairCode in
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Message", message: "Your pair code is:\(pairCode), The Alexa login page will open. Do you want to continue?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                alert.dismiss(animated: true)
                self?.cancellable?.cancel()
            }
            alert.addAction(cancelAction)
            let okAction = UIAlertAction(title: "Copy and continue", style: .default) { [weak self] _ in
                guard let self = self else { return }
                let vc = AlexaLoginVC()
                vc.urlPath = verificationUri
                vc.pairCode = pairCode
                vc.cancellable = self.cancellable
                UIPasteboard.general.string = pairCode
                let navVc = UINavigationController(rootViewController: vc)
                navVc.modalPresentationStyle = .fullScreen
                self.present(navVc, animated: true, completion: nil)
            }
            alert.addAction(okAction)
            // 在视图控制器中显示 UIAlertController
            self?.present(alert, animated: true, completion: nil)
        } completion: { [weak self] rs in
            self?.cancellable = nil
            if case .successful = rs {
                SVProgressHUD.showSuccess(withStatus: "Login successful")
                self?.dismiss(animated: true)
            } else {
                SVProgressHUD.showError(withStatus: "Login failure \(rs)")
            }
        }
    }

    private func _stopLogin() {
        cancellable?.cancel()
    }

    private func _logout() {
        sdk.alexa.logout()
    }
}

// MARK: - WebView

private class AlexaLoginVC: UIViewController, WKNavigationDelegate {
    private let disposeBag = DisposeBag()
    private lazy var webView: WKWebView = {
        let v = WKWebView()
        v.navigationDelegate = self
        v.rx.observeWeakly(Double.self, "estimatedProgress").subscribe(onNext: {[weak self] x in
            guard let progress = x else {
                self?.progoessView.isHidden = true
                return
            }
            self?.progoessView.setProgress(Float(progress), animated: true)
        }).disposed(by: disposeBag)
        return v
    }()

    private lazy var btnClose: UIBarButtonItem = {
        let v = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        v.rx.tap.subscribe(onNext: { [weak self] in
            self?.cancellable?.cancel()
            self?.webView.stopLoading()
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
        return v
    }()

    private lazy var progoessView: UIProgressView = {
        let v = UIProgressView()
        v.progressTintColor = .systemBlue
        v.trackTintColor = .white
        v.isHidden = true
        return v
    }()

    var urlPath: String = ""
    var pairCode: String = ""
    var cancellable: IDOCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = btnClose
        title = "Alexa login"
        view.addSubview(webView)
        webView.addSubview(progoessView)

        webView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        progoessView.snp.makeConstraints { make in
            make.left.right.equalTo(webView)
            if #available(iOS 11.0, *) {
                make.top.equalTo(webView.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(webView)
            }
            make.height.equalTo(2)
        }

        let url = URL(string: urlPath)!
        let request = URLRequest(url: url)
        webView.load(request)
    }

    // WKNavigationDelegate 方法
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 网页加载完成
        progoessView.progress = 0
        progoessView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 网页加载失败
        progoessView.progress = 0
        progoessView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // 网页加载失败（临时导航）
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 网页开始加载
        progoessView.isHidden = false
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 网页内容开始到达
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        // 网页重定向
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 网页内容进程终止
        progoessView.isHidden = true
        progoessView.progress = 0
    }
}
