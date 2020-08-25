//  © News Pty Limited. All rights reserved.

import Foundation
import ScreenKit


/// Handles default UI configuration of ScreenKit
final class MetrosScreenKitUIConfiguration: DefaultScreenKitUIConfiguration {
    
    public static var dateFormatter: DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.timeZone = LocalConfig.mastheadTimeZone
        dateFormatter.dateFormat = "MMM d, YYYY h:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        return dateFormatter
    }
    
    open let additionSupport = {() -> AdditionSupport in
        
        /// Date adition transformer. It transforms a timestamp inside the text into the users timezone with the required default format
        let dateAdditionTransformer = AdditionTransformer(typeName: "date", transformer: { (_, attributedString, addition) in
            guard let valueString = addition.value as? String, let date = Date(dateTime: valueString) else { return }
            
            let currentAtts = attributedString.attributes(at: addition.rangeStart, effectiveRange: nil)
            let dateString = dateFormatter.string(from: date)
            let attachmentString: NSAttributedString = NSAttributedString(string: dateString, attributes: currentAtts)
            
            let range = NSRange(location: addition.rangeStart, length: addition.rangeLength)
            let fullrange = NSRange(location: 0, length: attributedString.length)
            let underlineRange = NSIntersectionRange(range, fullrange)
            guard underlineRange.length != 0 else { WLOG("Range out of bounds"); return }
            attributedString.replaceCharacters(in: range, with: attachmentString)
        })
        
        return AdditionSupport([dateAdditionTransformer])
    }()
    
    override init() {
        super.init()
                
        configureTextWithAddition = self.additionSupport.transformer
        screenUIProvider = MetrosUIProvider()
    }
}
