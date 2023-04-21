//
//  VideoFullscreenTransitioner.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//
#if !os(macOS)
import AVFoundation
import UIKit

public class VideoFullscreenTransitioner: NSObject {
    
    public var playerView: VideoPlayerView?
    public var duration: TimeInterval = 0.25
    public var fullscreenControls: [UIView] = []
    public var fullscreenPlayerView: VideoFullscreenPlayerView?
    public var fullscreenVideoGravity: AVLayerVideoGravity?
    
    private var isBeingForward = true
    private var playerVideoGravity: AVLayerVideoGravity?
    
    private var animatorForCurrentTransition: UIViewImplicitlyAnimating?
    
}

extension VideoFullscreenTransitioner: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isBeingForward = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isBeingForward = false
        return self
    }
    
}

extension VideoFullscreenTransitioner: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animatorForCurrentSession = animatorForCurrentTransition {
            return animatorForCurrentSession
        }
        return isBeingForward ? presentAnimator(using: transitionContext) : dismissAnimator(using: transitionContext)
    }
    
}

private extension VideoFullscreenTransitioner {
    
    func presentAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let toView = toViewController.view,
            let playerView = playerView,
            let fullscreenPlayerView = fullscreenPlayerView
            else { return UIViewPropertyAnimator() }
        guard let superView = playerView.superview else {return UIViewPropertyAnimator()}
        let containerView = transitionContext.containerView
        let playerCenter = superView.convert(playerView.center, to: containerView)
        
        toView.clipsToBounds = true
        toView.bounds = playerView.bounds
        toView.center = playerCenter
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        containerView.addSubview(toView)
        
        switch toViewController.preferredInterfaceOrientationForPresentation {
        case .landscapeLeft:
            toView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        case .landscapeRight:
            toView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        default: break
        }
        
        fullscreenControls.forEach { $0.alpha = 0 }
        fullscreenPlayerView.layer.addSublayer(playerView.playerLayer)
        
        let duration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            toView.transform = .identity
            toView.bounds = containerView.bounds
            toView.center = containerView.center
            toView.layoutIfNeeded()
            
            self.fullscreenControls.forEach { $0.alpha = 1 }
            
            if let fullscreenVideoGravity = self.fullscreenVideoGravity {
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
                self.playerVideoGravity = playerView.playerLayer.videoGravity
                playerView.playerLayer.videoGravity = fullscreenVideoGravity
                CATransaction.commit()
            }
        }
        
        animator.addCompletion { _ in
            self.animatorForCurrentTransition = nil
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animatorForCurrentTransition = animator
        return animator
    }
    
    func dismissAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let fromView = fromViewController.view,
            let toViewController = transitionContext.viewController(forKey: .to),
            let toView = toViewController.view,
            let playerView = playerView
            else { return UIViewPropertyAnimator() }
        
        let containerView = transitionContext.containerView
        let playerRect = playerView.convert(playerView.bounds, to: containerView)
        
        if fromViewController.modalPresentationStyle == .fullScreen {
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            fromView.transform = .identity
            fromView.frame = playerRect
            fromView.layoutIfNeeded()
            
            self.fullscreenControls.forEach { $0.alpha = 0 }
            
            if let playerVideoGravity = self.playerVideoGravity {
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
                playerView.playerLayer.videoGravity = playerVideoGravity
                CATransaction.commit()
            }
        }
        
        animator.addCompletion { _ in
            fromView.removeFromSuperview()
            playerView.playerLayer.frame = playerView.bounds
            playerView.layer.insertSublayer(playerView.playerLayer, at: 0)

            self.animatorForCurrentTransition = nil
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animatorForCurrentTransition = animator
        return animator
    }
    
}
#endif
