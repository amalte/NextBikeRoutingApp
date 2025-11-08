import UIKit
import MobileCoreServices

/// Handles incoming shared URLs (from Google Maps) and passes them
/// to the main NextBikeRouter app via a custom URL scheme.
class ShareViewController: UIViewController {
    
    /// Called when the view appears, triggers the share handling logic.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleShare()
    }
    
    /// Extracts the URL that was shared and forwards it to the main app.
    private func handleShare() {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        
        for item in inputItems {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier("public.url") {
                    provider.loadItem(forTypeIdentifier: "public.url" as String, options: nil) { (item, error) in
                        if let urlToShare = item as? URL {
                            DispatchQueue.main.async {
                                self.openMainApp(urlToShare)
                            }
                        }
                    }
                    return
                }
            }
        }
    }
    
    /// Opens the main app (NextBikeRouter) with its URL scheme and passes it the shared URL as a query parameter.
    private func openMainApp(_ sharedURL: URL) {
        let encodedURL = sharedURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let urlScheme = URL(string: "nextbikerouter://import?sharedURL=\(encodedURL)") else { return }
        
        var responder: UIResponder? = self
        let openURLSelector = NSSelectorFromString("openURL:")
        while responder != nil {
            if responder?.responds(to: openURLSelector) == true {
                responder?.perform(openURLSelector, with: urlScheme)
                break
            }
            responder = responder?.next
        }
        
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
