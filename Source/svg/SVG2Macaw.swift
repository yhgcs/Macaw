import Foundation
import SWXMLHash

public class SVG2Macaw {
    
    let moveToAbsolute = Character("M")
    let moveToRelative = Character("m")
    let lineToAbsolute = Character("L")
    let lineToRelative = Character("l")
    let curveToAbsolute = Character("C")
    let curveToRelative = Character("c")
    let closePathAbsolute = Character("Z")
    let closePathRelative = Character("z")
    
    private enum PathCommandType {
        case MoveTo
        case LineTo
        case CurveTo
        case ClosePath
        case None
    }
    
    private typealias PathCommand = (type: PathCommandType, expression: String, absolute: Bool)
    
    private let xmlString: String
    
    private var nodes = [Node]()
    
    public init(string: String) {
        xmlString = string
    }
    
    public func parse() -> Group {
        let parsedXml = SWXMLHash.parse(xmlString)
        let rootGroup = Group(
            contents: []
        )
        iterateThroughXmlTree(parsedXml.children[0], rootGroup: rootGroup)
        return rootGroup
    }
    
    private func iterateThroughXmlTree(children: [XMLIndexer]) {
        for child in children {
            if let element = child.element {
                let node = handleElement(element)
            }
            iterateThroughXmlTree(child.children)
        }
    }
    
    private func iterateThroughXmlTree(xml: XMLIndexer, rootGroup: Group) {
        guard let element = xml.element else {
            return
        }
        let node = handleElement(element)
        if let group = node as? Group {
            for child in xml.children {
                iterateThroughXmlTree(child, rootGroup: group)
            }
        } else {
            for child in xml.children {
                iterateThroughXmlTree(child, rootGroup: rootGroup)
            }
        }
        rootGroup.contents.append(node)
    }
    
    private func attach(parent: Node, node: Node, rootGroup: Group) {
        if let parent = parent as? Group {
            parent.contents.append(node)
            rootGroup.contents.append(parent)
        }
    }
    
    private func handleElement(element: XMLElement) -> Node {
        switch element.name {
        case "svg":
            break
        case "g":
            return handleGroup(element)
        case "use":
            break
        case "symbol":
            break
        case "image":
            return handleImage(element)
        case "text":
            return handleText(element)
        case "tspan":
            break
        case "path":
            return handlePath(element)
        case "rect":
            return handleRectangle(element)
        case "circle":
            return handleCircle(element)
        case "ellipse":
            return handleEllipse(element)
        case "polyline":
            return handlePolyline(element)
        case "polygon":
            return handlePolygon(element)
        case "line":
            return handleLine(element)
        case "linearGradient":
            handleLinearGradient(element)
            break
        case "stop":
            break
        case "pattern":
            break
        case "clipPath":
            break
        case "defs":
            break
        default:
            break
        }
        return Node(pos: Transform())
    }
    
    private func handleGroup(element: XMLElement) -> Group {
        let group = Group(
            contents: [],
            pos: Transform(),
            opaque: true,
            visible: true,
            clip: nil,
            tag: []
        )
        return group
    }
    
    private func handleImage(element: XMLElement) -> Node {
        let image = Image(src: getStringValue(element, attribute: "xlink:href"))
        let transform = Transform().move(
            getDoubleValue(element, attribute: "x"),
            my: getDoubleValue(element, attribute: "y")
        )
        image.pos = transform
        image.w = getIntegerValue(element, attribute: "width")
        image.h = getIntegerValue(element, attribute: "height")
        return image
    }
    
    private func handleText(element: XMLElement) -> Text {
        let font = Font(
            name: getFontName(element),
            size: getFontSize(element),
            bold: getFontStyle(element, style: "bold"),
            italic: getFontStyle(element, style: "italic"),
            underline: getTextDecoration(element, decoration: "underline"),
            strike: getTextDecoration(element, decoration: "line-through")
        )
        let text = Text(text: element.text ?? "", font: font, fill: Fill())
        let transform = Transform().move(
            getDoubleValue(element, attribute: "x"),
            my: getDoubleValue(element, attribute: "y")
        )
        text.pos = transform
        return text
    }
    
    private func handleRectangle(element: XMLElement) -> Shape {
        let rect = Rect(
            x: getDoubleValue(element, attribute: "x"),
            y: getDoubleValue(element, attribute: "y"),
            w: getDoubleValue(element, attribute: "width"),
            h: getDoubleValue(element, attribute: "height")
        )
        let shape = Shape(
            form: rect,
            fill: getFillColor(element),
            stroke: getStroke(element)
        )
        return shape
    }
    
    private func handleCircle(element: XMLElement) -> Shape {
        let circle = Circle(
            cx: getDoubleValue(element, attribute: "cx"),
            cy: getDoubleValue(element, attribute: "cy"),
            r: getDoubleValue(element, attribute: "r")
        )
        let transform = Transform().move(
            getDoubleValue(element, attribute: "x"),
            my: getDoubleValue(element, attribute: "y")
        )
        let shape = Shape(
            form: circle,
            fill: getFillColor(element),
            stroke: getStroke(element),
            pos: transform
        )
        return shape
    }
    
