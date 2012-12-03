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
using System.IO.Packaging;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Markup;
using System.Windows.Media.Imaging;
using System.Windows.Xps.Packaging;
using System.Windows.Xps.Serialization;
using CodeReason.Reports.Document;

namespace CodeReason.Reports
{
    /// <summary>
    /// Contains a complete report template without data
    /// </summary>
    public class ReportDocument
    {
        private double _pageHeaderHeight;
        /// <summary>
        /// Gets or sets the page header height
        /// </summary>
        public double PageHeaderHeight
        {
            get { return _pageHeaderHeight; }
            set { _pageHeaderHeight = value; }
        }

        private double _pageFooterHeight;
        /// <summary>
        /// Gets or sets the page footer height
        /// </summary>
        public double PageFooterHeight
        {
            get { return _pageFooterHeight; }
            set { _pageFooterHeight = value; }
        }

        private double _pageHeight = double.NaN;
        /// <summary>
        /// Gets the original page height of the FlowDocument
        /// </summary>
        public double PageHeight
        {
            get { return _pageHeight; }
        }

        private double _pageWidth = double.NaN;
        /// <summary>
        /// Gets the original page width of the FlowDocument
        /// </summary>
        public double PageWidth
        {
            get { return _pageWidth; }
        }

        private string _reportName = "";
        /// <summary>
        /// Gets or sets the optional report name
        /// </summary>
        public string ReportName
        {
            get { return _reportName; }
            set { _reportName = value; }
        }

        private string _reportTitle = "";
        /// <summary>
        /// Gets or sets the optional report title
        /// </summary>
        public string ReportTitle
        {
            get { return _reportTitle; }
            set { _reportTitle = value; }
        }

        private string _xamlImagePath = "";
        /// <summary>
        /// XAML image path
        /// </summary>
        public string XamlImagePath
        {
            get { return _xamlImagePath; }
            set { _xamlImagePath = value; }
        }

        private string _xamlData = "";
        /// <summary>
        /// XAML report data
        /// </summary>
        public string XamlData
        {
            get { return _xamlData; }
            set { _xamlData = value; }
        }

        private CompressionOption _xpsCompressionOption = CompressionOption.NotCompressed;
        /// <summary>
        /// Gets or sets the compression option which is used to create XPS files
        /// </summary>
        public CompressionOption XpsCompressionOption
        {
            get { return _xpsCompressionOption; }
            set { _xpsCompressionOption = value; }
        }

        #region Events
        /// <summary>
        /// Event occurs after a data row is bound
        /// </summary>
        public event EventHandler<DataRowBoundEventArgs> DataRowBound = null;

        /// <summary>
        /// Event occurs after a page has been completed
        /// </summary>
        public event GetPageCompletedEventHandler GetPageCompleted = null;

        /// <summary>
        /// Event occurs if an exception has encountered while loading the BitmapSource
        /// </summary>
        public event EventHandler<ImageErrorEventArgs> ImageError = null;

        /// <summary>
        /// Event occurs before an image is being processed
        /// </summary>
        public event EventHandler<ImageEventArgs> ImageProcessing = null;

        /// <summary>
        /// Event occurs after an image has being processed
        /// </summary>
        public event EventHandler<ImageEventArgs> ImageProcessed = null;
        #endregion

        /// <summary>
        /// Fire event after a page has been completed
        /// </summary>
        /// <param name="ea">GetPageCompletedEventArgs</param>
        public void FireEventGetPageCompleted(GetPageCompletedEventArgs ea)
        {
            if (GetPageCompleted != null) GetPageCompleted(this, ea);
        }

        /// <summary>
        /// Fire event after a data row has been bound
        /// </summary>
        /// <param name="ea">DataRowBoundEventArgs</param>
        public void FireEventDataRowBoundEventArgs(DataRowBoundEventArgs ea)
        {
            if (DataRowBound != null) DataRowBound(this, ea);
        }

