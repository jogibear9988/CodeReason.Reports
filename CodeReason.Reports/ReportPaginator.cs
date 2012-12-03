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
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using CodeReason.Reports.Document;
using CodeReason.Reports.Interfaces;

namespace CodeReason.Reports
{
    /// <summary>
    /// Creates all pages of a report
    /// </summary>
    public class ReportPaginator : DocumentPaginator
    {
        // ReSharper disable InconsistentNaming
        /// <summary>
        /// Reference to a original flowdoc paginator
        /// </summary>
        protected DocumentPaginator _paginator;

        protected FlowDocument _flowDocument;
        protected ReportDocument _report;
        protected ReportData _data;
        protected Block _blockPageHeader;
        protected Block _blockPageFooter;
        protected ArrayList _reportContextValues;
        protected ReportPaginatorDynamicCache _dynamicCache;
        // ReSharper restore InconsistentNaming

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="report">report document</param>
        /// <param name="data">report data</param>
        /// <exception cref="ArgumentException">Flow document must have a specified page height</exception>
        /// <exception cref="ArgumentException">Flow document must have a specified page width</exception>
        /// <exception cref="ArgumentException">Flow document can have only one report header section</exception>
        /// <exception cref="ArgumentException">Flow document can have only one report footer section</exception>
        public ReportPaginator(ReportDocument report, ReportData data)
        {
            _report = report;
            _data = data;

            _flowDocument = report.CreateFlowDocument();
            _pageSize = new Size(_flowDocument.PageWidth, _flowDocument.PageHeight);

            if (_flowDocument.PageHeight == double.NaN) throw new ArgumentException("Flow document must have a specified page height");
            if (_flowDocument.PageWidth == double.NaN) throw new ArgumentException("Flow document must have a specified page width");

            _dynamicCache = new ReportPaginatorDynamicCache(_flowDocument);
            ArrayList listPageHeaders = _dynamicCache.GetFlowDocumentVisualListByType(typeof(SectionReportHeader));
            if (listPageHeaders.Count > 1) throw new ArgumentException("Flow document can have only one report header section");
            if (listPageHeaders.Count == 1) _blockPageHeader = (SectionReportHeader)listPageHeaders[0];
            ArrayList listPageFooters = _dynamicCache.GetFlowDocumentVisualListByType(typeof(SectionReportFooter));
            if (listPageFooters.Count > 1) throw new ArgumentException("Flow document can have only one report footer section");
            if (listPageFooters.Count == 1) _blockPageFooter = (SectionReportFooter)listPageFooters[0];

            _paginator = ((IDocumentPaginatorSource)_flowDocument).DocumentPaginator;

            // remove header and footer in our working copy
            Block block = _flowDocument.Blocks.FirstBlock;
            while (block != null)
            {
                Block thisBlock = block;
                block = block.NextBlock;
                if ((thisBlock == _blockPageHeader) || (thisBlock == _blockPageFooter)) _flowDocument.Blocks.Remove(thisBlock);
            }

            // get report context values
            _reportContextValues = _dynamicCache.GetFlowDocumentVisualListByInterface(typeof(IInlineContextValue));

            FillData();
        }

        protected void RememberAggregateValue(Dictionary<string, List<object>> aggregateValues, string aggregateGroups, object value)
        {
            if (String.IsNullOrEmpty(aggregateGroups)) return;

            string[] aggregateGroupParts = aggregateGroups.Split(new char[] { ',', ';', ' ' }, StringSplitOptions.RemoveEmptyEntries);

            // remember value for aggregate functions
            List<object> aggregateValueList;
            foreach (string aggregateGroup in aggregateGroupParts)
            {
                string trimmedGroup = aggregateGroup.Trim();
                if (String.IsNullOrEmpty(trimmedGroup)) continue;
                if (!aggregateValues.TryGetValue(trimmedGroup, out aggregateValueList))
                {
                    aggregateValueList = new List<object>();
                    aggregateValues[trimmedGroup] = aggregateValueList;
                }
                aggregateValueList.Add(value);
            }
        }

