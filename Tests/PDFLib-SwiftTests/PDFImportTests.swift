import XCTest
@testable import PDFLib_Swift

/// PDF import (PDI) and pCOS.
final class PDFImportTests: XCTestCase
{
    /// The C shims of CPDFLib are defined in a header, so they have to stay local to each
    /// object file. With external linkage an optimised build of an executable stops at the
    /// link ("duplicate symbol PDF_CHECK_TRY") as soon as two source files reach them, which
    /// the import functions do through pdf_try.
    func testShimsAreNotExportedSymbols() throws {
        #if canImport(Darwin)
        let here = UnsafeMutableRawPointer( bitPattern: -3 )    // RTLD_SELF
        XCTAssertNotNil( dlsym( here, "PDF_new" ), "the lookup itself does not work" )
        XCTAssertNil( dlsym( here, "PDF_CHECK_TRY" ) )
        XCTAssertNil( dlsym( here, "PDF_CHECK_CATCH" ) )
        #else
        throw XCTSkip( "needs the symbol lookup of a Darwin test bundle" )
        #endif
    }

    /// A PDF with `pages` empty A4 pages, written with PDFlib itself.
    func makePDF( pages: Int ) throws -> String {
        let path = NSTemporaryDirectory() + "pdflib-import-\(UUID().uuidString).pdf"
        addTeardownBlock { try? FileManager.default.removeItem( atPath: path ) }

        let pdf = PDF()
        try pdf.beginDocument( fileName: path )
        for _ in 0..<pages {
            pdf.beginPage( width: 595, height: 842 )
            pdf.endPage()
        }
        pdf.endDocument()
        return path
    }

    func testDocumentIsReadBackThroughPCOS() throws {
        let path = try makePDF( pages: 3 )

        let pdf = PDF()
        try pdf.beginDocument()
        let doc = try pdf.openPDIDocument( fileName: path )
        defer { pdf.closePDIDocument( doc ) }

        XCTAssertEqual( try pdf.pcosNumber( doc: doc, path: "length:pages" ), 3 )
        XCTAssertEqual( try pdf.pcosNumber( doc: doc, path: "pages[0]/width" ), 595 )
        XCTAssertEqual( try pdf.pcosNumber( doc: doc, path: "pages[2]/height" ), 842 )
        XCTAssertFalse( try pdf.pcosString( doc: doc, path: "pdfversionstring" ).isEmpty )
    }

    func testImportedPageIsPlaced() throws {
        let path = try makePDF( pages: 2 )

        let pdf = PDF()
        try pdf.beginDocument()
        let doc = try pdf.openPDIDocument( fileName: path )
        defer { pdf.closePDIDocument( doc ) }

        let page = try pdf.openPDIPage( doc: doc, page: 2 )
        XCTAssertEqual( try pdf.infoPDIPage( page, keyword: "width" ), 595 )

        pdf.beginPage( width: 10, height: 10 )
        try pdf.fitPDIPage( page )
        pdf.closePDIPage( page )
        pdf.endPage()
        pdf.endDocument()

        XCTAssertTrue( pdf.pdfData().starts( with: Array( "%PDF".utf8 ) ) )
    }

    /// A PDFlib exception has to come back as a Swift error with its message. PDFlib leaves
    /// the object that raised it unusable (its calls return nothing from then on), so the
    /// next document needs a new one.
    func testPDFlibExceptionComesBackAsError() throws {
        let path = try makePDF( pages: 1 )

        let pdf = PDF()
        try pdf.beginDocument()
        let doc = try pdf.openPDIDocument( fileName: path )

        XCTAssertThrowsError( try pdf.pcosNumber( doc: doc, path: "no/such/path[" ) )
        XCTAssertFalse( pdf.errorMessage().isEmpty )
        XCTAssertEqual( try pdf.pcosNumber( doc: doc, path: "length:pages" ), 0 )

        let next = PDF()
        try next.beginDocument()
        let again = try next.openPDIDocument( fileName: path )
        defer { next.closePDIDocument( again ) }
        XCTAssertEqual( try next.pcosNumber( doc: again, path: "length:pages" ), 1 )
    }

    func testMissingDocumentThrows() throws {
        let pdf = PDF()
        try pdf.beginDocument()

        XCTAssertThrowsError( try pdf.openPDIDocument( fileName: "/no/such/file.pdf" ) )
        XCTAssertFalse( pdf.errorMessage().isEmpty )
    }
}
