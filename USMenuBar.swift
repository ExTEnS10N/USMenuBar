//
//  USMenuBar.swift
//  UsayUI
//
//  Created by macsjh on 16/2/17.
//  Copyright © 2016年 TurboExtension. All rights reserved.
//

import UIKit

protocol USMenuBarDataSource:class{
	func numberOfItemInMenuBar(menuBar:USMenuBar) -> Int
	func uSMenuBar(menuBar:USMenuBar, titleForItemAtIndex index:Int) -> String
}

@objc protocol USMenuBarDelegate:class{
	optional func uSMenuBar(menuBar:USMenuBar, willSelectRowAtIndex index:Int)
	optional func uSMenuBar(menuBar:USMenuBar, didSelectRowAtIndex index:Int)
}

class USMenuBar: UIView {
	
	private var _dataSource:USMenuBarDataSource? {didSet{setNeedsDisplay()}}
	var dataSource:USMenuBarDataSource?{
		get{return _dataSource}
		set{_dataSource = newValue}
	}
	
	private var _delegate:USMenuBarDelegate?
	var delegate:USMenuBarDelegate?{
		get{return _delegate}
		set{_delegate = newValue}
	}
	
	private let slider = UIView()
	private var sliderCenter:NSLayoutConstraint?
	private var sliderWidth:NSLayoutConstraint?
	
	private var _selectedIndex:Int = -1
	var selectedIndex:Int{
		get{return _selectedIndex}
		set{
			slideToItem(indexOfItemToSlide: newValue, animated: true)
		}
	}
	
	func reloadData(){
		for (var i = 0; i < self.subviews.count; ++i){
			self.subviews[i].removeFromSuperview()
		}
		guard dataSource != nil else{return}
		let itemsCount = dataSource!.numberOfItemInMenuBar(self)
		guard itemsCount != 0 else {return}
		
		for (var i = 0; i < itemsCount; ++i){
			let button = UIButton(type: .Custom)
			button.backgroundColor = self.backgroundColor
			button.setTitle(dataSource?.uSMenuBar(self, titleForItemAtIndex: i), forState: .Normal)
			button.setTitleColor(UIColor(white: 0.67, alpha: 1.0), forState: .Normal)
			button.tag = 154 + i
			button.addTarget(self, action: "prepareForSelectedItem:", forControlEvents: .TouchUpInside)
			button.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(button)
			
			let width = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.bounds.width / CGFloat(itemsCount))
			let height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.bounds.height)
			let leading = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: (self.bounds.width * CGFloat(i)) / CGFloat(itemsCount))
			let top = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
			self.addConstraints([width, height, leading, top])
		}
		_selectedIndex = 154
		let firstButton = self.viewWithTag(_selectedIndex) as! UIButton
		firstButton.setTitleColor(self.tintColor, forState: .Normal)
		slider.frame = CGRect(x: 0.0, y: self.bounds.height - 5, width: firstButton.bounds.width, height: 5.0)
		slider.backgroundColor = self.tintColor
		slider.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(slider)
		
		sliderWidth = NSLayoutConstraint(item: slider, attribute: .Width, relatedBy: .Equal, toItem: firstButton.titleLabel, attribute: .Width, multiplier: 1.0, constant: 0)
		sliderCenter = NSLayoutConstraint(item: slider, attribute: .CenterX, relatedBy: .Equal, toItem: firstButton, attribute: .CenterX, multiplier: 1.0, constant: 0)
		let sliderHeight = NSLayoutConstraint(item: slider, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 5)
		let sliderBottom = NSLayoutConstraint(item: slider, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
		self.addConstraints([sliderWidth!, sliderCenter!, sliderHeight, sliderBottom])
	}
	
	///	滑动变更当前选中项到其隔壁项，并限定滑动进度，无动画效果
	///
	///	- parameter leftNeighbourOrNot: 前往左隔壁还是右隔壁，true为左，否则为右
	///	- parameter progress: 滑动进度
	func slideToNeighbourOnProgress(leftNeighbourOrNot isLeft:Bool, progress:CGFloat){
		self.removeConstraints([sliderCenter!, sliderWidth!])
		let lrIndex:Int = isLeft ? -1 : 1
		
		guard let button = self.viewWithTag(_selectedIndex + lrIndex) as? UIButton
			else {fatalError("The menu item sliding to is unexist")}
		sliderCenter = NSLayoutConstraint(item: slider, attribute: .CenterX, relatedBy: .Equal, toItem: button, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
		sliderWidth = NSLayoutConstraint(item: slider, attribute: .Width, relatedBy: .Equal, toItem: button.titleLabel, attribute: .Width, multiplier: 1.0, constant: 0)
		self.addConstraints([sliderCenter!, sliderWidth!])
		self.layoutIfNeeded()
		_selectedIndex = _selectedIndex + lrIndex
	}
	
	///	滑动到指定索引值的菜单项
	///
	///	- parameter indexOfItemToSlide:		菜单项索引值
	///	- parameter animated:	是否播放滑动动画
	func slideToItem(indexOfItemToSlide index:Int, animated: Bool){
		guard let button = self.viewWithTag(index + 154) as? UIButton
			else {fatalError("The menu item sliding to is unexist")}
		self.removeConstraints([sliderCenter!, sliderWidth!])
		sliderCenter = NSLayoutConstraint(item: slider, attribute: .CenterX, relatedBy: .Equal, toItem: button, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
		sliderWidth = NSLayoutConstraint(item: slider, attribute: .Width, relatedBy: .Equal, toItem: button.titleLabel, attribute: .Width, multiplier: 1.0, constant: 0)
		self.addConstraints([sliderCenter!, sliderWidth!])
		
		if animated{
			UIView.animateWithDuration(
				0.25,
				delay: 0,
				options: .CurveEaseInOut,
				animations: { () -> Void in
					self.layoutIfNeeded()
				},
				completion: nil
			)
		}
		_selectedIndex = index
	}
	
	func prepareForSelectedItem(button:UIButton){
		guard delegate != nil else{return}
		delegate?.uSMenuBar?(self, willSelectRowAtIndex: button.tag - 154)
		
		for perView in self.subviews{
			if perView.isKindOfClass(UIButton){
				let perButton = perView as! UIButton
				perButton.setTitleColor(UIColor(white: 0.67, alpha: 1.0), forState: .Normal)
			}
		}
		
		self.removeConstraints([sliderCenter!, sliderWidth!])
		sliderCenter = NSLayoutConstraint(item: slider, attribute: .CenterX, relatedBy: .Equal, toItem: button, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
		sliderWidth = NSLayoutConstraint(item: slider, attribute: .Width, relatedBy: .Equal, toItem: button.titleLabel, attribute: .Width, multiplier: 1.0, constant: 0)
		self.addConstraints([sliderCenter!, sliderWidth!])
		
		UIView.animateWithDuration(
			0.25,
			delay: 0,
			options: .CurveEaseInOut,
			animations: { () -> Void in
				self.layoutIfNeeded()
			},
			completion: { (Bool) -> Void in
				button.setTitleColor(self.tintColor, forState: .Normal)
				self.delegate?.uSMenuBar?(self, didSelectRowAtIndex: button.tag - 154)
		})
	}

	
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        reloadData()
    }
}
