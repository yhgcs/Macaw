
import AppKit

import XCTest
@testable import Macaw

class MacawSVGTestSuite: XCTestCase {
    
    fileprivate var testsData: String = ""
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        guard let testSuitePath = ProcessInfo.processInfo.environment["TEST_SUITE_DIR"] else {
            XCTAssert(false, "Failed to get test suite path from TEST_SUITE_DIR environment variable.")
            return
        }
        let outputDataFile = testSuitePath + "/data.csv"
        do {
            try testsData.write(toFile: outputDataFile, atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print (error)
        }
    }
    
    func parseAndSave(from: String, to: String) {
        let bundle = Bundle(for: type(of: TestUtils()))
        do {
            let rootNode = try SVGParser.parse(bundle:bundle, path: from)
            let content = SVGSerializer.serialize(node: rootNode)
            do {
                try content.write(toFile:to, atomically: false, encoding: String.Encoding.utf8)
            }
            catch let error as NSError {
                print("Failed to write: \(error)")
            }        } catch {
                print(error)
        }
         
    }
    

    func testSVGTest() {
        // IMPORTANT: correct path according to your environment
        let macawOutputDir = "macaw-serializer-output/"
        guard let testSuitePath = ProcessInfo.processInfo.environment["TEST_SUITE_DIR"] else {
            XCTAssert(false, "Failed to get test suite path from TEST_SUITE_DIR environment variable.")
            return
        }
        let bundle = Bundle(for: type(of: TestUtils()))
        
        if let path = bundle.path(forResource: "svglist", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                for name in myStrings {
                    print("processing: ", name)
                    if !name.isEmpty {
                        let destination = testSuitePath + "/" + macawOutputDir + name + ".svg"
                        parseAndSave(from: name, to: destination)
                        let task = Process()
                        task.currentDirectoryPath = testSuitePath
                        var environment = ProcessInfo.processInfo.environment
                        environment["PWD"] = testSuitePath
                        if let pathVar = environment["PATH"] {
                            environment["PATH"] = pathVar + ":" + "/usr/local/bin/"
                        } else {
                            environment["PATH"] = "/usr/local/bin/"
                        }
                        task.environment = environment
                        task.launchPath = testSuitePath + "/convert-and-compare.sh"
                        task.arguments = [destination]
                        let outpipe = Pipe()
                        task.standardOutput = outpipe
                        task.launch()
                        task.waitUntilExit()
                        let output = String(data: outpipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!
                        testsData += [name, output].map { String($0).replacingOccurrences(of:"(", with: "").replacingOccurrences(of:")", with:"").replacingOccurrences(of:" ", with:",") }.joined(separator: ",")
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
