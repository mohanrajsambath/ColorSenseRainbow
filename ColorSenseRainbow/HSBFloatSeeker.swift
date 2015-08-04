//
//  HSBFloatSeeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-08-02.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class HSBFloatSeeker: Seeker {
    
    override init () {
        super.init()
        
        var error : NSError?
        
        
        // Swift
        // The values 0 and 1 are valid so everything after is optional.  The solution "\\.?[0-9]*" isn't optimal
        // because the period could be specified without any digits after and a match be made or vice versa.
        
        var regex = NSRegularExpression ( pattern: "(?:NS|UI)Color\\s*\\(\\s*hue:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*saturation:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*brightness:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*alpha:\\s*([01]|[01]\\.[0-9]+)\\s*\\)", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Swift HSB float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        regex = NSRegularExpression ( pattern: "NSColor\\s*\\(\\s*(?:calibrated|device)Hue:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*saturation:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*brightness:\\s*([01]|[01]\\.[0-9]+)\\s*,\\s*alpha:\\s*([01]|[01]\\.[0-9]+)\\s*\\)", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Swift NSColor calibrated, device HSB float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        
        // Objective-C - Only functions with alpha defined
        
        regex = NSRegularExpression ( pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWithHue:\\s*([01]|[01]\\.[0-9]+)f?\\s*saturation:\\s*([01]|[01]\\.[0-9]+)f?\\s*brightness:\\s*([01]|[01]\\.[0-9]+)f?\\s*alpha:\\s*([01]|[01]\\.[0-9]+)f?\\s*\\]", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Objective-C HSB float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        // Don't care about saving the Calibrated, Device, or SRGB since we assume that any function that
        // replace the values will do so selectively instead of overwriting the whole string.
        
        regex = NSRegularExpression ( pattern: "\\[\\s*NSColor\\s*colorWith(?:Calibrated|Device)Hue:\\s*([01]|[01]\\.[0-9]+)f?\\s*saturation:\\s*([01]|[01]\\.[0-9]+)f?\\s*brightness:\\s*([01]|[01]\\.[0-9]+)f?\\s*alpha:\\s*([01]|[01]\\.[0-9]+)f?\\s*\\]", options: .allZeros, error: &error )
        
        if regex == nil {
            println ( "Error creating Objective-C calibrated, device HSB calculated float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
    }
    
    
    override func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        if ( ( match.numberOfRanges == 4 ) || ( match.numberOfRanges == 5 ) ) {
            var alphaValue : CGFloat = 1.0
            
            let matchString = stringFromRange( match.range, line: line )
            let hueString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
            let saturationString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
            let brightnessString = stringFromRange( match.rangeAtIndex( 3 ), line: line )
            var capturedStrings = [ matchString, hueString, saturationString, brightnessString ]
            
            if ( match.numberOfRanges == 5 ) {
                let alphaString = stringFromRange( match.rangeAtIndex( 4 ), line: line )
                
                alphaValue = CGFloat ( ( alphaString as NSString).doubleValue )
                capturedStrings.append( alphaString )
            }
            
            
            let hueValue = CGFloat ( ( hueString as NSString).doubleValue )
            let saturationValue = CGFloat ( ( saturationString as NSString).doubleValue )
            let brightnessValue = CGFloat ( ( brightnessString as NSString).doubleValue )
            
            let hueColor = NSColor ( deviceHue: hueValue, saturation: saturationValue, brightness: brightnessValue, alpha: alphaValue )
            
            if let rgbColor = hueColor.colorUsingColorSpace( NSColorSpace.deviceRGBColorSpace() ) {
                // If not converted to RGB ColorSpace then the plugin would crash later on.
            
                var searchResult = SearchResult ( color: rgbColor, textCheckingResult: match, capturedStrings: capturedStrings )
                searchResult.creationType = .DefaultHSB
                
                return searchResult
            }
        }
        
        return nil
    }
}
