import Flutter
import UIKit
import DocuSignSDK

public class SwiftDocusignFlutterPlugin: NSObject, FlutterPlugin {
    private var authResult: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "docusign_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftDocusignFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "getPlatformVersion":
          result("iOS " + UIDevice.current.systemVersion)
      case "auth":
          authResult = result
          auth(call: call)
      case "captiveSinging":
          captiveSigning(call: call)
      default:
          result(buildError(title: Constants.IncorrectCommand))
      }
    }
    
    func auth(call: FlutterMethodCall) {
        guard let params = call.arguments as? Array<String> else {
            authResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect params string"))
            return
        }
        
        guard let jsonData = params[0].data(using: .utf8),
            let authModel: AuthModel = try? JSONDecoder().decode(AuthModel.self, from: jsonData) else {
            authResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect json: \(params)"))
            return
        }
        
        guard let hostUrl = URL(string: authModel.host) else {
            authResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect host url: \(authModel.host)"))
            return
        }
        
        DSMManager.login(withAccessToken: authModel.accessToken,
                         accountId: authModel.accountId,
                         userId: authModel.userId,
                         userName: authModel.userName,
                         email: authModel.email,
                         host: hostUrl,
                         integratorKey: authModel.integratorKey,
                         completion: { (accountInfo, error) in
            if (error != nil) {
                self.authResult?(self.buildError(title: "auth failed", details: error?.localizedDescription))
            } else {
                self.authResult?(true)
            }
        })
    }
    
    func captiveSigning(call: FlutterMethodCall) {
        guard let params = call.arguments as? Array<String> else {
            authResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect params string"))
            return
        }
        
        guard let jsonData = params[0].data(using: .utf8),
            let captiveSignModel: CaptiveSignModel = try? JSONDecoder().decode(CaptiveSignModel.self, from: jsonData) else {
            authResult?(buildError(title: Constants.IncorrectArguments, details: "incorrect json: \(params)"))
            return
        }
        
        let envelopesManager = DSMEnvelopesManager()
        guard let viewController: UIViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            return
        }
        envelopesManager.presentCaptiveSigning(withPresenting: viewController,
                                               envelopeId: captiveSignModel.envelopeId,
                                               recipientUserName: captiveSignModel.recipientUserName,
                                               recipientEmail: captiveSignModel.recipientEmail,
                                               recipientClientUserId: captiveSignModel.recipientClientUserId,
                                               animated: true) { vc, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Success!")
        }
    }
    
    func buildError(title: String, details: String? = nil) -> FlutterError {
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
