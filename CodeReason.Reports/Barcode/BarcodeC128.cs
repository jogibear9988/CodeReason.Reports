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
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;

namespace CodeReason.Reports.Barcode
{
    /// <summary>
    /// Creates a barcode C128 as a Canvas
    /// </summary>
    public class BarcodeC128 : BarcodeBase
    {
        /// <summary>
        /// Enumeration of all Code 128 sub-types
        /// </summary>
        public enum Code128SubType
        {
            /// <summary>
            /// Code 128 A
            /// </summary>
            A,
            /// <summary>
            /// Code 128 B
            /// </summary>
            B,
            /// <summary>
            /// Code 128 B and C mixed
            /// </summary>
// ReSharper disable InconsistentNaming
            BC,
// ReSharper restore InconsistentNaming
            /// <summary>
            /// Code 128 C
            /// </summary>
            C
        }

        private static char[] _keysA = new char[107];
        private static void GenerateKeysA()
        {
            for (int i = 0; i < 64; i++)
            {
                _keysA[i] = (char)(32 + i);
            }
            for (int i = 64; i < 96; i++)
            {
                _keysA[i] = (char)(i);
            }
            for (int i = 96; i < _keysA.Length; i++)
            {
                _keysA[i] = '0';
            }
        }

        private static char[] _keysB = new char[107];
        private static void GenerateKeysB()
        {
            for (int i = 0; i < 96; i++)
            {
                _keysB[i] = (char)(32 + i);
            }
            for (int i = 96; i < _keysB.Length; i++)
            {
                _keysB[i] = '0';
            }
        }

        private static string[] _keysC = new string[107];
        private static void GenerateKeysC()
        {
            for (int i = 0; i < 100; i++)
            {
                _keysC[i] = String.Format("{0:00}", i);
            }
            for (int i = 100; i < _keysC.Length; i++)
            {
                _keysC[i] = "";
            }
        }

        /// <summary>
        /// Code table
        /// </summary>
        protected string[] CodeTable = new []
            {
                "101111", // 00
                "111011", // 01
                "111110", // 02
                "010112", // 03
                "010211", // 04
                "020111", // 05
                "011102", // 06
                "011201", // 07
                "021101", // 08
                "110102", // 09
                "110201", // 10
                "120101", // 11
                "001121", // 12
                "011021", // 13
                "011120", // 14
                "002111", // 15
                "012011", // 16
                "012110", // 17
                "112100", // 18
                "110021", // 19
                "110120", // 20
                "102101", // 21
                "112001", // 22
                "201020", // 23
                "200111", // 24
                "210011", // 25
                "210110", // 26
                "201101", // 27
                "211001", // 28
                "211100", // 29
                "101012", // 30
                "101210", // 31
                "121010", // 32
                "000212", // 33
                "020012", // 34
                "020210", // 35
                "001202", // 36
                "021002", // 37
                "021200", // 38
                "100202", // 39
                "120002", // 40
                "120200", // 41
                "001022", // 42
                "001220", // 43
                "021020", // 44
                "002012", // 45
                "002210", // 46
                "022010", // 47
                "202010", // 48
                "100220", // 49
                "120020", // 50
                "102002", // 51
                "102200", // 52
                "102020", // 53
                "200012", // 54
                "200210", // 55
                "220010", // 56
                "201002", // 57
                "201200", // 58
                "221000", // 59
                "203000", // 60
                "110300", // 61
                "320000", // 62
                "000113", // 63
                "000311", // 64
                "010013", // 65
                "010310", // 66
                "030011", // 67
                "030110", // 68
                "001103", // 69
                "001301", // 70
                "011003", // 71
                "011300", // 72
                "031001", // 73
                "031100", // 74
                "130100", // 75
                "110003", // 76
                "302000", // 77
                "130001", // 78
                "023000", // 79
                "000131", // 80
                "010031", // 81
                "010130", // 82
                "003101", // 83
                "013001", // 84
                "013100", // 85
                "300101", // 86
                "310001", // 87
                "310100", // 88
                "101030", // 89
                "103010", // 90
                "301010", // 91
                "000032", // 92
                "000230", // 93
                "020030", // 94
                "003002", // 95
                "003200", // 96
                "300002", // 97
                "300200", // 98
                "002030", // 99
                "003020", // 100
                "200030", // 101
                "300020", // 102
                "100301", // 103
                "100103", // 104
                "100121", // 105
                "1220001" // STOP
            };

        private Code128SubType _barcodeSubType = Code128SubType.BC;
        /// <summary>
        /// Gets or sets the barcode sub-type
        /// </summary>
        public Code128SubType BarcodeSubType
        {
            get { return _barcodeSubType; }
            set
            {
                _barcodeSubType = value;
                RedrawAll();
            }
        }

        /// <summary>
        /// Static constructor
        /// </summary>
        static BarcodeC128()
        {
            GenerateKeysA();
            GenerateKeysB();
            GenerateKeysC();
        }

        /// <summary>
        /// Constructor
        /// </summary>
        public BarcodeC128()
        {
            RedrawAll();
        }

