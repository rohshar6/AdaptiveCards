import AdaptiveCards_bridge
import AppKit

class BaseCardElementRenderer {
    static let shared = BaseCardElementRenderer()
    
    func updateView(view: NSView, element: ACSBaseCardElement, rootView: ACRView, style: ACSContainerStyle, hostConfig: ACSHostConfig, isfirstElement: Bool) -> NSView {
        let updatedView = ACRContentStackView(style: style, hostConfig: hostConfig)
        
        // For Spacing
        if !isfirstElement {
            updatedView.addSpacing(element.getSpacing())
        }
        
        if let elem = element as? ACSImage {
            switch elem.getHorizontalAlignment() {
            case .center: updatedView.alignment = .centerX
            case .right: updatedView.alignment = .trailing
            default: updatedView.alignment = .leading
            }
        }
        
        if let collectionElement = element as? ACSCollectionTypeElement, let columnView = view as? ACRColumnView {
            if let backgroundImage = collectionElement.getBackgroundImage(), let url = backgroundImage.getUrl() {
                columnView.setupBackgroundImageProperties(backgroundImage)
                rootView.registerImageHandlingView(columnView.backgroundImageView, for: url)
            }
        }
        
        // For seperator
        if element.getSeparator(), !isfirstElement {
            updatedView.addSeperator(true)
        }
        
        view.identifier = .init(element.getId() ?? "")
        updatedView.isHidden = !element.getIsVisible()
        
        // Input label handling
        if let inputElement = element as? ACSBaseInputElement, let label = inputElement.getLabel(), !label.isEmpty {
            let attributedString = NSMutableAttributedString(string: label)
            if let colorHex = hostConfig.getForegroundColor(style, color: .default, isSubtle: true), let textColor = ColorUtils.color(from: colorHex) {
                attributedString.addAttributes([.foregroundColor: textColor], range: NSRange(location: 0, length: attributedString.length))
            }
            let labelView = NSTextField(labelWithAttributedString: attributedString)
            labelView.isEditable = false
            updatedView.addArrangedSubview(labelView)
            updatedView.setCustomSpacing(spacing: 3, after: labelView)
        }
        
        updatedView.addArrangedSubview(view)
        if view is ACRContentStackView {
            view.widthAnchor.constraint(equalTo: updatedView.widthAnchor).isActive = true
        }
        return updatedView
    }
    
    func configBleed(collectionView: NSView, parentView: ACRContentStackView, with hostConfig: ACSHostConfig, element: ACSBaseCardElement, columnView: NSView?) {
        if !(element is ACSCollectionTypeElement) {
            return
        }
        guard let collection = element as? ACSCollectionTypeElement else {
            logError("Element is not ACSCollectionTypeElement")
            return
        }
        if !collection.getBleed() {
            return
        }
        guard let collectionView = collectionView as? ACRContentStackView else {
            logError("Container is not type of ACRContentStackView")
            return
        }
        // bleed specification requires the object that's asked to be bled to have padding
        if collection.getPadding() {
            let adaptiveBleedDirection = collection.getBleedDirection()
            let direction = ACRBleedDirection(rawValue: adaptiveBleedDirection.rawValue)
            
            // 1. create a background view (bv).
            // 2. Now, add bv to the parentView
            // bv is then pinned to the parentView to the bleed direction
            // bv gets current collection view's (cv) container style
            // container view's stack view (csv) holds content views, and bv dislpays
            // container style we transpose them, and get the final result
            
            let backgroundView = NSView()
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            collectionView.backgroundView = backgroundView
            // adding this above parentView backgroundImage view
            parentView.addSubview(backgroundView, positioned: .above, relativeTo: parentView.backgroundImageView)
            backgroundView.wantsLayer = true
            backgroundView.layer?.backgroundColor = collectionView.layer?.backgroundColor
            
            let top = ((direction.rawValue & ACRBleedDirection.ACRBleedToTopEdge.rawValue) != 0)
            let leading = ((direction.rawValue & ACRBleedDirection.ACRBleedToLeadingEdge.rawValue) != 0)
            let trailing = ((direction.rawValue & ACRBleedDirection.ACRBleedToTrailingEdge.rawValue) != 0)
            let bottom = ((direction.rawValue & ACRBleedDirection.ACRBleedToBottomEdge.rawValue) != 0)
            
            // In columnSetView, we have wrapping view, that wraps column view,
            // now here we set bleed property of both wrapping view
            // and column view
            collectionView.setBleedProp(top: top, bottom: bottom, trailing: trailing, leading: leading)
            if let columnView = columnView as? ACRColumnView {
                columnView.setBleedProp(top: top, bottom: bottom, trailing: trailing, leading: leading)
            }
            backgroundView.topAnchor.constraint(equalTo: top ? parentView.topAnchor : collectionView.topAnchor).isActive = true
            backgroundView.leadingAnchor.constraint(equalTo: leading ? parentView.leadingAnchor : collectionView.leadingAnchor).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: trailing ? parentView.trailingAnchor : collectionView.trailingAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: bottom ? parentView.bottomAnchor : collectionView.bottomAnchor).isActive = true
            
            if let borderWidth = collectionView.layer?.borderWidth {
                backgroundView.layer?.borderWidth = borderWidth
            }
            
            if let borderColor = collectionView.layer?.borderColor {
                backgroundView.layer?.borderColor = borderColor
            }
        }
    }
}
