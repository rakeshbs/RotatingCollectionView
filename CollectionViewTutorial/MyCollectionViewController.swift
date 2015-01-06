//
//  MyCollectionViewController.swift
//  CollectionViewTutorial
//
//  Created by bill on 2014/09/06.
//  Copyright (c) 2014年 bill. All rights reserved.
//

import UIKit
import Foundation


class MyCollectionViewController : UICollectionViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    var carImages : [String] = []
    var counterRotation : CGAffineTransform!
    
    override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,  selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        super.viewDidLoad()
        counterRotation = CGAffineTransformMakeRotation(0.0)
        var myFlowLayout: MyFlowLayout = MyFlowLayout()
        self.collectionView?.setCollectionViewLayout(myFlowLayout, animated: true)
        //myFlowLayout.itemSize = CGSizeMake(200.0, 00.0)
        //var pinchRecognizer: UIGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        //self.collectionView?.addGestureRecognizer(pinchRecognizer)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.animateCellsThread()
        }
        
        self.carImages = ["chevy_small.jpg",
        "mini_small.jpg",
        "rover_small.jpg",
        "smart_small.jpg",
        "highlander_small.jpg",
        "venza_small.jpg",
        "volvo_small.jpg",
        "vw_small.jpg",
        "ford_small.jpg",
        "nissan_small.jpg",
        "honda_small.jpg",
            "jeep_small.jpg","mini_small.jpg",
            "rover_small.jpg",
            "smart_small.jpg",
            "highlander_small.jpg",
            "venza_small.jpg",
            "volvo_small.jpg",
            "vw_small.jpg",
            "ford_small.jpg",
            "nissan_small.jpg",
            "honda_small.jpg"]
    }
    
   
    func handlePinch(sender: UIPinchGestureRecognizer) {
        var layout: MyFlowLayout = self.collectionView?.collectionViewLayout as MyFlowLayout
        if (sender.state == UIGestureRecognizerState.Began) {
            var initialPinchPoint: CGPoint = sender.locationInView(self.collectionView)
            var pinchedCellPath: NSIndexPath? = self.collectionView?.indexPathForItemAtPoint(initialPinchPoint)
            layout.currentCellPath = pinchedCellPath
       }
        else if (sender.state == UIGestureRecognizerState.Changed) {
            layout.setCurrentCellCenter(sender.locationInView(self.collectionView))
            layout.setCurrentCellScale(sender.scale)
        }
        else {
            self.collectionView?.performBatchUpdates({
                layout.currentCellPath = nil
                layout.currentCellScale = 1.0
                }, completion: nil)
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.carImages.count
    }
    
    
    func orientationChanged(notification : NSNotification)
    {
        let device = notification.object as UIDevice
        switch(device.orientation)
        {
            case UIDeviceOrientation.Portrait:
                self.nextRotation = 0
            
            case UIDeviceOrientation.PortraitUpsideDown:
                self.nextRotation = 3.145
            
            case UIDeviceOrientation.LandscapeLeft:
                self.nextRotation = 3.145/2
            
            case UIDeviceOrientation.LandscapeRight:
                self.nextRotation = -3.145/2
            
            default :
                self.nextRotation = nil
        }

    }
    
    
    override func viewWillTransitionToSize( size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator){
        super.viewWillTransitionToSize(size , withTransitionCoordinator: coordinator)

        
        let transf : CGAffineTransform = coordinator.targetTransform()
        let invertedRotation = CGAffineTransformInvert(transf)
        let currentBounds = view.bounds
        println("entrou")
        self.view.transform = CGAffineTransformConcat(self.view.transform, invertedRotation )
        let contentOffset: CGPoint = self.collectionView!.contentOffset
        
        coordinator.animateAlongsideTransition({ context in
             self.counterRotation =  CGAffineTransformConcat(self.counterRotation, transf)
            self.view.bounds = currentBounds
            self.collectionView!.contentOffset = contentOffset

            }, completion: ({ finished in
                
            })
        )
    }
    
    var isAnimating : Bool = false
    var nextRotation : CGFloat? = nil
    var currentRotation : CGFloat = 0
    
    func animateCellsThread()
    {
        let deltaTime:CGFloat = 0.01
        while (true)
        {
            var time:CGFloat = 0
            var delta:CGFloat = 0
            var broken :Bool = false
            var destinationRotation:CGFloat = 0
            if self.nextRotation  != nil {
                delta = (self.nextRotation! - currentRotation) * deltaTime * 2
                destinationRotation = self.nextRotation!
                println("currentRotation \(currentRotation)")
                println("nextRotation \(self.nextRotation!)")
                println("Delta \(delta)")
                self.nextRotation = nil
            }
            while (time <= 0.5 && delta != 0)
            {
                if self.nextRotation != nil {
                    broken = true
                    break
                }
                currentRotation += delta;
                for cell  in self.collectionView!.visibleCells()
                {
                
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.contentView.transform = CGAffineTransformMakeRotation(self.currentRotation)
                    })

                }
                
                time += deltaTime
                NSThread.sleepForTimeInterval(Double(deltaTime));
            }
            if (!broken)
            {
                
            }
            NSThread.sleepForTimeInterval(0.5);
        }
    }

    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var myCell : MyCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as MyCollectionViewCell
        var image : UIImage
        var row : Int = indexPath.row
        image = UIImage(named: self.carImages[0])!
        myCell.imageView.image = image
        if !self.isAnimating
        {
            myCell.contentView.transform = self.counterRotation
        }
        return myCell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
/*        var row: Int = indexPath.row
        self.carImages.removeAtIndex(row)
        var deletions: NSArray = [indexPath]
        self.collectionView?.deleteItemsAtIndexPaths(deletions)*/
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var header : MySupplementaryView? = nil
        if (kind == UICollectionElementKindSectionHeader) {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "MyHeader", forIndexPath: indexPath)
             as? MySupplementaryView
            header?.headerLabel.text = "Car Image Gallery"
        }
        return header!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var row : Int = indexPath.row
        var image : UIImage = UIImage(named: self.carImages[0])!
        return image.size
    }
    
}