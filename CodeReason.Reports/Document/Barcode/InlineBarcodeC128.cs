/************************************************************************
 * Copyright: Hans Wolff
 *
 * License:  This software abides by the LGPL license terms. For further
 *           licensing information please see the top level LICENSE.txt 
 *           file found in the root directory of CodeReason Reports.
 *
 * Author:   Hans Wolff
 *
 ************************************************************************/

using CodeReason.Reports.Barcode;
using CodeReason.Reports.Interfaces;
using System.Windows;

namespace CodeReason.Reports.Document.Barcode
{
    /// <summary>
    /// Inline barcode C128
    /// </summary>
    public class InlineBarcodeC128 : BarcodeC128, IInlineDocumentValue
    {
    }
}
