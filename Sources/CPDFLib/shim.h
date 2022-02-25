//
//  shim.h
//  PDFLib-Swift
//
//  Created by Javier Segura Perez on 27/1/22.
//

#ifndef CLIB_SWIFT_PDF
#define CLIB_SWIFT_PDF

#include <pdflib.h>
#include <stdbool.h>

typedef void (BLOCK) (void);

bool
PDF_CHECK_TRY(PDF *p) {
    return p && (setjmp(pdf_jbuf(p)->jbuf) == 0);
}

bool
PDF_CHECK_CATCH(PDF *p) {
    return p && pdf_catch(p);
}
    
    
    

#endif /* shim.h */