        /// <summary>
        /// Fill charts with data
        /// </summary>
        /// <param name="charts">list of charts</param>
        /// <exception cref="InvalidProgramException">window.Content is not a FrameworkElement</exception>
        protected virtual void FillCharts(ArrayList charts)
        {
            Window window = null;

            // fill charts
            foreach (IChart chart in charts)
            {
                if (chart == null) continue;
                Canvas chartCanvas = chart as Canvas;
                if (String.IsNullOrEmpty(chart.TableName)) continue;
                if (String.IsNullOrEmpty(chart.TableColumns)) continue;

                DataTable table = _data.GetDataTableByName(chart.TableName);
                if (table == null) continue;

                if (chartCanvas != null)
                {
                    // HACK: this here is REALLY dirty!!!
                    IChart newChart = (IChart)chart.Clone();
                    if (window == null)
                    {
                        window = new Window();
                        window.WindowStyle = WindowStyle.None;
                        window.BorderThickness = new Thickness(0);
                        window.ShowInTaskbar = false;
                        window.Left = 30000;
                        window.Top = 30000;
                        window.Show();
                    }
                    window.Width = chartCanvas.Width + 2 * SystemParameters.BorderWidth;
                    window.Height = chartCanvas.Height + 2 * SystemParameters.BorderWidth;
                    window.Content = newChart;

                    newChart.DataColumns = null;

                    newChart.DataView = table.DefaultView;
                    newChart.DataColumns = chart.TableColumns.Split(',', ';');
                    newChart.UpdateChart();

                    FrameworkElement windowContent = window.Content as FrameworkElement;
                    if (windowContent == null) throw new InvalidProgramException("window.Content is not a FrameworkElement");
                    RenderTargetBitmap bitmap = new RenderTargetBitmap((int)(windowContent.RenderSize.Width * 600d / 96d), (int)(windowContent.RenderSize.Height * 600d / 96d), 600d, 600d, PixelFormats.Pbgra32);
                    bitmap.Render(window);
                    chartCanvas.Children.Add(new Image() { Source = bitmap });
                }
                else
                {
                    chart.DataColumns = null;

                    chart.DataView = table.DefaultView;
                    chart.DataColumns = chart.TableColumns.Split(',', ';');
                    chart.UpdateChart();
                }
            }

            if (window != null) window.Close();
        }

