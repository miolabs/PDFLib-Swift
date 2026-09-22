//
//  PDFLib+Import.swift
//  PDFLib-Swift
//
//  PDF Import (PDI) and pCOS queries: open an existing PDF (file or PVF), ask it about
//  pages, encryption, fonts and images, and place its pages into the document being
//  generated. Needs a PDFlib+PDI or PPS licence (demo mode works with a stamp).
//

import Foundation
import CPDFLib


extension PDF
{
    // MARK: document handles

    /// Opens an existing PDF for import / pCOS queries. `filename` may be a PVF name.
    /// Typical options: "requiredmode=minimum", "errorpolicy=return", "password=...".
    /// Throws with PDFlib's message when the document cannot be opened (encrypted, damaged).
    public func openPDIDocument ( fileName: String, options: String = "errorpolicy=return" ) throws -> Int32 {
        var doc: Int32 = -1
        try pdf_try {
            doc = PDF_open_pdi_document( self.pdf, fileName.cString( using: .utf8 ), 0, options.cString( using: .utf8 ) )
        }
        if doc == -1 { throw PDFError.error( pdf ) }
        return doc
    }

    public func closePDIDocument ( _ doc: Int32 ) {
        PDF_close_pdi_document( pdf, doc )
    }

    // MARK: pCOS

    /// Numeric or boolean pCOS query, e.g. "length:pages", "length:pages[0]/fonts",
    /// "pages[0]/width", "pages[0]/Rotate", "encrypt/nocopy".
    public func pcosNumber ( doc: Int32, path: String ) throws -> Double {
        var value: Double = 0
        try pdf_try {
            value = PDF_PCOS_NUMBER( self.pdf, doc, path.cString( using: .utf8 ) )
        }
        return value
    }

    /// String pCOS query, e.g. "pdfversion", "encrypt/algorithm", "/Info/Producer", "type:pages[0]/fonts".
    public func pcosString ( doc: Int32, path: String ) throws -> String {
        var value = ""
        try pdf_try {
            if let c = PDF_PCOS_STRING( self.pdf, doc, path.cString( using: .utf8 ) ) {
                value = String( cString: c )
            }
        }
        return value
    }

    // MARK: pages

    /// Prepares a page of an imported document (1-based) for fitPDIPage.
    public func openPDIPage ( doc: Int32, page: Int32, options: String = "" ) throws -> Int32 {
        var handle: Int32 = -1
        try pdf_try {
            handle = PDF_open_pdi_page( self.pdf, doc, page, options.cString( using: .utf8 ) )
        }
        if handle == -1 { throw PDFError.error( pdf ) }
        return handle
    }

    public func closePDIPage ( _ page: Int32 ) {
        PDF_close_pdi_page( pdf, page )
    }

    /// Places an imported page on the current output page. "adjustpage" resizes the output
    /// page to the imported one; a negative offset with a smaller page clips to a region.
    public func fitPDIPage ( _ page: Int32, x: Double = 0, y: Double = 0, options: String = "adjustpage" ) throws {
        try pdf_try {
            PDF_fit_pdi_page( self.pdf, page, x, y, options.cString( using: .utf8 ) )
        }
    }

    /// Page property of an imported page: "width", "height", "rotate", "pagenumber", ...
    public func infoPDIPage ( _ page: Int32, keyword: String, options: String = "" ) throws -> Double {
        var value: Double = 0
        try pdf_try {
            value = PDF_info_pdi_page( self.pdf, page, keyword.cString( using: .utf8 ), options.cString( using: .utf8 ) )
        }
        return value
    }

    // MARK: errors

    /// Message of the last failed call (e.g. why openPDIDocument returned -1).
    public func errorMessage ( ) -> String {
        return String( cString: PDF_get_errmsg( pdf ) )
    }

    public func errorNumber ( ) -> Int32 {
        return PDF_get_errnum( pdf )
    }
}
