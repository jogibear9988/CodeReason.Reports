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
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Windows;
using System.Windows.Media.Imaging;
using System.Windows.Media;
using System.Windows.Shapes;
using Zen.Barcode;
using Image = System.Windows.Controls.Image;

namespace CodeReason.Reports.Barcode
{
    /// <summary>
    /// Creates a barcode QR as a Canvas
    /// </summary>
    public class BarcodeZenFramework : BarcodeBase
    {
        public enum BarcodeSymbologyZen
        {
            Unknown,
            Code39NC,
            Code39C,
            Code93,
            Code128,
            Code11NC,
            Code11C,
            CodeEan13,
            CodeEan8,
            Code25StandardNC,
            Code25StandardC,
            Code25InterleavedNC,
            Code25InterleavedC,
            CodePdf417,
            CodeQr,
        }

        public BarcodeSymbologyZen BarcodeSymbology { get; set; }
      
        /// <summary>
        /// Static constructor
        /// </summary>
        static BarcodeZenFramework()
        { }

        /// <summary>
        /// Constructor
        /// </summary>
        public BarcodeZenFramework()
        {
            RedrawAll();
        }
               
        /// <summary>
        /// Redraws the whole barcode
        /// </summary>
        public override void RedrawAll()
        {
            Children.Clear();

           
            if (Value != null)
            {
                var DrawObject = BarcodeDrawFactory.GetSymbology((BarcodeSymbology)(int)BarcodeSymbology);
                var img = DrawObject.Draw(Value.ToString(), 30);
                var bmpImage = ImageToBitmapImage(new Bitmap(img));

                var BarcodeImage = new Image();
                BarcodeImage.Stretch = Stretch.UniformToFill;
                BarcodeImage.Source = bmpImage;
                BarcodeImage.Width = this.Width;
                BarcodeImage.Height = this.Height;
                Children.Add(BarcodeImage);
            }  
        }

        private BitmapImage ImageToBitmapImage(System.Drawing.Bitmap image)
        {
            MemoryStream ms = new MemoryStream();
            image.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
            ms.Position = 0;
            BitmapImage bi = new BitmapImage();
            bi.BeginInit();
            bi.StreamSource = ms;
            bi.EndInit();
            return bi;
        }
    }
}
