namespace Cake.CodeAnalysisReporting.Tests
{
    using Shouldly;
    using Xunit;

    public sealed class CodeAnalysisReportExtensionsTests
    {
        public sealed class TheGetStyleSheetResourceNameExtension
        {
            [Fact]
            public void Should_Throw_If_Report_Is_Undefined()
            {
                // Given / When
                var result = Record.Exception(() => CodeAnalysisReport.Undefined.GetStyleSheetResourceName());

                // Then
                result.IsArgumentOutOfRangeException("report");
            }

            [Theory]
            [InlineData(CodeAnalysisReport.MsBuildXmlFileLoggerByRule, "msbuild-xmlfilelogger-by-rule.xsl")]
            [InlineData(CodeAnalysisReport.MsBuildXmlFileLoggerByAssembly, "msbuild-xmlfilelogger-by-assembly.xsl")]
            public void Should_Return_Stylesheet_Resource_Name(CodeAnalysisReport report, string expectedResult)
            {
                // When
                var result = report.GetStyleSheetResourceName();

                // Then
                result.ShouldBe(expectedResult);
            }
        }
    }
}
