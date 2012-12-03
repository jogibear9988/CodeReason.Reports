using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Controls;
using System.Windows.Xps.Packaging;

namespace CodeReason.Reports
{
    public class ReportWorkspace : INotifyPropertyChanged, IDisposable
    {
        private const string TemplateDirectoryName = "Templates";

        private readonly string workingDirectory;
        private DocumentViewer documentViewer;

        public ReportWorkspace(string workingDirectoryPath)
        {
            workingDirectory = workingDirectoryPath;
        }

        /// <summary>
        /// Gets the working directory.
        /// </summary>
        /// <value>The working directory.</value>
        public string WorkingDirectory
        {
            get
            {
                return workingDirectory;
            }
        }

        /// <summary>
        /// Gets or sets the document viewer.
        /// </summary>
        /// <value>The document viewer.</value>
        public DocumentViewer DocumentViewer
        {
            get
            {
                if (documentViewer == null)
                {
                    documentViewer = new DocumentViewer();
                }

                return documentViewer;
            }

            set
            {
                documentViewer = value;
            }
        }

        /// <summary>
        /// Gets the template directory.
        /// </summary>
        /// <value>The template directory.</value>
        public string TemplateDirectory
        {
            get
            {
                return Path.Combine(workingDirectory, TemplateDirectoryName);
            }
        }


        /// <summary>
        /// Previews the report.
        /// </summary>
        /// <param name="reportDocument">The report document.</param>
        /// <param name="data">The data.</param>
        public void PreviewReport(ReportDocument reportDocument, IEnumerable<ReportData> data)
        {
            XpsDocument xps = reportDocument.CreateXpsDocument(data);
            DocumentViewer.Document = xps.GetFixedDocumentSequence();
        }

        /// <summary>
        /// Previews the report.
        /// </summary>
        /// <param name="reportDocument">The report document.</param>
        /// <param name="data">The data.</param>
        public void PreviewReport(ReportDocument reportDocument, ReportData data)
        {
            XpsDocument xps = reportDocument.CreateXpsDocument(data);
            DocumentViewer.Document = xps.GetFixedDocumentSequence();

        }

        /// <summary>
        /// Loads the report from specified filename path.
        /// </summary>
        /// <param name="fileName">Name of the file.</param>
        /// <returns></returns>
        public ReportDocument LoadReport(string fileName)
        {
            if (!File.Exists(fileName))
            {
                throw new FileNotFoundException("Missing report file in specified path", fileName);
            }

            var reportDocument = new ReportDocument();

            var reader = new StreamReader(new FileStream(fileName, FileMode.Open, FileAccess.Read));
            reportDocument.XamlData = reader.ReadToEnd();
            reportDocument.XamlImagePath = this.TemplateDirectory;
            reader.Close();

            return reportDocument;
        }

        public event PropertyChangedEventHandler PropertyChanged;

        /// <summary>
        /// Raises this object's PropertyChanged event.
        /// </summary>
        /// <param name="propertyName">The property that has a new value.</param>
        protected virtual void OnPropertyChanged(string propertyName)
        {
            VerifyPropertyName(propertyName);

            PropertyChangedEventHandler handler = PropertyChanged;
            if (handler != null)
            {
                var e = new PropertyChangedEventArgs(propertyName);
                handler(this, e);
            }
        }

        #region Helper Debug Methods

        /// <summary>
        /// Warns the developer if this object does not have
        /// a public property with the specified name. This
        /// method does not exist and is not called in a Release build.
        /// </summary>
        [Conditional("DEBUG")]
        [DebuggerStepThrough]
        public void VerifyPropertyName(string propertyName)
        {
            // Verify that the property name matches a real,
            // public, instance property on this object.
            if (TypeDescriptor.GetProperties(this)[propertyName] == null)
            {
                Debug.Fail("Invalid property name: " + propertyName);
            }
        }
        #endregion



        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        /// <filterpriority>2</filterpriority>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Child classes can override this method to perform
        /// clean-up logic, such as removing event handlers.
        /// </summary>
        protected virtual void Dispose(bool disposing)
        {
        }

    }
}
