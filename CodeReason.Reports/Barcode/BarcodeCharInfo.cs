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

namespace CodeReason.Reports.Barcode
{
    /// <summary>
    /// Barcode character info
    /// </summary>
    public class BarcodeCharInfo
    {
        private int _index = -1;
        /// <summary>
        /// Index of the character
        /// </summary>
        public int Index
        {
            get { return _index; }
            set { _index = value; }
        }

        private double _left = -1;
        /// <summary>
        /// Character left position
        /// </summary>
        public double Left
        {
            get { return _left; }
            set { _left = value; }
        }

        private string _text = "";
        /// <summary>
        /// Text to be displayed
        /// </summary>
        public string Text
        {
            get { return _text; }
            set { _text = value; }
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="index">Character index</param>
        /// <param name="left">Left position of character</param>
        /// <param name="text">Text to be displayed</param>
        public BarcodeCharInfo(int index, double left, string text)
        {
            _index = index;
            _left = left;
            _text = text;
        }
    }
}
