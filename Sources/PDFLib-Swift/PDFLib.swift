import Foundation
import CPDFLib


public enum PDFError : Error {
    case error(_ pdf:OpaquePointer!)
}

extension PDFError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .error(pdf): return "[PDFError] \(String(describing: PDF_get_errmsg(pdf)))"
        }
    }
}

open class PDF
{
    let pdf:OpaquePointer!
    let empty_string = "".cString(using: .utf8)
    
    public init() {
        pdf = PDF_new()
    }
    
    deinit {
        PDF_delete(pdf)
    }
    
    public func setInfo(key:String, value:String) {
        PDF_set_info(pdf, key.cString(using: .utf8), value.cString(using: .utf8))        
    }
    
    public func setOptions( _ options:String) {
        PDF_set_option( pdf, options.cString(using: .utf8) )
    }
    

    public func loadFont(name:String, len:Int32 = 0, encoding:String, options:String = "") throws -> Int32 {
        let font = PDF_load_font(pdf, name.cString(using: .utf8), len, encoding.cString(using: .utf8), options.cString(using: .utf8))
        
        if font == -1 { throw PDFError.error(pdf) }
        
        return font

    }
    
    public func beginDocument(fileName:String?) throws {
        
        if (PDF_begin_document( pdf, fileName != nil ? fileName!.cString(using: .utf8) : empty_string, 0, empty_string ) == -1) {
            throw PDFError.error(pdf)
        }
    }
    
    public func endDocument () {
        PDF_end_document( pdf, empty_string )
    }
    
    public func beginPage (width:Double = 0.0, height:Double = 0.0, options:String = "") {
        PDF_begin_page_ext( pdf, width, height, options.cString(using: .utf8) )
    }
    
    public func endPage (){
        PDF_end_page_ext(pdf, empty_string)
    }
    
    // Text
    
    public func fitTextLine (text:String, len:Int32 = 0, x:Double, y:Double, options:String) {
        PDF_fit_textline( pdf, text.cString(using: .utf8), len, x, y, options.cString(using: .utf8) )
    }
    
    public func addTextFlow(textFlow:Int32, text:String, len:Int32 = 0, options:String = "") throws -> Int32 {
        let tf = PDF_add_textflow(pdf, textFlow, text.cString(using: .utf8), len, options.cString(using: .utf8))
        if tf == -1 { throw PDFError.error(pdf) }
        return tf
    }
    
    // Draw primitives
    
    public func setColor (fstype:String, colorspace:String, c1:Double = 0.0, c2:Double = 0.0, c3: Double = 0.0, c4:Double = 0.0) {
        PDF_setcolor(pdf, fstype.cString(using: .utf8), colorspace.cString(using: .utf8), c1, c2, c3, c4)
    }
    
    public func rect (x:Double, y:Double, width:Double, height:Double) {
        PDF_rect(pdf, x, y, width, height)
    }
    
    public func fill () {
        PDF_fill(pdf)
    }
    
    public func arc ( x: Double, y: Double, radius: Double, alpha: Double, beta: Double ) {
        PDF_arc(pdf, x, y, radius, alpha, beta)
    }
    
    public func setLineWidth ( width: Double ) {
        PDF_setlinewidth(pdf, width)
    }
    
    public func moveTo(x:Double, y: Double) {
        PDF_moveto(pdf, x, y)
    }
    
    public func lineTo ( x: Double, y: Double ) {
        PDF_lineto(pdf, x, y)
    }
    
    public func stroke () {
        PDF_stroke(pdf)
    }
    
    // Images
    
    public func loadImage(imageType:String = "auto", fileName:String, len:Int32 = 0, options:String = "") throws -> Int32 {
        let image = PDF_load_image(pdf, imageType.cString(using: .utf8), fileName.cString(using: .utf8), len, options.cString(using: .utf8))
        
        if image == -1 { throw PDFError.error(pdf) }
        
        return image
        
    }
    
    public func fitImage(image:Int32, x:Double = 0, y: Double = 0, options:String = "") {
        PDF_fit_image(pdf, image, x, y, options.cString(using: .utf8))
    }
    
    public func closeImage(image:Int32) {
        PDF_close_image( pdf, image )
    }
    
    // Tables
    
    public func fitTable(table:Int32, llx:Double, lly:Double, urx:Double, ury:Double, options:String = "") throws -> String {
        guard let r = PDF_fit_table(pdf, table, llx, lly, urx, ury, options.cString(using: .utf8)) else {
            throw PDFError.error(pdf)
        }
        
        let result = String(cString: r)
        if result == "_error" { throw PDFError.error(pdf) }
        return result
    }
    
    public func addTableCell(table:Int32, column:Int32, row:Int32, text:String, len:Int32 = 0, options:String) throws -> Int32 {
        let result = PDF_add_table_cell(pdf, table, column, row, text.cString(using: .utf8), len, options.cString(using: .utf8))
        if result == -1 { throw PDFError.error(pdf) }
        return result
    }
    
    public func deleteTable (table:Int32, options:String = ""){
        PDF_delete_table(pdf, table, options)
    }
        
}