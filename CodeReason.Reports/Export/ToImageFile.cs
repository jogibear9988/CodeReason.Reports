using System.IO;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Media;
using System.Windows.Media.Imaging;

using Microsoft.Win32;

namespace CodeReason.Reports.Export
{
    /// <summary>
    /// Export to PNG
    /// </summary>
    public static class ToImageFile
    {
        /// <summary>
        /// It will show the SaveFileDialog to save the current report's content as PNG files.
        /// </summary>
        /// <param name="doc">Retrieve it from xps.GetFixedDocumentSequence() or documentViewer.Document</param>
        /// <param name="dpiX">The horizontal DPI of the bitmap</param>
        /// <param name="dpiY">The vertical DPI of the bitmap</param>
        public static void InteractiveExport(this FixedDocumentSequence doc, double dpiX = 96, double dpiY = 96)
        {
            var dlg = new SaveFileDialog { DefaultExt = ".png", Filter = "PNG Images (.png)|*.png" };

            var result = dlg.ShowDialog();

            if (result != true) return;
            var filename = dlg.FileName;
            Export(doc, filename, dpiX, dpiY);
        }

        /// <summary>
        /// Saving the current report's content as PNG files.
        /// </summary>
        /// <param name="doc">Retrieve it from xps.GetFixedDocumentSequence() or documentViewer.Document</param>
        /// <param name="fileNamePath"></param>
        /// <param name="dpiX">The horizontal DPI of the bitmap</param>
        /// <param name="dpiY">The vertical DPI of the bitmap</param>
        public static void Export(this FixedDocumentSequence doc, string fileNamePath, double dpiX = 96, double dpiY = 96)
        {
            var paginator = doc.DocumentPaginator;

            var pageCount = paginator.PageCount;
            if (pageCount == 0) return;

            var path = Path.GetDirectoryName(fileNamePath);
            var filename = Path.GetFileNameWithoutExtension(fileNamePath);

            var stringFormat = "00";
            if (pageCount.ToString().Length > 2)
            {
                stringFormat = stringFormat.PadRight(pageCount - 2, '0');
            }

            for (var i = 0; i < pageCount; i++)
            {
                var visual = paginator.GetPage(i).Visual;

                var fe = visual as FrameworkElement;
                if (fe == null) continue;

                var bmp = new RenderTargetBitmap((int)fe.ActualWidth, (int)fe.ActualHeight, dpiX, dpiY, PixelFormats.Default);

                bmp.Render(fe);

                var png = new PngBitmapEncoder();
                png.Frames.Add(BitmapFrame.Create(bmp));
                var pngFilePath = string.Format("{0}\\{1}-{2}.png", path, filename, (i + 1).ToString(stringFormat));
                using (Stream stream = File.Create(pngFilePath))
                {
                    png.Save(stream);
                }
            }
        }
    }
}
