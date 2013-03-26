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
using System.Data;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;
using System.Windows.Xps.Packaging;
using CodeReason.Reports;

namespace SimpleReport
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

            /*using (var workspace = new ReportWorkspace(Environment.CurrentDirectory))
            {
                var reportDocument = workspace.LoadReport(@"Templates\SimpleReport.xaml");
                ReportData data = new ReportData();
                DataTable table = new DataTable("Ean");
                table.Columns.Add("Position", typeof(string));
                table.Columns.Add("Item", typeof(string));
                table.Columns.Add("EAN", typeof(string));
                table.Columns.Add("Count", typeof(int));
                Random rnd = new Random(1234);
                for (int i = 1; i <= 500; i++)
                {
                    table.Rows.Add(new object[] { i, "Item " + i.ToString("0000"), "123456790123", rnd.Next(9) + 1 });
                }
                data.DataTables.Add(table);
                //the flowDocument no fill table data?
                var flowDocument = reportDocument.createFlowDocument();
            }*/


            if (!_firstActivated) return;

            _firstActivated = false;

            Task.Factory.StartNew(() =>
                {
                    try
                    {
                        //Thread.CurrentThread.SetApartmentState(ApartmentState.STA);

                        using (var workspace = new ReportWorkspace(Environment.CurrentDirectory))
                        {
                            //workspace.DocumentViewer = documentViewer;
                            var reportDocument = workspace.LoadReport(@"Templates\SimpleReport.xaml");

                            ReportData data = new ReportData();

                            // set constant document values
                            data.ReportDocumentValues.Add("PrintDate", DateTime.Now); // print date is now

                            // sample table "Ean"
                            DataTable table = new DataTable("Ean");
                            table.Columns.Add("Position", typeof(string));
                            table.Columns.Add("Item", typeof(string));
                            table.Columns.Add("EAN", typeof(string));
                            table.Columns.Add("Count", typeof(int));
                            Random rnd = new Random(1234);
                            for (int i = 1; i <= 1500; i++)
                            {
                                // randomly create some items
                                table.Rows.Add(new object[] { i, "Item " + i.ToString("0000"), "123456790123", rnd.Next(9) + 1 });
                            }
                            data.DataTables.Add(table);

                            DateTime dateTimeStart = DateTime.Now; // start time measure here

                            Dispatcher.Invoke(new Action(() => documentViewer.Document = reportDocument.CreateFlowDocument(data)));
                            
                        
                            /*XpsDocument xps = reportDocument.CreateXpsDocument(data, (page, pagecount) => { Dispatcher.Invoke(new Action(() => busyDecorator.BusyContent = "Rendering Page " + page.ToString() + " of " + pagecount.ToString())); });
                            Dispatcher.Invoke(new Action(() => documentViewer.Document = xps.GetFixedDocumentSequence()));

                            // show the elapsed time in window title
                            Dispatcher.Invoke(new Action(() => Title += " - generated in " + (DateTime.Now - dateTimeStart).TotalMilliseconds + "ms"));*/
                        
                        }
                    }
                    catch (Exception ex)
                    {
                        // show exception
                        MessageBox.Show(ex.Message + "\r\n\r\n" + ex.GetType() + "\r\n" + ex.StackTrace, ex.GetType().ToString(), MessageBoxButton.OK, MessageBoxImage.Stop);
                    }
                    finally
                    {
                        Dispatcher.Invoke(new Action(() => busyDecorator.IsBusy = false));
                    }
                });
        }
    }
}
