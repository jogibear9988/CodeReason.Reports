using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Media;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;
using System.Reflection;
using Saxon.Api;

namespace CodeReason.Reports.Math
{
    internal static class MathMLToSVGviaXSLT
    {
        private static XsltTransformer transformer = null;

        public static SVGImage.SVG.SVGImage Convert(Stream mathML)
        {
            var xml = XmlReader.Create(mathML);

            return _convert(xml);
        }

        public static SVGImage.SVG.SVGImage Convert(TextReader mathML)
        {
            var xml = XmlReader.Create(mathML);

            return _convert(xml);
        }

        private static SVGImage.SVG.SVGImage _convert(XmlReader xml)
        {
            var processor = new Processor();

            // Load the source document
            XdmNode input = processor.NewDocumentBuilder().Build(xml);

            // Create a transformer for the stylesheet
            if (transformer == null)
            {
                var file = Path.Combine(System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase), "libs\\pMML2SVG\\pmml2svg.xsl");
                var xslt = XmlReader.Create(file);
                transformer = processor.NewXsltCompiler().Compile(xslt).Load();
            }

            // Set the root node of the source document to be the initial context node
            transformer.InitialContextNode = input;

            var ms = new MemoryStream();

            // Create a serializer
            var serializer = new Serializer();
            serializer.SetOutputStream(ms);

            // Transform the source XML
            transformer.Run(serializer);

            serializer.Close();

            ms.Position = 0;

            var img = new SVGImage.SVG.SVGImage();
            img.SetImage(ms);
            
            return img;
        }
    }
}
