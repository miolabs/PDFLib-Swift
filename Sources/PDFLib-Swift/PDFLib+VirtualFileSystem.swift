//
//  PDFLib+VirtualFileSystem.swift
//  PDFLib-Swift
//
//  Created by Javier Segura Perez on 2/10/24.
//
import Foundation
import CPDFLib

extension PDF
{
    public func createPVF( filename:String, data:Data ) {
        var bytes = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &bytes, count: data.count)
        
        PDF_create_pvf( pdf, filename.cString(using: .utf8), 0, &bytes, bytes.count, "")
    }
    
    public func deletePVF( filename:String ) {
        PDF_delete_pvf( pdf, filename.cString(using: .utf8), 0 )
    }

}
