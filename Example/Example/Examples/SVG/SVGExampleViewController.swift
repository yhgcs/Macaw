import UIKit
import Macaw

class SVGExampleView: MacawView {
    
    required init?(coder aDecoder: NSCoder) {
        let path = NSBundle.mainBundle().pathForResource("test", ofType: "svg")
        let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        let parser = SVG2Macaw(string: text)
        
        super.init(node: parser.parse(), coder: aDecoder)
    }
    
    required init?(node: Node, coder aDecoder: NSCoder) {
        super.init(node: node, coder: aDecoder)
    }
}
