//
//  VisualEffectView.swift
//  timeARC
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect
    let intensity: CGFloat

    func makeUIView(context: UIViewRepresentableContext<Self>) -> CustomIntensityVisualEffectView {
        CustomIntensityVisualEffectView(effect: self.effect, intensity: self.intensity)
    }

    func updateUIView(_ uiView: CustomIntensityVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = self.effect
    }
}

// https://stackoverflow.com/a/47475656/2019384
class CustomIntensityVisualEffectView: UIVisualEffectView {

    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator.fractionComplete = intensity
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Private
    private var animator: UIViewPropertyAnimator!
}
