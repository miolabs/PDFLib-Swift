import XCTest
@testable import PDFLib_Swift

final class PDFLib_SwiftTests: XCTestCase {
        
    var searchPath:String { get {
        let testBundle = Bundle(for: type(of: self))
        let searchPath = testBundle.bundlePath.appending("/Contents/Resources/PDFLib-Swift_PDFLib-SwiftTests.bundle/Contents/Resources/Resources/")
        return searchPath
    }}
    var imagefile:String { get { return "nesrin.jpg" } }

    
    func testStarterBasic() throws {
                        
        print("Executing at: \(FileManager().currentDirectoryPath)")
        
        let pdf = PDF()
                
//        pdf.setOptions("SearchPath={{\(searchPath)}}")
        pdf.setParameter(key: "SearchPath", value: searchPath)
        
        try pdf.beginDocument( fileName: "starter_basic.pdf" )
        
        pdf.setInfo( key: "Creator", value: "PDFlib starter sample" )
        pdf.setInfo( key: "Title",  value: "starter_basic" )

        /* We load the image before the first page, and use it
         * on all pages
         */

        let image = try pdf.loadImage(fileName: imagefile)
        
        /* Page 1 */
        pdf.beginPage(options: "width=a4.width height=a4.height")
        
        var opts = "fontname={NotoSerif-Regular} encoding=unicode embedding fontsize=24 textformat=utf8"
        
        /* using plain ASCII text */
        try pdf.fitTextLine(text: "en: Hello!", x: 50, y: 700, options: opts)
        
        /* using PDFlib's character references */
        opts = "fontname={NotoSerif-Regular} encoding=unicode embedding fontsize=24 textformat=utf8 charref=true"
        try pdf.fitTextLine(text: "es: &#xA1;Hola!", x: 50, y: 550, options: opts)
        
        pdf.fitImage(image: image, options: "scale=0.25")
        
        pdf.endPage()
        
        /* Page 2 */
        pdf.beginPage( options: "width=a4.width height=a4.height" )

        /* red rectangle */
        pdf.setColor(fstype: "fill", colorspace: "rgb", c1: 1.0)
        pdf.rect(x: 200, y: 200, width: 250, height: 150)
        pdf.fill()

        /* blue circle */
        pdf.setColor(fstype: "fill", colorspace: "rgb", c3: 1.0)
        pdf.arc( x: 400, y: 600, radius: 100, alpha: 0, beta: 360 )
        pdf.fill()

        /* thick gray line */
        pdf.setColor(fstype: "stroke", colorspace: "gray", c1: 0.5)
        pdf.setLineWidth(width: 10)
        pdf.moveTo(x: 100, y: 500)
        pdf.lineTo(x: 300, y: 700)
        pdf.stroke()
        
        /* Using the same image handle means the data will be copied
         * to the PDF only once, which saves space.
         */
        pdf.fitImage( image: image, x: 150, y: 25, options:"scale=0.25" )
        
        pdf.endPage()

        /* Page 3 */
        pdf.beginPage(options: "width=a4.width height=a4.height")

        /* Fit the image to a box of predefined size (without distortion) */
        pdf.fitImage( image: image, x: 100, y: 200, options: "boxsize={400 400} position={center} fitmethod=meet" )

        pdf.endPage()

        pdf.closeImage(image: image)
        
        pdf.endDocument()

    }
    
