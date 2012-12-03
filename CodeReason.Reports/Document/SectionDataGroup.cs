using System.Windows;
using System.Windows.Documents;

namespace CodeReason.Reports.Document
{
    /// <summary>
    /// Provides a section for grouped data
    /// </summary>
    public class SectionDataGroup : Section
    {
        /// <summary>
        /// Gets or sets the data group name
        /// </summary>
        public string DataGroupName
        {
            get { return (string)GetValue(DataGroupProperty); }
            set { SetValue(DataGroupProperty, value); }
        }

        // Using a DependencyProperty as the backing store for DataGroup.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty DataGroupProperty =
            DependencyProperty.Register("DataGroupName", typeof(string), typeof(SectionDataGroup), new UIPropertyMetadata(""));
    }
}
