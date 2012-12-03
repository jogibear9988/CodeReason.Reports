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
using System.Windows.Documents;

namespace CodeReason.Reports
{
    /// <summary>
    /// Dynamic cache class for report paginator
    /// </summary>
    public class ReportPaginatorDynamicCache
    {
        private FlowDocument _flowDocument;
        /// <summary>
        /// Gets the associacted flow document
        /// </summary>
        public FlowDocument FlowDocument
        {
            get { return _flowDocument; }
        }

        private Dictionary<Type, ArrayList> _documentByType = new Dictionary<Type, ArrayList>();
        private Dictionary<Type, ArrayList> _documentByInterface = new Dictionary<Type, ArrayList>();

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="flowDocument">flow document</param>
        public ReportPaginatorDynamicCache(FlowDocument flowDocument)
        {
            _flowDocument = flowDocument;

            BuildCache();
        }

        /// <summary>
        /// Build cache
        /// </summary>
        private void BuildCache()
        {
            DocumentWalker walker = new DocumentWalker();
            walker.VisualVisited += WalkerVisualVisited;
            walker.Walk(_flowDocument);
        }

        private void WalkerVisualVisited(object sender, object visitedObject, bool start)
        {
            if (visitedObject == null) return;
            Type type = visitedObject.GetType();
            if (!_documentByType.ContainsKey(type)) _documentByType[type] = new ArrayList();
            _documentByType[type].Add(visitedObject);

            foreach (Type interfaceType in type.GetInterfaces())
            {
                if (!_documentByInterface.ContainsKey(interfaceType)) _documentByInterface[interfaceType] = new ArrayList();
                _documentByInterface[interfaceType].Add(visitedObject);
            }
        }

        /// <summary>
        /// Gets an ArrayList of all document visual object of a specific type
        /// </summary>
        /// <param name="type">type of document visual object</param>
        /// <returns>empty ArrayList, if type does not exist</returns>
        public ArrayList GetFlowDocumentVisualListByType(Type type)
        {
            if (type == null) return new ArrayList();
            if (!_documentByType.ContainsKey(type)) return new ArrayList();
            return _documentByType[type];
        }

        /// <summary>
        /// Gets an ArrayList of all document visual object of a specific interface
        /// </summary>
        /// <param name="type">type of document visual object</param>
        /// <returns>empty ArrayList, if type does not exist</returns>
        /// <exception cref="ArgumentException">Specified type must be an interface</exception>
        public ArrayList GetFlowDocumentVisualListByInterface(Type type)
        {
            if (type == null) return new ArrayList();
            if (!type.IsInterface) throw new ArgumentException("Specified type must be an interface");
            if (!_documentByInterface.ContainsKey(type)) return new ArrayList();
            return _documentByInterface[type];
        }
    }
}
