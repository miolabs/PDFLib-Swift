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

/* pCOS entry points are C variadic (printf-style path); Swift cannot call those, so
   pass the path through "%s". */
static inline double
PDF_PCOS_NUMBER(PDF *p, int doc, const char *path) {
    return PDF_pcos_get_number(p, doc, "%s", path);
}

static inline const char *
PDF_PCOS_STRING(PDF *p, int doc, const char *path) {
    return PDF_pcos_get_string(p, doc, "%s", path);
}
    
    
    

#endif /* shim.h */