    func testStarterTable() throws {
        print("Executing at: \(FileManager().currentDirectoryPath)")
        
        let pdf = PDF()
                
//        pdf.setOptions( "SearchPath={{\(searchPath)}}" )
        pdf.setParameter(key: "SearchPath", value: searchPath)
        
        try pdf.beginDocument( fileName: "starter_table.pdf" )
        
        pdf.setInfo( key: "Creator", value: "PDFlib starter sample" )
        pdf.setInfo( key: "Title",  value: "starter_table" )
        
        /* -------------------- Add table cells -------------------- */

        /* ---------- Row 1: table header (spans all columns) */
        var row:Int32 = 1
        var col:Int32 = 1
        var tbl:Int32 = -1
        let headertext = "Table header (centered across all columns)"
        let rowmax:Int32 = 50
        let colmax:Int32 = 5
        
        let font = try pdf.loadFont(name: "NotoSerif-Regular", encoding: "winansi")
         
        var opts = "fittextline={position=center font=\(font) fontsize=14} colspan=\(colmax)"
        tbl = try pdf.addTableCell(table: tbl, column: col, row: row, text: headertext, options: opts)

        /* ---------- Row 2: various kinds of content */
        /* ----- Simple text cell */
        row += 1
        col = 1

        opts = "fittextline={font=\(font) fontsize=10 orientate=west}"
        tbl = try pdf.addTableCell(table: tbl, column: col, row: row, text: "vertical line", options: opts)
        
        /* ----- Colorized background */
        col += 1

        opts = "fittextline={font=\(font) fontsize=10} matchbox={fillcolor={rgb 0.9 0.5 0}}"
        tbl = try pdf.addTableCell(table: tbl, column: col, row: row, text: "some color", options: opts)
        
        /* ----- Multi-line text with Textflow */
        col += 1
                
        var tf:Int32 = -1
        let tf_text = """
            Lorem ipsum dolor sit amet, consectetur adi&shy;pi&shy;sicing elit,
            sed do eius&shy;mod tempor incidi&shy;dunt ut labore et dolore magna
            ali&shy;qua. Ut enim ad minim ve&shy;niam, quis nostrud exer&shy;citation
            ull&shy;amco la&shy;bo&shy;ris nisi ut ali&shy;quip ex ea commodo
            con&shy;sequat.
            Duis aute irure dolor in repre&shy;henderit in voluptate velit esse
            cillum dolore
            eu fugiat nulla pari&shy;atur. Excep&shy;teur sint occae&shy;cat
            cupi&shy;datat
            non proident, sunt in culpa qui officia dese&shy;runt mollit anim id est
            laborum.
            """

        
        opts = "charref fontname=NotoSerif-Regular encoding=winansi fontsize=8"
        tf = try pdf.addTextFlow(textFlow: tf, text: tf_text, options: opts)
        
        opts = "margin=2 textflow=\(tf)"
        tbl = try pdf.addTableCell( table: tbl, column: col, row: row, text: "", options: opts )
        
        /* ----- Rotated image */
        col += 1

        let image = try pdf.loadImage(fileName: imagefile)

        opts = "image=\(image) fitimage={orientate=west}"
        tbl = try pdf.addTableCell(table: tbl, column: col, row: row, text: "", options: opts)

        /* ----- Diagonal stamp */
        col += 1
        
        opts = "fittextline={font=\(font) fontsize=10 stamp=ll2ur}"
        tbl = try pdf.addTableCell(table: tbl, column: col, row: row, text: "entry void", options: opts)
        
        /* ---------- Fill row 3 and above with their numbers */
        for _ in row..<rowmax {
            row += 1
            for _ in 1..<colmax {
                opts = "colwidth=20% fittextline={font=\(font) fontsize=10}"
                tbl = try pdf.addTableCell(table: tbl, column: col, row: row, text: "Col \(col)/Row \(row)", options: opts)
                col += 1
            }
        }
        
        /* ---------- Place the table on one or more pages ---------- */

        /*
         * Loop until all of the table is placed; create new pages
         * as long as more table instances need to be placed.
         */
        let llx:Double = 50
        let lly:Double = 50
        let urx:Double = 550
        let ury:Double = 800
        var result:String = ""
        
//        while result != "_boxfull" {
        while result != "_stop" {

            pdf.beginPage(options: "width=a4.width height=a4.height")

            /* Shade every other row; draw lines for all table cells.
             * Add "showcells showborder" to visualize cell borders.
             */
            opts = "header=1 rowheightdefault=auto fill={{area=rowodd fillcolor={gray 0.9}}} stroke={{line=other}}"
            
            /* Place the table instance */
            result = try pdf.fitTable(table: tbl, llx: llx, lly: lly, urx: urx, ury: ury, options: opts)            

            pdf.endPage()
        }
        
        /* Check the result; "_stop" means all is ok. */
//        if (strcmp(result, "_stop"))
//        {
//            if (!strcmp(result, "_error"))
//            {
//                printf("Error when placing table: %s\n", PDF_get_errmsg(p));
//                PDF_delete(p);
//                return(2);
//            }
//            else
//            {
//                /* Any other return value is a user exit caused by
//                 * the "return" option; this requires dedicated code to
//                 * deal with.
//                 */
//                printf("User return found in Table\n");
//                PDF_delete(p);
//                return(2);
//            }
//        }
        
        /* This will also delete Textflow handles used in the table */
        pdf.deleteTable(table: tbl)

        pdf.endDocument()
    }
    
