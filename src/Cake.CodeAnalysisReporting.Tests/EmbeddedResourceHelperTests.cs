namespace Cake.CodeAnalysisReporting.Tests
{
    using Shouldly;
    using Xunit;

    public sealed class EmbeddedResourceHelperTests
    {
        public sealed class TheGetReportStyleSheetMethod
        {
            [Fact]
            public void Should_Throw_If_ReportName_Is_Null()
            {
                // Given / When
                var result = Record.Exception(() => EmbeddedResourceHelper.GetReportStyleSheet(null));

                // Then
                result.IsArgumentNullException("reportName");
            }

            [Fact]
            public void Should_Throw_If_ReportName_Is_Empty()
            {
                // Given / When
                var result = Record.Exception(() => EmbeddedResourceHelper.GetReportStyleSheet(string.Empty));

                // Then
                result.IsArgumentOutOfRangeException("reportName");
            }

            [Fact]
            public void Should_Throw_If_ReportName_Is_WhiteSpace()
            {
                // Given / When
                var result = Record.Exception(() => EmbeddedResourceHelper.GetReportStyleSheet(" "));

                // Then
                result.IsArgumentOutOfRangeException("reportName");
            }

            [Fact]
            public void Should_Throw_If_Unknown_Report_Name()
            {
                // Given / When
                var result = Record.Exception(() => EmbeddedResourceHelper.GetReportStyleSheet("Foo"));

                // Then
                result.IsArgumentOutOfRangeException("reportName");
            }

            [Theory]
            [InlineData("msbuild-xmlfilelogger-by-assembly.xsl")]
            [InlineData("msbuild-xmlfilelogger-by-rule.xsl")]
            public void Should_Read_Embedded_Resource(string reportName)
            {
                // When
                var result = EmbeddedResourceHelper.GetReportStyleSheet(reportName);

                // Then
                result.ShouldNotBeNullOrWhiteSpace();
            }
        }
    }
}
