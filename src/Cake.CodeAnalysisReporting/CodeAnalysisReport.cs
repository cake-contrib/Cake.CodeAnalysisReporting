namespace Cake.CodeAnalysisReporting
{
    /// <summary>
    /// Available out-of-the-box reports.
    /// </summary>
    public enum CodeAnalysisReport
    {
        /// <summary>
        /// Undefined value.
        /// </summary>
        Undefined,

        /// <summary>
        /// Report from a MsBuild logfile genereated by the <code>XmlFileLogger</code> class from
        /// MSBuild Extension Pack grouped by rule number.
        /// </summary>
        MsBuildXmlFileLoggerByRule,

        /// <summary>
        /// Report from a MsBuild logfile genereated by the <code>XmlFileLogger</code> class from
        /// MSBuild Extension Pack grouped by assembly.
        /// </summary>
        MsBuildXmlFileLoggerByAssembly
    }
}
