namespace Cake.CodeAnalysisReporting.Tests
{
    using System.IO;
    using Shouldly;
    using Testing;
    using Xunit;

    public sealed class MsBuildCodeAnalysisReporterTests
    {
        public sealed class TheCreateCodeAnalysisReportMethodWithFilePath
        {
            [Fact]
            public void Should_Throw_If_FileSystem_Is_Null()
            {
                // Given / When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        null,
                        @"c:\msbuild.log",
                        CodeAnalysisReport.MsBuildXmlFileLoggerByRule,
                        @"c:\report.html"));

                // Then
                result.IsArgumentNullException("fileSystem");
            }

            [Fact]
            public void Should_Throw_If_LogFile_Is_Null()
            {
                // Given
                var environment = FakeEnvironment.CreateWindowsEnvironment();
                var fileSystem = new FakeFileSystem(environment);

                // When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        fileSystem,
                        null,
                        CodeAnalysisReport.MsBuildXmlFileLoggerByRule,
                        @"c:\report.html"));

                // Then
                result.IsArgumentNullException("logFile");
            }

            [Fact]
            public void Should_Throw_If_Report_Is_Undefined()
            {
                // Given
                var environment = FakeEnvironment.CreateWindowsEnvironment();
                var fileSystem = new FakeFileSystem(environment);

                // When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        fileSystem,
                        @"c:\msbuild.log",
                        CodeAnalysisReport.Undefined,
                        @"c:\report.html"));

                // Then
                result.IsArgumentOutOfRangeException("report");
            }

            [Fact]
            public void Should_Throw_If_OutputFile_Is_Null()
            {
                // Given
                var environment = FakeEnvironment.CreateWindowsEnvironment();
                var fileSystem = new FakeFileSystem(environment);

                // When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        fileSystem,
                        @"c:\msbuild.log",
                        CodeAnalysisReport.MsBuildXmlFileLoggerByRule,
                        null));

                // Then
                result.IsArgumentNullException("outputFile");
            }

            [Theory]
            [InlineData("Test.Cake.Prca.xml", CodeAnalysisReport.MsBuildXmlFileLoggerByAssembly)]
            [InlineData("Test.Cake.Prca.xml", CodeAnalysisReport.MsBuildXmlFileLoggerByRule)]
            public void Should_Return_Report(string logfileResourceName, CodeAnalysisReport report)
            {
                // Given
                var logFileName = Path.GetTempFileName();
                var environment = FakeEnvironment.CreateWindowsEnvironment();
                var fileSystem = new FakeFileSystem(environment);

                using (var ms = new MemoryStream())
                using (var stream = this.GetType().Assembly.GetManifestResourceStream("Cake.CodeAnalysisReporting.Tests.Testfiles." + logfileResourceName))
                {
                    stream.CopyTo(ms);
                    var data = ms.ToArray();

                    fileSystem.CreateFile(logFileName, data);
                }

                var outputFileName = Path.GetTempFileName();
                try
                {
                    // When
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        fileSystem,
                        logFileName,
                        report,
                        outputFileName);

                    // Then
                    File.Exists(outputFileName).ShouldBe(true);
                }
                finally
                {
                    if (File.Exists(outputFileName))
                    {
                        File.Delete(outputFileName);
                    }
                }
            }
        }

        public sealed class TheCreateCodeAnalysisReportMethodWithFileContent
        {
            [Fact]
            public void Should_Throw_If_LogFileContent_Is_Null()
            {
                // Given / When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        null,
                        "Foo"));

                // Then
                result.IsArgumentNullException("logFileContent");
            }

            [Fact]
            public void Should_Throw_If_LogFileContent_Is_Empty()
            {
                // Given / When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        string.Empty,
                        "Foo"));

                // Then
                result.IsArgumentOutOfRangeException("logFileContent");
            }

            [Fact]
            public void Should_Throw_If_LogFileContent_Is_WhiteSpace()
            {
                // Given / When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        " ",
                        "Foo"));

                // Then
                result.IsArgumentOutOfRangeException("logFileContent");
            }

            [Fact]
            public void Should_Throw_If_StyleSheetContent_Is_Null()
            {
                // Given / When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        "Foo",
                        null));

                // Then
                result.IsArgumentNullException("styleSheetContent");
            }

            [Fact]
            public void Should_Throw_If_StyleSheetContent_Is_Empty()
            {
                // Given / When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        "Foo",
                        string.Empty));

                // Then
                result.IsArgumentOutOfRangeException("styleSheetContent");
            }

            [Fact]
            public void Should_Throw_If_StyleSheetContent_Is_WhiteSpace()
            {
                // Given / When
                var result = Record.Exception(() =>
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        "Foo",
                        " "));

                // Then
                result.IsArgumentOutOfRangeException("styleSheetContent");
            }

            [Theory]
            [InlineData("Test.Cake.Prca.xml", "msbuild-xmlfilelogger-by-rule.xsl")]
            [InlineData("Test.Cake.Prca.xml", "msbuild-xmlfilelogger-by-assembly.xsl")]
            public void Should_Return_Report(string logfileResourceName, string reportName)
            {
                // Given
                string logfileContent;
                using (var stream = this.GetType().Assembly.GetManifestResourceStream("Cake.CodeAnalysisReporting.Tests.Testfiles." + logfileResourceName))
                {
                    using (var sr = new StreamReader(stream))
                    {
                        logfileContent = sr.ReadToEnd();
                    }
                }

                // When
                var result =
                    MsBuildCodeAnalysisReporter.CreateCodeAnalysisReport(
                        logfileContent,
                        EmbeddedResourceHelper.GetReportStyleSheet(reportName));

                // Then
                result.ShouldNotBeNullOrWhiteSpace();
            }
        }
    }
}
