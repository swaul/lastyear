//
//  ShareToiMessageView.swift
//  LastYear
//
//  Created by Paul Kühnel on 04.10.22.
//

import MessageUI
import SwiftUI

struct MessageComposeView: UIViewControllerRepresentable {
    typealias Completion = (_ messageSent: Bool) -> Void

    static var canSendText: Bool { MFMessageComposeViewController.canSendText() }
    static var canSendAttachments: Bool { MFMessageComposeViewController.canSendAttachments() }
    
    let recipients: [String]?
    let body: String?
    let attachment: UIImage?
    let completion: Completion?
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard
            Self.canSendText,
                Self.canSendAttachments,
                let image = attachment,
                let imageData = image.pngData()
        else {
            let errorView = MessagesUnavailableView()
            return UIHostingController(rootView: errorView)
        }
        
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        controller.addAttachmentData(imageData, typeIdentifier: "image/png", filename: "lastyear.png")

        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: self.completion)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        private let completion: Completion?

        public init(completion: Completion?) {
            self.completion = completion
        }
        
        public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
            completion?(result == .sent)
        }
    }
}

struct MessagesUnavailableView: View {
    var body: some View {
        VStack {
            Image(systemName: "xmark.octagon")
                .font(.system(size: 64))
                .foregroundColor(.red)
            Text("Messages is unavailable")
                .font(.system(size: 24))
        }
    }
}
