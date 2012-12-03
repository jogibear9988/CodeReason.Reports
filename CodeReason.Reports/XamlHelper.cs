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
using System.Windows.Documents;
using System.Windows.Markup;
using System.Xml;
using System.Windows.Media.Imaging;
using System.Windows.Media;

namespace CodeReason.Reports
{
    /// <summary>
    /// Helper class for XAML
    /// </summary>
    public static class XamlHelper
    {
        /// <summary>
        /// Loads a XAML object from string
        /// </summary>
        /// <param name="s">string containing the XAML object</param>
        /// <returns>XAML object or null, if string was empty</returns>
        public static object LoadXamlFromString(string s)
        {
            if (String.IsNullOrEmpty(s)) return null;
            StringReader stringReader = new StringReader(s);
            XmlReader xmlReader = XmlTextReader.Create(stringReader, new XmlReaderSettings());
            return XamlReader.Load(xmlReader);
        }

        /// <summary>
        /// Clones a table row
        /// </summary>
        /// <param name="orig">original table row</param>
        /// <returns>cloned table row</returns>
        public static TableRow CloneTableRow(TableRow orig)
        {
            if (orig == null) return null;
            string s = XamlWriter.Save(orig);
            return (TableRow)LoadXamlFromString(s);
        }

        /// <summary>
        /// Clones a complete block
        /// </summary>
        /// <param name="orig">orininal block</param>
        /// <returns>cloned block</returns>
        public static Block CloneBlock(Block orig)
        {
            if (orig == null) return null;
            string s = XamlWriter.Save(orig);
            return (Block)LoadXamlFromString(s);
        }

        /// <summary>
        /// Clones a complete UIElement
        /// </summary>
        /// <param name="orig">original UIElement</param>
        /// <returns>cloned UIElement</returns>
        public static UIElement CloneUIElement(UIElement orig)
        {
            if (orig == null) return null;
            string s = XamlWriter.Save(orig);
            return (UIElement)LoadXamlFromString(s);
        }

        /// <summary>
        /// Saves a visual to bitmap into stream
        /// </summary>
        /// <param name="visual">visual</param>
        /// <param name="stream">stream</param>
        /// <param name="width">width</param>
        /// <param name="height">height</param>
        /// <param name="dpiX">X DPI resolution</param>
        /// <param name="dpiY">Y DPI resolution</param>
        public static void SaveImageBmp(Visual visual, Stream stream, int width, int height, double dpiX, double dpiY)
        {
            RenderTargetBitmap bitmap = new RenderTargetBitmap((int)(width * dpiX / 96d), (int)(height * dpiY / 96d), dpiX, dpiY, PixelFormats.Pbgra32);
            bitmap.Render(visual);

            BmpBitmapEncoder image = new BmpBitmapEncoder();
            image.Frames.Add(BitmapFrame.Create(bitmap));
            image.Save(stream);
        }

        /// <summary>
        /// Saves a visual to PNG into stream
        /// </summary>
        /// <param name="visual">visual</param>
        /// <param name="stream">stream</param>
        /// <param name="width">width</param>
        /// <param name="height">height</param>
        /// <param name="dpiX">X DPI resolution</param>
        /// <param name="dpiY">Y DPI resolution</param>
        public static void SaveImagePng(Visual visual, Stream stream, int width, int height, double dpiX, double dpiY)
        {
            RenderTargetBitmap bitmap = new RenderTargetBitmap((int)(width * dpiX / 96d), (int)(height * dpiY / 96d), dpiX, dpiY, PixelFormats.Pbgra32);
            bitmap.Render(visual);

            PngBitmapEncoder image = new PngBitmapEncoder();
            image.Frames.Add(BitmapFrame.Create(bitmap));
            image.Save(stream);
        }
    }
}
