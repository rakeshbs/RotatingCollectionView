//
//  MyFlowLayout.swift
//  CollectionViewTutorial
//
//  Created by bill on 9/7/14.
//  Copyright (c) 2014 bill. All rights reserved.
//

import UIKit
import Foundation

class MyFlowLayout : UICollectionViewFlowLayout {

    var currentCellPath : NSIndexPath? = nil
    var currentCellCenter : CGPoint? = nil
    var currentCellScale: CGFloat = 0.0
    
    func setCurrentCellScale(scale: CGFloat) {
        currentCellScale = scale
        self.invalidateLayout()
    }
    
    func setCurrentCellCenter(origin: CGPoint) {
        currentCellCenter = origin
        self.invalidateLayout()
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var attributes: UICollectionViewLayoutAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        self.modifyLayoutAttributes(attributes)
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var allAttributesInRect: NSArray = super.layoutAttributesForElementsInRect(rect)!
        for cellAttributes in allAttributesInRect {
            self.modifyLayoutAttributes(cellAttributes as UICollectionViewLayoutAttributes)
        }
        return allAttributesInRect
    }
    
    func modifyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        if (layoutAttributes.indexPath == currentCellPath) {
            layoutAttributes.transform3D = CATransform3DMakeScale(currentCellScale, currentCellScale, 1.0)
            layoutAttributes.center = currentCellCenter!
            layoutAttributes.zIndex = 1
        }
    }
    
}