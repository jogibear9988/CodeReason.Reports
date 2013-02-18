using System.IO;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Media;
using System.Windows.Media.Imaging;

using iTextSharp.text; //from http://sourceforge.net/projects/itextsharp/
using iTextSharp.text.pdf;

using Microsoft.Win32;

namespace CodeReason.Reports.Export
{
    /// <summary>
    /// Export to PDF
    /// </summary>
    public static class ToPdfFile
    {
        /// <summary>
        /// It will show the SaveFileDialog to save the current report's content as a PDF file.
        /// </summary>
        /// <param name="doc">Retrieve it from xps.GetFixedDocumentSequence() or documentViewer.Document</param>
        /// <param name="pageSize">Example: PageSize.A4</param>
        /// <param name="quality">Resolution of the Images in the PDF </param>  
        public static void InteractiveExport(this FixedDocumentSequence doc, Rectangle pageSize, double quality = 1)
        {
            var dlg = new SaveFileDialog { DefaultExt = ".pdf", Filter = "PDF Files (.pdf)|*.pdf" };

            var result = dlg.ShowDialog();

            if (result != true) return;
            var filename = dlg.FileName;
            Export(doc, filename, pageSize, quality);
        }

        /// <summary>
        /// Saving the current report's content as a PDF file.
        /// </summary>
        /// <param name="doc">Retrieve it from xps.GetFixedDocumentSequence() or documentViewer.Document</param>
        /// <param name="fileNamePath"></param>
        /// <param name="pageSize">Example: PageSize.A4</param>
        /// <param name="quality">Resolution of the Images in the PDF </param>        
        public static void Export(this FixedDocumentSequence doc, string fileNamePath, Rectangle pageSize, double quality = 1)
        {
            var paginator = doc.DocumentPaginator;

            var pageCount = paginator.PageCount;
            if (pageCount == 0) return;

            //create a new pdf doc with the specified size
            var pdfDoc = new iTextSharp.text.Document(pageSize);
            PdfWriter.GetInstance(pdfDoc, new FileStream(fileNamePath, FileMode.Create));
            pdfDoc.Open();

            //render pages to images and then save theme as a pdf file.
            for (var i = 0; i < pageCount; i++)
            {
                var visual = paginator.GetPage(i).Visual;

                var fe = visual as FrameworkElement;
                if (fe == null) continue;

                var bmp = fe.RenderBitmap(quality);
                //var bmp = new RenderTargetBitmap((int)fe.ActualWidth, (int)fe.ActualHeight, dpiX, dpiY, PixelFormats.Default);
                bmp.Render(fe);

                var png = new PngBitmapEncoder();
                png.Frames.Add(BitmapFrame.Create(bmp));

                using (var ms = new MemoryStream())
                {
                    png.Save(ms);
                    //get image byte from stream
                    var imgBytes = ms.ToArray();
                    var pngImg = Image.GetInstance(imgBytes);
                    //fit to page
                    pngImg.ScaleAbsolute(pdfDoc.PageSize.Width, pdfDoc.PageSize.Height);
                    pngImg.SetAbsolutePosition(0, 0);
                    //add to page
                    pdfDoc.Add(pngImg);
                    //start a new page
                    pdfDoc.NewPage();
                }
            }

            pdfDoc.Close();
        }
    }
}