    func testFontMetrics() throws {
 
        print("Executing at: \(FileManager().currentDirectoryPath)")
        
        let pdf = PDF()
                
//        pdf.setOptions( "SearchPath={{\(searchPath)}}" )
        pdf.setParameter(key: "SearchPath", value: searchPath)
        
        try pdf.beginDocument( fileName: "font_metrics_info.pdf" )
        
        pdf.setInfo( key: "Creator", value: "PDFlib Cookbook" )
        pdf.setInfo( key: "Title",  value: "Font Metrics Info" )
        
        /* Start page */
        pdf.beginPage(options: "width=300 height=200")
        let font = try pdf.loadFont(name: "NotoSerif-Regular", encoding: "winansi", options: "embedding")

        
        /* Retrieve the font metrics for a font size of 10. If no fontsize
         * is supplied the metrics will be based on a font size of 1000.
         */
        let capheight  = pdf.infoFont( font, keyword: "capheight", options: "fontsize=10" )
        let ascender   = pdf.infoFont( font, keyword: "ascender", options: "fontsize=10" )
        let descender  = pdf.infoFont( font, keyword: "descender", options: "fontsize=10" )
        let xheight    = pdf.infoFont( font, keyword: "xheight", options: "fontsize=10" )

        pdf.setFont(font, size: 10)
        
        let text = "ABCdefghij"
        let x:Double = 150
        var y:Double = 140
        
        try pdf.fitTextLine(text: "capheight for font size 10: " + String(format: "%.2f", capheight), x: x, y: y, options: "alignchar :")
                             
        var optlist = "matchbox={fillcolor={rgb 1 0.8 0.8} boxheight={capheight none}}"
        try pdf.fitTextLine( text: text, x: x + 60, y: y, options: optlist)

        y -= 30
        try pdf.fitTextLine( text: "ascender for font size 10: " + String( format: "%.2f", ascender), x: x, y: y, options: "alignchar :")
               
        optlist = "matchbox={fillcolor={rgb 1 0.8 0.8} boxheight={ascender none}}"
        try pdf.fitTextLine( text: text, x: x + 60, y: y, options: optlist)

        y -= 30
        try pdf.fitTextLine( text: "descender for font size 10: " + String( format:"%.2f", descender), x: x, y: y, options: "alignchar :")
        
        optlist = "matchbox={fillcolor={rgb 1 0.8 0.8} boxheight={none descender}}"
        try pdf.fitTextLine( text: text, x: x + 60, y: y, options: optlist)

        y -= 30
        try pdf.fitTextLine( text: "xheight for font size 10: " + String( format: "%.1f", xheight), x: x, y: y, options: "alignchar :")
        
        optlist = "matchbox={fillcolor={rgb 1 0.8 0.8} boxheight={xheight none}}"
        try pdf.fitTextLine( text: text, x: x + 60, y: y, options: optlist)

        y -= 30
        let width = pdf.stringWidth(text, font: font, size: 10)
        try pdf.fitTextLine( text: "width for font size 10: " + String( format: "%.1f", width), x: x, y: y, options: "alignchar :")

        
        /* Finish page */
        pdf.endPage()
        pdf.endDocument()
    }
}
