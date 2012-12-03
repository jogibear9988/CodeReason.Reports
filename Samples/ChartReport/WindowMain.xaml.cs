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
using System.Windows;
using System.Windows.Threading;
using System.Windows.Xps.Packaging;
using CodeReason.Reports;

namespace ChartReport
{
    /// <summary>
    /// Application's main window
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

                    StreamReader reader = new StreamReader(new FileStream(@"Templates\ChartReport.xaml", FileMode.Open, FileAccess.Read));
                    reportDocument.XamlData = reader.ReadToEnd();
                    reportDocument.XamlImagePath = Path.Combine(Environment.CurrentDirectory, @"Templates\");
                    reader.Close();

                    ReportData data = new ReportData();

                    // set constant document values
                    data.ReportDocumentValues.Add("PrintDate", DateTime.Now); // print date is now

                    // sample table "Example1"
                    DataTable table = new DataTable("Example1");
                    table.Columns.Add("Year", typeof(string));
                    table.Columns.Add("Value", typeof(decimal));
                    Random rnd = new Random(1234);
                    for (int i = 1990; i <= 2009; i++)
                    {
                        // randomly create some values
                        table.Rows.Add(new object[] { i, rnd.Next(100000) + 10000 });
                    }
                    data.DataTables.Add(table);

                    // sample table "Example2"
                    table = new DataTable("Example2");
                    table.Columns.Add("Year", typeof(string));
                    table.Columns.Add("Value", typeof(decimal));
                    int citizens = rnd.Next(100000);
                    for (int i = 1990; i <= 2009; i++)
                    {
                        // randomly create some values
                        table.Rows.Add(new object[] { i, citizens });
                        citizens += rnd.Next(10000);
                    }
                    data.DataTables.Add(table);

                    // sample table "Example3"
                    table = new DataTable("Example3");
                    table.Columns.Add("Opinion", typeof(string));
                    table.Columns.Add("Percent", typeof(decimal));
                    table.Rows.Add(new object[] { "Yes", 36.2 });
                    table.Rows.Add(new object[] { "No", 21.5 });
                    table.Rows.Add(new object[] { "Unsure", 100 - 36.2 - 21.5 });
                    data.DataTables.Add(table);

                    DateTime dateTimeStart = DateTime.Now; // start time measure here

                    XpsDocument xps = reportDocument.CreateXpsDocument(data);

                    // concat XPS files
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
    }
}
