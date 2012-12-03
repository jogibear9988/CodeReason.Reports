/************************************************************************
 * Copyright: Hans Wolff
 *
 * License:  This software abides by the LGPL license terms. For further
 *           licensing information please see the top level LICENSE.txt 
 *           file found in the root directory of CodeReason Reports.
 *
 * Authors:  Hans Wolff, Theo Zographos
 *
 ************************************************************************/

using System;
using System.Collections.Generic;

namespace CodeReason.Reports.Document
{
    /// <summary>
    /// Computes a single aggregate report value that is to be displayed on the report (e.g. report title)
    /// </summary>
    public class InlineAggregateValue : InlineHasValue
    {
        private string _aggregateGroup;
        /// <summary>
        /// Gets or sets the aggregate group
        /// </summary>
        public string AggregateGroup
        {
            get { return _aggregateGroup; }
            set { _aggregateGroup = value; }
        }

        private ReportAggregateValueType _aggregateValueType = ReportAggregateValueType.Count;
        /// <summary>
        /// Gets or sets the report value aggregate type
        /// </summary>
        public ReportAggregateValueType AggregateValueType
        {
            get { return _aggregateValueType; }
            set { _aggregateValueType = value; }
        }

        private string _emptyValue = "";
        /// <summary>
        /// Gets or sets the value which is shown if the computation has no result
        /// </summary>
        public string EmptyValue
        {
            get { return _emptyValue; }
            set { _emptyValue = value; }
        }

        private string _errorValue = "!ERROR!";
        /// <summary>
        /// Gets or sets the value which is shown if the computation fails
        /// </summary>
        public string ErrorValue
        {
            get { return _errorValue; }
            set { _errorValue = value; }
        }

        /// <summary>
        /// Computes an aggregate value and formats it
        /// </summary>
        /// <param name="values">list of values</param>
        /// <returns>calculated and formatted value</returns>
        /// <exception cref="NotSupportedException">The aggregate value type {0} is not supported yet!</exception>
        public string ComputeAndFormat(Dictionary<string, List<object>> values)
        {
            if ((values == null) || (values.Count <= 0)) return _emptyValue;

            string[] groups = _aggregateGroup.Split(new char[] { ',', ';', ' ' }, StringSplitOptions.RemoveEmptyEntries);
            decimal? result = null;
            bool isTimeSpan = false;
            long count = 0;
            foreach (var group in groups)
            {
                if (!values.ContainsKey(group)) return _emptyValue;

                foreach (object value in values[group])
                {
                    count++;
                    if (_aggregateValueType == ReportAggregateValueType.Count) continue; // count needs no real calculation

                    decimal thisValue;
                    if (value == null) return _errorValue;
                    if (value is TimeSpan)
                    {
                        thisValue = Convert.ToDecimal(((TimeSpan)value).Ticks);
                        isTimeSpan = true;
                    }
                    else
                    {
                        if (!Decimal.TryParse(value.ToString(), out thisValue)) return _errorValue;
                    }
                    switch (_aggregateValueType)
                    {
                        case ReportAggregateValueType.Average:
                        case ReportAggregateValueType.Sum:
                            if (result == null) { result = thisValue; break; }
                            result += thisValue;
                            break;
                        case ReportAggregateValueType.Maximum:
                            if (result == null) { result = thisValue; break; }
                            if (thisValue > result) result = thisValue;
                            break;
                        case ReportAggregateValueType.Minimum:
                            if (result == null) { result = thisValue; break; }
                            if (thisValue < result) result = thisValue;
                            break;
                        default:
                            throw new NotSupportedException(String.Format("The aggregate value type {0} is not supported yet!", _aggregateValueType));
                    }
                }
            }
            if (_aggregateValueType == ReportAggregateValueType.Count) result = count;
            if (result == null) return _emptyValue;

            if (_aggregateValueType == ReportAggregateValueType.Average) result /= count; // calculate average

            if (isTimeSpan) return TimeSpan.FromTicks(Convert.ToInt64(result)).ToString();  //for timespans

            return FormatValue(result, Format);
        }
    }

    /// <summary>
    /// Enumeration of available aggregate types
    /// </summary>
    public enum ReportAggregateValueType
    {
        /// <summary>
        /// Computes the average value
        /// </summary>
        Average,
        /// <summary>
        /// Gets the values count
        /// </summary>
        Count,
        /// <summary>
        /// Determines the maximum value
        /// </summary>
        Maximum,
        /// <summary>
        /// Determines the minimum value
        /// </summary>
        Minimum,
        /// <summary>
        /// Computes the sum over all values
        /// </summary>
        Sum
    }
}
