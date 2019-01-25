//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by Charles Martin Reed on 1/24/19.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: class {
  func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
  
  //MARK:- Properties
  weak var delegate: PinterestLayoutDelegate!
  
  fileprivate var numberOfColumns = 2
  fileprivate var cellPadding: CGFloat = 6
  
  fileprivate var cache = [UICollectionViewLayoutAttributes]() //used to hold calculated attributes for each value, which are handled during the prepare() call
  
  fileprivate var contentHeight: CGFloat = 0  //incremented as photos are added
  
  fileprivate var contentWidth: CGFloat {
    guard let collectionView = collectionView else { return 0 }
    
    let insets = collectionView.contentInset
    return collectionView.bounds.width - (insets.left + insets.right)
  }
  
  //collectionViewContentSize - returns width and height of collection view contents, the entire content area, not just the visible parts. Used internally to configure the scroll view content size.
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  //called when layout operation is about to take place. Use to determine collection view's size and position of its items.
  //because this is a demo implementation, we're not dealing with what needs to happen when the  collection view layout is invalidated - such as when changing between screen orientations
  override func prepare() {
    guard cache.isEmpty == true, let collectionView = collectionView else { return } //only calculated once, when the cache is empty
    
    let columnWidth = contentWidth / CGFloat(numberOfColumns)
    var xOffset = [CGFloat]()
    for column in 0..<numberOfColumns {
      xOffset.append(CGFloat(column) * columnWidth)
    }
    
    var column = 0
    var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
    
    for item in 0..<collectionView.numberOfItems(inSection: 0) {
      let indexPath = IndexPath(item: item, section: 0)
      let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
      let height = cellPadding * 2 + photoHeight
      let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
      let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
      
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = insetFrame
      cache.append(attributes)
      
      contentHeight = max(contentHeight, frame.maxY)
      yOffset[column] = yOffset[column] + height
      
      column = column < (numberOfColumns - 1) ? (column + 1) : 0
    }
  }
  
  //layoutAttributesForElements(in:) - returns layout attributes for all items in the rect as an [UICollectionViewLayoutAttributes]
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }
  
  //layoutAttributesForItem(at:) - provides on demand layout information to the collection view, for the item at the requested indexPath
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }
}