        /// <summary>
        /// Fills document with data
        /// </summary>
        /// <exception cref="InvalidDataException">ReportTableRow must have a TableRowGroup as parent</exception>
        protected virtual void FillData()
        {
            ArrayList blockDocumentValues = _dynamicCache.GetFlowDocumentVisualListByInterface(typeof(IInlineDocumentValue)); // walker.Walk<IInlineDocumentValue>(_flowDocument);
            ArrayList blockTableRows = _dynamicCache.GetFlowDocumentVisualListByInterface(typeof(ITableRowForDataTable)); // walker.Walk<TableRowForDataTable>(_flowDocument);
            ArrayList blockAggregateValues = _dynamicCache.GetFlowDocumentVisualListByType(typeof(InlineAggregateValue)); // walker.Walk<InlineAggregateValue>(_flowDocument);
            ArrayList charts = _dynamicCache.GetFlowDocumentVisualListByInterface(typeof(IChart)); // walker.Walk<IChart>(_flowDocument);
            ArrayList dynamicHeaderTableRows = _dynamicCache.GetFlowDocumentVisualListByInterface(typeof(ITableRowForDynamicHeader));
            ArrayList dynamicDataTableRows = _dynamicCache.GetFlowDocumentVisualListByInterface(typeof(ITableRowForDynamicDataTable));
            ArrayList documentConditions = _dynamicCache.GetFlowDocumentVisualListByInterface(typeof(IDocumentCondition));

            List<Block> blocks = new List<Block>();
            if (_blockPageHeader != null) blocks.Add(_blockPageHeader);
            if (_blockPageFooter != null) blocks.Add(_blockPageFooter);

            DocumentWalker walker = new DocumentWalker();
            blockDocumentValues.AddRange(walker.TraverseBlockCollection<IInlineDocumentValue>(blocks));

            Dictionary<string, List<object>> aggregateValues = new Dictionary<string, List<object>>();

            FillCharts(charts);

            // hide conditional text blocks
            foreach (IDocumentCondition dc in documentConditions)
            {
                if (dc == null) continue;
                dc.PerformRenderUpdate(_data);
            }            

            // fill report values
            foreach (IInlineDocumentValue dv in blockDocumentValues)
            {
                if (dv == null) continue;
                object obj;
                if ((dv.PropertyName != null) && (_data.ReportDocumentValues.TryGetValue(dv.PropertyName, out obj)))
                {
                    dv.Value = obj;
                    RememberAggregateValue(aggregateValues, dv.AggregateGroup, obj);
                }
                else
                {
                    if ((_data.ShowUnknownValues) && (dv.Value == null)) dv.Value = "[" + ((dv.PropertyName != null) ? dv.PropertyName : "NULL") + "]";
                    RememberAggregateValue(aggregateValues, dv.AggregateGroup, null);
                }
            }

            // fill dynamic tables
            foreach (ITableRowForDynamicDataTable iTableRow in dynamicDataTableRows)
            {
                TableRow tableRow = iTableRow as TableRow;
                if (tableRow == null) continue;

                TableRowGroup tableGroup = tableRow.Parent as TableRowGroup;
                if (tableGroup == null) continue;

                TableRow currentRow;

                DataTable table = _data.GetDataTableByName(iTableRow.TableName);

                for (int i = 0; i < table.Rows.Count; i++)
                {
                    currentRow = new TableRow();

                    DataRow dataRow = table.Rows[i];
                    for (int j = 0; j < table.Columns.Count; j++)
                    {
                        string value = dataRow[j].ToString();
                        currentRow.Cells.Add(new TableCell(new Paragraph(new Run(value))));
                    }
                    tableGroup.Rows.Add(currentRow);
                }
            }

            foreach (ITableRowForDynamicHeader iTableRow in dynamicHeaderTableRows)
            {
                TableRow tableRow = iTableRow as TableRow;
                if (tableRow == null) continue;

                DataTable table = _data.GetDataTableByName(iTableRow.TableName);

                foreach (DataRow row in table.Rows)
                {
                    string value = row[0].ToString();
                    TableCell tableCell = new TableCell(new Paragraph(new Run(value)));
                    tableRow.Cells.Add(tableCell);
                }

            }

            // group table row groups
            Dictionary<TableRowGroup, List<TableRow>> groupedRows = new Dictionary<TableRowGroup, List<TableRow>>();
            Dictionary<TableRowGroup, string> tableNames = new Dictionary<TableRowGroup, string>();
            foreach (TableRow tableRow in blockTableRows)
            {
                TableRowGroup rowGroup = tableRow.Parent as TableRowGroup;
                if (rowGroup == null) continue;

                ITableRowForDataTable iTableRow = tableRow as ITableRowForDataTable;
                if ((iTableRow != null) && (iTableRow.TableName != null))
                {
                    string tableName;
                    if (tableNames.TryGetValue(rowGroup, out tableName))
                    {
                        if (tableName != iTableRow.TableName.Trim().ToLowerInvariant()) throw new ReportingException("TableRowGroup cannot be mapped to different DataTables in TableRowForDataTable");
                    }
                    else tableNames[rowGroup] = iTableRow.TableName.Trim().ToLowerInvariant();
                }

                List<TableRow> rows;
                if (!groupedRows.TryGetValue(rowGroup, out rows))
                {
                    rows = new List<TableRow>();
                    groupedRows[rowGroup] = rows;
                }
                rows.Add(tableRow);
            }

            // fill tables
            foreach (KeyValuePair<TableRowGroup, List<TableRow>> groupedRow in groupedRows)
            {
                TableRowGroup rowGroup = groupedRow.Key;

                ITableRowForDataTable iTableRow = groupedRow.Value[0] as ITableRowForDataTable;
                if (iTableRow == null) continue;

                DataTable table = _data.GetDataTableByName(iTableRow.TableName);
                if (table == null)
                {
                    if (_data.ShowUnknownValues)
                    {
                        // show unknown values
                        foreach (TableRow tableRow in groupedRow.Value)
                            foreach (TableCell cell in tableRow.Cells)
                            {
                                DocumentWalker localWalker = new DocumentWalker();
                                List<ITableCellValue> tableCells = localWalker.TraverseBlockCollection<ITableCellValue>(cell.Blocks);
                                foreach (ITableCellValue cv in tableCells)
                                {
                                    IPropertyValue dv = cv as IPropertyValue;
                                    if (dv == null) continue;
                                    dv.Value = "[" + dv.PropertyName + "]";
                                    RememberAggregateValue(aggregateValues, cv.AggregateGroup, null);
                                }
                            }
                    }
                    else continue;
                }
                else
                {
                    List<TableRow> listNewRows = new List<TableRow>();
                    TableRow newTableRow;

                    // clone XAML rows
                    List<string> clonedRows = new List<string>();
                    foreach (TableRow row in rowGroup.Rows)
                    {
                        TableRowForDataTable reportTableRow = row as TableRowForDataTable;
                        if (reportTableRow == null) clonedRows.Add(null);
                        clonedRows.Add(XamlWriter.Save(reportTableRow));
                    }

                    for (int i = 0; i < table.Rows.Count; i++)
                    {
                        DataRow dataRow = table.Rows[i];

                        for (int j = 0; j < rowGroup.Rows.Count; j++)
                        {
                            TableRow row = rowGroup.Rows[j];

                            TableRowForDataTable reportTableRow = row as TableRowForDataTable;
                            if (reportTableRow == null)
                            {
                                // clone regular row
                                listNewRows.Add(XamlHelper.CloneTableRow(row));
                            }
                            else
                            {
                                // clone ReportTableRows
                                newTableRow = (TableRow)XamlHelper.LoadXamlFromString(clonedRows[j]);

                                foreach (TableCell cell in newTableRow.Cells)
                                {
                                    DocumentWalker localWalker = new DocumentWalker();
                                    List<ITableCellValue> newCells = localWalker.TraverseBlockCollection<ITableCellValue>(cell.Blocks);
                                    foreach (ITableCellValue cv in newCells)
                                    {
                                        IPropertyValue dv = cv as IPropertyValue;
                                        if (dv == null) continue;
                                        try
                                        {
                                            object obj = dataRow[dv.PropertyName];
                                            if (obj == DBNull.Value) obj = null;
                                            dv.Value = obj;

                                            RememberAggregateValue(aggregateValues, cv.AggregateGroup, obj);
                                        }
                                        catch
                                        {
                                            if (_data.ShowUnknownValues) dv.Value = "[" + dv.PropertyName + "]"; else dv.Value = "";
                                            RememberAggregateValue(aggregateValues, cv.AggregateGroup, null);
                                        }
                                    }
                                }
                                listNewRows.Add(newTableRow);

                                // fire event
                                _report.FireEventDataRowBoundEventArgs(new DataRowBoundEventArgs(_report, dataRow) { TableName = dataRow.Table.TableName, TableRow = newTableRow });
                            }
                        }
                    }
                    rowGroup.Rows.Clear();
                    foreach (TableRow row in listNewRows) rowGroup.Rows.Add(row);
                }
            }

            // fill aggregate values
            foreach (InlineAggregateValue av in blockAggregateValues)
            {
                if (String.IsNullOrEmpty(av.AggregateGroup)) continue;

                string[] aggregateGroups = av.AggregateGroup.Split(new char[] { ',', ';', ' ' }, StringSplitOptions.RemoveEmptyEntries);

                foreach (var group in aggregateGroups)
                {
                    if (!aggregateValues.ContainsKey(group))
                    {
                        av.Text = av.EmptyValue;
                        break;
                    }
                }
                av.Text = av.ComputeAndFormat(aggregateValues);
            }
        }

