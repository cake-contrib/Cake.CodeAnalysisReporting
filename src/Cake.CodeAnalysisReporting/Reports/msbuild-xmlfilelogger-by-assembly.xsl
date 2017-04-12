<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                version="2.0">

  <xsl:output method="html" indent="yes" omit-xml-declaration="yes" />

  <!--*************************************************************-->
  <!-- Global Variables -->
  <!--*************************************************************-->

  <!-- Root target to analyze -->
  <xsl:variable name="msbuild.root" select="//build" />

  <!--*************************************************************-->
  <!-- Main templates -->
  <!--*************************************************************-->

  <xsl:template match="/">
    <div id="msbuild-report">
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
        #msbuild-report
        {
        font-family: Arial, Helvetica, sans-serif;
        margin-left: 0;
        margin-right: 0;
        margin-top: 0;
        }

        #msbuild-report .header
        {
        background-color: #566077;
        background-repeat: repeat-x;
        color: #fff;
        font-weight: bolder;
        height: 50px;
        vertical-align: middle;
        }

        #msbuild-report .headertext
        {
        height: 35px;
        margin-left: 15px;
        padding-top: 15px;
        width: auto;
        }

        #msbuild-report .wrapper
        {
        padding-left: 20px;
        padding-right: 20px;
        width: auto;
        }

        #msbuild-report .legend
        {
        background-color: #ffc;
        border: #d7ce28 1px solid;
        font-size: small;
        margin-top: 15px;
        padding: 5px;
        vertical-align: middle;
        width: inherit;
        }

        #msbuild-report .clickablerow
        {
        cursor: pointer;
        }

        #msbuild-report .clickablerow.collapsed .toggleIcon
        {
        background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAwAAAAPCAMAAADnP957AAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAAGUExURWlpaf///1gubPoAAAACdFJOU/8A5bcwSgAAAFZJREFUeNpiYEQCAAHEgMwBCCAQhwEGAAKIAUmWASCAYBwwBgggFA5AAEEYEA0MAAGEIgMQQCgcgABCMQ0ggFDsAQggFBcABBAKByCAUDgAAYTCAQgwADPcAIy9WFq3AAAAAElFTkSuQmCC');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #msbuild-report .clickablerow.expanded .toggleIcon
        {
        background-image:  url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAwAAAAPCAMAAADnP957AAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAAGUExURWlpaf///1gubPoAAAACdFJOU/8A5bcwSgAAAFRJREFUeNpiYEQCAAHEgMwBCCAQhwEGAAKIAUmWASCAUDgAAYTCAQggCAeigQEggFBkAAIIhQMQQCgcgABCsQcggFBcABBAKByAAELhAAQQCgcgwAA1kACQrCOu2AAAAABJRU5ErkJggg==');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #msbuild-report .tabletotal
        {
        border-top: 1px #000;
        font-weight: 700;
        }

        #msbuild-report .results-table
        {
        border-collapse: collapse;
        font-size: 12px;
        margin-top: 20px;
        text-align: left;
        width: 100%;
        }

        #msbuild-report .results-table th
        {
        background: #b9c9fe;
        border-bottom: 1px solid #fff;
        border-top: 4px solid #aabcfe;
        color: #039;
        font-size: 13px;
        font-weight: 400;
        padding: 8px;
        }

        #msbuild-report .results-table td
        {
        background: #e8edff;
        border-bottom: 1px solid #fff;
        border-top: 1px solid transparent;
        color: #669;
        padding: 5px;
        }

        #msbuild-report .results-table td.error
        {
        background-image:url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJPSURBVDjLpZPLS5RhFMYfv9QJlelTQZwRb2OKlKuINuHGLlBEBEOLxAu46oL0F0QQFdWizUCrWnjBaDHgThCMoiKkhUONTqmjmDp2GZ0UnWbmfc/ztrC+GbM2dXbv4ZzfeQ7vefKMMfifyP89IbevNNCYdkN2kawkCZKfSPZTOGTf6Y/m1uflKlC3LvsNTWArr9BT2LAf+W73dn5jHclIBFZyfYWU3or7T4K7AJmbl/yG7EtX1BQXNTVCYgtgbAEAYHlqYHlrsTEVQWr63RZFuqsfDAcdQPrGRR/JF5nKGm9xUxMyr0YBAEXXHgIANq/3ADQobD2J9fAkNiMTMSFb9z8ambMAQER3JC1XttkYGGZXoyZEGyTHRuBuPgBTUu7VSnUAgAUAWutOV2MjZGkehgYUA6O5A0AlkAyRnotiX3MLlFKduYCqAtuGXpyH0XQmOj+TIURt51OzURTYZdBKV2UBSsOIcRp/TVTT4ewK6idECAihtUKOArWcjq/B8tQ6UkUR31+OYXP4sTOdisivrkMyHodWejlXwcC38Fvs8dY5xaIId89VlJy7ACpCNCFCuOp8+BJ6A631gANQSg1mVmOxxGQYRW2nHMha4B5WA3chsv22T5/B13AIicWZmNZ6cMchTXUe81Okzz54pLi0uQWp+TmkZqMwxsBV74Or3od4OISPr0e3SHa3PX0f3HXKofNH/UIG9pZ5PeUth+CyS2EMkEqs4fPEOBJLsyske48/+xD8oxcAYPzs4QaS7RR2kbLTTOTQieczfzfTv8QPldGvTGoF6/8AAAAASUVORK5CYII=');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #msbuild-report .results-table td.warning
        {
        background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAIsSURBVDjLpVNLSJQBEP7+h6uu62vLVAJDW1KQTMrINQ1vPQzq1GOpa9EppGOHLh0kCEKL7JBEhVCHihAsESyJiE4FWShGRmauu7KYiv6Pma+DGoFrBQ7MzGFmPr5vmDFIYj1mr1WYfrHPovA9VVOqbC7e/1rS9ZlrAVDYHig5WB0oPtBI0TNrUiC5yhP9jeF4X8NPcWfopoY48XT39PjjXeF0vWkZqOjd7LJYrmGasHPCCJbHwhS9/F8M4s8baid764Xi0Ilfp5voorpJfn2wwx/r3l77TwZUvR+qajXVn8PnvocYfXYH6k2ioOaCpaIdf11ivDcayyiMVudsOYqFb60gARJYHG9DbqQFmSVNjaO3K2NpAeK90ZCqtgcrjkP9aUCXp0moetDFEeRXnYCKXhm+uTW0CkBFu4JlxzZkFlbASz4CQGQVBFeEwZm8geyiMuRVntzsL3oXV+YMkvjRsydC1U+lhwZsWXgHb+oWVAEzIwvzyVlk5igsi7DymmHlHsFQR50rjl+981Jy1Fw6Gu0ObTtnU+cgs28AKgDiy+Awpj5OACBAhZ/qh2HOo6i+NeA73jUAML4/qWux8mt6NjW1w599CS9xb0mSEqQBEDAtwqALUmBaG5FV3oYPnTHMjAwetlWksyByaukxQg2wQ9FlccaK/OXA3/uAEUDp3rNIDQ1ctSk6kHh1/jRFoaL4M4snEMeD73gQx4M4PsT1IZ5AfYH68tZY7zv/ApRMY9mnuVMvAAAAAElFTkSuQmCC');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #msbuild-report .errorlist td
        {
        background: #FFF;
        border-bottom: 0;
        border-top: 0 solid transparent;
        color: #000;
        padding: 0;
        }

        #msbuild-report .inner-results
        {
        border-collapse: collapse;
        font-size: 12px;
        margin-bottom: 3px;
        margin-top: 4px;
        text-align: left;
        width: 100%;
        }

        #msbuild-report .inner-results td
        {
        background: #FFF;
        border-bottom: 1px solid #fff;
        border-top: 1px solid transparent;
        color: #669;
        padding: 3px;
        }

        #msbuild-report .inner-results td.error
        {
        background-image:url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJPSURBVDjLpZPLS5RhFMYfv9QJlelTQZwRb2OKlKuINuHGLlBEBEOLxAu46oL0F0QQFdWizUCrWnjBaDHgThCMoiKkhUONTqmjmDp2GZ0UnWbmfc/ztrC+GbM2dXbv4ZzfeQ7vefKMMfifyP89IbevNNCYdkN2kawkCZKfSPZTOGTf6Y/m1uflKlC3LvsNTWArr9BT2LAf+W73dn5jHclIBFZyfYWU3or7T4K7AJmbl/yG7EtX1BQXNTVCYgtgbAEAYHlqYHlrsTEVQWr63RZFuqsfDAcdQPrGRR/JF5nKGm9xUxMyr0YBAEXXHgIANq/3ADQobD2J9fAkNiMTMSFb9z8ambMAQER3JC1XttkYGGZXoyZEGyTHRuBuPgBTUu7VSnUAgAUAWutOV2MjZGkehgYUA6O5A0AlkAyRnotiX3MLlFKduYCqAtuGXpyH0XQmOj+TIURt51OzURTYZdBKV2UBSsOIcRp/TVTT4ewK6idECAihtUKOArWcjq/B8tQ6UkUR31+OYXP4sTOdisivrkMyHodWejlXwcC38Fvs8dY5xaIId89VlJy7ACpCNCFCuOp8+BJ6A631gANQSg1mVmOxxGQYRW2nHMha4B5WA3chsv22T5/B13AIicWZmNZ6cMchTXUe81Okzz54pLi0uQWp+TmkZqMwxsBV74Or3od4OISPr0e3SHa3PX0f3HXKofNH/UIG9pZ5PeUth+CyS2EMkEqs4fPEOBJLsyske48/+xD8oxcAYPzs4QaS7RR2kbLTTOTQieczfzfTv8QPldGvTGoF6/8AAAAASUVORK5CYII=');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #msbuild-report .inner-results td.warning
        {
        background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAIsSURBVDjLpVNLSJQBEP7+h6uu62vLVAJDW1KQTMrINQ1vPQzq1GOpa9EppGOHLh0kCEKL7JBEhVCHihAsESyJiE4FWShGRmauu7KYiv6Pma+DGoFrBQ7MzGFmPr5vmDFIYj1mr1WYfrHPovA9VVOqbC7e/1rS9ZlrAVDYHig5WB0oPtBI0TNrUiC5yhP9jeF4X8NPcWfopoY48XT39PjjXeF0vWkZqOjd7LJYrmGasHPCCJbHwhS9/F8M4s8baid764Xi0Ilfp5voorpJfn2wwx/r3l77TwZUvR+qajXVn8PnvocYfXYH6k2ioOaCpaIdf11ivDcayyiMVudsOYqFb60gARJYHG9DbqQFmSVNjaO3K2NpAeK90ZCqtgcrjkP9aUCXp0moetDFEeRXnYCKXhm+uTW0CkBFu4JlxzZkFlbASz4CQGQVBFeEwZm8geyiMuRVntzsL3oXV+YMkvjRsydC1U+lhwZsWXgHb+oWVAEzIwvzyVlk5igsi7DymmHlHsFQR50rjl+981Jy1Fw6Gu0ObTtnU+cgs28AKgDiy+Awpj5OACBAhZ/qh2HOo6i+NeA73jUAML4/qWux8mt6NjW1w599CS9xb0mSEqQBEDAtwqALUmBaG5FV3oYPnTHMjAwetlWksyByaukxQg2wQ9FlccaK/OXA3/uAEUDp3rNIDQ1ctSk6kHh1/jRFoaL4M4snEMeD73gQx4M4PsT1IZ5AfYH68tZY7zv/ApRMY9mnuVMvAAAAAElFTkSuQmCC');
        background-repeat: no-repeat;
        background-position-y: center;
        }

        #msbuild-report .inner-header th
        {
        background: #b9c9fe;
        color: #039;
        }

        #msbuild-report .inner-rule-description
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

        #msbuild-report .inner-rule-description tr
        {
        background-color: transparent;
        border: 0px;
        }

        #msbuild-report .inner-rule-description td
        {
        background-color: transparent;
        border: 0px;
        }
      </style>
      <xsl:apply-templates select="$msbuild.root" />
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
          Total Warnings: <xsl:value-of select="count(//warning)" /><br />
          Total Errors: <xsl:value-of select="count(//error)"/><br />
          Total Messages: <xsl:value-of select="count(//warning)+count(//error)"/><br />
        </div>
      </div>
      <table class='results-table'>
        <thead>
          <tr>
            <th scope='col'></th>
            <th scope='col'></th>
            <th scope='col'>Assembly</th>
            <th scope='col'>Warnings</th>
            <th scope='col'>Errors</th>
            <th scope='col'>Total Messages</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="//project">
            <xsl:sort select="./@file"/>

            <xsl:call-template name="print-module">
              <xsl:with-param name="buildRootPath" select="$buildRootPath" />
            </xsl:call-template>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!--
  Outputs the table entries for a single assembly.
  
  Parameters:
    buildRootPath: Root path for all the builds. This path will be truncated from the location
  -->
  <xsl:template name="print-module">
    <xsl:param name="buildRootPath" />

    <xsl:variable name="thisProject" select="." />
    <!-- All warnings and errors below this project. -->
    <xsl:variable name="allWarningsErrors" select=".//warning | .//error" />
    <!-- All warnings and errors below this project, but not part of another project. -->
    <xsl:variable name="allDirectWarningsErrors" select="$allWarningsErrors[generate-id($thisProject)=generate-id(ancestor::project[1])]" />

    <!-- Only output projects with at least one issue. -->
    <xsl:if test="count($allDirectWarningsErrors) &gt; 0" >
      <xsl:variable name="module.id" select="generate-id()" />
      <xsl:variable name="imageClass">
        <xsl:choose>
          <xsl:when test="count($allDirectWarningsErrors[name() = 'error']) > 0">error</xsl:when>
          <xsl:when test="count($allDirectWarningsErrors[name() = 'warning']) > 0">warning</xsl:when>
          <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <tr class="clickablerow collapsed" onclick="toggle(this, '{$module.id}')">
        <td style="width: 10px" class="toggleIcon">
        </td>
        <td style="width: 16px" class="{$imageClass}">
        </td>
        <td>
          <xsl:call-template name="removeRoot">
            <xsl:with-param name="path" select="./@file" />
            <xsl:with-param name="buildRootPath" select="$buildRootPath" />
          </xsl:call-template>
        </td>
        <td>
          <xsl:value-of select="count($allDirectWarningsErrors[name() = 'warning'])" />
        </td>
        <td>
          <xsl:value-of select="count($allDirectWarningsErrors[name() = 'error'])"/>
        </td>
        <td>
          <xsl:value-of select="count($allDirectWarningsErrors)"/>
        </td>
      </tr>

      <xsl:variable name="projectRootPath">
        <xsl:call-template name="removeLastPathPart">
          <xsl:with-param name="path" select="./@file"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:call-template name="print-module-error-list">
        <xsl:with-param name="module.id" select="$module.id"/>
        <xsl:with-param name="allDirectWarningsErrors" select="$allDirectWarningsErrors"/>
        <xsl:with-param name="buildRootPath" select="$buildRootPath"/>
        <xsl:with-param name="projectRootPath" select="$projectRootPath"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="print-module-error-list">
    <xsl:param name="module.id" />
    <xsl:param name="allDirectWarningsErrors" />
    <xsl:param name="buildRootPath" />
    <xsl:param name="projectRootPath" />

    <tr id="{$module.id}" class="errorlist" style="display: none">
      <td></td>
      <td colspan="6">
        <table cellpadding="2" cellspacing="0" width="100%" class="inner-results">
          <thead>
            <tr class="inner-header">
              <th scope='col'></th>
              <th scope='col'>Source</th>
              <th scope='col'>Location</th>
              <th scope='col'>Code</th>
              <th scope='col'>Category</th>
              <th scope='col'>Message</th>
            </tr>
          </thead>
          <tbody>
            <xsl:variable name="tempWithCode">
              <xsl:for-each select="$allDirectWarningsErrors">
                <message>
                  <xsl:attribute name="source">
                    <xsl:value-of select="ancestor::target[1]/@name" />
                  </xsl:attribute>
                  <xsl:attribute name="type">
                    <xsl:value-of select="name()" />
                  </xsl:attribute>

                  <xsl:choose>
                    <xsl:when test="@code">
                      <xsl:attribute name="code">
                        <xsl:value-of select="@code" />
                      </xsl:attribute>
                      <xsl:attribute name="message">
                        <xsl:value-of select="text()" />
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:attribute name="code">
                        <xsl:value-of select="substring-before(text(),' :')" />
                      </xsl:attribute>
                      <xsl:attribute name="message">
                        <xsl:if test="substring-after(text(),': ') = ''">
                          <xsl:value-of select="text()" />
                        </xsl:if>
                        <xsl:if test="substring-after(text(),': ') != ''">
                          <xsl:value-of select="substring-after(text(),': ')" />
                        </xsl:if>
                      </xsl:attribute>
                    </xsl:otherwise>
                  </xsl:choose>

                  <xsl:attribute name="line">
                    <xsl:value-of select="@line" />
                  </xsl:attribute>
                  <xsl:attribute name="column">
                    <xsl:value-of select="@column" />
                  </xsl:attribute>
                  <xsl:attribute name="file">
                    <xsl:value-of select="@file" />
                  </xsl:attribute>
                </message>
              </xsl:for-each>
            </xsl:variable>
                        
            <xsl:for-each select="msxsl:node-set($tempWithCode)/*">
              <xsl:sort select="@source"/>
              <xsl:sort select="@code"/>

              <xsl:variable name="message.id" select="generate-id()" />
              <xsl:variable name="rule.check.id" select="@CheckId" />
              <xsl:variable name="innerImageClass">
                <xsl:choose>
                  <xsl:when test="@type = 'error'">error</xsl:when>
                  <xsl:when test="@type = 'warning'">warning</xsl:when>
                  <xsl:otherwise>unknown</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              
              <tr>
                <td style="width: 16px" class="{$innerImageClass}">
                </td>
                <td>
                  <xsl:value-of select="@source" />
                </td>
                <td>
                  <xsl:choose>
                    <xsl:when test="@file!=''">
                      <xsl:call-template name="removeRoot">
                        <xsl:with-param name="path" select="@file" />
                        <xsl:with-param name="buildRootPath" select="$projectRootPath" />
                      </xsl:call-template>
                      (<xsl:value-of select="@line" />, <xsl:value-of select="@column" />)
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
                  <xsl:value-of select="@code" />
                </td>
                <td>
                  <xsl:value-of select="substring-before(@message,' :')" />
                </td>
                <td>
                  <xsl:if test="substring-after(@message,': ') = ''">
                    <xsl:value-of select="@message" />
                  </xsl:if>
                  <xsl:if test="substring-after(@message,': ') != ''">
                    <xsl:value-of select="substring-after(@message,': ')" />
                  </xsl:if>
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