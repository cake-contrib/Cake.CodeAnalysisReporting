<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <xsl:output method="html" indent="yes" omit-xml-declaration="yes" />

  <!--*************************************************************-->
  <!-- Global Variables -->
  <!--*************************************************************-->

  <!-- Root target to analyze -->
  <xsl:variable name="compiler.root" select="//build" />
  <!-- Targets in the log file which should be analyzed -->
  <xsl:variable name="relevantTargets" select="//target[@name='CoreCompile'] | //target[@name='RunCodeAnalysis']" />

  <!-- Create a key for all the rule codes from warnings and errors. -->
  <xsl:key
    name="issuesbycode"
    match="//target[@name='CoreCompile']//warning | //target[@name='CoreCompile']//error | //target[@name='RunCodeAnalysis']//warning | //target[@name='RunCodeAnalysis']//error"
    use="@code"/>
  <!-- Create a key for all the rule codes from errors. -->
  <xsl:key
    name="errorsbycode"
    match="//target[@name='CoreCompile']//error | //target[@name='RunCodeAnalysis']//error"
    use="@code"/>
  <!-- Create a key for all the rule codes from warnings. -->
  <xsl:key
    name="warningsbycode"
    match="//target[@name='CoreCompile']//warning | //target[@name='RunCodeAnalysis']//warning"
    use="@code"/>

  <!--*************************************************************-->
  <!-- Main templates -->
  <!--*************************************************************-->

  <xsl:template match="/">
    <div id="compiler-report">
      <script language="javascript">
        function toggle(rootElement, contentDivId)
        {
        var contentElement = document.getElementById(contentDivId);

        if (contentElement.style.display == 'none')
        contentElement.style.display = '';
        else
        contentElement.style.display = 'none';

        rootElement.classList.toggle('collapsed');
        rootElement.classList.toggle('expanded');
        }
      </script>
      <style type="text/css">
        #compiler-report
        {
        font-family: Arial, Helvetica, sans-serif;
        margin-left: 0;
        margin-right: 0;
        margin-top: 0;
        }

        #compiler-report .header
        {
        background-color: #566077;
        background-repeat: repeat-x;
        color: #fff;
        font-weight: bolder;
        height: 50px;
        vertical-align: middle;
        }

        #compiler-report .headertext
        {
        height: 35px;
        margin-left: 15px;
        padding-top: 15px;
        width: auto;
        }

        #compiler-report .wrapper
        {
        padding-left: 20px;
        padding-right: 20px;
        width: auto;
        }

        #compiler-report .legend
        {
        background-color: #ffc;
        border: #d7ce28 1px solid;
        font-size: small;
        margin-top: 15px;
        padding: 5px;
        vertical-align: middle;
        width: inherit;
        }

        #compiler-report .clickablerow
        {
        cursor: pointer;
        }

        #compiler-report .clickablerow.collapsed .toggleIcon
        {
        background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAwAAAAPCAMAAADnP957AAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAAGUExURWlpaf///1gubPoAAAACdFJOU/8A5bcwSgAAAFZJREFUeNpiYEQCAAHEgMwBCCAQhwEGAAKIAUmWASCAYBwwBgggFA5AAEEYEA0MAAGEIgMQQCgcgABCMQ0ggFDsAQggFBcABBAKByCAUDgAAYTCAQgwADPcAIy9WFq3AAAAAElFTkSuQmCC');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #compiler-report .clickablerow.expanded .toggleIcon
        {
        background-image:  url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAwAAAAPCAMAAADnP957AAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAAGUExURWlpaf///1gubPoAAAACdFJOU/8A5bcwSgAAAFRJREFUeNpiYEQCAAHEgMwBCCAQhwEGAAKIAUmWASCAUDgAAYTCAQggCAeigQEggFBkAAIIhQMQQCgcgABCsQcggFBcABBAKByAAELhAAQQCgcgwAA1kACQrCOu2AAAAABJRU5ErkJggg==');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #compiler-report .tabletotal
        {
        border-top: 1px #000;
        font-weight: 700;
        }

        #compiler-report .results-table
        {
        border-collapse: collapse;
        font-size: 12px;
        margin-top: 20px;
        text-align: left;
        width: 100%;
        }

        #compiler-report .results-table th
        {
        background: #b9c9fe;
        border-bottom: 1px solid #fff;
        border-top: 4px solid #aabcfe;
        color: #039;
        font-size: 13px;
        font-weight: 400;
        padding: 8px;
        }

        #compiler-report .results-table td
        {
        background: #e8edff;
        border-bottom: 1px solid #fff;
        border-top: 1px solid transparent;
        color: #669;
        padding: 5px;
        }

        #compiler-report .results-table td.error
        {
        background-image:url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJPSURBVDjLpZPLS5RhFMYfv9QJlelTQZwRb2OKlKuINuHGLlBEBEOLxAu46oL0F0QQFdWizUCrWnjBaDHgThCMoiKkhUONTqmjmDp2GZ0UnWbmfc/ztrC+GbM2dXbv4ZzfeQ7vefKMMfifyP89IbevNNCYdkN2kawkCZKfSPZTOGTf6Y/m1uflKlC3LvsNTWArr9BT2LAf+W73dn5jHclIBFZyfYWU3or7T4K7AJmbl/yG7EtX1BQXNTVCYgtgbAEAYHlqYHlrsTEVQWr63RZFuqsfDAcdQPrGRR/JF5nKGm9xUxMyr0YBAEXXHgIANq/3ADQobD2J9fAkNiMTMSFb9z8ambMAQER3JC1XttkYGGZXoyZEGyTHRuBuPgBTUu7VSnUAgAUAWutOV2MjZGkehgYUA6O5A0AlkAyRnotiX3MLlFKduYCqAtuGXpyH0XQmOj+TIURt51OzURTYZdBKV2UBSsOIcRp/TVTT4ewK6idECAihtUKOArWcjq/B8tQ6UkUR31+OYXP4sTOdisivrkMyHodWejlXwcC38Fvs8dY5xaIId89VlJy7ACpCNCFCuOp8+BJ6A631gANQSg1mVmOxxGQYRW2nHMha4B5WA3chsv22T5/B13AIicWZmNZ6cMchTXUe81Okzz54pLi0uQWp+TmkZqMwxsBV74Or3od4OISPr0e3SHa3PX0f3HXKofNH/UIG9pZ5PeUth+CyS2EMkEqs4fPEOBJLsyske48/+xD8oxcAYPzs4QaS7RR2kbLTTOTQieczfzfTv8QPldGvTGoF6/8AAAAASUVORK5CYII=');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #compiler-report .results-table td.warning
        {
        background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAIsSURBVDjLpVNLSJQBEP7+h6uu62vLVAJDW1KQTMrINQ1vPQzq1GOpa9EppGOHLh0kCEKL7JBEhVCHihAsESyJiE4FWShGRmauu7KYiv6Pma+DGoFrBQ7MzGFmPr5vmDFIYj1mr1WYfrHPovA9VVOqbC7e/1rS9ZlrAVDYHig5WB0oPtBI0TNrUiC5yhP9jeF4X8NPcWfopoY48XT39PjjXeF0vWkZqOjd7LJYrmGasHPCCJbHwhS9/F8M4s8baid764Xi0Ilfp5voorpJfn2wwx/r3l77TwZUvR+qajXVn8PnvocYfXYH6k2ioOaCpaIdf11ivDcayyiMVudsOYqFb60gARJYHG9DbqQFmSVNjaO3K2NpAeK90ZCqtgcrjkP9aUCXp0moetDFEeRXnYCKXhm+uTW0CkBFu4JlxzZkFlbASz4CQGQVBFeEwZm8geyiMuRVntzsL3oXV+YMkvjRsydC1U+lhwZsWXgHb+oWVAEzIwvzyVlk5igsi7DymmHlHsFQR50rjl+981Jy1Fw6Gu0ObTtnU+cgs28AKgDiy+Awpj5OACBAhZ/qh2HOo6i+NeA73jUAML4/qWux8mt6NjW1w599CS9xb0mSEqQBEDAtwqALUmBaG5FV3oYPnTHMjAwetlWksyByaukxQg2wQ9FlccaK/OXA3/uAEUDp3rNIDQ1ctSk6kHh1/jRFoaL4M4snEMeD73gQx4M4PsT1IZ5AfYH68tZY7zv/ApRMY9mnuVMvAAAAAElFTkSuQmCC');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #compiler-report .errorlist td
        {
        background: #FFF;
        border-bottom: 0;
        border-top: 0 solid transparent;
        color: #000;
        padding: 0;
        }

        #compiler-report .inner-results
        {
        border-collapse: collapse;
        font-size: 12px;
        margin-bottom: 3px;
        margin-top: 4px;
        text-align: left;
        width: 100%;
        }

        #compiler-report .inner-results td
        {
        background: #FFF;
        border-bottom: 1px solid #fff;
        border-top: 1px solid transparent;
        color: #669;
        padding: 3px;
        }

        #compiler-report .inner-results td.error
        {
        background-image:url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJPSURBVDjLpZPLS5RhFMYfv9QJlelTQZwRb2OKlKuINuHGLlBEBEOLxAu46oL0F0QQFdWizUCrWnjBaDHgThCMoiKkhUONTqmjmDp2GZ0UnWbmfc/ztrC+GbM2dXbv4ZzfeQ7vefKMMfifyP89IbevNNCYdkN2kawkCZKfSPZTOGTf6Y/m1uflKlC3LvsNTWArr9BT2LAf+W73dn5jHclIBFZyfYWU3or7T4K7AJmbl/yG7EtX1BQXNTVCYgtgbAEAYHlqYHlrsTEVQWr63RZFuqsfDAcdQPrGRR/JF5nKGm9xUxMyr0YBAEXXHgIANq/3ADQobD2J9fAkNiMTMSFb9z8ambMAQER3JC1XttkYGGZXoyZEGyTHRuBuPgBTUu7VSnUAgAUAWutOV2MjZGkehgYUA6O5A0AlkAyRnotiX3MLlFKduYCqAtuGXpyH0XQmOj+TIURt51OzURTYZdBKV2UBSsOIcRp/TVTT4ewK6idECAihtUKOArWcjq/B8tQ6UkUR31+OYXP4sTOdisivrkMyHodWejlXwcC38Fvs8dY5xaIId89VlJy7ACpCNCFCuOp8+BJ6A631gANQSg1mVmOxxGQYRW2nHMha4B5WA3chsv22T5/B13AIicWZmNZ6cMchTXUe81Okzz54pLi0uQWp+TmkZqMwxsBV74Or3od4OISPr0e3SHa3PX0f3HXKofNH/UIG9pZ5PeUth+CyS2EMkEqs4fPEOBJLsyske48/+xD8oxcAYPzs4QaS7RR2kbLTTOTQieczfzfTv8QPldGvTGoF6/8AAAAASUVORK5CYII=');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #compiler-report .inner-results td.warning
        {
        background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAIsSURBVDjLpVNLSJQBEP7+h6uu62vLVAJDW1KQTMrINQ1vPQzq1GOpa9EppGOHLh0kCEKL7JBEhVCHihAsESyJiE4FWShGRmauu7KYiv6Pma+DGoFrBQ7MzGFmPr5vmDFIYj1mr1WYfrHPovA9VVOqbC7e/1rS9ZlrAVDYHig5WB0oPtBI0TNrUiC5yhP9jeF4X8NPcWfopoY48XT39PjjXeF0vWkZqOjd7LJYrmGasHPCCJbHwhS9/F8M4s8baid764Xi0Ilfp5voorpJfn2wwx/r3l77TwZUvR+qajXVn8PnvocYfXYH6k2ioOaCpaIdf11ivDcayyiMVudsOYqFb60gARJYHG9DbqQFmSVNjaO3K2NpAeK90ZCqtgcrjkP9aUCXp0moetDFEeRXnYCKXhm+uTW0CkBFu4JlxzZkFlbASz4CQGQVBFeEwZm8geyiMuRVntzsL3oXV+YMkvjRsydC1U+lhwZsWXgHb+oWVAEzIwvzyVlk5igsi7DymmHlHsFQR50rjl+981Jy1Fw6Gu0ObTtnU+cgs28AKgDiy+Awpj5OACBAhZ/qh2HOo6i+NeA73jUAML4/qWux8mt6NjW1w599CS9xb0mSEqQBEDAtwqALUmBaG5FV3oYPnTHMjAwetlWksyByaukxQg2wQ9FlccaK/OXA3/uAEUDp3rNIDQ1ctSk6kHh1/jRFoaL4M4snEMeD73gQx4M4PsT1IZ5AfYH68tZY7zv/ApRMY9mnuVMvAAAAAElFTkSuQmCC');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #compiler-report .inner-header th
        {
        background: #b9c9fe;
        color: #039;
        }

        #compiler-report .inner-rule-description
        {
        background-color: transparent;
        border-collapse: collapse;
        border: 0px;
        font-size: 12px;
        margin-bottom: 3px;
        margin-top: 4px;
        text-align: left;
        width: 100%;
        }

        #compiler-report .inner-rule-description tr
        {
        background-color: transparent;
        border: 0px;
        }

        #compiler-report .inner-rule-description td
        {
        background-color: transparent;
        border: 0px;
        }
      </style>
      <xsl:apply-templates select="$compiler.root" />
    </div>
  </xsl:template>

  <xsl:template match="build">
    <!-- Remove .sln file from path to get the path of the solution file -->
    <xsl:variable name="solutionPath">
      <xsl:call-template name="removeLastPathPart">
        <xsl:with-param name="path" select=".//project/@file[1]"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- Assume source code is in a sub folder of the repository and remove this path to get to the repository root -->
    <xsl:variable name="repositoryRoot">
      <xsl:call-template name="removeLastPathPart">
        <xsl:with-param name="path" select="substring($solutionPath,1,string-length($solutionPath)-1)"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- Remove repository root path to get the common path containing all repositories -->
    <xsl:variable name="buildRootPath">
      <xsl:call-template name="removeLastPathPart">
        <xsl:with-param name="path" select="substring($repositoryRoot,1,string-length($repositoryRoot)-1)"/>
      </xsl:call-template>
    </xsl:variable>

    <div class="wrapper">
      <div class="legend">
        <div>
          Assemblies checked: <xsl:value-of select="count(//target[@name='CoreCompile'])" /><br />
          Warnings: <xsl:value-of select="count($relevantTargets//warning)" /><br />
          Errors: <xsl:value-of select="count($relevantTargets//error)"/><br />
          Total Messages: <xsl:value-of select="count($relevantTargets//warning)+count($relevantTargets//error)"/><br />
        </div>
      </div>
      <table class='results-table'>
        <thead>
          <tr>
            <th scope='col'></th>
            <th scope='col'></th>
            <th scope='col'>Code</th>
            <th scope='col'>Warnings</th>
            <th scope='col'>Errors</th>
            <th scope='col'>Total Messages</th>
          </tr>
        </thead>
        <tbody>
          <xsl:variable name="messages" select="$relevantTargets//warning | $relevantTargets//error" />

          <!-- Group issues by rule code -->
          <xsl:apply-templates select="$messages[generate-id(.)=generate-id(key('issuesbycode',@code)[1])]">
            <!-- Sort issues by rule code -->
            <xsl:sort select="@code"/>
            <xsl:with-param name="buildRootPath" select="$buildRootPath" />
          </xsl:apply-templates>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!--
  Template to be run for any warning or error reporting in the build log.
  
  Parameters:
    buildRootPath: Root path for all the builds. This path will be truncated from the location
  -->
  <xsl:template match="warning|error">
    <xsl:param name="buildRootPath" />
    
    <xsl:call-template name="print-module-error-list-bycode">
      <xsl:with-param name="buildRootPath" select="$buildRootPath" />
    </xsl:call-template>    
  </xsl:template>

  <!--
  Outputs the table entries for a single warning or error.
  
  Parameters:
    buildRootPath: Root path for all the builds. This path will be truncated from the location
  -->
  <xsl:template name="print-module-error-list-bycode">
    <xsl:param name="buildRootPath" />
    <xsl:variable name="module.id" select="generate-id()" />
    <xsl:variable name="imageClass">
      <xsl:choose>
        <xsl:when test="count(key('errorsbycode', @code)) > 0">error</xsl:when>
        <xsl:when test="count(key('warningsbycode', @code)) > 0">warning</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <tr class="clickablerow collapsed" onclick="toggle(this, '{$module.id}')">
      <td style="width: 10px" class="toggleIcon">
      </td>
      <td style="width: 16px" class="{$imageClass}">
      </td>
      <td>
        <xsl:value-of select="@code" />
      </td>
      <td>
        <xsl:value-of select="count(key('warningsbycode', @code))" />
      </td>
      <td>
        <xsl:value-of select="count(key('errorsbycode', @code))"/>
      </td>
      <td>
        <xsl:value-of select="count(key('issuesbycode', @code))"/>
      </td>
    </tr>
    <tr id="{$module.id}" class="errorlist" style="display: none">
      <td></td>
      <td colspan="6">
        <table cellpadding="2" cellspacing="0" width="100%" class="inner-results">
          <thead>
            <tr class="inner-header">
              <th scope='col'></th>
              <th scope='col'>Location</th>
              <th scope='col'>Message</th>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="key('issuesbycode', @code)">
              <xsl:sort select="@file"/>

              <xsl:variable name="message.id" select="generate-id()" />
              <xsl:variable name="rule.check.id" select="@CheckId" />
              <xsl:variable name="innerImageClass">
                <xsl:choose>
                  <xsl:when test="name() = 'error'">error</xsl:when>
                  <xsl:when test="name() = 'warning'">warning</xsl:when>
                  <xsl:otherwise>unknown</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <tr>
                <td style="width: 16px" class="{$innerImageClass}">
                </td>
                <td>
                  <!-- Remove build root folder from affected file name, to improve layout -->
                  <xsl:variable name="shortFileName">
                    <xsl:call-template name="removeRoot">
                      <xsl:with-param name="path" select="./@file" />
                      <xsl:with-param name="buildRootPath" select="$buildRootPath" />
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="@file!=''">
                      <xsl:value-of select="$shortFileName" /> (<xsl:value-of select="@line" />, <xsl:value-of select="@column" />)
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:choose>
                        <xsl:when test="@line='-1'">
                          -
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="@line" />, <xsl:value-of select="@column" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <xsl:variable name="message" select="substring-after(text(),': ')"/>
                  <xsl:choose>
                    <xsl:when test="$message =''">
                      <xsl:value-of select="text()" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$message" />
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </td>
    </tr>
  </xsl:template>

  <!--*************************************************************-->
  <!-- Helper templates -->
  <!--*************************************************************-->

  <!--
  Removes the last part of a path being it either a file name or directory.
  -->
  <xsl:template name="removeLastPathPart">
    <xsl:param name="path" />
    <xsl:choose>
      <xsl:when test="contains($path,'\')">
        <xsl:value-of select="substring-before($path,'\')" />
        <xsl:text>\</xsl:text>
        <xsl:call-template name="removeLastPathPart">
          <xsl:with-param name="path" select="substring-after($path,'\')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>

  <!--
  Removes the beginning of a specific path.
  -->
  <xsl:template name="removeRoot">
    <xsl:param name="path" />
    <xsl:param name="buildRootPath" />
    <xsl:choose>
      <xsl:when test="starts-with($path, $buildRootPath)">
        <xsl:value-of select="substring($path,string-length($buildRootPath)+1)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="compiletask">
          <xsl:call-template name="removeLastPathPart">
            <xsl:with-param name="path" select="parent::task/@file[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="substring($compiletask,string-length($buildRootPath)+1)" />
        <xsl:value-of select="$path" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>