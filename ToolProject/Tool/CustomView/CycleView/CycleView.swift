//
//  CycleView.swift
//  优快学车Boss
//
//  Created by 我是五高你敢信 on 2016/12/30.
//  Copyright © 2016年 我是五高你敢信. All rights reserved.
//

import UIKit
protocol CycleViewDelegate: class {
    
    func imageViewBeClickWithTag(_ tag: Int)
}

class CycleView: UIView {
    
    fileprivate var imageArray: [String]?
    
    fileprivate let page = UIPageControl()
    
    var timer: Timer?
    
    fileprivate var index: Int = 1
    
    fileprivate lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.scrollsToTop = false
        return scrollView
    }()
    
    weak var delegate: CycleViewDelegate?
    
    //MARK: 操作数组
    fileprivate func operateArray() {
        
        
        let firstObject = self.imageArray?.first
        let lastObject = self.imageArray?.last
        
        self.imageArray?.append(firstObject!)
        self.imageArray?.insert(lastObject!, at: 0)
    }
    
    //MARK: 创建ScrollView
    fileprivate func creatScrollView() {
        //1 设置scrollView的frame
        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: width() * CGFloat(((imageArray?.count)!)), height: height())
        
        //2 添加图片到scrollView
        for (index,imageName) in self.imageArray!.enumerated() {
            
            let imageView = UIImageView(frame: bounds)
            imageView.setX(CGFloat(index) * width())
            imageView.contentMode = .scaleAspectFit
            imageView.layer.masksToBounds = true
            imageView.sd_setImage(with: URL(string: imageName))
            scrollView.addSubview(imageView)
            
            let button = UIButton(frame: bounds)
            button.setX(CGFloat(index) * width())
            button.tag = index
            button.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
            scrollView.addSubview(button)
        }
        
        
        
        //3 设定scrollView起始offset
        scrollView.contentOffset = CGPoint(x: width(), y: 0)
        
        addSubview(scrollView)
    }
    
    @objc fileprivate func buttonClick(sender: UIButton) {
        
        var tagIndex = sender.tag
        
        if sender.tag == 0 {
            tagIndex = (imageArray?.count)! - 2
        }else if sender.tag == (imageArray?.count)! - 1 {
            tagIndex = 0
        }else {
            tagIndex -= 1
        }
        
        
        if let delegate = delegate {
            delegate.imageViewBeClickWithTag(tagIndex)
        }
    }
    
    //MARK: 创建timer
    fileprivate func createTimer(timerIntervar: TimeInterval) {
        
        
        timer = Timer(timeInterval: timerIntervar, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        timer?.fire()
    }
    
    //MARK: timer执行方法
    @objc fileprivate func timerAction() {
        
        index += 1;
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * width(),y: 0), animated: true)
        
        if index == (imageArray?.count)! - 1 {
            index = 1
        }
        
    }
    
    //MARK: - 创建pageControl
    fileprivate func createPageControl() {
        
        page.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        page.setCenterX(centerX())
        page.setCenterY(height() - 10)
        page.numberOfPages = (imageArray?.count)! - 2
        
        addSubview(page)
    }
    
    
}

extension CycleView {
    
    //MARK: - 外部方法
    func setImageArray(_ imageArray:[String]?, timeIntervar: TimeInterval = 6) {
        
        guard let imageArray = imageArray else {
            return
        }
        self.imageArray = imageArray
        
        operateArray()
        
        creatScrollView()
        
        createPageControl()
        
        // 延迟几秒再第一次轮播
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeIntervar) {
            self.createTimer(timerIntervar: timeIntervar)
        }
    }
    
    
}

extension CycleView: UIScrollViewDelegate {
    
    //MARK: - scrollView协议方法
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //拖拽停止后的方法
        scrollViewEndAnimation(scrollView: scrollView)
        //拖拽后重制index
        index = Int(scrollView.contentOffset.x / width())
        
        page.currentPage = index - 1
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        scrollViewEndAnimation(scrollView: scrollView)
        
        index = Int(scrollView.contentOffset.x / width())
        
        page.currentPage = index - 1
    }
    
    fileprivate func scrollViewEndAnimation(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x == CGFloat((self.imageArray?.count)! - 1) * width(){
            scrollView.setContentOffset(CGPoint(x: width(), y: 0), animated: false)
        }else if scrollView.contentOffset.x == 0 {
            scrollView.setContentOffset(CGPoint(x: width() * CGFloat((self.imageArray?.count)! - 2), y: 0), animated: false)
        }
        
    }
    
}