    private func handleEllipse(element: XMLElement) -> Shape {
        let ellipse = Ellipse(
            cx: getDoubleValue(element, attribute: "cx"),
            cy: getDoubleValue(element, attribute: "cy"),
            rx: getDoubleValue(element, attribute: "rx"),
            ry: getDoubleValue(element, attribute: "ry")
        )
        let transform = Transform().move(
            getDoubleValue(element, attribute: "x"),
            my: getDoubleValue(element, attribute: "y")
        )
        let shape = Shape(
            form: ellipse,
            fill: getFillColor(element),
            stroke: getStroke(element),
            pos: transform
        )
        return shape
    }
    
    private func handleLine(element: XMLElement) -> Shape {
        let line = Line(
            x1: getDoubleValue(element, attribute: "x1"),
            y1: getDoubleValue(element, attribute: "y1"),
            x2: getDoubleValue(element, attribute: "x2"),
            y2: getDoubleValue(element, attribute: "y2")
        )
        let transform = Transform().move(
            getDoubleValue(element, attribute: "x"),
            my: getDoubleValue(element, attribute: "y")
        )
        let shape = Shape(
            form: line,
            fill: getFillColor(element),
            stroke: getStroke(element),
            pos: transform
        )
        return shape
    }
    
    private func handlePolygon(element: XMLElement) -> Shape {
        var polygonPoints = [Double]()
        if let points = element.attributes["points"] {
            let separatedPoints = points.componentsSeparatedByString(" ")
            for point in separatedPoints {
                if let value = NSNumberFormatter().numberFromString(point) {
                    polygonPoints.append(value.doubleValue)
                }
            }
        }
        let polygon = Polygon(points: polygonPoints)
        let transform = Transform().move(
            getDoubleValue(element, attribute: "x"),
            my: getDoubleValue(element, attribute: "y")
        )
        let shape = Shape(
            form: polygon,
            fill: getFillColor(element),
            stroke: getStroke(element),
            pos: transform
        )
        return shape
    }
    
    private func handlePolyline(element: XMLElement) -> Shape {
        var polylinePoints = [Double]()
        if let points = element.attributes["points"] {
            let separatedPoints = points.componentsSeparatedByString(" ")
            for point in separatedPoints {
                let parts = point.componentsSeparatedByString(",")
                for part in parts {
                    if let value = NSNumberFormatter().numberFromString(part) {
                        polylinePoints.append(value.doubleValue)
                    }
                }
            }
        }
        let polyline = Polyline(points: polylinePoints)
        let transform = Transform().move(
            getDoubleValue(element, attribute: "x"),
            my: getDoubleValue(element, attribute: "y")
        )
        let shape = Shape(
            form: polyline,
            fill: getFillColor(element),
            stroke: getStroke(element),
            pos: transform
        )
        return shape
    }
    
    private func handlePath(element: XMLElement) -> Shape {
        var path = Path(segments: [])
        if let d = element.attributes["d"] {
            let pathSegments = parsePathCommands(d)
            path = Path(segments: pathSegments)
        }
        let transform = Transform().move(
            getDoubleValue(element, attribute: "x"),
            my: getDoubleValue(element, attribute: "y")
        )
        let shape = Shape(
            form: path,
            fill: getFillColor(element),
            stroke: getStroke(element),
            pos: transform
        )
        return shape
    }
    
    private func handleLinearGradient(element: XMLElement) {
        let linearGradient = LinearGradient(
            userSpace: true,
            stops: [],
            x1: getDoubleValue(element, attribute: "x1"),
            y1: getDoubleValue(element, attribute: "y1"),
            x2: getDoubleValue(element, attribute: "x2"),
            y2: getDoubleValue(element, attribute: "y2")
        )
    }
    
    private func getFontName(element: XMLElement) -> String {
        guard let fontName = element.attributes["font-family"] else {
            return "Serif"
        }
        return fontName
    }
    
    private func getFontSize(element: XMLElement) -> Int {
        let defaultFontSize = 12
        guard let fontSizeString = element.attributes["font-size"] else {
            return defaultFontSize
        }
        guard let fontSize = NSNumberFormatter().numberFromString(fontSizeString) else {
            return defaultFontSize
        }
        return fontSize.integerValue
    }
    
    private func getFontStyle(element: XMLElement, style: String) -> Bool {
        guard let fontStyle = element.attributes["font-style"] else {
            return false
        }
        if fontStyle.lowercaseString == style {
            return true
        }
        return false
    }
    
    private func getTextDecoration(element: XMLElement, decoration: String) -> Bool {
        guard let textDecoration = element.attributes["text-decoration"] else {
            return false
        }
        if textDecoration.containsString(decoration) {
            return true
        }
        return false
    }
    
