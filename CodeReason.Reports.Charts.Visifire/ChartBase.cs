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
using System.Data;
using System.Reflection;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace CodeReason.Reports.Charts.Visifire
{
    /// <summary>
    /// Base class for charts
    /// </summary>
    public abstract class ChartBase : Canvas, IChartVisifire
    {
        /// <summary>
        /// Visifire chart
        /// </summary>
        protected global::Visifire.Charts.Chart Chart;

        /// <summary>
        /// Render chart as
        /// </summary>
        protected global::Visifire.Charts.RenderAs RenderAs = global::Visifire.Charts.RenderAs.Column;

        /// <summary>
        /// Gets or sets the background brush
        /// </summary>
        public new Brush Background
        {
            get { return (Brush) GetValue(BackgroundProperty); }
            set { SetValue(BackgroundProperty, value); }
        }

        // Using a DependencyProperty as the backing store for Background.  This enables animation, styling, binding, etc...
        public new static readonly DependencyProperty BackgroundProperty =
            DependencyProperty.Register("Background", typeof (Brush), typeof (ChartBase), new UIPropertyMetadata(Brushes.White));

        /// <summary>
        /// Use bevel border for chart
        /// </summary>
        public bool Bevel
        {
            get { return (bool) GetValue(BevelProperty); }
            set { SetValue(BevelProperty, value); }
        }

        // Using a DependencyProperty as the backing store for Bevel.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty BevelProperty =
            DependencyProperty.Register("Bevel", typeof (bool), typeof (ChartBase), new UIPropertyMetadata(false));

        /// <summary>
        /// Gets or sets the border brush
        /// </summary>
        public Brush BorderBrush
        {
            get { return (Brush) GetValue(BorderBrushProperty); }
            set { SetValue(BorderBrushProperty, value); }
        }

        // Using a DependencyProperty as the backing store for BorderBrush.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty BorderBrushProperty =
            DependencyProperty.Register("BorderBrush", typeof (Brush), typeof (ChartBase), new UIPropertyMetadata(Brushes.Gray));

        /// <summary>
        /// Gets or sets the border thickness
        /// </summary>
        public Thickness BorderThickness
        {
            get { return (Thickness) GetValue(BorderThicknessProperty); }
            set { SetValue(BorderThicknessProperty, value); }
        }

        // Using a DependencyProperty as the backing store for BorderThickness.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty BorderThicknessProperty =
            DependencyProperty.Register("BorderThickness", typeof (Thickness), typeof (ChartBase), new UIPropertyMetadata(new Thickness(1)));

        /// <summary>
        /// Enables / disables lighting
        /// </summary>
        public bool LightingEnabled
        {
            get { return (bool) GetValue(LightingEnabledProperty); }
            set { SetValue(LightingEnabledProperty, value); }
        }

        // Using a DependencyProperty as the backing store for LightingEnabled.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty LightingEnabledProperty =
            DependencyProperty.Register("LightingEnabled", typeof (bool), typeof (ChartBase), new UIPropertyMetadata(true));

        /// <summary>
        /// Gets or sets the chart title
        /// </summary>
        public string Title
        {
            get { return (string) GetValue(TitleProperty); }
            set { SetValue(TitleProperty, value); }
        }

        // Using a DependencyProperty as the backing store for Title.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty TitleProperty =
            DependencyProperty.Register("Title", typeof (string), typeof (ChartBase), new UIPropertyMetadata(""));

        /// <summary>
        /// Use a unique color for each bar
        /// </summary>
        public virtual bool UniqueColors
        {
            get { return (bool) GetValue(UniqueColorsProperty); }
            set { SetValue(UniqueColorsProperty, value); }
        }

        // Using a DependencyProperty as the backing store for UniqueColors.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty UniqueColorsProperty =
            DependencyProperty.Register("UniqueColors", typeof (bool), typeof (ChartBase), new UIPropertyMetadata(true));

        /// <summary>
        /// Enables or disables the 3D view of the bars
        /// </summary>
        public virtual bool View3D
        {
            get { return (bool) GetValue(View3DProperty); }
            set { SetValue(View3DProperty, value); }
        }

        // Using a DependencyProperty as the backing store for View3D.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty View3DProperty =
            DependencyProperty.Register("View3D", typeof (bool), typeof (ChartBase), new UIPropertyMetadata(false));

        /// <summary>
        /// Clones the chart
        /// </summary>
        /// <returns>cloned chart</returns>
        public virtual object Clone()
        {
            ChartBase res = (ChartBase) BaseClone();
            res.Background = Background;
            res.Bevel = Bevel;
            res.BorderBrush = BorderBrush;
            res.BorderThickness = BorderThickness;
            res.LightingEnabled = LightingEnabled;
            res.Title = Title;
            res.UniqueColors = UniqueColors;
            res.View3D = View3D;
            return res;
        }

        private double FormatValue(object value, Type type)
        {
            if (type == typeof (bool))
            {
                if (!String.IsNullOrEmpty(value.ToString()))
                    return ((bool) value) ? 1 : 0;
                return 0;
            }
            if ((type == typeof (int)) || (type == typeof (uint)) || (type == typeof (long)) || (type == typeof (ulong)) ||
                (type == typeof (byte)) || (type == typeof (sbyte)) || (type == typeof (short)) || (type == typeof (ushort)))
            {
                if (!String.IsNullOrEmpty(value.ToString()))
                    return Int64.Parse(value.ToString());
                return 0;
            }
            if ((type == typeof (float)) || (type == typeof (double)) || (type == typeof (decimal)))
            {
                if (!String.IsNullOrEmpty(value.ToString()))
                    return (double) Decimal.Parse(value.ToString());
                return 0;
            }
            throw new NotSupportedException();
        }

        /// <summary>
        /// Prepares the chart properties
        /// </summary>
        protected virtual void PrepareChart()
        {
            Chart = new global::Visifire.Charts.Chart();
            Chart.AnimationEnabled = false;
            Chart.ScrollingEnabled = false;
            Chart.ToolTipEnabled = false;
            Chart.Width = Width;
            Chart.Height = Height;
            Chart.Watermark = false;

            // set dependency properties
            Chart.Background = Background;
            Chart.Bevel = Bevel;
            Chart.BorderBrush = BorderBrush;
            Chart.BorderThickness = BorderThickness;
            Chart.LightingEnabled = LightingEnabled;
            Chart.Titles.Clear();
            if (!String.IsNullOrEmpty(Title)) Chart.Titles.Add(new global::Visifire.Charts.Title() {Text = Title});
            Chart.UniqueColors = UniqueColors;
            Chart.View3D = View3D;
        }

        /// <summary>
        /// Updates the chart to use the chart data
        /// </summary>
        /// <exception cref="NotSupportedException">Data type {0} is not supported for Y value</exception>
        public virtual void UpdateChart()
        {
            PrepareChart();

            if ((DataColumns != null) && (DataColumns.Length > 1))
            {
                global::Visifire.Charts.DataSeries ds = new global::Visifire.Charts.DataSeries();
                ds.RenderAs = RenderAs;
                Chart.Series.Add(ds);

                foreach (DataRowView rowView in DataView)
                {
                    global::Visifire.Charts.DataPoint dp = new global::Visifire.Charts.DataPoint();
                    ds.RenderAs = RenderAs;
                    ds.DataPoints.Add(dp);

                    dp.AxisXLabel = rowView[DataColumns[0]].ToString();

                    Type type = DataView.Table.Columns[DataColumns[1]].DataType;
                    try
                    {
                        dp.YValue = FormatValue(rowView[DataColumns[1]], type);
                    }
                    catch (NotSupportedException)
                    {
                        throw new NotSupportedException("Data type " + type + " is not supported for Y value");
                    }

                    if (DataColumns.Length > 2)
                    {
                        type = DataView.Table.Columns[DataColumns[2]].DataType;
                        try
                        {
                            dp.ZValue = FormatValue(rowView[DataColumns[2]], type);
                        }
                        catch (NotSupportedException)
                        {
                            throw new NotSupportedException("Data type " + type + " is not supported for Z value");
                        }
                    }
                }
            }

            Children.Clear();
            Children.Add(Chart);

            UpdateLayout();
        }

        #region IChart Members

        /// <summary>
        /// Gets or sets the table columns which are used to draw the chart
        /// </summary>
        public virtual string TableColumns { get; set; }

        /// <summary>
        /// Gets or sets the table name containing the data to be drawn
        /// </summary>
        public virtual string TableName { get; set; }

        /// <summary>
        /// Gets or sets the data columns which are used to draw the chart
        /// </summary>
        public virtual string[] DataColumns { get; set; }

        /// <summary>
        /// Data view to be used to draw the data
        /// </summary>
        public virtual DataView DataView { get; set; }

        /// <summary>
        /// Clones the chart properties
        /// </summary>
        /// <returns>cloned object</returns>
        private object BaseClone()
        {
            //First we create an instance of this specific type.
            object newObject = Activator.CreateInstance(GetType());

            //We get the array of fields for the new type instance.
            FieldInfo[] fields = newObject.GetType().GetFields();

            int i = 0;
            foreach (FieldInfo fi in GetType().GetFields())
            {
                //We query if the fiels support the ICloneable interface.
                Type cloneType = fi.FieldType.GetInterface("ICloneable", true);
                if (cloneType != null)
                {
                    //Getting the ICloneable interface from the object.
                    ICloneable clone = (ICloneable) fi.GetValue(this);

                    //We use the clone method to set the new value to the field.
                    fields[i].SetValue(newObject, clone.Clone());
                }
                else
                {
                    // If the field doesn't support the ICloneable 
                    // interface then just set it.
                    fields[i].SetValue(newObject, fi.GetValue(this));
                }

                //Now we check if the object support the 
                //IEnumerable interface, so if it does
                //we need to enumerate all its items and check if 
                //they support the ICloneable interface.
                Type enumType = fi.FieldType.GetInterface("IEnumerable", true);
                if (enumType != null)
                {
                    //Get the IEnumerable interface from the field.
                    IEnumerable enumInterface = (IEnumerable) fi.GetValue(this);

                    //This version support the IList and the 
                    //IDictionary interfaces to iterate on collections.
                    Type listType = fields[i].FieldType.GetInterface("IList", true);
                    Type dictType = fields[i].FieldType.GetInterface("IDictionary", true);

                    int j = 0;
                    if (listType != null)
                    {
                        //Getting the IList interface.
                        IList list = (IList) fields[i].GetValue(newObject);
                        foreach (object obj in enumInterface)
                        {
                            //Checking to see if the current item 
                            //support the ICloneable interface.
                            cloneType = obj.GetType().GetInterface("ICloneable", true);
                            if (cloneType != null)
                            {
                                //If it does support the ICloneable interface, 
                                //we use it to set the clone of
                                //the object in the list.
                                ICloneable clone = (ICloneable) obj;
                                list[j] = clone.Clone();
                            }

                            //NOTE: If the item in the list is not 
                            //support the ICloneable interface then in the 
                            //cloned list this item will be the same 
                            //item as in the original list
                            //(as long as this type is a reference type).
                            j++;
                        }
                    }
                    else if (dictType != null)
                    {
                        //Getting the dictionary interface.
                        IDictionary dict = (IDictionary) fields[i].GetValue(newObject);
                        j = 0;

                        foreach (DictionaryEntry de in enumInterface)
                        {
                            //Checking to see if the item 
                            //support the ICloneable interface.
                            cloneType = de.Value.GetType().GetInterface("ICloneable", true);
                            if (cloneType != null)
                            {
                                ICloneable clone = (ICloneable) de.Value;
                                dict[de.Key] = clone.Clone();
                            }
                            j++;
                        }
                    }
                }
                i++;
            }
            return newObject;
        }

        #endregion

        /// <summary>
        /// Render size has changed
        /// </summary>
        /// <param name="sizeInfo">size information</param>
        protected override void OnRenderSizeChanged(SizeChangedInfo sizeInfo)
        {
            base.OnRenderSizeChanged(sizeInfo);

            if (Chart != null)
            {
                Chart.Width = sizeInfo.NewSize.Width;
                Chart.Height = sizeInfo.NewSize.Height;
            }
        }
    }
}