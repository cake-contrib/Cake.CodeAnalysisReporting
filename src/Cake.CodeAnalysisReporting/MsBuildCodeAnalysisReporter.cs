namespace Cake.CodeAnalysisReporting
{
    using System.IO;
    using System.Text;
    using System.Xml;
    using System.Xml.Xsl;
    using Core.IO;

    /// <summary>
    /// Class for creating reports from code analysis logfiles.
    /// </summary>
    internal static class MsBuildCodeAnalysisReporter
    {
        /// <summary>
        /// Creates a report from a MsBuild logfile.
        /// </summary>
        /// <param name="fileSystem">Cake file system instance.</param>
        /// <param name="logFile">Path of the MsBuild logfile.</param>
        /// <param name="report">Type of report which should be created.</param>
        /// <param name="outputFile">Path of the generated report file.</param>
        public static void CreateCodeAnalysisReport(
            IFileSystem fileSystem,
            FilePath logFile,
            CodeAnalysisReport report,
            FilePath outputFile)
        {
            fileSystem.NotNull(nameof(fileSystem));
            logFile.NotNull(nameof(logFile));
            report.NotUndefined(nameof(report));
            outputFile.NotNull(nameof(outputFile));

            var xmlFile = fileSystem.GetFile(logFile);
            var resultFile = fileSystem.GetFile(outputFile);

            using (Stream
                xmlStream = xmlFile.OpenRead(),
                resultStream = resultFile.OpenWrite())
            {
                var xslReader = XmlReader.Create(new StringReader(report.GetStyleSheetResourceName()));
                var xmlReader = XmlReader.Create(xmlStream);

                var resultWriter =
                    XmlWriter.Create(
                        resultStream,
                        GetSettings());

                Transform(xslReader, xmlReader, resultWriter);
            }
        }

        /// <summary>
        /// Creates a report from a MsBuild logfile.
        /// </summary>
        /// <param name="logFileContent">Content of the MsBuild logfile.</param>
        /// <param name="styleSheetContent">Content of the stylesheet used to generate the report.</param>
        /// <returns>Content of the report.</returns>
        public static string CreateCodeAnalysisReport(
            string logFileContent,
            string styleSheetContent)
        {
            logFileContent.NotNullOrWhiteSpace(nameof(logFileContent));
            styleSheetContent.NotNullOrWhiteSpace(nameof(styleSheetContent));

            using (TextReader
                xslReader = new StringReader(styleSheetContent),
                xmlReader = new StringReader(logFileContent))
            {
                using (var result = new MemoryStream())
                {
                    Transform(xslReader, xmlReader, result, GetSettings());
                    result.Position = 0;
                    return Encoding.UTF8.GetString(result.ToArray());
                }
            }
        }

        private static XmlWriterSettings GetSettings()
        {
            return new XmlWriterSettings
            {
                OmitXmlDeclaration = true,
                Indent = true,
                Encoding = Encoding.UTF8
            };
        }

        private static void Transform(TextReader xsl, TextReader xml, Stream result, XmlWriterSettings settings)
        {
            xsl.NotNull(nameof(xsl));
            xml.NotNull(nameof(xml));
            result.NotNull(nameof(result));

            var xslXmlReader = XmlReader.Create(xsl);
            var xmlXmlReader = XmlReader.Create(xml);
            var resultXmlTextWriter = XmlWriter.Create(result, settings);
            Transform(xslXmlReader, xmlXmlReader, resultXmlTextWriter);
        }

        private static void Transform(XmlReader xsl, XmlReader xml, XmlWriter result)
        {
            xsl.NotNull(nameof(xsl));
            xml.NotNull(nameof(xml));
            result.NotNull(nameof(result));

            var xslTransform = new XslCompiledTransform();
            xslTransform.Load(xsl);
            xslTransform.Transform(xml, result);
        }
    }
}
