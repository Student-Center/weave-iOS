//
//  ActivityView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/9/24.

import SwiftUI

public struct ActivityView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    public let activityItmes: [Any]
    public let applicationActivities: [UIActivity]? = nil
    
    public func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let activityViewController = UIActivityViewController(
            activityItems: activityItmes,
            applicationActivities: applicationActivities
        )
        
        if isPresented && uiViewController.presentedViewController == nil {
            uiViewController.present(activityViewController, animated: true)
        }
        activityViewController.completionWithItemsHandler = { (_, _, _, _) in
            isPresented = false
        }
    }
}
