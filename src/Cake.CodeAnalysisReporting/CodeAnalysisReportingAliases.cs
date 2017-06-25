namespace Cake.CodeAnalysisReporting
{
    using Core;
    using Core.Annotations;
    using Core.IO;

    /// <summary>
    /// Contains functionality for creating report from code analysis log files.
    /// </summary>
    [CakeAliasCategory("Code Analysis Reporting")]
    public static class CodeAnalysisReportingAliases
    {
        /// <summary>
        /// Creates a report from a MsBuild logfile.
        /// </summary>
        /// <param name="context">The Cake context.</param>
        /// <param name="logFile">Path of the MsBuild logfile.</param>
        /// <param name="report">Type of report which should be created.</param>
        /// <param name="outputFile">Path of the generated report file.</param>
        /// <example>
        /// <para>Creates a report from MsBuild warnings grouped by assembly:</para>
        /// <code>
        /// <![CDATA[
        ///     CreateMsBuildCodeAnalysisReport(
        ///         @"C:\build\msbuild.log",
        ///         Report.MsBuildXmlFileLoggerByAssembly,
        ///         @"C:\build\issuesByAssembly.html");
        /// ]]>
        /// </code>
        /// </example>
        [CakeMethodAlias]
        [CakeAliasCategory("MsBuild")]
        public static void CreateMsBuildCodeAnalysisReport(
            this ICakeContext context,
            FilePath logFile,
            CodeAnalysisReport report,
            FilePath outputFile)
        {
            context.NotNull(nameof(context));
            logFile.NotNull(nameof(logFile));
            report.NotUndefined(nameof(report));
            outputFile.NotNull(nameof(outputFile));

            MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                context.FileSystem,
                logFile,
                report,
                outputFile);
        }

        /// <summary>
        /// Creates a report from a MsBuild logfile.
        /// </summary>
        /// <param name="context">The Cake context.</param>
        /// <param name="logFileContent">Content of the MsBuild logfile.</param>
        /// <param name="styleSheetContent">Content of the stylesheet used to generate the report.</param>
        /// <returns>Content of the report.</returns>
        /// <example>
        /// <para>Creates a report for a logfile loaded to memory and using a stylesheet from memory:</para>
        /// <code>
        /// <![CDATA[
        ///     var reportData =
        ///         CreateMsBuildCodeAnalysisReport(
        ///             myLogFileContent,
        ///             myStyleSheetContent);
        /// ]]>
        /// </code>
        /// </example>
        [CakeMethodAlias]
        [CakeAliasCategory("MsBuild")]
        public static string CreateMsBuildCodeAnalysisReport(
            this ICakeContext context,
            string logFileContent,
            string styleSheetContent)
        {
            context.NotNull(nameof(context));
            logFileContent.NotNullOrWhiteSpace(nameof(logFileContent));
            styleSheetContent.NotNullOrWhiteSpace(nameof(styleSheetContent));

            return MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                logFileContent,
                styleSheetContent);
        }
    }
}