        /// <summary>
        /// Creates a flow document of the report data
        /// </summary>
        /// <returns></returns>
        /// <exception cref="ArgumentException">XAML data does not represent a FlowDocument</exception>
        /// <exception cref="ArgumentException">Flow document must have a specified page height</exception>
        /// <exception cref="ArgumentException">Flow document must have a specified page width</exception>
        /// <exception cref="ArgumentException">"Flow document must have only one ReportProperties section, but it has {0}"</exception>
        public FlowDocument CreateFlowDocument()
        {
            MemoryStream mem = new MemoryStream();
            byte[] buf = Encoding.UTF8.GetBytes(_xamlData);
            mem.Write(buf, 0, buf.Length);
            mem.Position = 0;
            FlowDocument res = XamlReader.Load(mem) as FlowDocument;
            if (res == null) throw new ArgumentException("XAML data does not represent a FlowDocument");

            if (res.PageHeight == double.NaN) throw new ArgumentException("Flow document must have a specified page height");
            if (res.PageWidth == double.NaN) throw new ArgumentException("Flow document must have a specified page width");

            // remember original values
            _pageHeight = res.PageHeight;
            _pageWidth = res.PageWidth;

            // search report properties
            DocumentWalker walker = new DocumentWalker();
            List<SectionReportHeader> headers = walker.Walk<SectionReportHeader>(res);
            List<SectionReportFooter> footers = walker.Walk<SectionReportFooter>(res);
            List<ReportProperties> properties = walker.Walk<ReportProperties>(res);
            if (properties.Count > 0)
            {
                if (properties.Count > 1) throw new ArgumentException(String.Format("Flow document must have only one ReportProperties section, but it has {0}", properties.Count));
                ReportProperties prop = properties[0];
                if (prop.ReportName != null) ReportName = prop.ReportName;
                if (prop.ReportTitle != null) ReportTitle = prop.ReportTitle;
                if (headers.Count > 0) PageHeaderHeight = headers[0].PageHeaderHeight;
                if (footers.Count > 0) PageFooterHeight = footers[0].PageFooterHeight;

                // remove properties section from FlowDocument
                DependencyObject parent = prop.Parent;
                if (parent is FlowDocument) { ((FlowDocument)parent).Blocks.Remove(prop); parent = null; }
                if (parent is Section) { ((Section)parent).Blocks.Remove(prop); }
            }

            // make height smaller to have enough space for page header and page footer
            res.PageHeight = _pageHeight - _pageHeight * (PageHeaderHeight + PageFooterHeight) / 100d;

            // search image objects
            List<Image> images = new List<Image>();
            walker.Tag = images;
            walker.VisualVisited += WalkerVisualVisited;
            walker.Walk(res);

            // load all images
            foreach (Image image in images)
            {
                if (ImageProcessing != null) ImageProcessing(this, new ImageEventArgs(this, image));
                try
                {
                    if (image.Tag is string)
                        image.Source = new BitmapImage(new Uri("file:///" + Path.Combine(_xamlImagePath, image.Tag.ToString())));
                }
                catch (Exception ex)
                {
                    // fire event on exception and check for Handled = true after each invoke
                    if (ImageError != null)
                    {
                        bool handled = false;
                        lock (ImageError)
                        {
                            ImageErrorEventArgs eventArgs = new ImageErrorEventArgs(ex, this, image);
                            foreach (var ed in ImageError.GetInvocationList())
                            {
                                ed.DynamicInvoke(this, eventArgs);
                                if (eventArgs.Handled) { handled = true; break; }
                            }
                        }
                        if (!handled) throw;
                    }
                    else throw;
                }
                if (ImageProcessed != null) ImageProcessed(this, new ImageEventArgs(this, image));
                // TODO: find a better way to specify file names
            }

            return res;
        }

        private void WalkerVisualVisited(object sender, object visitedObject, bool start)
        {
            if (!(visitedObject is Image)) return;

            DocumentWalker walker = sender as DocumentWalker;
            if (walker == null) return;

            List<Image> list = walker.Tag as List<Image>;
            if (list == null) return;

            list.Add((Image)visitedObject);
        }

