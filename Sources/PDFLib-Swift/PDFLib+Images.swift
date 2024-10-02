//
//  PDFLib+Images.swift
//  PDFLib-Swift
//
//  Created by Javier Segura Perez on 2/10/24.
//
import Foundation
import CPDFLib

extension PDF
{
    public func loadImage(imageType:String = "auto", fileName:String, len:Int32 = 0, options:String = "") throws -> Int32
    {
        let image:Int32 = PDF_load_image(pdf, imageType.cString(using: .utf8), fileName.cString(using: .utf8), len, options.cString(using: .utf8))
        
        if image == -1 { throw PDFError.error(pdf) }
        
        return image
    }
        
    public func fitImage( _ image:Int32, x:Double = 0, y: Double = 0, options:String = "") {
        PDF_fit_image(pdf, image, x, y, options.cString(using: .utf8))
    }
    
    public func closeImage( _ image:Int32) {
        PDF_close_image( pdf, image )
    }
}
