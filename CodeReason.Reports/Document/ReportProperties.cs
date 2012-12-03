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

using System.Windows;
using System.Windows.Documents;

namespace CodeReason.Reports.Document
{
    /// <summary>
    /// Specifies properties for report
    /// </summary>
    public class ReportProperties : Section
    {
        /// <summary>
        /// Gets or sets the report name
        /// </summary>
        public string ReportName
        {
            get { return (string)GetValue(ReportNameProperty); }
            set { SetValue(ReportNameProperty, value); }
        }

        // Using a DependencyProperty as the backing store for ReportName.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty ReportNameProperty =
            DependencyProperty.Register("ReportName", typeof(string), typeof(ReportProperties), new UIPropertyMetadata(null));

        /// <summary>
        /// Gets or sets the report title
        /// </summary>
        public string ReportTitle
        {
            get { return (string)GetValue(ReportTitleProperty); }
            set { SetValue(ReportTitleProperty, value); }
        }

        // Using a DependencyProperty as the backing store for ReportTitle.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty ReportTitleProperty =
            DependencyProperty.Register("ReportTitle", typeof(string), typeof(ReportProperties), new UIPropertyMetadata(null));
    }
}
