# PDFLib-Swift

A description of this package.
# PDFLib-Swift


cp include/pdflib.h /usr/local/include
cp lib/libpdf.a /usr/local/lib 
cp pdflib.pc /usr/local/lib/pkgconfig 

# to remove large git files from the repo
git filter-branch -f --index-filter 'git rm --cached --ignore-unmatch fixtures/11_user_answer.json'