        /// <summary>
        /// Clones a visual block
        /// </summary>
        /// <param name="block">block to be cloned</param>
        /// <param name="pageNumber">current page number</param>
        /// <returns>cloned block</returns>
        /// <exception cref="InvalidProgramException">Error cloning XAML block</exception>
        private ContainerVisual CloneVisualBlock(Block block, int pageNumber)
        {
            FlowDocument tmpDoc = new FlowDocument();
            tmpDoc.ColumnWidth = double.PositiveInfinity;
            tmpDoc.PageHeight = _report.PageHeight;
            tmpDoc.PageWidth = _report.PageWidth;
            tmpDoc.PagePadding = new Thickness(0);

            string xaml = XamlWriter.Save(block);
            Block newBlock = XamlReader.Parse(xaml) as Block;
            if (newBlock == null) throw new InvalidProgramException("Error cloning XAML block");
            tmpDoc.Blocks.Add(newBlock);

            DocumentWalker walkerBlock = new DocumentWalker();
            ArrayList blockValues = new ArrayList();
            blockValues.AddRange(walkerBlock.Walk<IInlineContextValue>(tmpDoc));

            // fill context values
            FillContextValues(blockValues, pageNumber);

            DocumentPage dp = ((IDocumentPaginatorSource)tmpDoc).DocumentPaginator.GetPage(0);
            return (ContainerVisual)dp.Visual;
        }

