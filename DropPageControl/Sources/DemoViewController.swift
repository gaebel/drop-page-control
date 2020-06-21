//
//  DemoViewController.swift
//  DropPageControl
//
//  Created by Jan Gaebel on 19.06.20.
//  Copyright © 2020 Jan Gaebel. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    // MARK: - DemoViewController

    let pageControl = PageControl()
    let scrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width * 4, height: 300)

        for index in 0...3 {
            let bgview = UIView(frame: CGRect(x: view.frame.width * CGFloat(index), y: 0,
                                              width: view.frame.width,
                                              height: 300))
            bgview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            switch index {
            case 0:
                bgview.backgroundColor = .red
            case 1:
                bgview.backgroundColor = .green
            case 2:
                bgview.backgroundColor = .yellow
            default:
                bgview.backgroundColor = .blue
            }
            scrollView.addSubview(bgview)
        }

        view.addSubview(scrollView)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.scrollView = scrollView
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
