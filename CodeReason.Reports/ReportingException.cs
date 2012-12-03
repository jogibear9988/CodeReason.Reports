using System;

namespace CodeReason.Reports
{
    /// <summary>
    /// Represents a simple reporting exception
    /// </summary>
    public class ReportingException : ApplicationException
    {
        /// <summary>
        /// Gets the exception message
        /// </summary>
        public new string Message { get; protected set; }

        /// <summary>
        /// Constructor
        /// </summary>
        public ReportingException() : this(null)
        {
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="message">error message</param>
        public ReportingException(string message)
        {
            Message = message;
        }
    }
}
