//
//  MacawSVGTestSuiteWithViews.swift
//  MacawTests
//
//  Created by Yuriy Kashnikov on 10/4/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

#if os(iOS)
    
    import XCTest
    @testable import Macaw
    
    class MacawSVGTestSuiteWithViews: XCTestCase {
        
        fileprivate var testsData: String = ""
        fileprivate var testSuitePath: String = ""
        
        override func setUp() {
            super.setUp()
            
            if let path = getSuiteFolder() {
                testSuitePath = path
            } else {
                XCTAssert(false, "Failed to locate test suite folder.")
            }
        }
        
        override func tearDown() {
            super.tearDown()
            
        }
        
        func svgToImage(resourceName: String, size: CGSize = CGSize(width: CGFloat(480), height: CGFloat(360))) -> UIImage? {
            let bundle = Bundle(for: type(of: TestUtils()))
            let rootNode = try! SVGParser.parse(bundle:bundle, path: resourceName)
            let macawView = MacawView(node: rootNode, frame:CGRect(origin: CGPoint.zero, size: size))
            macawView.backgroundColor = UIColor.white
            UIGraphicsBeginImageContext(size)
            macawView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let img =  UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return img
        }
        
        func getSuiteFolder () -> String? {
            let bundle = Bundle(for: type(of: TestUtils()))
            if let filepath = bundle.path(forResource: "settings", ofType: "txt") {
                do {
                    let contents = try String(contentsOfFile: filepath)
                    return contents.trimmingCharacters(in: .whitespacesAndNewlines) + "/MacawTests/scripts"
                } catch {
                    return .none
                }
            }
            return .none
        }
        
        func testHarness() {
            let pngOutputDir = "macaw-pngs"
            let bundle = Bundle(for: type(of: TestUtils()))
            if let path = bundle.path(forResource: "svglist", ofType: "txt") {
                do {
                    let data = try String(contentsOfFile: path, encoding: .utf8)
                    let tests = data.components(separatedBy: .newlines)
                    for name in tests {
                        print("processing: ", name)
                        // TODO: For problem with "shapes-polygon-03-t-manual", see https://github.com/exyte/Macaw/issues/183
                        if !name.isEmpty && name != "shapes-polygon-03-t-manual" {
                            let destination = testSuitePath + "/" + pngOutputDir + "/" + name + ".png"
                            if let image = svgToImage(resourceName: name), let data = UIImagePNGRepresentation(image) {
                                try? data.write(to: URL(fileURLWithPath: destination))
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        
    }
#endif
