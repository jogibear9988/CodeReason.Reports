using System.IO;
using System.Windows.Documents;
using System.Windows.Xps.Packaging;
using Microsoft.Win32;

namespace CodeReasonRptsExport
{
    /// <summary>
    /// Export to XSP
    /// </summary>
    public static class ToXpsFile
    {
        /// <summary>
        /// It will show the SaveFileDialog to save the current report's content as an XPS file.
        /// </summary>
        /// <param name="doc">Retrieve it from xps.GetFixedDocumentSequence() or documentViewer.Document</param>
        public static void InteractiveExport(this FixedDocumentSequence doc)
        {            
            var dlg = new SaveFileDialog
                                     {
                                         DefaultExt = ".xps", 
                                         Filter = "XPS Documents (.xps)|*.xps"
                                     };

            var result = dlg.ShowDialog();

            if (result != true) return;
            var filename = dlg.FileName;
            Export(doc, filename);
        }

        /// <summary>
        /// Saving the current report's content as an XPS file.
        /// </summary>
        /// <param name="doc">Retrieve it from xps.GetFixedDocumentSequence() or documentViewer.Document</param>
        /// <param name="fileName"></param>
        public static void Export(this FixedDocumentSequence doc, string fileName)
        {
            using (var xpsd = new XpsDocument(fileName, FileAccess.ReadWrite))
            {
                //it needs a ref. to System.Printing asm.
                var xw = XpsDocument.CreateXpsDocumentWriter(xpsd); 
                xw.Write(doc);
            }
        }
    }
}