        /// <summary>
        /// Gets the index of a char in a char array
        /// </summary>
        /// <param name="array">char array</param>
        /// <param name="ch">char</param>
        /// <returns>index or -1, if not found</returns>
        private static int IndexOfCharArray(char[] array, char ch)
        {
            for (int i = 0; i < array.Length; i++)
            {
                if (array[i] == ch) return i;
            }
            return -1;
        }

        /// <summary>
        /// Gets the index of a string in a string array
        /// </summary>
        /// <param name="array">string array</param>
        /// <param name="str">string</param>
        /// <returns>index or -1, if not found</returns>
        private static int IndexOfStringArray(string[] array, string str)
        {
            for (int i = 0; i < array.Length; i++)
            {
                if (array[i] == str) return i;
            }
            return -1;
        }

        private double DrawCharByIndex(Canvas canvas, double left, double top, double height, int charIndex)
        {
            string sequence = CodeTable[charIndex];

            double width = 0;
            for (int i = 0; i < sequence.Length; i++)
            {
                double lineWidth = 0d;
                switch (sequence[i])
                {
                    case '0':
                        lineWidth = 1d;
                        break;
                    case '1':
                        lineWidth = 2d;
                        break;
                    case '2':
                        lineWidth = 3d;
                        break;
                    case '3':
                        lineWidth = 4d;
                        break;
                }
                if (lineWidth < 1d)
                {
                    throw new ArgumentOutOfRangeException();
                }

                double charWidth = lineWidth; // *XRes;
                //if (g != null)
                //{
                //    if ((i % 2) == 0)
                //        g.FillRectangle(_foreColorBrush, (float)(left + width), _margin.Top, (float)charWidth, (float)height);
                //}
                if (canvas != null)
                {
                    if ((i % 2) == 0)
                    {
                        Rectangle rect = new Rectangle();
                        rect.Fill = BrushBars;
                        rect.RenderTransform = new TranslateTransform(left + width, top);
                        rect.Width = charWidth;
                        rect.Height = height;
                        canvas.Children.Add(rect);
                    }
                }

                width += charWidth;
            }
            return width;
        }

        private List<int> GenerateCodeSequence(string code, out List<BarcodeCharInfo> charInfo)
        {
            List<int> res = new List<int>();
            charInfo = new List<BarcodeCharInfo>();
            bool isB = false;
            if (code == null) code = "";

            // start character first
            switch (_barcodeSubType)
            {
                case Code128SubType.A:
                    res.Add(103);  // Start A
                    break;
                case Code128SubType.B:
                    res.Add(104);  // Start B
                    break;
                case Code128SubType.BC:
                    if ((code.Length >= 2) && (Char.IsDigit(code[0])) && (Char.IsDigit(code[1])))
                    {
                        res.Add(105); // Start C
                    }
                    else
                    {
                        isB = true;
                        res.Add(104); // Start B
                    }
                    break;
                case Code128SubType.C:
                    res.Add(105);  // Start C
                    break;
            }

            // text
            string partC = "";
            for (int i = 0; i < code.Length; i++)
            {
                int charIndex = -1;
                switch (_barcodeSubType)
                {
                    case Code128SubType.A:
                        charIndex = IndexOfCharArray(_keysA, code[i]);
                        charInfo.Add(new BarcodeCharInfo(i, -1, code[i].ToString()));
                        break;
                    case Code128SubType.B:
                        charIndex = IndexOfCharArray(_keysB, code[i]);
                        charInfo.Add(new BarcodeCharInfo(i, -1, code[i].ToString()));
                        break;
                    case Code128SubType.BC:
                        if (isB)
                        {
                            if ((i <= code.Length - 2) && (Char.IsDigit(code[i])) && (Char.IsDigit(code[i + 1])))
                            {
                                isB = false;
                                res.Add(99); // Code C
                                charInfo.Add(new BarcodeCharInfo(i, -1, ""));

                                partC += code[i];
                                if (partC.Length == 2)
                                {
                                    charIndex = IndexOfStringArray(_keysC, partC);
                                    charInfo.Add(new BarcodeCharInfo(i, -1, partC));
                                    partC = "";
                                }
                                else continue;
                            }
                            else
                            {
                                charIndex = IndexOfCharArray(_keysB, code[i]);
                                charInfo.Add(new BarcodeCharInfo(i, -1, code[i].ToString()));
                            }
                        }
                        else
                        {
                            if (partC.Length <= 0)
                            {
                                if ((i >= code.Length - 1) || (!Char.IsDigit(code[i])) || (!Char.IsDigit(code[i + 1])))
                                {
                                    isB = true;
                                    res.Add(100); // Code B
                                    charInfo.Add(new BarcodeCharInfo(i, -1, ""));

                                    charIndex = IndexOfCharArray(_keysB, code[i]);
                                    charInfo.Add(new BarcodeCharInfo(i, -1, code[i].ToString()));
                                    break;
                                }
                            }

                            partC += code[i];
                            if (partC.Length == 2)
                            {
                                charIndex = IndexOfStringArray(_keysC, partC);
                                charInfo.Add(new BarcodeCharInfo(i, -1, partC));
                                partC = "";
                            }
                            else continue;
                        }
                        break;
                    case Code128SubType.C:
                        partC += code[i];
                        if (partC.Length == 2)
                        {
                            charIndex = IndexOfStringArray(_keysC, partC);
                            charInfo.Add(new BarcodeCharInfo(i, -1, partC));
                            partC = "";
                        }
                        else continue;
                        break;
                }

                if (charIndex < 0) throw new ArgumentOutOfRangeException("code", "The barcode value contains an unsupported character \"" + code[i] + "\"");

                res.Add(charIndex);
            }

            if (partC.Length > 0) throw new ArgumentException("Code 128C only supports a even number of characters", "code");
            return res;
        }