    private func getStroke(element: XMLElement) -> Stroke {
        return Stroke(
            fill: getStrokeColor(element),
            width: getStrokeWidth(element),
            cap: .round,
            join: .round
        )
    }
    
    private func getStrokeColor(element: XMLElement) -> Color {
        guard let strokeColor = element.attributes["stroke"] else {
            return Color.black
        }
        return createColor(with: strokeColor)
    }
    
    private func getStrokeWidth(element: XMLElement) -> Double {
        guard let strokeWidth = element.attributes["stroke-width"] else {
            return 0
        }
        guard let value = NSNumberFormatter().numberFromString(strokeWidth) else {
            return 0
        }
        return value.doubleValue
    }
    
    private func getFillColor(element: XMLElement) -> Color {
        guard let fillColor = element.attributes["fill"] else {
            return Color.black
        }
        return createColor(with: fillColor)
    }
    
    private func getDoubleValue(element: XMLElement, attribute: String) -> Double {
        if let attributeValue = element.attributes[attribute] {
            let digitsArray = attributeValue.componentsSeparatedByCharactersInSet(
                NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            let digits = digitsArray.joinWithSeparator("")
            guard let value = NSNumberFormatter().numberFromString(digits) else {
                return 0
            }
            return value.doubleValue
        }
        return 0
    }
    
    private func getIntegerValue(element: XMLElement, attribute: String) -> Int {
        if let attributeValue = element.attributes[attribute] {
            let digitsArray = attributeValue.componentsSeparatedByCharactersInSet(
                NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            let digits = digitsArray.joinWithSeparator("")
            guard let value = NSNumberFormatter().numberFromString(digits) else {
                return 0
            }
            return value.integerValue
        }
        return 0
    }
    
    private func getStringValue(element: XMLElement, attribute: String) -> String {
        guard let attributeValue = element.attributes[attribute] else {
            return ""
        }
        return attributeValue
    }
    
    private func createColor(with hexString: String) -> Color {
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            cleanedHexString = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
        }
        
        var rgbValue: UInt32 = 0
        NSScanner(string: cleanedHexString).scanHexInt(&rgbValue)
        
        let red = CGFloat((rgbValue >> 16) & 0xff)
        let green = CGFloat((rgbValue >> 08) & 0xff)
        let blue = CGFloat((rgbValue >> 00) & 0xff)
        
        return Color.rgb(Int(red), g: Int(green), b: Int(blue))
    }
    
    private func parsePathCommands(d: String) -> [PathSegment] {
        var pathCommands = [PathCommand]()
        var commandChar = Character(" ")
        var commandString = ""
        for character in d.characters {
            if isPathCommandCharacter(character) {
                if !commandString.isEmpty {
                    pathCommands.append(
                        PathCommand(
                            type: getPathCommandType(commandChar),
                            expression: commandString,
                            absolute: true
                        )
                    )
                }
                if character == closePathAbsolute || character == closePathRelative {
                    pathCommands.append(
                        PathCommand(
                            type: getPathCommandType(character),
                            expression: commandString,
                            absolute: true
                        )
                    )
                }
                commandString = ""
                commandChar = character
            } else {
                commandString.append(character)
            }
        }
        var commands = [PathSegment]()
        for command in pathCommands {
            if let parsedCommand = parsePathCommand(command) {
                commands.append(parsedCommand)
            }
        }
        return commands
    }
    
    private func parsePathCommand(command: PathCommand) -> PathSegment? {
        var commandParams = command.expression.componentsSeparatedByString(" ")
        switch command.type {
        case .MoveTo:
            return Move(x: Double(commandParams[0])!, y: Double(commandParams[1])!, absolute: true)
        case .LineTo:
            return PLine(x: Double(commandParams[0])!, y: Double(commandParams[1])!, absolute: true)
        case .CurveTo:
            return Cubic(x1: Double(commandParams[0])!, y1: Double(commandParams[1])!, x2: Double(commandParams[2])!, y2: Double(commandParams[3])!, x: Double(commandParams[4])!, y: Double(commandParams[5])!, absolute: true)
        case .ClosePath:
            return Close()
        default:
            return nil
        }
    }
    
    private func isPathCommandCharacter(character: Character) -> Bool {
        switch character {
        case moveToAbsolute:
            return true
        case moveToRelative:
            return true
        case lineToAbsolute:
            return true
        case lineToRelative:
            return true
        case curveToAbsolute:
            return true
        case curveToRelative:
            return true
        case closePathAbsolute:
            return true
        case closePathRelative:
            return true
        default:
            return false
        }
    }
    
    private func getPathCommandType(character: Character) -> PathCommandType {
        switch character {
        case moveToAbsolute:
            return .MoveTo
        case moveToRelative:
            return .MoveTo
        case lineToAbsolute:
            return .LineTo
        case lineToRelative:
            return .LineTo
        case curveToAbsolute:
            return .CurveTo
        case curveToRelative:
            return .CurveTo
        case closePathAbsolute:
            return .ClosePath
        case closePathRelative:
            return .ClosePath
        default:
            return .None
        }
    }
    
}
