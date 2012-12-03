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

using System;
using System.IO;
using System.Windows;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using System.Windows.Xps.Packaging;
using CodeReason.Reports;

namespace ImageReport
{
    /// <summary>
    /// Application's main form
    /// </summary>
    public partial class WindowMain : Window
    {
        private bool _firstActivated = true;

        /// <summary>
        /// Constructor
        /// </summary>
        public WindowMain()
        {
            InitializeComponent();
        }

        /// <summary>
        /// Window has been activated
        /// </summary>
        /// <param name="sender">sender</param>
        /// <param name="e">event details</param>
        private void Window_Activated(object sender, EventArgs e)
        {
            if (!_firstActivated) return;

            _firstActivated = false;

            Dispatcher.BeginInvoke(DispatcherPriority.ApplicationIdle, new Action(delegate
            {
                try
                {
                    ReportDocument reportDocument = new ReportDocument();
                    reportDocument.ImageProcessing += ReportDocumentImageProcessing;
                    reportDocument.ImageError += ReportDocumentImageError;

                    StreamReader reader = new StreamReader(new FileStream(@"Templates\ImageReport.xaml", FileMode.Open, FileAccess.Read));
                    reportDocument.XamlData = reader.ReadToEnd();
                    reportDocument.XamlImagePath = Path.Combine(Environment.CurrentDirectory, @"Templates\");
                    reader.Close();

                    ReportData data = new ReportData();

                    // set constant document values
                    data.ReportDocumentValues.Add("PrintDate", DateTime.Now); // print date is now

                    DateTime dateTimeStart = DateTime.Now; // start time measure here

                    XpsDocument xps = reportDocument.CreateXpsDocument(data);
                    documentViewer.Document = xps.GetFixedDocumentSequence();

                    // show the elapsed time in window title
                    Title += " - generated in " + (DateTime.Now - dateTimeStart).TotalMilliseconds + "ms";
                }
                catch (Exception ex)
                {
                    // show exception
                    MessageBox.Show(ex.Message + "\r\n\r\n" + ex.GetType() + "\r\n" + ex.StackTrace, ex.GetType().ToString(), MessageBoxButton.OK, MessageBoxImage.Stop);
                }
                finally
                {
                    busyDecorator.IsBusyIndicatorHidden = true;
                }
            }));
        }

        /// <summary>
        /// Event occurs for each image before it is processed
        /// </summary>
        /// <param name="sender">sender</param>
        /// <param name="e">image error event details</param>
        private void ReportDocumentImageError(object sender, ImageErrorEventArgs e)
        {
            e.Handled = true; // just suppress exceptions
        }

        /// <summary>
        /// Event occurs for each image before it is processed
        /// </summary>
        /// <param name="sender">sender</param>
        /// <param name="e">image event details</param>
        private void ReportDocumentImageProcessing(object sender, ImageEventArgs e)
        {
            System.Drawing.Bitmap bitmap = null;

            if (e.Image.Name == "imageDynamic1")
            {
                // create image dynamically
                bitmap = new System.Drawing.Bitmap(100, 100);
                for (int y = 0; y < bitmap.Height; y++)
                {
                    for (int x = 0; x < bitmap.Width; x++)
                    {
                        bitmap.SetPixel(x, y, System.Drawing.Color.FromArgb((byte)(x + y), (byte)(x + y), 0));
                    }
                }
            }

            if (e.Image.Name == "imageDynamic2")
            {
                // create image dynamically
                bitmap = new System.Drawing.Bitmap(100, 100);
                for (int y = 0; y < bitmap.Height; y++)
                {
                    for (int x = 0; x < bitmap.Width; x++)
                    {
                        bitmap.SetPixel(x, y, System.Drawing.Color.FromArgb((byte)(x), (byte)(y), 0));
                    }
                }
            }

            if (bitmap != null)
            {
                // save this image into a memory stream
                MemoryStream mem = new MemoryStream();
                bitmap.Save(mem, System.Drawing.Imaging.ImageFormat.Bmp);
                mem.Position = 0;

                // load new media image into report
                BitmapImage image = new BitmapImage();
                image.BeginInit();
                image.StreamSource = mem;
                image.EndInit();
                e.Image.Source = image;
            }
        }
    }
}
