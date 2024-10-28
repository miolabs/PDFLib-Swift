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
        data.withUnsafeBytes { buffer in
            PDF_create_pvf( pdf, filename.cString(using: .utf8), 0, buffer, data.count, "")
        }
    }
    
    public func deletePVF( filename:String ) {
        PDF_delete_pvf( pdf, filename.cString(using: .utf8), 0 )
    }

}
