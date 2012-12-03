/************************************************************************
 * Copyright: Pepe
 *
 * License:  This software abides by the LGPL license terms. For further
 *           licensing information please see the top level LICENSE.txt 
 *           file found in the root directory of CodeReason Reports.
 *
 * Authors:  Pepe
 *
 ************************************************************************/

using System;
using System.Data;
using System.IO;
using System.Windows;
using System.Windows.Threading;
using System.Windows.Xps.Packaging;
using CodeReason.Reports;

namespace DynamicReport
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
                    StreamReader reader = new StreamReader(new FileStream(@"Templates\DynamicReport.xaml", FileMode.Open, FileAccess.Read));
                    reportDocument.XamlData = reader.ReadToEnd();
                    reportDocument.XamlImagePath = Path.Combine(Environment.CurrentDirectory, @"Templates\");
                    reader.Close();

                    DataTable tableHeader;
                    DataTable tableData;
                    object[] obj;
                    ReportData data = new ReportData();

                    // REPORT 1 DATA
                    tableHeader = new DataTable("Header");
                    tableData = new DataTable("Data");

                    tableHeader.Columns.Add();
                    tableHeader.Rows.Add(new object[] { "Service" });
                    tableHeader.Rows.Add(new object[] { "Amount" });
                    tableHeader.Rows.Add(new object[] { "Price" });
                    tableData.Columns.Add();
                    tableData.Columns.Add();
                    tableData.Columns.Add();
                    obj = new object[3];
                    for (int i = 0; i < 15; i++)
                    {
                        obj[0] = String.Format("Service offered. Nº{0}", i);
                        obj[1] = i * 2;
                        obj[2] = String.Format("{0} €", i);
                        tableData.Rows.Add(obj);
                    }

                    data.DataTables.Add(tableData);
                    data.DataTables.Add(tableHeader);

                    // REPORT 2 DATA
                    tableHeader = new DataTable("Header2");
                    tableData = new DataTable("Data2");

                    tableHeader.Columns.Add();
                    tableHeader.Rows.Add(new object[] { "Service" });
                    tableHeader.Rows.Add(new object[] { "Amount" });
                    tableData.Columns.Add();
                    tableData.Columns.Add();
                    obj = new object[2];
                    for (int i = 0; i < 15; i++)
                    {

                        obj[0] = String.Format("Service offered. Nº{0}", i);
                        obj[1] = i;
                        tableData.Rows.Add(obj);
                    }

                    data.DataTables.Add(tableData);
                    data.DataTables.Add(tableHeader);

                    XpsDocument xps = reportDocument.CreateXpsDocument(data);
                    documentViewer.Document = xps.GetFixedDocumentSequence();
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
    }
}
