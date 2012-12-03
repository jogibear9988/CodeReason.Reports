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
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;
using CodeReason.Reports.Interfaces;
using CodeReason.Reports.Chart;

namespace CodeReason.Reports.Document.Chart
{
    /// <summary>
    /// Creates a bar chart as a Canvas
    /// </summary>
    public class BarChart2D : Canvas, IChart
    {
        /// <summary>
        /// Determine if this component is initialized
        /// </summary>
        protected bool _isInitialized = false;

        /// <summary>
        /// Gets or sets the brush which is to be used to draw the axes
        /// </summary>
        public Brush AxesBrush
        {
            get { return (Brush)GetValue(BrushAxesProperty); }
            set { SetValue(BrushAxesProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for BrushAxes.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty BrushAxesProperty =
            DependencyProperty.Register("AxesBrush", typeof(Brush), typeof(BarChart2D), new UIPropertyMetadata(Brushes.Black));

        /// <summary>
        /// Gets or sets the stroke thickness for the axes
        /// </summary>
        public double AxesStrokeThickness
        {
            get { return (double)GetValue(AxesStrokeThicknessProperty); }
            set { SetValue(AxesStrokeThicknessProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for AxesStrokeThickness.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty AxesStrokeThicknessProperty =
            DependencyProperty.Register("AxesStrokeThickness", typeof(double), typeof(BarChart2D), new UIPropertyMetadata(1.5d));

        /// <summary>
        /// Gets or sets the brush which is to be used to draw the bars
        /// </summary>
        public Brush BarsBrush
        {
            get { return (Brush)GetValue(BrushBarsProperty); }
            set { SetValue(BrushBarsProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for BrushBars.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty BrushBarsProperty =
            DependencyProperty.Register("BarsBrush", typeof(Brush), typeof(BarChart2D), new UIPropertyMetadata(Brushes.Blue));

        /// <summary>
        /// Gets or sets the stroke which is to be used to draw the bars
        /// </summary>
        public Brush BarsStroke
        {
            get { return (Brush)GetValue(BarsStrokeProperty); }
            set { SetValue(BarsStrokeProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for BarsStroke.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty BarsStrokeProperty =
            DependencyProperty.Register("BarsStroke", typeof(Brush), typeof(BarChart2D), new UIPropertyMetadata(Brushes.DarkBlue));

        /// <summary>
        /// Gets or sets the stroke thickness which is to be used to draw the bars
        /// </summary>
        public double BarsStrokeThickness
        {
            get { return (double)GetValue(BarsStrokeThicknessProperty); }
            set { SetValue(BarsStrokeThicknessProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for BarsStrokeThickness.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty BarsStrokeThicknessProperty =
            DependencyProperty.Register("BarsStrokeThickness", typeof(double), typeof(BarChart2D), new UIPropertyMetadata(1.5d));

        /// <summary>
        /// Gets the gap between bars in percent
        /// </summary>
        public double GapBetweenBars
        {
            get { return (double)GetValue(GapBetweenBarsProperty); }
            set { SetValue(GapBetweenBarsProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for GapBetweenBars.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty GapBetweenBarsProperty =
            DependencyProperty.Register("GapBetweenBars", typeof(double), typeof(BarChart2D), new UIPropertyMetadata(0.3));

        /// <summary>
        /// Gets or sets the margin of the chart in percent
        /// </summary>
        public Thickness MarginChart
        {
            get { return (Thickness)GetValue(MarginChartProperty); }
            set { SetValue(MarginChartProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for MarginChart.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty MarginChartProperty =
            DependencyProperty.Register("MarginChart", typeof(Thickness), typeof(BarChart2D), new UIPropertyMetadata(new Thickness(10)));

        /// <summary>
        /// Determines if the axes have arrows
        /// </summary>
        public bool ShowArrows
        {
            get { return (bool)GetValue(ShowArrowsProperty); }
            set { SetValue(ShowArrowsProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for ShowArrows.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty ShowArrowsProperty =
            DependencyProperty.Register("ShowArrows", typeof(bool), typeof(BarChart2D), new UIPropertyMetadata(true));

        /// <summary>
        /// Gets or sets the table columns which are used to draw the chart
        /// </summary>
        public string TableColumns
        {
            get { return (string)GetValue(TableColumnsProperty); }
            set { SetValue(TableColumnsProperty, value); }
        }

        // Using a DependencyProperty as the backing store for TableColumns.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty TableColumnsProperty =
            DependencyProperty.Register("TableColumns", typeof(string), typeof(BarChart2D), new UIPropertyMetadata(null));

        /// <summary>
        /// Gets or sets the table name containing the data to be drawn
        /// </summary>
        public string TableName
        {
            get { return (string)GetValue(TableNameProperty); }
            set { SetValue(TableNameProperty, value); }
        }

        // Using a DependencyProperty as the backing store for TableName.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty TableNameProperty =
            DependencyProperty.Register("TableName", typeof(string), typeof(BarChart2D), new UIPropertyMetadata(null));

        private string _chartTitleText = "Demo";
        /// <summary>
        /// Gets or set the chart title text
        /// </summary>
        public string ChartTitleText
        {
            get { return _chartTitleText; }
            set { _chartTitleText = value; }
        }

        private string[] _dataColumns = new string[] { "DemoX", "DemoY" };
        /// <summary>
        /// Gets or sets the data columns which are used to draw the chart
        /// </summary>
        public string[] DataColumns
        {
            get { return _dataColumns; }
            set
            {
                _dataColumns = value;
                RedrawAll();
            }
        }

        private DataView _dataView = null;
        /// <summary>
        /// Data view to be used to draw the data
        /// </summary>
        public DataView DataView
        {
            get { return _dataView; }
            set
            {
                _dataView = value;
                RedrawAll();
            }
        }

        /// <summary>
        /// Constructor
        /// </summary>
        public BarChart2D()
        {
            // create demo table
            DataTable table = new DataTable();
            table.Columns.Add("DemoX", typeof(string));
            table.Columns.Add("DemoY", typeof(int));
            table.Rows.Add("ABC", 23475);
            table.Rows.Add("DEF", 34567);
            table.Rows.Add("GHI", 56789);
            table.Rows.Add("JKL", 67890);
            table.Rows.Add("MNO", 78901);
            DataView = table.DefaultView;
            Init();
            RedrawAll();
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="dataView">Data view containg the data to be drawn</param>
        /// <param name="dataColumns">Columns to be used to draw the chart</param>
        public BarChart2D(DataView dataView, string[] dataColumns)
        {
            _dataView = dataView;
            _dataColumns = dataColumns;
            _chartTitleText = null;
            if (_dataView != null) _chartTitleText = dataView.Table.TableName;
            Init();
            RedrawAll();
        }

        /// <summary>
        /// Property initialization
        /// </summary>
        protected void Init()
        {
            BarsBrush = BrushFactory.CreateHorizontalLinearGradientBrush(Colors.DarkBlue, Colors.Blue);

            _isInitialized = true;
        }

        /// <summary>
        /// Render size has changed
        /// </summary>
        /// <param name="sizeInfo">size info</param>
        protected override void OnRenderSizeChanged(SizeChangedInfo sizeInfo)
        {
            base.OnRenderSizeChanged(sizeInfo);
            RedrawAll();
        }

        private bool IsDecimalValueType(Type type)
        {
            if (type == typeof(decimal)) return true;
            if (type == typeof(double)) return true;
            if (type == typeof(int)) return true;
            if (type == typeof(long)) return true;
            if (type == typeof(uint)) return true;
            if (type == typeof(ulong)) return true;
            return false;
        }

        /// <summary>
        /// Redraws the whole chart
        /// </summary>
        /// <exception cref="ArgumentException">This chart needs exactly two data columns</exception>
        /// <exception cref="ArgumentException">Second data column must be a number</exception>
        public void RedrawAll()
        {
            Children.Clear();

            if (!_isInitialized) return;
            if (_dataView == null) return;
            if ((_dataColumns == null) || (_dataColumns.Length <= 0)) return;
            if (_dataColumns.Length != 2) throw new ArgumentException("This chart needs exactly two data columns");
            if (!_dataView.Table.Columns.Contains(_dataColumns[1])) return;
            if (!IsDecimalValueType(_dataView.Table.Columns[_dataColumns[1]].DataType)) throw new ArgumentException("Second data column must be a number");

            double actualWidth = ActualWidth;
            if ((double.IsNaN(actualWidth)) || (actualWidth <= 0)) actualWidth = Width;
            if ((double.IsNaN(actualWidth)) || (actualWidth <= 0)) return;
            double actualHeight = ActualHeight;
            if ((double.IsNaN(actualHeight)) || (actualHeight <= 0)) actualHeight = Height;
            if ((double.IsNaN(actualHeight)) || (actualHeight <= 0)) return;

            Rect rectClient = new Rect(MarginChart.Left / 100d * actualWidth + (ShowArrows ? 2 * AxesStrokeThickness : 0), MarginChart.Top / 100d * actualHeight,
                actualWidth - (MarginChart.Left + MarginChart.Right) / 100d * actualWidth,
                actualHeight - (MarginChart.Top + MarginChart.Bottom) / 100d * actualHeight - (ShowArrows ? 2 * AxesStrokeThickness : 0));

            if (_dataView.Table.Rows.Count > 0)
            {
                // detemine highest and smallest value
                decimal highestValue = decimal.MinValue;
                decimal lowestValue = decimal.MaxValue;
                for (int i = 0; i < _dataView.Table.Rows.Count; i++)
                {
                    decimal num = decimal.Parse(_dataView.Table.Rows[i][_dataColumns[1]].ToString());
                    if (highestValue < num) highestValue = num;
                    if (lowestValue > num) lowestValue = num;
                }

                if (lowestValue < 0) throw new NotSupportedException("Values below 0 cannot be shown yet"); // TODO: 
                decimal yScale = (decimal)(rectClient.Height - (ShowArrows ? 8 * AxesStrokeThickness + ((GapBetweenBars == 0) ? 2 * AxesStrokeThickness : 0) : 0)) / highestValue;

                // draw bars
                double drawWidth = (rectClient.Width - (ShowArrows ? 8 * AxesStrokeThickness + ((GapBetweenBars == 0) ? 2 * AxesStrokeThickness : 0) : 0));

                //drawWidth = barWidth * _dataView.Table.Rows.Count + GapBetweenBars * barWidth * (_dataView.Table.Rows.Count) + GapBetweenBars * barWidth;
                double barWidth = 1 / (_dataView.Table.Rows.Count / drawWidth + GapBetweenBars * (_dataView.Table.Rows.Count) / drawWidth + GapBetweenBars / drawWidth);
                double gapWidth = GapBetweenBars * barWidth;

                if (barWidth > 0)
                {
                    double left = rectClient.Left + gapWidth;
                    for (int i = 0; i < _dataView.Table.Rows.Count; i++)
                    {
                        decimal num = decimal.Parse(_dataView.Table.Rows[i][_dataColumns[1]].ToString());

                        Rectangle rect = new Rectangle();
                        rect.Fill = BarsBrush;
                        rect.StrokeThickness = 0;
                        rect.Width = barWidth;
                        rect.Height = (double)(num * yScale);
                        rect.RenderTransform = new TranslateTransform(left, rectClient.Bottom - rect.Height);
                        Children.Add(rect);

                        Line line = new Line();
                        line.Fill = BarsStroke;
                        line.Stroke = BarsStroke;
                        line.StrokeThickness = BarsStrokeThickness;
                        line.X1 = left;
                        line.Y1 = rectClient.Bottom - rect.Height + BarsStrokeThickness / 2;
                        line.X2 = left;
                        line.Y2 = rectClient.Bottom;
                        Children.Add(line);

                        line = new Line();
                        line.Fill = BarsStroke;
                        line.Stroke = BarsStroke;
                        line.StrokeThickness = BarsStrokeThickness;
                        line.X1 = left - BarsStrokeThickness / 2;
                        line.Y1 = rectClient.Bottom - rect.Height;
                        line.X2 = left + barWidth + BarsStrokeThickness / 2;
                        line.Y2 = rectClient.Bottom - rect.Height;
                        Children.Add(line);

                        left += barWidth;

                        line = new Line();
                        line.Fill = BarsStroke;
                        line.Stroke = BarsStroke;
                        line.StrokeThickness = BarsStrokeThickness;
                        line.X1 = left;
                        line.Y1 = rectClient.Bottom - rect.Height + BarsStrokeThickness / 2;
                        line.X2 = left;
                        line.Y2 = rectClient.Bottom;
                        Children.Add(line);

                        left += gapWidth;
                    }
                }
            }

            {
                // vertical line
                Line line = new Line();
                line.Fill = AxesBrush;
                line.Stroke = AxesBrush;
                line.StrokeThickness = AxesStrokeThickness;
                line.X1 = rectClient.Left;
                line.Y1 = rectClient.Bottom + AxesStrokeThickness / 2;
                line.X2 = rectClient.Left;
                line.Y2 = rectClient.Top + (ShowArrows ? 8 * AxesStrokeThickness : 0);
                Children.Add(line);

                // horizontal line
                line = new Line();
                line.Fill = AxesBrush;
                line.Stroke = AxesBrush;
                line.StrokeThickness = AxesStrokeThickness;
                line.X1 = rectClient.Left - AxesStrokeThickness / 2;
                line.Y1 = rectClient.Bottom;
                line.X2 = rectClient.Right - (ShowArrows ? 8 * AxesStrokeThickness : 0);
                line.Y2 = rectClient.Bottom;
                Children.Add(line);

                if (ShowArrows)
                {
                    // draw vertical line end cap
                    Polygon polygon = new Polygon();
                    polygon.Fill = AxesBrush;
                    polygon.Stroke = AxesBrush;
                    polygon.Points.Add(new Point(rectClient.Left, rectClient.Top));
                    polygon.Points.Add(new Point(rectClient.Left - 2 * AxesStrokeThickness, rectClient.Top + 8 * AxesStrokeThickness));
                    polygon.Points.Add(new Point(rectClient.Left + 2 * AxesStrokeThickness, rectClient.Top + 8 * AxesStrokeThickness));
                    Children.Add(polygon);

                    // draw horizontal line end cap
                    polygon = new Polygon();
                    polygon.Fill = AxesBrush;
                    polygon.Stroke = AxesBrush;
                    polygon.Points.Add(new Point(rectClient.Right, rectClient.Bottom));
                    polygon.Points.Add(new Point(rectClient.Right - 8 * AxesStrokeThickness, rectClient.Bottom - 2 * AxesStrokeThickness));
                    polygon.Points.Add(new Point(rectClient.Right - 8 * AxesStrokeThickness, rectClient.Bottom + 2 * AxesStrokeThickness));
                    Children.Add(polygon);
                }

                // TODO: draw axes description
            }
        }
    }
}
