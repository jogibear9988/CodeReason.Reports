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

using System.Collections.Generic;
using System.Reflection;

namespace CodeReason.Reports
{
    /// <summary>
    /// Static cache class for report paginator
    /// </summary>
    internal static class ReportPaginatorStaticCache
    {
        private static Dictionary<string, ReportContextValueType> _reportContextValueTypes;

        /// <summary>
        /// Static constructor
        /// </summary>
        static ReportPaginatorStaticCache() 
        {
            // add static cache for report context value names
            _reportContextValueTypes = new Dictionary<string, ReportContextValueType>(20);
            foreach (FieldInfo fi in typeof(ReportContextValueType).GetFields())
            {
                if (((int)fi.Attributes & (int)FieldAttributes.Static) == 0) continue;
                _reportContextValueTypes.Add(fi.Name.ToLowerInvariant(), (ReportContextValueType)fi.GetRawConstantValue());
            }
        }

        /// <summary>
        /// Gets a report context value type by name
        /// </summary>
        /// <param name="name">name of report context value</param>
        /// <returns>null, if it does not exist</returns>
        public static ReportContextValueType? GetReportContextValueTypeByName(string name)
        {
            if (name == null) return null;
            name = name.ToLowerInvariant();
            if (!_reportContextValueTypes.ContainsKey(name)) return null;
            return _reportContextValueTypes[name];
        }
    }
}
