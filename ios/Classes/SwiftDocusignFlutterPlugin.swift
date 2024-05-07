import Flutter
import UIKit
import DocuSignSDK

public class SwiftDocusignFlutterPlugin: NSObject, FlutterPlugin {
    private var loginResult: FlutterResult?
    private var captiveSignResult: FlutterResult?
    
    private let lock = NSLock()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "docusign_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftDocusignFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        NotificationCenter.default.addObserver(instance, selector: #selector(instance.onSigningCancelled(notification:)), name: Notification.Name("DSMSigningCancelledNotification"), object: nil)
        NotificationCenter.default.addObserver(instance, selector: #selector(instance.onSigningCompleted(notification:)), name: Notification.Name("DSMSigningCompletedNotification"), object: nil)
    }
    
    @objc func onSigningCompleted(notification: Notification) {
        captiveSignResult?(nil)
        lock.unlock()
    }

    @objc func onSigningCancelled(notification: Notification) {
        captiveSignResult?(buildError(title: "Singing cancelled"))
        lock.unlock()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "login":
          lock.lock()
          loginResult = result
          login(call: call)
      case "captiveSinging":
          lock.lock()
          captiveSignResult = result
          captiveSigning(call: call)
      default:
          result(buildError(title: Constants.IncorrectCommand))
      }
    }
    
    func login(call: FlutterMethodCall) {
        guard let params = call.arguments as? Array<String> else {
            loginResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect params string"))
            lock.unlock()
            return
        }
        
        guard let jsonData = params[0].data(using: .utf8),
            let authModel: AuthModel = try? JSONDecoder().decode(AuthModel.self, from: jsonData) else {
            loginResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect json: \(params)"))
            lock.unlock()
            return
        }
        
        guard let hostUrl = URL(string: authModel.host) else {
            loginResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect host url: \(authModel.host)"))
            lock.unlock()
            return
        }
        
        DSMManager.login(withAccessToken: authModel.accessToken,
                         expiresIn: authModel.expiresIn,
                         accountId: authModel.accountId,
                         userId: authModel.userId,
                         userName: authModel.userName,
                         email: authModel.email,
                         host: hostUrl,
                         integratorKey: authModel.integratorKey,
                         refreshToken: authModel.refreshToken,
                         completion: { (accountInfo, error) in
            if (error != nil) {
                self.loginResult?(self.buildError(title: "auth failed", details: error?.localizedDescription))
                self.lock.unlock()
            } else {
                self.loginResult?(nil)
                self.lock.unlock()
            }
        })
    }
    
    func captiveSigning(call: FlutterMethodCall) {
        guard let params = call.arguments as? Array<String> else {
            captiveSignResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect params string"))
            lock.unlock()
            return
        }
        
        guard let jsonData = params[0].data(using: .utf8),
            let captiveSignModel: CaptiveSignModel = try? JSONDecoder().decode(CaptiveSignModel.self, from: jsonData) else {
            captiveSignResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect json: \(params)"))
            lock.unlock()
            return
        }
        
        let envelopesManager = DSMEnvelopesManager()
        guard let viewController: UIViewController = getPresentingViewController() else {
            captiveSignResult?(buildError(title: "Singing cancelled"))
            lock.unlock()
            return
        }
        
        envelopesManager.presentCaptiveSigning(withPresenting: viewController,
                                               envelopeId: captiveSignModel.envelopeId,
                                               recipientUserName: captiveSignModel.recipientUserName,
                                               recipientEmail: captiveSignModel.recipientEmail,
                                               recipientClientUserId: captiveSignModel.recipientClientUserId,
                                               animated: true) { vc, error in
            if let error = error {
                self.captiveSignResult?(self.buildError(title: "Singing cancelled"))
                self.lock.unlock()
                return
            }
        }
    }
    
    private func getPresentingViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    private func buildError(title: String, details: String? = nil) -> FlutterError {
        return FlutterError.init(code: "NATIVE_ERR",
                                 message: "Error: \(title)",
                                 details: details)
    }
}

struct AuthModel: Decodable {
    let accessToken: String;
    let accountId: String;
    let userId: String;
    let userName: String;
    let email: String;
    let host: String;
    let integratorKey: String;
}

struct CaptiveSignModel: Decodable {
    let envelopeId: String;
    let recipientUserName: String;
    let recipientEmail: String;
    let recipientClientUserId: String;
}

struct Constants {
    static let IncorrectArguments = "IncorrectArguments"
    static let IncorrectCommand = "IncorrectCommand"
}
