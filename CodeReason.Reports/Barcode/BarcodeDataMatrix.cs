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
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using DataMatrix.net;

namespace CodeReason.Reports.Barcode
{
    /// <summary>
    /// Creates a barcode QR as a Canvas
    /// </summary>
    public class BarcodeDataMatrix : BarcodeBase
    {
      
        /// <summary>
        /// Static constructor
        /// </summary>
        static BarcodeDataMatrix()
        { }

        /// <summary>
        /// Constructor
        /// </summary>
        public BarcodeDataMatrix()
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
                DmtxImageEncoder encoder = new DmtxImageEncoder();
                var bmpImage = ImageToBitmapImage(encoder.EncodeImage(Value.ToString()));

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