        /// <summary>
        /// Redraws the whole barcode
        /// </summary>
        public override void RedrawAll()
        {
            Children.Clear();

            double actualWidth = ActualWidth;
            double actualHeight = ActualHeight;
            if ((double.IsNaN(actualWidth)) || (actualWidth <= 0)) actualWidth = Width;
            if ((double.IsNaN(actualHeight)) || (actualHeight <= 0)) actualHeight = Height;
            if ((double.IsNaN(actualWidth)) || (actualWidth <= 0)) return;
            if ((double.IsNaN(actualHeight)) || (actualHeight <= 0)) return;

            Rect rectClient = new Rect(0, 0, actualWidth, actualHeight);

            if (Value == null) return;

            string text = InlineHasValue.FormatValue(Value, Format);
            if (String.IsNullOrEmpty(text)) return;

            List<BarcodeCharInfo> charInfo;
            List<int> codeSequence = GenerateCodeSequence(text, out charInfo);
            if (codeSequence.Count <= 0) return;

            // override shown text
            if ((Text != null) && (!String.IsNullOrEmpty(Text))) text = Text;

            int checkSum = 0;
            double left = 0;

            // measure barcode first
            double startCharWidth = 0;
            for (int i = 0; i < codeSequence.Count; i++)
            {
                double charWidth = DrawCharByIndex(null, left, 0, 1, codeSequence[i]);
                if (i == 0) startCharWidth = charWidth;
                left += charWidth;

                if (i == 0) checkSum = codeSequence[0]; else checkSum += codeSequence[i] * i;
            }
            double barcodeDataWidth = left - startCharWidth;

            // draw check sum
            left += DrawCharByIndex(null, left, 0, 1, (checkSum % 103)); // Check Sum

            // draw stop char
            left += DrawCharByIndex(null, left, 0, 1, 106); // Stop

            double barcodeWidth = left;

            Canvas canvas = new Canvas();

            // show barcode text
            Label labelText = null;
            double textHeight = 0;
            decimal labelScale = 1;
            TransformGroup tgl = null;
            if (ShowText)
            {
                labelText = new Label();
                labelText.Content = text;
                labelText.Padding = new Thickness(0.25); // HACK: something is not right here
                labelText.FontFamily = FontFamily;
                labelText.FontStretch = FontStretch;
                labelText.FontStyle = FontStyle;
                labelText.FontWeight = FontWeight;
                labelText.FontSize = 1;
                labelText.Measure(new Size(actualWidth, actualHeight));

                labelScale = (decimal)rectClient.Width / (decimal)barcodeWidth * (decimal)barcodeDataWidth / (decimal)labelText.DesiredSize.Width;
                textHeight = labelText.DesiredSize.Height * (double)labelScale;

                // set new size of barcode text
                tgl = new TransformGroup();
                tgl.Children.Add(new ScaleTransform((double)labelScale, (double)labelScale));
                labelText.RenderTransform = tgl;
            }

            // draw barcode now
            left = 0;
            for (int i = 0; i < codeSequence.Count; i++)
            {
                double lineHeight = 1;
                double th = 0;
                if (labelText != null) th = labelText.DesiredSize.Height;
                if ((ShowText) && (i > 0)) lineHeight = (rectClient.Height - (double)labelScale * th / 2) / rectClient.Height;

                double charWidth = DrawCharByIndex(canvas, left, 0, lineHeight, codeSequence[i]);
                left += charWidth;
            }

            // draw check sum
            left += DrawCharByIndex(canvas, left, 0, 1, (checkSum % 103)); // Check Sum

            // draw stop char
            left += DrawCharByIndex(canvas, left, 0, 1, 106); // Stop

            // move text to right place
            if ((ShowText) && (labelText != null))
            {
                tgl.Children.Add(new TranslateTransform(startCharWidth * rectClient.Width / left, rectClient.Height - textHeight));
                Children.Add(labelText);
            }

            TransformGroup tg = new TransformGroup();
            tg.Children.Add(new ScaleTransform(rectClient.Width / left, rectClient.Height - textHeight / 2));
            tg.Children.Add(new TranslateTransform(rectClient.Left, rectClient.Top));
            canvas.RenderTransform = tg;
            Children.Add(canvas);
        }
    }
}
