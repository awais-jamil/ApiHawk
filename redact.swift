import Foundation
import Vision
import Cocoa

let fileURLs = [
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371657.png",
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371653.png",
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371623.png",
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371631.png",
    "/Users/awais-mealplanet/.gemini/antigravity-ide/brain/d64882ad-a25c-45f5-ab49-cd8cecd4eff3/media__1786525371639.png"
]

func redactImage(at path: String) {
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
        context.setFillColor(NSColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 1.0).cgColor)

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let text = topCandidate.string.lowercased()
            
            let words = text.split(separator: " ")
            let hasLongWord = words.contains { $0.count > 25 }
            
            let isSensitive = text.contains("mealplanet") || 
                              text.contains("preprod") || 
                              text.contains("eyjh") || 
                              hasLongWord
                              
            if isSensitive {
                let boundingBox = observation.boundingBox
                let rect = NSRect(
                    x: boundingBox.origin.x * imageSize.width,
                    y: boundingBox.origin.y * imageSize.height,
                    width: boundingBox.size.width * imageSize.width,
                    height: boundingBox.size.height * imageSize.height
                )
                
                let expandedRect = rect.insetBy(dx: -4, dy: -2)
                context.fill(expandedRect)
                print("Redacted: '\(text)'")
            }
        }
        
        newImage.unlockFocus()
        
        if let tiffData = newImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            let outURL = URL(fileURLWithPath: path).deletingPathExtension().appendingPathExtension("redacted.png")
            try? pngData.write(to: outURL)
            print("Saved: \(outURL.lastPathComponent)")
        }
    }
    
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false
    
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try? handler.perform([request])
}

for path in fileURLs {
    redactImage(at: path)
}