        /// <summary>
        /// Helper method to create page header or footer from flow document template
        /// </summary>
        /// <param name="data">report data</param>
        /// <returns></returns>
        public XpsDocument CreateXpsDocument(ReportData data)
        {
            MemoryStream ms = new MemoryStream();
            Package pkg = Package.Open(ms, FileMode.Create, FileAccess.ReadWrite);
            string pack = "pack://report.xps";
            PackageStore.RemovePackage(new Uri(pack));
            PackageStore.AddPackage(new Uri(pack), pkg);
            XpsDocument doc = new XpsDocument(pkg, CompressionOption.NotCompressed, pack);
            XpsSerializationManager rsm = new XpsSerializationManager(new XpsPackagingPolicy(doc), false);

            ReportPaginator rp = new ReportPaginator(this, data);
            rsm.SaveAsXaml(rp);
            return doc;
        }

        /// <summary>
        /// Helper method to create page header or footer from flow document template
        /// </summary>
        /// <param name="data">enumerable report data</param>
        /// <returns></returns>
        /// <exception cref="ArgumentNullException">data</exception>
        public XpsDocument CreateXpsDocument(IEnumerable<ReportData> data)
        {
            if (data == null) throw new ArgumentNullException("data");
            int count = 0; ReportData firstData = null;
            foreach (ReportData rd in data) { if (firstData == null) firstData = rd; count++; }
            if (count == 1) return CreateXpsDocument(firstData); // we have only one ReportData object -> use the normal ReportPaginator instead

            MemoryStream ms = new MemoryStream();
            Package pkg = Package.Open(ms, FileMode.Create, FileAccess.ReadWrite);
            string pack = "pack://report.xps";
            PackageStore.RemovePackage(new Uri(pack));
            PackageStore.AddPackage(new Uri(pack), pkg);
            XpsDocument doc = new XpsDocument(pkg, CompressionOption.NotCompressed, pack);
            XpsSerializationManager rsm = new XpsSerializationManager(new XpsPackagingPolicy(doc), false);

            MultipleReportPaginator rp = new MultipleReportPaginator(this, data);
            rsm.SaveAsXaml(rp);
            return doc;
        }

        /// <summary>
        /// Helper method to create page header or footer from flow document template
        /// </summary>
        /// <param name="data">report data</param>
        /// <param name="fileName">file to save XPS to</param>
        /// <returns></returns>
        public XpsDocument CreateXpsDocument(ReportData data, string fileName)
        {
            Package pkg = Package.Open(fileName, FileMode.Create, FileAccess.ReadWrite);
            string pack = "pack://report.xps";
            PackageStore.RemovePackage(new Uri(pack));
            PackageStore.AddPackage(new Uri(pack), pkg);
            XpsDocument doc = new XpsDocument(pkg, _xpsCompressionOption, pack);
            XpsSerializationManager rsm = new XpsSerializationManager(new XpsPackagingPolicy(doc), false);

            ReportPaginator rp = new ReportPaginator(this, data);
            rsm.SaveAsXaml(rp);
            rsm.Commit();
            pkg.Close();
            return new XpsDocument(fileName, FileAccess.Read);
        }

        /// <summary>
        /// Helper method to create page header or footer from flow document template
        /// </summary>
        /// <param name="data">enumerable report data</param>
        /// <param name="fileName">file to save XPS to</param>
        /// <returns></returns>
        public XpsDocument CreateXpsDocument(IEnumerable<ReportData> data, string fileName)
        {
            if (data == null) throw new ArgumentNullException("data");
            int count = 0; ReportData firstData = null;
            foreach (ReportData rd in data) { if (firstData == null) firstData = rd; count++; }
            if (count == 1) return CreateXpsDocument(firstData); // we have only one ReportData object -> use the normal ReportPaginator instead

            Package pkg = Package.Open(fileName, FileMode.Create, FileAccess.ReadWrite);
            string pack = "pack://report.xps";
            PackageStore.RemovePackage(new Uri(pack));
            PackageStore.AddPackage(new Uri(pack), pkg);
            XpsDocument doc = new XpsDocument(pkg, _xpsCompressionOption, pack);
            XpsSerializationManager rsm = new XpsSerializationManager(new XpsPackagingPolicy(doc), false);

            MultipleReportPaginator rp = new MultipleReportPaginator(this, data);
            rsm.SaveAsXaml(rp);
            rsm.Commit();
            pkg.Close();
            return new XpsDocument(fileName, FileAccess.Read);
        }
    }
}
