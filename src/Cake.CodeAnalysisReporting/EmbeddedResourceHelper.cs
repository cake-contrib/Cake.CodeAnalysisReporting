namespace Cake.CodeAnalysisReporting
{
    using System;
    using System.IO;

    /// <summary>
    /// Helper class for reading embedded resources.
    /// </summary>
    internal static class EmbeddedResourceHelper
    {
        /// <summary>
        /// Returns the content of an embedded stylesheet.
        /// </summary>
        /// <param name="reportName">Name of the stylesheet.</param>
        /// <returns>Content of an embedded stylesheet.</returns>
        public static string GetReportStyleSheet(string reportName)
        {
            reportName.NotNullOrWhiteSpace(nameof(reportName));

            using (var stream = typeof(EmbeddedResourceHelper).Assembly.GetManifestResourceStream("Cake.CodeAnalysisReporting.Reports." + reportName))
            {
                if (stream == null)
                {
                    throw new ArgumentOutOfRangeException(nameof(reportName));
                }

                using (var sr = new StreamReader(stream))
                {
                    return sr.ReadToEnd();
                }
            }
        }
    }
}
