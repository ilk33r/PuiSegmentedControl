//
//  PuiPageViewSegmentedControl.swift
//  PuiSegmentedControl
//
//  Created by Kemal Bakacak on 20.01.2019.
//  Copyright © 2019 Kemal Bakacak. All rights reserved.
//

import Foundation

public protocol PuiScrollViewSegmentedControlDelegate: NSObjectProtocol {
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
	func scrollViewDidScroll(_ scrollView: UIScrollView)
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
	
}

open class PuiPageViewSegmentedControl: PuiSegmentedControl {
    
    // MARK: - Public Properties
    
    public weak var pageViewController: UIPageViewController? {
        didSet {
            self.pageViewController?.delegate = self
            
            // Find scroll view
            for subview in self.pageViewController?.view.subviews ?? [] {
                if let scrollView = subview as? UIScrollView {
                    scrollView.delegate = self
                    self.scrollView = scrollView
                    break
                }
            }
        }
    }
	public weak var scrollViewDelegate: PuiScrollViewSegmentedControlDelegate?
    
    // MARK: - Private Properties
    
    private var scrollView: UIScrollView?
    private var initialScrollViewPosition: CGFloat = 0
    
    // MARK: - Override Methods
    
    open override func segmentedControlTransationBegin(oldValue: Int, newValue: Int) {
        super.segmentedControlTransationBegin(oldValue: oldValue, newValue: newValue)
        
        // When user tapped to segmented control, then tapped to pageview before animation finished.
        // Segment problem occurs. So I disable to scroll when animation.
        self.scrollView?.isScrollEnabled = false
    }
    
    open override func segmentedControlTransationEnded(oldValue: Int, newValue: Int) {
        super.segmentedControlTransationEnded(oldValue: oldValue, newValue: newValue)
        
        // Enable scroll end of animation.
        self.scrollView?.isScrollEnabled = true
    }
}

extension PuiPageViewSegmentedControl: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        // Call super method
        self.pageViewTransactionEnded(isCompleted: completed)
    }
}

extension PuiPageViewSegmentedControl: UIScrollViewDelegate {
    
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		// Call scrollview delegate
		self.scrollViewDelegate?.scrollViewWillBeginDragging(scrollView)
		
		// Set initial position
		self.initialScrollViewPosition = scrollView.contentOffset.x
	}
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Call scrollview delegate
		self.scrollViewDelegate?.scrollViewDidScroll(scrollView)
		
		// Check content offset
        if self.initialScrollViewPosition == scrollView.contentOffset.x {
            return
        }
        
        // Calculate percent of view
        let differenceScrollViewPosition = (self.initialScrollViewPosition - scrollView.contentOffset.x)
        let ratio = differenceScrollViewPosition / (self.pageViewController?.view.frame.width ?? 0)
        
        // Call super method
        self.scrollSegmentedControl(ratio: ratio)
    }
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		// Call scrollview delegate
		self.scrollViewDelegate?.scrollViewDidEndDecelerating(scrollView)
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// Call scrollview delegate
		self.scrollViewDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
	}
}
