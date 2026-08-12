import Foundation
import Vision
import Cocoa

let fileMap = [
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371657.png": "detail_overview.png",
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371653.png": "detail_response.png",
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371623.png": "list_view_1.png",
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371639.png": "detail_request.png"
]

func processImage(at path: String, outName: String) {
    guard let nsImage = NSImage(contentsOfFile: path),
          let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return
    }

    let request = VNRecognizeTextRequest { (request, error) in
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

        let imageSize = nsImage.size
        let newImage = NSImage(size: imageSize)
        newImage.lockFocus()
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        nsImage.draw(in: NSRect(origin: .zero, size: imageSize))

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let text = topCandidate.string
            let lowerText = text.lowercased()
            
            let words = lowerText.split(separator: " ")
            let hasLongWord = words.contains { $0.count > 25 }
            
            let isBaseUrl = lowerText.contains("mealplanet") || lowerText.contains("preprod") || lowerText.contains("apigateway")
            let isToken = lowerText.contains("eyjh") || hasLongWord
            let isEndpoint = lowerText.contains("catalog-service") || lowerText.contains("customer-profile-service") || lowerText.contains("fetch")
            
            if isBaseUrl || isToken || isEndpoint {
                let boundingBox = observation.boundingBox
                let rect = NSRect(
                    x: boundingBox.origin.x * imageSize.width,
                    y: boundingBox.origin.y * imageSize.height,
                    width: boundingBox.size.width * imageSize.width,
                    height: boundingBox.size.height * imageSize.height
                )
                
                // Clear the background
                context.setFillColor(NSColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 1.0).cgColor)
                let expandedRect = rect.insetBy(dx: -4, dy: -2)
                context.fill(expandedRect)
                
                // Draw text
                var replacementText = ""
                var textColor = NSColor.white
                
                if isEndpoint {
                    replacementText = "/v1/orders/checkout"
                    textColor = NSColor(white: 0.9, alpha: 1.0)
                } else if isBaseUrl {
                    replacementText = text.contains("•") ? "https://api.myapp.com/v1 •" : "https://api.myapp.com/v1"
                    textColor = NSColor(white: 0.65, alpha: 1.0)
                } else if isToken {
                    let dummyStr = "token_abc123def456ghi789jkl012mno345pqr"
                    if lowerText.contains("bearer") {
                        replacementText = "Bearer " + dummyStr
                    } else {
                        replacementText = dummyStr
                    }
                    textColor = NSColor(white: 0.85, alpha: 1.0)
                }
                
                let fontSize = rect.height * 0.75
                let font = NSFont.systemFont(ofSize: fontSize, weight: .regular)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: textColor
                ]
                
                let textRect = NSRect(x: rect.origin.x, y: rect.origin.y - (rect.height * 0.1), width: rect.width + 200, height: rect.height + 10)
                let attrString = NSAttributedString(string: replacementText, attributes: attributes)
                attrString.draw(in: textRect)
                
                print("Replaced: '\(text)' with '\(replacementText)'")
            }
        }
        
        newImage.unlockFocus()
        
        if let tiffData = newImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            let outURL = URL(fileURLWithPath: "/Users/awais-mealplanet/Desktop/api_hawk/screenshots/\(outName)")
            try? pngData.write(to: outURL)
            print("Saved: \(outName)")
        }
    }
    
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false
    
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try? handler.perform([request])
}

for (path, outName) in fileMap {
    processImage(at: path, outName: outName)
}
