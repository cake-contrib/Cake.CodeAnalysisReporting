# Build Script

To use the Cake Code Analysis Reporting addin in your Cake file simply import it. Then define a task.

```csharp
#addin "Cake.CodeAnalysisReporting"

Task("create-report").Does(() =>
{
    CreateMsBuildCodeAnalysisReport(
        @"C:\build\msbuild.log",
        Report.MsBuildByAssembly,
        @"C:\build\issuesByAssembly.html");
}
```