        protected virtual void FillContextValues(ArrayList list, int pageNumber)
        {
            // fill context values
            foreach (IInlineContextValue cv in list)
            {
                if (cv == null) continue;
                ReportContextValueType? reportContextValueType = ReportPaginatorStaticCache.GetReportContextValueTypeByName(cv.PropertyName);
                if (reportContextValueType == null)
                {
                    if (_data.ShowUnknownValues) cv.Value = "<" + ((cv.PropertyName != null) ? cv.PropertyName : "NULL") + ">"; else cv.Value = "";
                }
                else
                {
                    switch (reportContextValueType.Value)
                    {
                        case ReportContextValueType.PageNumber:
                            cv.Value = pageNumber;
                            break;
                        case ReportContextValueType.PageCount:
                            cv.Value = _pageCount;
                            break;
                        case ReportContextValueType.ReportName:
                            cv.Value = _report.ReportName;
                            break;
                        case ReportContextValueType.ReportTitle:
                            cv.Value = _report.ReportTitle;
                            break;
                    }
                }
            }
        }

        /// <summary>
        /// This is most important method, modifies the original 
        /// </summary>
        /// <param name="pageNumber">page number</param>
        /// <returns></returns>
        public override DocumentPage GetPage(int pageNumber)
        {
            for (int i = 0; i < 2; i++) // do it twice because filling context values could change the page count
            {
                // compute page count
                if (pageNumber == 0)
                {
                    _paginator.ComputePageCount();
                    _pageCount = _paginator.PageCount;
                }

                // fill context values
                FillContextValues(_reportContextValues, pageNumber + 1);
            }

            DocumentPage page = _paginator.GetPage(pageNumber);
            if (page == DocumentPage.Missing) return DocumentPage.Missing; // page missing

            _pageSize = page.Size;

            // add header block
            ContainerVisual newPage = new ContainerVisual();

            if (_blockPageHeader != null)
            {
                ContainerVisual v = CloneVisualBlock(_blockPageHeader, pageNumber + 1);
                v.Offset = new Vector(0, 0);
                newPage.Children.Add(v);
            }

            // TODO: process ReportContextValues

            // add content page
            ContainerVisual smallerPage = new ContainerVisual();
            smallerPage.Offset = new Vector(0, _report.PageHeaderHeight / 100d * _report.PageHeight);
            smallerPage.Children.Add(page.Visual);
            newPage.Children.Add(smallerPage);

            // add footer block
            if (_blockPageFooter != null)
            {
                ContainerVisual v = CloneVisualBlock(_blockPageFooter, pageNumber + 1);
                v.Offset = new Vector(0, _report.PageHeight - _report.PageFooterHeight / 100d * _report.PageHeight);
                newPage.Children.Add(v);
            }

            // create modified BleedBox
            Rect bleedBox = new Rect(page.BleedBox.Left, page.BleedBox.Top, page.BleedBox.Width,
                _report.PageHeight - (page.Size.Height - page.BleedBox.Size.Height));

            // create modified ContentBox
            Rect contentBox = new Rect(page.ContentBox.Left, page.ContentBox.Top, page.ContentBox.Width,
                _report.PageHeight - (page.Size.Height - page.ContentBox.Size.Height));

            DocumentPage dp = new DocumentPage(newPage, new Size(_report.PageWidth, _report.PageHeight), bleedBox, contentBox);
            _report.FireEventGetPageCompleted(new GetPageCompletedEventArgs(page, pageNumber, null, false, null));
            return dp;
        }

        /// <summary>
        /// Determines if the current page count is valid
        /// </summary>
        public override bool IsPageCountValid
        {
            get { return _paginator.IsPageCountValid; }
        }

        private int _pageCount;
        /// <summary>
        /// Gets the total page count
        /// </summary>
        public override int PageCount
        {
            get { return _pageCount; }
        }

        private Size _pageSize = Size.Empty;
        /// <summary>
        /// Gets or sets the page size
        /// </summary>
        public override Size PageSize
        {
            get { return _pageSize; }
            set { _pageSize = value; }
        }

        /// <summary>
        /// Gets the paginator source
        /// </summary>
        public override IDocumentPaginatorSource Source
        {
            get { return _paginator.Source; }
        }
    }
}
