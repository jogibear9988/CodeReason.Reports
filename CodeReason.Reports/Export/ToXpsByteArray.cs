using System.IO;
using System.IO.Packaging;
using System.Windows.Documents;
using System.Windows.Xps.Packaging;
using System.Windows.Xps.Serialization;

namespace CodeReasonRptsExport
{
    /// <summary>
    /// Export to ByteArray
    /// </summary>
    public static class ToXpsByteArray
    {
        /// <summary>
        /// Converting the current report's content to a ByteArray.
        /// It's suitable for storing the XPS content of the rpt in a database.
        /// </summary>
        /// <param name="doc">Retrieve it from xps.GetFixedDocumentSequence() or documentViewer.Document</param>
        /// <returns></returns>
        public static byte[] Export(this FixedDocumentSequence doc)
        {
            using (var ms = new MemoryStream())
            {
                using (var package = Package.Open(ms, FileMode.CreateNew))
                {
                    using (var xpsd = new XpsDocument(package, CompressionOption.Maximum))
                    {
                        var xpsSm = new XpsSerializationManager(new XpsPackagingPolicy(xpsd), false);
                        xpsSm.SaveAsXaml(doc.DocumentPaginator);
                        xpsSm.Commit();
                        return ms.ToArray();
                    }
                }
            }
        }
    }
}
