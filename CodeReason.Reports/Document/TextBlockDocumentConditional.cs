using System;
using System.Windows.Controls;
using CodeReason.Reports.Interfaces;

namespace CodeReason.Reports.Document
{
    /// <summary>
    /// TextBlock which is visible if document conditional is met
    /// </summary>
    public class TextBlockDocumentConditional : TextBlock, IDocumentCondition
    {
        /// <summary>
        /// Inverts the condition
        /// </summary>
        public bool ConditionInvert { get; set; }

        /// <summary>
        /// Condition property name
        /// </summary>
        public string ConditionPropertyName { get; set; }

        /// <summary>
        /// Condition property value
        /// </summary>
        public object ConditionPropertyValue { get; set; }

        /// <summary>
        /// Checks if a condition is fulfilled
        /// </summary>
        /// <param name="reportData">report data</param>
        /// <returns>true, if condition is fulfilled</returns>
        /// <exception cref="ArgumentNullException">reportData</exception>
        public bool CheckConditionFulfilled(ReportData reportData)
        {
            if (reportData == null) throw new ArgumentNullException("reportData");
            if (ConditionPropertyName == null) return false;

            object currentValue;
            if (!reportData.ReportDocumentValues.TryGetValue(ConditionPropertyName, out currentValue)) return false;

            if (currentValue == null)
                return (ConditionPropertyValue == null);
            return (currentValue.ToString().Equals(ConditionPropertyValue));
        }

        /// <summary>
        /// Changes the visibility of this TextBlock if needed
        /// </summary>
        /// <param name="data">report document data</param>
        public void PerformRenderUpdate(ReportData data)
        {
            bool visible = CheckConditionFulfilled(data);
            if (ConditionInvert) visible = !visible;
            Visibility = visible ? System.Windows.Visibility.Visible : System.Windows.Visibility.Collapsed;
        }
    }
}
