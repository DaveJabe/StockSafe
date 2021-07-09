//
//  CollectionViewLeadingFlowLayout.swift
//  StockSafe
//
//  Created by David Jabech on 7/9/21.
//

import UIKit

protocol CollectionViewLeadingFlowLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}

class CollectionViewLeadingFlowLayout: UICollectionViewLayout {
    
    public weak var delegate: CollectionViewLeadingFlowLayoutDelegate?
    
    fileprivate let numberOfColumns = 4
    fileprivate let cellPadding: CGFloat = 10
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        let size = CGSize(width: contentWidth, height: contentHeight)
        return size
    }
    
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else {
            return }
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffsets = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffsets.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        var yOffsets: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let labelHeight = delegate?.collectionView(collectionView, heightForItemAtIndexPath: indexPath)
            let height = (cellPadding * 2) + labelHeight!
            let frame = CGRect(x: xOffsets[column],
                               y: yOffsets[column],
                               width: columnWidth,
                               height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffsets[column] = yOffsets[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
