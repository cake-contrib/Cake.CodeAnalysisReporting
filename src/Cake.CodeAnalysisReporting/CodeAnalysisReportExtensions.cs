namespace Cake.CodeAnalysisReporting
{
    using System;

    /// <summary>
    /// Extensions for <see cref="CodeAnalysisReport"/> enumeration.
    /// </summary>
    internal static class CodeAnalysisReportExtensions
    {
        /// <summary>
        /// Returns the name of the embedded stylesheet for a specific report.
        /// </summary>
        /// <param name="report">Report for which the stylesheet should be returned.</param>
        /// <returns>Content of the stylesheet.</returns>
        public static string GetStyleSheetResourceName(this CodeAnalysisReport report)
        {
            switch (report)
            {
                case CodeAnalysisReport.MsBuildXmlFileLoggerByAssembly:
                    return "msbuild-xmlfilelogger-by-assembly.xsl";

                case CodeAnalysisReport.MsBuildXmlFileLoggerByRule:
                    return "msbuild-xmlfilelogger-by-rule.xsl";

                default:
                    throw new ArgumentOutOfRangeException(nameof(report));
            }
        }
    }
}
