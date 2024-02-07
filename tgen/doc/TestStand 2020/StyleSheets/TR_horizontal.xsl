<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n1="http://www.ieee.org/ATML/2007/TestResults" xmlns:c="http://www.ieee.org/ATML/2006/Common" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:user="http://www.ni.com/TestStand/ATML/4.5" xmlns:ts="www.ni.com/TestStand/ATMLTestResults/1.0" id="TS20.0.0">
	<!--This alias is added so that the html output does not contain these namespaces. The omit-xml-declaration attribute of xsl:output element did not prevent the addition of these namespaces to the html output-->
	<xsl:namespace-alias stylesheet-prefix="xsl" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="n1" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="c" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="xsi" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="msxsl" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="user" result-prefix="#default"/>
	<xsl:namespace-alias stylesheet-prefix="ts" result-prefix="#default"/>
	<msxsl:script language="javascript" implements-prefix="user">
  <![CDATA[	
	//Utility functions for escaping stylesheetpath, getting absolute image paths	
    //Image Paths are added from msxsl script because if xslt templates are used the path
    //containing unicode characters are converted into %ascicode characters which won't work on a japanese machine
	
	var gStyleSheetPathPrefix = "";


	
	function InitializeStylesheetPath(stylesheetPath)
	{
		
		gStyleSheetPathPrefix = GetFolderPath(stylesheetPath);
		return "";
	}
	
	// This function first converts all back-slashes into forward-slashes and then
	// removes the file name part of the input file path
	function GetFolderPath(sFilePath)
	{
		var sConvertedFilePath;
		var index = sFilePath.indexOf("\\");
		if (index == -1)
			sConvertedFilePath = sFilePath;
		else
		{
			sConvertedFilePath = "";
			do
			{
				sConvertedFilePath += sFilePath.substring(0,index) + "/";
				sFilePath = sFilePath.substring(index+1,sFilePath.length);
				index = sFilePath.indexOf("\\");
			}
			while (index != -1);
			sConvertedFilePath += sFilePath;
		}

		var sFolderPath = "";

		index = sConvertedFilePath.lastIndexOf("/");
		if (index != -1)
			sFolderPath = sConvertedFilePath.substring(0,index) + "/";

		return sFolderPath;
	}
	
	function GetAbsolutePath(fName) 
	{
		return gStyleSheetPathPrefix + fName; 
	}	
	
	function GetExpandCollapseImage(putImage)
	{
		var imgsrc = GetAbsolutePath('minus.png');
		if (putImage)
			return '<img alt="" src="'+ imgsrc + '" width="18" height="13" class="state:expanded" onclick="ExpCollAll(this)"/>';
		else
			return "";
	}
	
	
	function GetTableExpandCollapseImage(putImage)
	{
		var imgsrc = GetAbsolutePath('minus.png');
		if (putImage)
			return '<img alt="" src="' + imgsrc + '" width="18" height="13" class="state:expanded" onclick="HideUnhideSequence(this)"/>';
		else
			return "";
	}
	
	function GetPropertyExpandCollapseImage(putImage)
	{
		var imgsrc = GetAbsolutePath('plus.png');
		if (putImage)
			return '<img alt="" src="' + imgsrc + '" width="18" height="13" class="state:collapsed" onclick="ExpandCollapse(this)"/>';
		else
			return " ";
	}

	// 'gIsTableTagOpen' is used to save the state of a current table to check whether it open or not.
	var gIsTableTagOpen = false;
			
	//The global variable 'gCollectAsserts' is a boolean flag which indicates whether all asserts shall be collected and displayed at the end of the generated report.
	var gCollectAsserts = false; 
				
	// 'gCollectionOfAllAsserts' stores all the asserts that are being generated while the report is processed.
	var gCollectionOfAllAsserts = null;
				
	//This method creates a new table.
	function StartTable()
	{
		var retVal = "";	
		if (!gIsTableTagOpen) {
			retVal = "<br><table style='width:70%'>\n" +
						"<tr>\n" +
						"<td rowspan='2' style='width:30%' align='center' valign='bottom'><b>Step</b></td>\n" +
						"<td rowspan='2' style='width:8%' align='center' valign='bottom'><b>Status</b></td>\n" +
						"<td rowspan='2' style='width:17%' align='center' valign='bottom'><b>Measurement</b></td>\n" +
						"<td colspan='4' style='width:45%' align='center' valign='bottom'><b>Limits</b></td>\n" +
                        //CREATE_EXTRA_COLUMNS: Users needs to add extra columns here if needed. The data for the 
						//columns need to be added in ADD_COLUMN_DATA
				        //Ex:To add another column having 'Extra information' as the column header
				        //"<td rowspan='2' valign='bottom' align='center' style='width:20%'><span style='font-size:0.63em;'><b>StepID</b></span></td>\n" +  						
						"</tr>\n" +
						"<tr>\n" +
						"<td style='width:16%' align='center' valign='bottom'><b>Nominal Value</b></td>\n" +
						"<td style='width:16%' align='center' valign='bottom'><b>Low Limit</b></td>\n" +
						"<td style='width:16%' align='center' valign='bottom'><b>High Limit</b></td>\n" +
						"<td style='width:13%' align='center' valign='bottom'><b>Comparison Type</b></td>\n" +
						"</tr>\n";
			gIsTableTagOpen = true;
		}
		return retVal;
	}
			
	//This method closes the current table.
	function EndTable()
	{
		var retVal = "";
		if (gIsTableTagOpen)
		{
			retVal = "</table>";
			gIsTableTagOpen = false;
		}
		return retVal;	
	}
			
	//This method is used to query the state of the current table being processed from XSLT.
	function isTableOpen()
	{
		return gIsTableTagOpen;
	}	           
	
	// This method initializes 'gCollectAsserts' and 'gCollectionOfAllAsserts' which are used to collect asserts and display them at the end of the report. 
	function InitAssertMode()
	{
		gCollectAsserts = true;
		if (null === gCollectionOfAllAsserts)
		{
			gCollectionOfAllAsserts = new Array();
		}
		return "";
	}
	
	// This method adds an assert message to 'gCollectionOfAllAsserts'.
	function AddAssert(assertMessage)
	{
		if (gCollectAsserts)
		{
			gCollectionOfAllAsserts[gCollectionOfAllAsserts.length] = assertMessage;
		}
		return "";
	}
	
	// This method generates a table which contains all the assert messages generated while the report is processed.
	function GetAssertTable()
	{
		var retVal = "";
		if (gCollectAsserts)
		{
			var index = 0; 	
			var allAssertTRs = "";
			var noOfAsserts = gCollectionOfAllAsserts.length;
			while (index < noOfAsserts)
			{
				allAssertTRs += "<tr>\n<td align='left'><span style='font-size:0.63em;'>" + 
										 gCollectionOfAllAsserts[index] +
										 "</span></td>\n</tr>\n";
				++index;                     
			} 
			if (noOfAsserts !== 0)
			{
				retVal = "<br/><table style='width:50%'>\n" +
							"<tr>\n" +
							"<td align='center' valign='bottom'><b>Asserts generated while processing the report</b></td>\n" +
							"</tr>\n";
				retVal += allAssertTRs;
				retVal += "</table>\n";
			}
		}
		return retVal;
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	/**
		Functions to compute the limit threshold values
	**/
	function GetLimitThresholdValue(thresholdType, limitType, nominal, lowHigh, isLow)
	{
		var computedLimitValue = 0;
		var returnValue = "";
		
		thresholdType = thresholdType.item(0).text;
		limitType = limitType.item(0).nodeValue;
		nominal = nominal.item(0).nodeValue;
		lowHigh = lowHigh.item(0).nodeValue;
		
		var base = 0;
		var prefix = "";
		var isDecimal = false;
		var isUnsigned = false;
		var missingTestStandNumberPrefix = "";
		
		switch (limitType)
		{
			case "c:binary" :
				base = 2;
				prefix = missingTestStandNumberPrefix = "0b";
				break;
			case "c:octal" :
				base = 8;
				prefix = missingTestStandNumberPrefix = "0c";
				break;
			case "c:hexadecimal" :
				base = 16;
				prefix = missingTestStandNumberPrefix = "0x";
				break;
			case "c:unsignedInteger" :
				base = 10;
				isUnsigned = true;
				break;
		    case "c:integer" :
				base = 10;
				break;
		    default :
				base = 10;
				prefix = "";
				isDecimal = true;
				break;
		}

		var nominalDecimal = Number(nominal);
		var lowHighDecimal = Number(lowHigh); 
		var lowhigh = lowHigh.toString();
		var nominalString = nominal.toString();
		
		if(lowhigh == "INF")
			lowHighDecimal = +Infinity;
		else if(lowhigh == "-INF")
			lowHighDecimal = -Infinity;
		
		if(nominalString == "INF")
			nominalDecimal = +Infinity;
		else if(nominalString == "-INF")
			nominalDecimal = -Infinity;
		
		var sign = "-";
		var thresholdTypeSymbol = "%";
		var space = " ";
		
		var sign = "-";
		var thresholdTypeSymbol = "%";
		var space = " ";
		
		switch (thresholdType)
		{
			case "PERCENTAGE" :
				if (isLow == true)
				{
					if(nominalDecimal > 0)
					{
					computedLimitValue = nominalDecimal - lowHighDecimal/100*nominalDecimal;
					}
					else
					{
					computedLimitValue = nominalDecimal + lowHighDecimal/100*nominalDecimal;
					sign = "+";
					}
				}
				else
				{   if(nominalDecimal > 0)
					{
					computedLimitValue = nominalDecimal + lowHighDecimal/100*nominalDecimal;
					sign = "+";
					}
					else
					{
					computedLimitValue = nominalDecimal - lowHighDecimal/100*nominalDecimal;
					}
				}
				break;
			
			case "PPM" :
				if (isLow == true)
				{
					if(nominalDecimal > 0)
					{
					computedLimitValue = nominalDecimal - lowHighDecimal/1000000*nominalDecimal;
					}
					else
					{
					computedLimitValue = nominalDecimal + lowHighDecimal/1000000*nominalDecimal;
					sign = "+";
					}
				}
				else
				{	if(nominalDecimal > 0)
					{
					computedLimitValue = nominalDecimal + lowHighDecimal/1000000*nominalDecimal;
					sign = "+";
					}
					else
					{
					computedLimitValue = nominalDecimal - lowHighDecimal/1000000*nominalDecimal;
					}
				}
				thresholdTypeSymbol = "PPM";
				break;
				
			case "DELTA" :
				if (isLow == true)
				{
					computedLimitValue = nominalDecimal - lowHighDecimal;
				}
				else
				{
					computedLimitValue = nominalDecimal + lowHighDecimal;
					sign = "+";
				}
				thresholdTypeSymbol = "";
				space = "";
				break;
		}
		
		if (isDecimal == false)
		{
			computedLimitValue = Math.floor(computedLimitValue);
			lowHighDecimal = Math.floor(lowHighDecimal);
		}
					
		
		if (isNaN(computedLimitValue) == true)
		{
			if(isNaN(lowHighDecimal) == true )
			{
				returnValue = prefix + "NAN" + " (Nominal " + sign + " " + missingTestStandNumberPrefix + 
                    "NAN" + space + thresholdTypeSymbol + ")";
			}
			else if(lowHighDecimal == +Infinity || lowHighDecimal == -Infinity)
			{
				returnValue = prefix + "NAN" + " (Nominal " + sign + " " + missingTestStandNumberPrefix + 
                    (lowHighDecimal < 0 ? "-INF" : "+INF") + space + thresholdTypeSymbol + ")";
			}
			else
			{
				returnValue = prefix + "NAN"  + " (Nominal " + sign + " " + missingTestStandNumberPrefix + 
                    (isUnsigned? (lowHighDecimal >>> 0).toString(base): lowHighDecimal.toString(base)) + space + thresholdTypeSymbol + ")";
			}
	
		}
		else if(computedLimitValue == +Infinity || computedLimitValue == -Infinity || lowHighDecimal == +Infinity || lowHighDecimal == -Infinity)
		{				
			if(lowHighDecimal == +Infinity || lowHighDecimal == -Infinity)
			{
				returnValue = prefix + (computedLimitValue < 0 ? "-INF" : "+INF")  + " (Nominal " + sign + " " + missingTestStandNumberPrefix + 
                    (lowHighDecimal < 0 ? "-INF" : "+INF") + space + thresholdTypeSymbol + ")";
			}
			else
			{
				returnValue = prefix + (computedLimitValue < 0 ? "-INF" : "+INF")  + " (Nominal " + sign + " " + missingTestStandNumberPrefix + 
                    (isUnsigned? (lowHighDecimal >>> 0).toString(base): lowHighDecimal.toString(base)) + space + thresholdTypeSymbol + ")";
			}
		}
		else
		{
			returnValue = prefix + (isUnsigned? (computedLimitValue >>> 0).toString(base) : computedLimitValue.toString(base)) + " (Nominal " + sign + " " + missingTestStandNumberPrefix + 
                            (isUnsigned? (lowHighDecimal >>> 0).toString(base) : lowHighDecimal.toString(base)) + space + thresholdTypeSymbol + ")";
		}
				
		return returnValue;
	}
	
	var tagsToReplace = {
		'&': '&amp;',
		'<': '&lt;',
		'>': '&gt;', 
		'"': '&quot;', 
		'\'': '&apos;'
	};
	
	function replaceTag(tag) {
		return tagsToReplace[tag] || tag;
	}
	
	function safe_tags_replace(str) {
		return str.replace(/[&<>]/g, replaceTag);
	}	
	
	function ReplaceWhitespaceAndNewLine(nodelist, disableOutputEscape)
	{
		var node = nodelist.item(0);
		var valueChildNode = node.selectSingleNode("Value");
		var text = "";

		if (valueChildNode)
		    text = valueChildNode.text;
		else
		    text = node.text;
		    
		if (!disableOutputEscape)
			text = safe_tags_replace(text);

		var sRet = "";
		var newLine = "<br/>";
		var index = text.indexOf("\n");
		
		if (index == -1)
			sRet = text;
		while(index != -1)
		{
			sRet += text.substring(0,index) + newLine;
			text = text.substring(index+1,text.length);
			index = text.indexOf("\n");
			if (index == -1)
				sRet += text;
		}
		
		var newText = sRet;
		sRet = "";
	
		if (newText != "")
		{
			var slashR = "\\r";
			index = newText.indexOf(slashR);
			
			if (index == -1)
				sRet = newText;
			else
			{
				while(index != -1)
				{
					sRet += newText.substring(0,index);
					newText = newText.substring(index+2, newText.length);
					index = newText.indexOf(slashR);
					if (index == -1)
						sRet += newText;
				}
			}
		}
		
		// Replace white spaces where necessary
		
		var tempNode = "";
		var stringBuild = "";
		var regex = /(((<[^>]*>)+)([^<]*)((<\/[^>]*>)+))|<([a-zA-Z]|\d)[^>]*>/gm;
		var match = null;
		var prevIndex = 0;
		var regexFound = false;
		while ((match = regex.exec(sRet)) !== null) 
		{
			// This is necessary to avoid infinite loops with zero-width matches
			if (match.index === regex.lastIndex) 
			{
				regex.lastIndex++;
			}
			regexFound = true;
			tempNode = sRet.slice(prevIndex,match.index+1);
			tempNode = tempNode.replace(/ /gm, '&nbsp;');
			tempNode = tempNode.replace(/\t/gm, '&nbsp;&nbsp;&nbsp;&nbsp;');
			tempNode += sRet.slice(match.index+1, regex.lastIndex);
			stringBuild += tempNode;
			tempNode = "";
			prevIndex = regex.lastIndex;
		}
		if (regexFound && prevIndex<sRet.length)
		{
			tempNode = sRet.slice(prevIndex, sRet.length);
			tempNode = tempNode.replace(/ /gm, '&nbsp;');
			tempNode = tempNode.replace(/\t/gm, '&nbsp;&nbsp;&nbsp;&nbsp;');
			stringBuild += tempNode;
		}
		else if (!regexFound)
		{
			stringBuild = sRet.replace(/ /gm, '&nbsp;');
			stringBuild = stringBuild.replace(/\t/gm, '&nbsp;&nbsp;&nbsp;&nbsp;');
		}
		else if (stringBuild == "")
		{
			stringBuild = "&nbsp;"
		}
		return stringBuild;
	}	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	]]></msxsl:script>
	<xsl:output method="html" indent="no" omit-xml-declaration="yes" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" media-type="text/html"/>
	<!-- A global variable to hold the path to the directory that contains the stylesheet (the path ends with a '/'). -->
	<xsl:variable name="gStylesheetPath">
		<xsl:call-template name="GetStylesheetPath"/>
	</xsl:variable>
	<!-- A global variable which controls the indentation of all sequence tables. 
          If set to 'false()', all the sequence tables will have the same level of indentation.-->
	<xsl:variable name="gIndentTables" select="true()"/>
	<!-- A global variable which specifies whether the transformed HTML report shall be displayed as a plain HTML.
          If set to 'true()', the transformed HTML report will be displayed in fully expanded state without any expand/collapse functionality.-->
	<xsl:variable name="gGeneratePlainHTML" select="false()"/>
	<!-- A global variable to control the display of TestStand specific information for all the steps logged in the report.
         If set to 'true()', TestStand specific information for all steps will be displayed in the transformed HTML report.-->
	<xsl:variable name="gShowTestStandSpecificInformation" select="false()"/>
	<!-- A global variable which specifies whether the asserts present in the XSL code shall be evaluated or not.
         If set to 'true()', all the asserts present in the XSL code will be evaluated for validity.-->
	<xsl:variable name="gProcessAsserts" select="false()"/>
	<!-- A global variable which specifies whether the transformation of the report into HTML shall be aborted if an assert condition fails to validate.
         If set to 'true()', a partially tranformed HTML report will be displayed to user along with an assert message specifying the reason behind aborting the transformation.
         If set to 'false()', the transformation of the report to HTML won't be aborted even if an assert condition fails to validate. Assert messages specifying the assert conditions 
                                 that failed to validate will be displayed in form of a table (having the header of the table named as "Asserts generated while processing the report") 
                                 at the end of the transformed HTML report.
         NOTE: 'gTerminateOnAssert' is effective only if 'gProcessAsserts' is set to 'true()'.-->
	<xsl:variable name="gTerminateOnAssert" select="false()"/>
	<!--INITIALIZE_NUMBER_OF_CUSTOM_COLUMNS-->
	<!-- A global variable which specifies the number of custom columns added by the user. -->
	<xsl:variable name="gNoOfCustomColumns" select="0"/>
	<!-- Global column span variables -->
	<xsl:variable name="gFirstColumnSpan" select="7 + $gNoOfCustomColumns"/>
	<xsl:variable name="gSecondColumnSpan" select="6 + $gNoOfCustomColumns"/>
	<xsl:variable name="gThirdColumnSpan" select="5 + $gNoOfCustomColumns"/>
	<!-- A global variable which specfies the number of empty <td> HTML tags to be added for a row that displays Step information.-->
	<xsl:variable name="gStepEmptyCells">
		<xsl:call-template name="GetStepEmptyCells">
			<xsl:with-param name="noOfEmptyCells" select="$gThirdColumnSpan - $gNoOfCustomColumns"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- A global variable which specifies the number of empty <td> HTML tags to be added for a row that displays Limit information for steps of Multiple Numeric Limit type-->
	<xsl:variable name="gMultiNumericLimitEmptyCells">
		<xsl:call-template name="GetStepEmptyCells">
			<xsl:with-param name="noOfEmptyCells" select="$gNoOfCustomColumns"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- A global variable to hold the number of pixels that make up a single space-->
	<xsl:variable name="gSingleSpaceValue" select="5"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>XML Report</title>
				<style type="text/css">
					body {font-family:verdana;font-size:1.1em;}
					table{font-size: 0.55em;border:0.1em outset silver;border-collapse:collapse;padding:0.4em;}
					td{border:0.1em outset silver;border-collapse:collapse;padding:0.4em;white-space:nowrap;}
					.trHide{display:none;}
					.trUnhide{display:100%;}
					.divHide{display:none;}
					.divIndentUnhide{position:relative; left:30px; display:block;}
					.divWithoutIndentUnhide{display:block;}
					hr{width:87%;height:2px;text-align:left;margin-left:0;color:gray;background-color:gray;border-style:groove;}
				</style>
				<script type="text/javascript"><![CDATA[
				//The global variable 'gStyleSheetPath' stores the path to the stylesheet.
				var gStyleSheetPath = ""; 
						
				//The global variable 'gIndentTables' is a boolean flag which indicates whether tables should be indented or not.
				var gIndentTables = true;
					
				// This method initializes all the javascript global variables.
				//'gStyleSheetPath' (stylesheet path)
				//'gIndentTables' (boolean flag indicating whether tables should be indented or not)
				function Init(styleSheetPath, indentTables)
				{	
					gStyleSheetPath = styleSheetPath;
					if (indentTables === false) 
					{
						gIndentTables = false;
					}
				}
					
				// This method is used to expand  Parameters/TestResults/AdditionalResults/Attributes.
				function Expand(node)
				{
					var trTag = node.parentNode.parentNode;
					var currLevel = parseInt(GetRequiredAttrValue(trTag, "level"), 10);
					var shouldUnHide = 'true';
					var level = -1;
					SetRequiredAttrValue(trTag, "state", "expanded");
					trTag = trTag.nextSibling;
					while (trTag)
					{
						if (trTag.nodeType == 1) //Only for element nodes and not for text nodes
						{
							var nextLevel = parseInt(GetRequiredAttrValue(trTag, "level"), 10); 
							if (nextLevel > currLevel)
							{
								if (shouldUnHide == 'true')
								{
									SetRequiredAttrValue(trTag, "class", 'trUnhide');
									if (GetRequiredAttrValue(trTag, "state") == 'collapsed')
									{
										level = nextLevel;
										shouldUnHide = 'false';
									}
								 }
								 else if (nextLevel <= level)
								 {
									level = -1;
									shouldUnHide = 'true';
									SetRequiredAttrValue(trTag, "class", 'trUnhide');
									if (GetRequiredAttrValue(trTag, "state") == 'collapsed')
									{
										level = nextLevel;
										shouldUnHide = 'false';
									}
								}
							}
							else
							{
								break;
							}
						}
						trTag = trTag.nextSibling;
					}
				}
						
				// This method is used to collapse  Parameters/TestResults/AdditionalResults/Attributes.
				function Collapse(node)
				{
					var trTag = node.parentNode.parentNode;
					SetRequiredAttrValue(trTag, "state", "collapsed");
					var currLevel = parseInt(GetRequiredAttrValue(trTag, "level"), 10);
					trTag = trTag.nextSibling;
					while (trTag)
					{
						if (trTag.nodeType == 1) //Only for element nodes and not for text nodes
						{
							var nextLevel = parseInt(GetRequiredAttrValue(trTag, "level"), 10);
							if (nextLevel > currLevel)
							{
								SetRequiredAttrValue(trTag, "class", 'trHide');
							}
							else
							{
								break;
							}
						}
						trTag =  trTag.nextSibling;
					}
				}
					
				// This method is used to expand/collapse Parameters/TestResults/AdditionalResults/Attributes. The plus/minus image is changed based on expand/collapse.
				function ExpandCollapse(node)
				{
					var expCollState = GetRequiredAttrValue(node, "state");
					if (expCollState === "collapsed")
					{
						node.setAttribute("src", gStyleSheetPath + "minus.png");
						SetRequiredAttrValue(node, "state", "expanded");
						Expand(node);
					}
					else if (expCollState === "expanded")
					{
						node.setAttribute("src", gStyleSheetPath + "plus.png");
						SetRequiredAttrValue(node, "state", "collapsed");
						Collapse(node);
					}
				}
				
				// This method returns the class attribute
				function GetClassAttributeValue(className)
				{
					className = className.replace(/canHide:\w+/, "");
					className = className.replace(/level:\w+/, "");
					className = className.replace(/state:\w+/, "");
					return className.match(/\w+/)[0];
				}
				
				// This method returns the class attribute
				function GetNonClassAttributeValue(className, attrName)
				{
					var attrValue = "";
					var regExpStr = attrName + ":\\w+";
					var regExp = new RegExp(regExpStr, "");
					var attrValueArray = className.match(regExp);
					if (attrValueArray)
						attrValue = attrValueArray[0].substring(attrValueArray[0].indexOf(':') + 1);
					return attrValue;
				}
				
				// This method is used to get the required attribute value from the class attribute of the node
				function GetRequiredAttrValue(node, attrName)
				{
					var attrValue = "";
					if (attrName === "class")
						attrValue = GetClassAttributeValue(node.className);
					else
						attrValue = GetNonClassAttributeValue(node.className, attrName);
					return attrValue;
				}

				// This method sets the class attribute
				function SetClassAttributeValue(node, attrValue)
				{
					var attrStr = node.className;
					
					var tempAttrValArray = attrStr.match(/canHide:\w+/, "");
					if (tempAttrValArray)
						attrValue += " " + tempAttrValArray[0];
					
					tempAttrValArray = attrStr.match(/level:\w+/, "");
					if (tempAttrValArray)
						attrValue += " " + tempAttrValArray[0];
					
					tempAttrValArray = attrStr.match(/state:\w+/, "");
					if (tempAttrValArray)
						attrValue += " " + tempAttrValArray[0];
						
					node.className = attrValue;
				}
				
				// This method sets the class attribute
				function SetNonClassAttributeValue(node, attrName, attrValue)
				{
					var regExpStr = attrName + ":\\w+";
					var regExp = new RegExp(regExpStr, "");
					var tempClassName = node.className;
					if (regExp.test(tempClassName))
						node.className = tempClassName.replace(regExp, attrName + ":" + attrValue);
					else
						node.className = tempClassName + " " + attrName + ":" + attrValue;
				}
				
				// This method is used to set the required attribute value in the class attribute of the node
				function SetRequiredAttrValue(node, attrName, attrValue)
				{
					if (attrName === "class")
						SetClassAttributeValue(node, attrValue);
					else
						SetNonClassAttributeValue(node, attrName, attrValue);
				}
					
				// This method is used to hide/unhide a Sequence
				function HideUnhideSequence(node)
				{
					var expCollState = GetRequiredAttrValue(node, "state");
					var expCollDivNode = node.parentNode.parentNode.parentNode.parentNode.nextSibling;
					var unHideSequence = (expCollState === "collapsed");
					var imgSrcAttrValue = '';
					var divClassNameValue = '';
					var stateAttrValue = '';
					if(unHideSequence) 
					{
						imgSrcAttrValue = gStyleSheetPath + 'minus.png';
						divClassNameValue = gIndentTables ? 'divIndentUnhide' : 'divWithoutIndentUnhide';
						stateAttrValue = 'expanded';
					}
					else 
					{
						imgSrcAttrValue = gStyleSheetPath + 'plus.png';
						divClassNameValue = 'divHide';
						stateAttrValue = 'collapsed';
					}					
					node.setAttribute("src", imgSrcAttrValue);
					SetRequiredAttrValue(node, "state", stateAttrValue);
					SetRequiredAttrValue(expCollDivNode, "class", divClassNameValue);
					// The below condition is for checking whether postactions are present, at a different block level, for sequence call steps.
					if (GetRequiredAttrValue(expCollDivNode, "canHide") === '2')
					{
						SetRequiredAttrValue(expCollDivNode.nextSibling.nextSibling, "class", divClassNameValue);
					}
				}
				
				// This method is used to expand/collapse all the Sequences along with all the Parameters/TestResults/AdditionalResults/Attributes. The plus/minus image is changed based on ExpandAll/CollapseAll.
				function ExpCollAll(node)
				{
					var expCollState = GetRequiredAttrValue(node, "state");
					var expandAll = (expCollState === "collapsed");
					var imgSrcAttrValue = '';
					var divClassNameValue = '';
					var trClassNameAttrValue = '';
					var stateAttrValue = '';
					if(expandAll) 
					{
						imgSrcAttrValue = gStyleSheetPath + 'minus.png';
						divClassNameValue = gIndentTables ? 'divIndentUnhide' : 'divWithoutIndentUnhide';
						trClassNameAttrValue = 'trUnhide';
						stateAttrValue = 'expanded';
					}
					else 
					{
						imgSrcAttrValue = gStyleSheetPath + 'plus.png';
						divClassNameValue = 'divHide';
						trClassNameAttrValue = 'trHide';
						stateAttrValue = 'collapsed';
					}
					node.setAttribute("src", imgSrcAttrValue);
					SetRequiredAttrValue(node, "state", stateAttrValue);
					var allDivElems = document.getElementsByTagName("div");
					var noOfDivElems = allDivElems.length;
					while (noOfDivElems--) 
					{
						if (GetRequiredAttrValue(allDivElems[noOfDivElems], "canHide") !== '0') 
						{
								SetRequiredAttrValue(allDivElems[noOfDivElems], "class", divClassNameValue);
						}
					}
					var allTrTags = document.getElementsByTagName("tr");
					var noOfTrTags = allTrTags.length;
					while (noOfTrTags--) 
					{
						if (parseInt(GetRequiredAttrValue(allTrTags[noOfTrTags], "level"), 10) > 1) 
						{
							SetRequiredAttrValue(allTrTags[noOfTrTags], "class", trClassNameAttrValue);
						}
					}
					var allImgTags = document.getElementsByTagName("img");
					var noOfImgTags = allImgTags.length;
					while (noOfImgTags--) 
					{
						allImgTags[noOfImgTags].src = imgSrcAttrValue;
						SetRequiredAttrValue(allImgTags[noOfImgTags], "state", stateAttrValue);
						var parent = allImgTags[noOfImgTags].parentNode;
						if (parent.nodeName.toLowerCase() === "td") 
						{
							SetRequiredAttrValue(parent.parentNode, "state", stateAttrValue);
						}
					}
				}
				
				/** An expand function to expand all divisions during PDF Generation
				**/
				expandAll = function()
				{
					var imgSrcAttrValue = gStyleSheetPath + 'minus.png';
					var divClassNameValue = gIndentTables ? 'divIndentUnhide' : 'divWithoutIndentUnhide';
					var trClassNameAttrValue = 'trUnhide';
					var stateAttrValue = 'expanded';
					
					var allDivElems = document.getElementsByTagName("div");
					var noOfDivElems = allDivElems.length;
					while (noOfDivElems--) 
					{
						if (GetRequiredAttrValue(allDivElems[noOfDivElems], "canHide") !== '0') 
						{
								SetRequiredAttrValue(allDivElems[noOfDivElems], "class", divClassNameValue);
						}
					}
					
					var allTrTags = document.getElementsByTagName("tr");
					var noOfTrTags = allTrTags.length;
					while (noOfTrTags--) 
					{
						if (parseInt(GetRequiredAttrValue(allTrTags[noOfTrTags], "level"), 10) > 1) 
						{
							SetRequiredAttrValue(allTrTags[noOfTrTags], "class", trClassNameAttrValue);
						}
					}
					
					var allImgTags = document.getElementsByTagName("img");
					var noOfImgTags = allImgTags.length;
					while (noOfImgTags--) 
					{
						allImgTags[noOfImgTags].src = imgSrcAttrValue;
						SetRequiredAttrValue(allImgTags[noOfImgTags], "state", stateAttrValue);
					}
				}
				
				]]></script>
			</head>
			<body onload="Init('{$gStylesheetPath}',{$gIndentTables})">
				<!-- Initializes the global Javascript variables pertaining to processing of asserts, if the following are true
                      a) 'gProcessAsserts' is set to 'true()'  and
                      b) 'gTerminateOnAssert' is set to 'false()'
                 -->
                <xsl:if test="function-available('user:InitializeStylesheetPath')">
					<xsl:value-of select="user:InitializeStylesheetPath(string($gStylesheetPath))"/>
				</xsl:if>
				<xsl:if test="$gProcessAsserts and not($gTerminateOnAssert)">
					<xsl:value-of select="user:InitAssertMode()" disable-output-escaping="yes"/>
				</xsl:if>
				<h3>
					<span style="font-size:0.7em;">ATML TestResult Report</span>
				</h3>
				<xsl:apply-templates select="n1:TestResults"/>
				<br/>
				<h3>
					<span style="font-size:0.7em;">End ATML TestResult Report</span>
				</h3>
				<hr/>
				<!-- Adds a table at the end of the transformed HTML report displaying all the assert meesages pertaining to the
                      failed assert conditions, if the following are true
                      a) 'gProcessAsserts' is set to 'true()'  and
                      b) 'gTerminateOnAssert' is set to 'false()'
                 -->
				<xsl:if test="$gProcessAsserts and not($gTerminateOnAssert)">
					<div id="AssertTable" class="canHide:0">
						<xsl:value-of select="user:GetAssertTable()" disable-output-escaping="yes"/>
					</div>
				</xsl:if>

				<script type="text/javascript">
					try {
						window.cefQuery({
							request: 'Expand',
							onSuccess: function(response) {
							  expandAll();
							},
							onFailure: function(error_code, error_message) {expandAll();}
						});
						expandAll();
					}
					catch (err) {
						// Do nothing
					}
				</script>
			</body>
		</html>
	</xsl:template>
	<!-- Template to get the path to directory that contains the stylesheet. The paths ends with a '/'. -->
	<xsl:template match="processing-instruction('xml-stylesheet')" name="GetStylesheetPath">
		<xsl:variable name="PI" select="./processing-instruction('xml-stylesheet')"/>
		<xsl:variable name="fullFilePath">
			<xsl:call-template name="ReplaceBackwardSlashInPath">
				<xsl:with-param name="filepath" select="substring-before(substring-after($PI, 'href=&quot;'), '&quot;')"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($fullFilePath,'/')">
				<xsl:call-template name="Substring-before-last">
					<xsl:with-param name="string1" select="$fullFilePath"/>
					<xsl:with-param name="string2" select="'/'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to return a substring of 'string1' starting from index 0 to the last occurence of 'string2' (inclusive) in 'string1'.-->
	<xsl:template name="Substring-before-last">
		<xsl:param name="string1" select="''"/>
		<xsl:param name="string2" select="''"/>
		<xsl:choose>
			<xsl:when test="$string1 != '' and $string2 != ''">
				<xsl:variable name="head" select="substring-before($string1, $string2)"/>
				<xsl:variable name="tail" select="substring-after($string1, $string2)"/>
				<xsl:value-of select="concat($head, $string2)"/>
				<xsl:if test="contains($tail, $string2)">
					<xsl:call-template name="Substring-before-last">
						<xsl:with-param name="string1" select="$tail"/>
						<xsl:with-param name="string2" select="$string2"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$gProcessAsserts">
				<xsl:call-template name="ProcessAssert">
					<xsl:with-param name="assertMessage">
						In template 'Substring-before-last' : Atleast one of the xsl parameters 'string1' or 'string2' is empty.
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Template to replace all occurences of '\', present in 'filepath', with '/' .-->
	<xsl:template name="ReplaceBackwardSlashInPath">
		<xsl:param name="filepath"/>
		<xsl:choose>
			<xsl:when test="contains($filepath, '\')">
				<xsl:value-of select="translate($filepath, '\', '/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$filepath"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template that returns the name of the sequence and the path of the sequence file that contains the sequence for a processed <TestGroup> element.-->
	<xsl:template name="GetTestGroup">
		<xsl:param name="testGroupNameAndPath"/>
		<xsl:choose>
			<!-- This check is performed to verify if the sequence name is empty or not. 
                  'testGroupNameAndPath' holds the sequence file name and the sequence name as : SequenceFileName#SequenceName -->
			<xsl:when test="contains($testGroupNameAndPath, '#')">
				<xsl:value-of select="substring-after($testGroupNameAndPath, '#')"/>
				<br/>
				(<xsl:value-of select="substring-before($testGroupNameAndPath, '#')"/>)
			</xsl:when>
			<xsl:otherwise>
				<br/>
				(<xsl:value-of select="$testGroupNameAndPath"/>)
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template returns the date and time in the format : MM/DD/YYYY  HH:MM:SS AM/PM -->
	<xsl:template name="GetDateAndTime">
		<xsl:param name="dateTime"/>
		<xsl:variable name="date" select="substring-before($dateTime, 'T')"/>
		<xsl:variable name="time" select="substring-before(substring-after($dateTime, 'T'), '.')"/>
		<xsl:variable name="hours" select="substring-before($time, ':')"/>
		<xsl:variable name="minsSecs" select="substring-after($time, ':')"/>
		<xsl:variable name="timeIn12HrFormat">
			<xsl:choose>
				<xsl:when test="$hours > 11">
					<xsl:choose>
						<xsl:when test="$hours - 12 = 0">12</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$hours - 12"/>
						</xsl:otherwise>
					</xsl:choose>:<xsl:value-of select="$minsSecs"/> PM
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$hours = 0">12</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$hours"/>
						</xsl:otherwise>
					</xsl:choose>:<xsl:value-of select="$minsSecs"/> AM
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat(substring-before(substring-after($date,'-'),'-'),'/',substring-after(substring-after($date,'-'),'-'),'/',substring-before($date,'-'), '  ', $timeIn12HrFormat)"/>
		<xsl:if test="$gProcessAsserts">
			<xsl:if test="$dateTime=''">
				<xsl:call-template name="ProcessAssert">
					<xsl:with-param name="assertMessage">
						In template 'GetDateAndTime' : Xsl parameter 'dateTime' is empty.
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$date='' or $time=''">
				<xsl:call-template name="ProcessAssert">
					<xsl:with-param name="assertMessage">
						In template 'GetDateAndTime' : Xsl parameter 'dateTime' is not in the expected format. The expected format is 'yyyy-mm-ddThh:mm:ss'.
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- Template to process <TestResults> root element -->
	<xsl:template match="n1:TestResults">
		<div id="ReportHeader" style="font-size:1.1em;" class="canHide:0">
			<!-- Add the report header table.-->
			<table>
				<tbody>
					<tr class="level:0">
						<td>
							<span style="font-size:0.98em;">
								<b>TestStation</b>
							</span>
						</td>
						<td>
							<xsl:value-of select="n1:TestStation/c:SerialNumber"/>
						</td>
					</tr>
					<xsl:if test="n1:Extension/ts:TSResultSetProperties/ts:TestSocketIndex">
						<tr class="level:0">
							<td>
								<span style="font-size:0.98em;">
									<b>Test Socket Index</b>
								</span>
							</td>
							<td>
								<xsl:call-template name="GetDatumValue">
									<xsl:with-param name="datumNode" select="n1:Extension/ts:TSResultSetProperties/ts:TestSocketIndex"/>
								</xsl:call-template>
							</td>
						</tr>
					</xsl:if>
					<tr class="level:0">
						<td>
							<span style="font-size:0.98em;">
								<b>UUT Serial Number</b>
							</span>
						</td>
						<td>
							<xsl:value-of select="n1:UUT/c:SerialNumber"/>
						</td>
					</tr>
					<tr class="level:0">
						<td>
							<span style="font-size:0.98em;">
								<b>UUT Type</b>
							</span>
						</td>
						<td>
							<xsl:value-of select="n1:UUT/@UutType"/>
						</td>
					</tr>
					<tr class="level:0">
						<td>
							<span style="font-size:0.98em;">
								<b>Start Date and Time</b>
							</span>
						</td>
						<td>
							<xsl:call-template name="GetDateAndTime">
								<xsl:with-param name="dateTime" select="n1:ResultSet/@startDateTime"/>
							</xsl:call-template>
						</td>
					</tr>
					<tr class="level:0">
						<td>
							<span style="font-size:0.98em;">
								<b>End Date and Time</b>
							</span>
						</td>
						<td>
							<xsl:call-template name="GetDateAndTime">
								<xsl:with-param name="dateTime" select="n1:ResultSet/@endDateTime"/>
							</xsl:call-template>
						</td>
					</tr>
					<tr class="level:0">
						<td>
							<span style="font-size:0.98em;">
								<b>Operator</b>
							</span>
						</td>
						<td>
							<xsl:value-of select="n1:Personnel/n1:SystemOperator/@name"/>
						</td>
					</tr>
					<tr class="level:0">
						<td>
							<span style="font-size:0.98em;">
								<b>Sequence File Path</b>
							</span>
						</td>
						<td>
							<xsl:value-of select="n1:ResultSet/@name"/>
						</td>
					</tr>
					<xsl:if test="n1:Extension/ts:TSResultSetProperties/ts:NumOfResults">
						<tr class="level:0">
							<td>
								<span style="font-size:0.98em;">
									<b>Number of Results</b>
								</span>
							</td>
							<td>
								<xsl:value-of select="n1:Extension/ts:TSResultSetProperties/ts:NumOfResults/@value"/>
							</td>
						</tr>
					</xsl:if>
					<tr class="level:0">
						<td>
							<span style="font-size:0.98em;">
								<b>Outcome</b>
							</span>
						</td>
						<td>
							<xsl:variable name="outcome">
								<xsl:call-template name="GetOutcome">
									<xsl:with-param name="outcomeNode" select="n1:ResultSet/n1:Outcome"/>
								</xsl:call-template>
							</xsl:variable>
							<span>
								<xsl:attribute name="style">color:<xsl:call-template name="GetStatusColor"><xsl:with-param name="status" select="$outcome"/></xsl:call-template></xsl:attribute>
								<xsl:value-of select="$outcome"/>
							</span>
							<xsl:if test="n1:ResultSet/n1:TestGroup/n1:Events/n1:Event[@ID='Error Message']/n1:Data[@name='Error Message']">
								<xsl:variable name="errCode">
									<xsl:call-template name="GetDatumValue">
										<xsl:with-param name="datumNode" select="n1:ResultSet/n1:TestGroup/n1:Events/n1:Event[@ID='Error Code']/n1:Data[@name='Error Code']/c:Datum"/>
									</xsl:call-template>
								</xsl:variable>
								<span style="color:#FF0000;">: <xsl:value-of disable-output-escaping="yes" select="user:ReplaceWhitespaceAndNewLine(n1:ResultSet/n1:TestGroup/n1:Events/n1:Event[@ID='Error Message']/n1:Data[@name='Error Message']/c:Datum/c:Value, true())"/>
									<xsl:text> </xsl:text>[Error Code: <xsl:value-of select="$errCode"/>, 
									   <xsl:value-of select="n1:ResultSet/n1:TestGroup/n1:Events/n1:Event[@ID='Error Code']/n1:Message"/>]</span>
							</xsl:if>
						</td>
					</tr>
					<xsl:if test="n1:Extension/ts:TSResultSetProperties/ts:IsPartialExecution">
						<tr class="level:0">
							<td>
								<span style="font-size:0.98em;">
									<b>Partial TPS Executed</b>
								</span>
							</td>
							<td>
								<xsl:choose>
									<xsl:when test="n1:Extension/ts:TSResultSetProperties/ts:IsPartialExecution/@value = 'true'">True</xsl:when>
									<xsl:otherwise>False</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="n1:UUT/c:Definition/c:Identification/c:IdentificationNumbers/c:IdentificationNumber[@type='Part']">
						<tr class="level:0">
							<td>
								<span style="font-size:0.98em;">
									<b>Part Number:</b>
								</span>
							</td>
							<td>
								<xsl:value-of select="n1:UUT/c:Definition/c:Identification/c:IdentificationNumbers/c:IdentificationNumber[@type='Part']/@number"/>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="n1:Extension/ts:TSResultSetProperties/ts:TSRData">
						<tr class="level:0">
							<td>
								<span style="font-size:0.98em;">
									<b>TSR File Name</b>
								</span>
							</td>
							<td>
								<xsl:value-of select="n1:Extension/ts:TSResultSetProperties/ts:TSRData/@TSRFileName"/>
							</td>
						</tr>
						<tr class="level:0">
							<td>
								<span style="font-size:0.98em;">
									<b>TSR File ID</b>
								</span>
							</td>
							<td>
								<xsl:value-of select="n1:Extension/ts:TSResultSetProperties/ts:TSRData/@TSRFileID"/>
							</td>
						</tr>
						<tr class="level:0">
							<td>
								<span style="font-size:0.98em;">
									<b>TSR File Closed</b>
								</span>
							</td>
							<td>
								<xsl:choose>
									<xsl:when test="n1:Extension/ts:TSResultSetProperties/ts:TSRData/@TSRFileClosed = 'true'">OK</xsl:when>
									<xsl:otherwise>The .tsr file was not closed normally when written. This can indicate that the testing process was interrupted or aborted.</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</xsl:if>
          <xsl:if test="n1:UUT/c:Definition/c:Extension">
            <xsl:apply-templates select="n1:UUT/c:Definition/c:Extension/ts:TSCollection/c:Item[@name='AdditionalData']/c:Collection">
              <xsl:with-param name="stepNode" select="n1:UUT/c:Definition/c:Extension/ts:TSCollection/c:Item[@name='AdditionalData']"/>
              <xsl:with-param name="putAsFlatData" select="true()"/>
            </xsl:apply-templates>
          </xsl:if>
		  <xsl:if test="n1:TestStation/c:Definition/c:Extension">
            <xsl:apply-templates select="n1:TestStation/c:Definition/c:Extension/ts:TSAdditionalData/ts:TSCollection/c:Item[@name='AdditionalData']/c:Collection">
              <xsl:with-param name="stepNode" select="n1:TestStation/c:Definition/c:Extension/ts:TSAdditionalData/ts:TSCollection/c:Item[@name='AdditionalData']"/>
              <xsl:with-param name="putAsFlatData" select="true()"/>
            </xsl:apply-templates>
          </xsl:if>
          <!-- CREATE_UUTHEADER_INFO: Section to insert additional column to UUT report header-->
					<!--tr class="level:0">
						 <td>
							  <span style="font-size:0.98em;"><b>ResultSet ID</b></span>
						 </td>
						 <td>
							 <xsl:value-of select="n1:ResultSet/@ID"/>
						 </td>
					</tr-->
				</tbody>
			</table>
		</div>
		<br/>
		<hr/>
		<br/>
		<xsl:if test="$gIndentTables">
			<xsl:text disable-output-escaping="yes">&amp;nbsp;&amp;nbsp;</xsl:text>
		</xsl:if>
		<!-- Add the 'Expand All/Collapse All' functionality if,
			  a) There are results to be logged and
			  b) 'gGeneratePlainHTML' is set to 'false()'
		-->
		<xsl:if test="n1:ResultSet/n1:TestGroup and not($gGeneratePlainHTML)">
			<xsl:value-of select="user:GetExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
			<b style="font-size:0.54em;">
				<u>Expand All / Collapse All</u>
			</b>
			<br/>
		</xsl:if>
		<xsl:apply-templates select="n1:ResultSet"/>
	</xsl:template>
	<!-- Template to process the <ResultSet> element -->
	<xsl:template match="n1:ResultSet">
		<xsl:choose>
			<xsl:when test="n1:TestGroup">
				<xsl:apply-templates select="n1:TestGroup">
					<xsl:with-param name="isRootTestGroup" select="true()"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="n1:Test">
				<h3>
					<span style="font-size:0.7em; padding-left:{5 * $gSingleSpaceValue}px;">No Results Found</span>
				</h3>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Template to process the <TestGroup> element-->
	<xsl:template match="n1:TestGroup">
		<!-- 'isRootTestGroup' identifies whether the currently processed <TestGroup> element is the immediate child of <ResultSet> element.-->
		<xsl:param name="isRootTestGroup" select="false()"/>
		<xsl:if test="not(contains(@ID,'_PostAction')) or (n1:Test|n1:SessionAction|n1:TestGroup)">
			<!-- Identifies whether the post action step, if defined for the currently processed sequence call step, is at a block level greater than the current step's block level or not -->
			<xsl:variable name="hasPostActionAtGreaterBlockLevel">
				<xsl:variable name="nextSibling" select="following-sibling::*[1]"/>
				<xsl:choose>
					<xsl:when test="$nextSibling">
						<xsl:variable name="nextStepBlockLevel" select="$nextSibling/n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
						<xsl:variable name="currStepBlockLevel" select="n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
						<xsl:choose>
							<xsl:when test="$nextStepBlockLevel > $currStepBlockLevel">2</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- Adjusts the indentation of the table, in case the block level of the currently processed step is different than its immediate predecessor's block level. -->
			<xsl:call-template name="HandleIndentationForBlockLevel">
				<xsl:with-param name="currentNode" select="."/>
			</xsl:call-template>
			<!-- The check is to make sure that data for the sequence call step calling the root testgroup i.e. 'MainSequence' shouldn't be displayed by the report,
				 as the sequence call step calling 'MainSequence' is a part of process model and not the client sequence file.-->
			<xsl:if test="not($isRootTestGroup)">
				<!-- The check is to make sure that if multiple <TestGroup> elements are children of a <TestGroup> element then 
					 a separate sequence table exists for each of the child <TestGroup> elements -->
				<xsl:if test="not(user:isTableOpen())">
					<xsl:value-of select="user:StartTable()" disable-output-escaping="yes"/>
				</xsl:if>
				<!-- Add sequence call step information -->
				<tr class="level:0 state:expanded">
					<td>
						<!-- Add expand/collapse functionality for a sequence table. Skip if it has only post action sequence call with no results-->
						<xsl:variable name="hasOnlyPostActionSequenceCallWithNoResults" select="count(n1:Test|n1:SessionAction|n1:TestGroup) = 1 and n1:TestGroup[contains(@ID,'_PostAction')] and count(n1:TestGroup[contains(@ID,'_PostAction')]/n1:Test|n1:TestGroup[contains(@ID,'_PostAction')]/n1:SessionAction|n1:TestGroup[contains(@ID,'_PostAction')]/n1:TestGroup) = 0"/>
						<xsl:if test="not($hasOnlyPostActionSequenceCallWithNoResults)">
							<xsl:value-of select="user:GetTableExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
						</xsl:if>
						<!-- Add sequence call step name -->
						<xsl:choose>
							<xsl:when test="@userDefinedType">
								<xsl:variable name="seqCallName">
									<xsl:value-of select="substring-after(@userDefinedType, 'SequenceCallStepName = ')"/>
								</xsl:variable>
								<xsl:value-of select="substring($seqCallName,2,string-length($seqCallName)-2)"/>
								<!-- Add '_PostAction' postfix to the name of the sequence call step, in case its a 'Call sequence' postaction.-->
								<xsl:if test="substring(@ID, string-length(@ID) - 10) = '_PostAction'">
									<xsl:text>_PostAction</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test="contains(@name,'#')">
								<xsl:value-of select="substring-after(@name,'#')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@name"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<!-- Add step outcome -->
					<xsl:call-template name="AddStepOutcome">
						<xsl:with-param name="outcomeNode" select="n1:Outcome"/>
					</xsl:call-template>
					<xsl:choose>
						<!-- Process limit if step has only one limit-->
						<xsl:when test="count(n1:TestResult/n1:TestLimits)=1 or count(n1:TestResult/n1:Extension/ts:TSLimitProperties/ts:IsTestMeasurement)=1">
							<xsl:call-template name="ProcessSingleLimit">
								<xsl:with-param name="stepNode" select="."/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<!-- Add empty columns, in case the step has no limits or has multiple limits -->
							<xsl:value-of select="$gStepEmptyCells" disable-output-escaping="yes"/>
						</xsl:otherwise>
					</xsl:choose>
					<!-- ADD_COLUMN_DATA: Users can add data to the extra column created in CREATE_EXTRA_COLUMNS section here -->
					<!--td align="right">
						<xsl:value-of select="n1:Extension/ts:TSStepProperties/ts:StepId"/>
					</td-->
				</tr>
				<xsl:if test="count(n1:TestResult/n1:TestLimits)=1">
					<!-- Process attributes, if present, for the following limit properties
								  a)  'Step.Limits'
								  b)  'Step.Limits.Low'
								  c)  'Step.Limits.High'
								  d)  'Step.Limits.String'
								  e)  'Step.Comp'
								  f)  'Step.Units'
					-->
					<xsl:call-template name="ProcessLimitAttributes">
						<xsl:with-param name="stepNode" select="."/>
						<xsl:with-param name="limitID" select="n1:TestResult/n1:TestLimits/../@ID"/>
						<xsl:with-param name="level" select="1"/>
					</xsl:call-template>
				</xsl:if>
				<!-- Process limits if step has multiple limits-->
				<xsl:call-template name="ProcessMultiNumericLimits">
					<xsl:with-param name="stepNode" select="."/>
				</xsl:call-template>
				<!-- Add step description, if present-->
				<xsl:call-template name="AddStepDescription">
					<xsl:with-param name="stepNode" select="."/>
				</xsl:call-template>
				<!-- Process events, if present -->
				<xsl:apply-templates select="n1:Events" mode="Event"/>
				<!-- Process input parameters of a step-->
				<xsl:apply-templates select="n1:Parameters">
					<xsl:with-param name="processParameters" select="true()"/>
				</xsl:apply-templates>
				<!-- Process output parameters and additional results of a step -->
				<xsl:call-template name="ProcessTestResultElems">
					<xsl:with-param name="stepNode" select="."/>
				</xsl:call-template>
				<!-- Process TestStand specific information logged for a step-->
				<xsl:apply-templates select="n1:Extension/ts:TSStepProperties">
					<xsl:with-param name="level" select="1"/>
				</xsl:apply-templates>
				<xsl:value-of select="user:EndTable()" disable-output-escaping="yes"/>
			</xsl:if>
			<xsl:if test="$gProcessAsserts">
				<xsl:choose>
					<xsl:when test="not($isRootTestGroup) and name(..)='ResultSet'">
						<xsl:call-template name="ProcessAssert">
							<xsl:with-param name="assertMessage">
								<xsl:text disable-output-escaping="yes">In template 'n1:TestGroup' : Xsl parameter 'isRootTestGroup' is set to 'false()' which is incorrect. 'isRootTestGroup' shall be 'true()' in case the processed &amp;lt;TestGroup&amp;gt; element is child of &amp;lt;ResultSet&amp;gt; element.</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$isRootTestGroup and name(..)!='ResultSet'">
						<xsl:call-template name="ProcessAssert">
							<xsl:with-param name="assertMessage">
								<xsl:text disable-output-escaping="yes">In template 'n1:TestGroup' : Xsl parameter 'isRootTestGroup' is set to 'true()' which is incorrect. 'isRootTestGroup' shall be 'false()' in case the processed &amp;lt;TestGroup&amp;gt; element is not a child of &amp;lt;ResultSet&amp;gt; element.</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<!-- Adds parent <div> HTML tags for every sequence table to be created.-->
			<xsl:call-template name="OpenDivTags">
				<xsl:with-param name="noOfDivTags" select="1"/>
				<xsl:with-param name="canHide">
					<xsl:value-of select="$hasPostActionAtGreaterBlockLevel"/>
				</xsl:with-param>
				<xsl:with-param name="isRootSequenceTable" select="$isRootTestGroup"/>
			</xsl:call-template>
			<br/>
			<!-- Adds sequence name and the path of the sequence file that contains the sequence pertaining to the <TestGroup> element-->
			<xsl:if test="contains(@name,'#')">
				<b style="font-size:0.54em;">Begin Sequence : <xsl:call-template name="GetTestGroup">
						<xsl:with-param name="testGroupNameAndPath" select="@name"/>
					</xsl:call-template>
				</b>
			</xsl:if>
			<!-- Add a new table here only to log the information of those steps with block level 0 present in the sequence pertaining to the <TestGroup> element. For steps with non zero block level, table is added after handling that block level. -->
			<xsl:if test="(n1:Test|n1:SessionAction|n1:TestGroup)[1]/n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value = 0">
				<xsl:value-of select="user:StartTable()" disable-output-escaping="yes"/>
			</xsl:if>
			<xsl:apply-templates/>
			<!-- Close the table -->
			<xsl:value-of select="user:EndTable()" disable-output-escaping="yes"/>
			<xsl:variable name="lastChild" select="child::*[last()]"/>
			<xsl:if test="$lastChild/n1:Extension">
				<xsl:variable name="lastChildBlockLevel" select="$lastChild/n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
				<xsl:if test="$lastChildBlockLevel!=0">
					<xsl:call-template name="CloseDivTags">
						<xsl:with-param name="noOfDivTags" select="$lastChildBlockLevel"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			<!-- Add delimiter specifying the end of currently processed sequence.
				  The format of the delimiter is : 'End Sequence: %SequenceName%', where %SequenceName% is the name of the currently processed sequence. -->
			<xsl:if test="contains(@name,'#')">
				<br/>
				<b style="font-size:0.54em;">End Sequence : <xsl:value-of select="substring-after(@name,'#')"/>
				</b>
			</xsl:if>
			<!-- Close parent <div> HTML tag added for a sequence table.-->
			<xsl:call-template name="CloseDivTags">
				<xsl:with-param name="noOfDivTags" select="1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- Template to process <Test> element -->
	<xsl:template match="n1:Test">
		<!-- Adjusts the indentation of the table, in case the block level of the currently processed step is different than its immediate predecessor's block level. -->
		<xsl:call-template name="HandleIndentationForBlockLevel">
			<xsl:with-param name="currentNode" select="."/>
		</xsl:call-template>
		<xsl:if test="not(user:isTableOpen())">
			<xsl:value-of select="user:StartTable()" disable-output-escaping="yes"/>
		</xsl:if>
		<tr class="level:0 state:expanded">
			<td>
				<!-- Add step name-->
				<xsl:choose>
					<xsl:when test="@userDefinedType">
						<xsl:variable name="seqCallName">
							<xsl:value-of select="substring-after(@userDefinedType, 'SequenceCallStepName = ')"/>
						</xsl:variable>
						<xsl:value-of select="substring($seqCallName,2,string-length($seqCallName)-2)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="nextSibling" select="following-sibling::*[1]"/>
						<!-- Add expand/collapse functionality, in case the postaction of the current step is at a block level higher than the current step's block level. -->
						<xsl:if test="$nextSibling">
							<xsl:variable name="nextStepBlockLevel" select="$nextSibling/n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
							<xsl:variable name="currStepBlockLevel" select="n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
							<xsl:if test="$nextStepBlockLevel > $currStepBlockLevel">
								<xsl:value-of select="user:GetTableExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
							</xsl:if>
						</xsl:if>
						<xsl:value-of select="@name"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<!-- Add step outcome -->
			<xsl:call-template name="AddStepOutcome">
				<xsl:with-param name="outcomeNode" select="n1:Outcome"/>
			</xsl:call-template>
			<xsl:choose>
				<!-- Process limit if step has only one limit-->
				<xsl:when test="count(n1:TestResult/n1:TestLimits)=1 or count(n1:TestResult/n1:Extension/ts:TSLimitProperties/ts:IsTestMeasurement)=1">
					<xsl:call-template name="ProcessSingleLimit">
						<xsl:with-param name="stepNode" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- Add empty columns, in case the step has multiple limits-->
					<xsl:value-of select="$gStepEmptyCells" disable-output-escaping="yes"/>
				</xsl:otherwise>
			</xsl:choose>
			<!-- ADD_COLUMN_DATA: Users can add data to the extra column created in CREATE_EXTRA_COLUMNS section here -->
			<!--td align="right">
				<xsl:value-of select="n1:Extension/ts:TSStepProperties/ts:StepId"/>
			</td-->
		</tr>
		<xsl:if test="count(n1:TestResult/n1:TestLimits)=1">
			<!-- Process attributes, if present, for the following limit properties
						  a)  'Step.Limits'
						  b)  'Step.Limits.Low'
						  c)  'Step.Limits.High'
						  d)  'Step.Limits.String'
						  e)  'Step.Comp'
						  f)  'Step.Units'
			-->
			<xsl:call-template name="ProcessLimitAttributes">
				<xsl:with-param name="stepNode" select="."/>
				<xsl:with-param name="limitID" select="n1:TestResult/n1:TestLimits/../@ID"/>
				<xsl:with-param name="level" select="1"/>
			</xsl:call-template>
		</xsl:if>
		<!-- Process limits if step has multiple limits-->
		<xsl:call-template name="ProcessMultiNumericLimits">
			<xsl:with-param name="stepNode" select="."/>
		</xsl:call-template>
		<!-- Add step description, if present-->
		<xsl:call-template name="AddStepDescription">
			<xsl:with-param name="stepNode" select="."/>
		</xsl:call-template>
		<!-- Process events, if present -->
		<xsl:apply-templates select="n1:Events" mode="Event"/>
		<!-- Process input parameters of a step-->
		<xsl:apply-templates select="n1:Parameters">
			<xsl:with-param name="processParameters" select="true()"/>
		</xsl:apply-templates>
		<!-- Process output parameters and additional results of a step -->
		<xsl:call-template name="ProcessTestResultElems">
			<xsl:with-param name="stepNode" select="."/>
		</xsl:call-template>
		<!-- Process TestStand specific information logged for a step-->
		<xsl:apply-templates select="n1:Extension/ts:TSStepProperties">
			<xsl:with-param name="level" select="1"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Template to process <SessionAction> element -->
	<xsl:template match="n1:SessionAction">
		<!-- Identifies whether its a flow control step or not -->
		<xsl:variable name="isFlowControlStep">
			<xsl:call-template name="IsFlowControlStep">
				<xsl:with-param name="node" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Adjusts the indentation of the table, in case the block level of the currently processed step is different than its immediate predecessor's block level. -->
		<xsl:call-template name="HandleIndentationForBlockLevel">
			<xsl:with-param name="currentNode" select="."/>
		</xsl:call-template>
		<xsl:if test="not(user:isTableOpen())">
			<xsl:value-of select="user:StartTable()" disable-output-escaping="yes"/>
		</xsl:if>
		<tr class="level:0 state:expanded">
			<td>
				<!-- Add step name-->
				<xsl:choose>
					<xsl:when test="@userDefinedType">
						<xsl:variable name="seqCallName">
							<xsl:value-of select="substring-after(@userDefinedType, 'SequenceCallStepName = ')"/>
						</xsl:variable>
						<xsl:value-of select="substring($seqCallName,2,string-length($seqCallName)-2)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="nextSibling" select="following-sibling::*[1]"/>
						<xsl:if test="$nextSibling">
							<xsl:variable name="nextStepBlockLevel" select="$nextSibling/n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
							<xsl:variable name="currStepBlockLevel" select="n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
							<xsl:if test="$nextStepBlockLevel > $currStepBlockLevel">
								<!-- Add expand/collapse functionality, in case the postaction of the current step is at a block level higher than the current step's block level. -->
								<xsl:value-of select="user:GetTableExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
							</xsl:if>
						</xsl:if>
						<xsl:value-of select="@name"/>
						<!-- Add ReportText as a postfix to the step name, in case of a flow control step-->
						<xsl:if test="$isFlowControlStep='true'">
							<xsl:variable name="value" select="normalize-space(n1:Data/c:Collection/c:Item[@name='ReportText']/c:Datum/c:Value)"/>
							<span style="padding-left:{$gSingleSpaceValue}px;">
								<xsl:choose>
									<xsl:when test="starts-with($value,'(')">
										<xsl:value-of select="substring($value,2,string-length($value)-2)" disable-output-escaping="yes"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$value" disable-output-escaping="yes"/>
									</xsl:otherwise>
								</xsl:choose>
							</span>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<!-- Add step outcome -->
			<xsl:call-template name="AddStepOutcome">
				<xsl:with-param name="outcomeNode" select="n1:ActionOutcome"/>
			</xsl:call-template>
			<!-- Add empty cells for limit columns-->
			<xsl:value-of select="$gStepEmptyCells" disable-output-escaping="yes"/>
			<!-- ADD_COLUMN_DATA: Users can add data to the extra column created in CREATE_EXTRA_COLUMNS section here -->
			<!--td align="right">
				<xsl:value-of select="n1:Extension/ts:TSStepProperties/ts:StepId"/>
			</td-->
		</tr>
		<!-- Add step description, if present-->
		<xsl:call-template name="AddStepDescription">
			<xsl:with-param name="stepNode" select="."/>
		</xsl:call-template>
		<!-- Process events -->
		<xsl:apply-templates select="n1:Events" mode="Event"/>
		<!-- Process input parameters of the step -->
		<xsl:apply-templates select="n1:Parameters">
			<xsl:with-param name="processParameters" select="true()"/>
		</xsl:apply-templates>
		<!-- Process output parameters and additional results for the step-->
		<xsl:if test="n1:Data">
			<!-- Skip the processing of <Data> element if it is a flow control step and has one result logged, 
                  as the logged result pertains to 'ReportText' and has already been added as postfix of the step name. -->
			<xsl:if test="not($isFlowControlStep='true' and count(n1:Data/c:Collection/c:Item)=1)">
				<tr class="level:1 state:collapsed">
					<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2}px;">TestResults/Data</td>
				</tr>
				<xsl:apply-templates select="n1:Data">
					<xsl:with-param name="isFlowControlStep" select="$isFlowControlStep"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
		<!-- Process TestStand specific information logged for a step-->
		<xsl:apply-templates select="n1:Extension/ts:TSStepProperties">
			<xsl:with-param name="level" select="1"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Template to process the output parameters and additional results of a step-->
	<xsl:template match="n1:Data">
		<xsl:param name="isFlowControlStep" select="false()"/>
		<xsl:if test="c:Collection/c:Item">
			<xsl:apply-templates select="c:Collection">
				<xsl:with-param name="stepNode" select=".."/>
				<xsl:with-param name="isFlowControlStep" select="$isFlowControlStep"/>
				<xsl:with-param name="objectPath" select="'TestResult'"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<!-- Template to process the input parameters of a step -->
	<xsl:template match="n1:Parameters">
		<!-- 'processParameters' is used to make sure that input parameters are not reprocessed as an impact of making a call to <xsl:apply-templates/> -->
		<xsl:param name="processParameters" select="false()"/>
		<xsl:if test="$processParameters">
			<xsl:if test="count(n1:Parameter)">
				<tr class="level:1 state:collapsed">
					<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2}px;">Parameters</td>
				</tr>
				<xsl:apply-templates select="n1:Parameter/n1:Data" mode="Parameter"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- Template to add the information of a input parameter of a step, to the transformed HTML report -->
	<xsl:template match="n1:Parameter/n1:Data" mode="Parameter">
		<xsl:variable name="stepNode" select="../../.."/>
		<xsl:variable name="objectPath" select="concat('Parameter.',../@ID)"/>
		<xsl:if test="c:Collection">
			<xsl:choose>
				<xsl:when test="c:Collection/@xsi:type='ts:NI_TDMSReference'">
					<xsl:for-each select="c:Collection">
						<xsl:call-template name="ProcessTDMSReference">
							<xsl:with-param name="level" select="1"/>
							<xsl:with-param name="objectPath" select="$objectPath"/>
							<xsl:with-param name="stepNode" select="$stepNode"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="hasAttributes">
						<xsl:call-template name="HasAttributes">
							<xsl:with-param name="node" select="$stepNode"/>
							<xsl:with-param name="objectPath" select="$objectPath"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="paddingValue">
						<xsl:choose>
							<xsl:when test="$hasAttributes='true' or count(c:Collection/*) > 0">
								<xsl:value-of select="$gSingleSpaceValue * 2"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$gSingleSpaceValue * 3"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<tr class="level:1 state:expanded">
						<td colspan="{$gFirstColumnSpan}" style="padding-left:{$paddingValue}px;">
							<xsl:if test="count(c:Collection/*) > 0 or $hasAttributes='true'">
								<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
							</xsl:if>
							<xsl:value-of select="../@ID"/>:
							<!-- Add description of the input parameter, if present-->
							<xsl:if test="../n1:Description">
								<span style="padding-left:{$gSingleSpaceValue * 2}px;"><br/>(<xsl:value-of select="../n1:Description"/>)</span>
							</xsl:if>
						</td>
					</tr>
					<!-- Check if the processed property has attributes. If yes, then process attributes. -->
					<xsl:if test="$hasAttributes='true'">
						<xsl:call-template name="ProcessAttributes">
							<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
							<xsl:with-param name="node" select="$stepNode"/>
							<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
							<xsl:with-param name="level" select="2"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<!-- Add input parameter data to the transformed HTML report -->
		<xsl:if test="not(c:Collection/@xsi:type = 'ts:NI_TDMSReference')">
			<xsl:apply-templates>
				<xsl:with-param name="level" select="1"/>
				<xsl:with-param name="objectPath" select="$objectPath"/>
				<xsl:with-param name="stepNode" select="$stepNode"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<!-- Template to add the information of an output parameter or an additional result of a step, to the transformed HTML report -->
	<xsl:template match="n1:TestResult">
		<!-- 'processTestResult' is used to make sure that output parameters and additional results are not reprocessed as an impact of making a call to <xsl:apply-templates/> -->
		<xsl:param name="processTestResult" select="false()"/>
		<!-- Makes sure that limits are not reprocessed, as they are handled as a special case-->
		<xsl:if test="$processTestResult and not(n1:TestLimits) and not(n1:Extension/ts:TSLimitProperties/ts:IsTestMeasurement)">
			<!--  Process data held by the output parameter or additional result.-->
			<xsl:apply-templates select="n1:TestData"/>
		</xsl:if>
	</xsl:template>
	<!-- Template to add data of the processed output parameter or additional result to the transformed HTML report.-->
	<xsl:template match="n1:TestData">
		<xsl:variable name="stepNode" select="../.."/>
		<xsl:variable name="objectPath" select="concat('TestResult.',../@ID)"/>
		<xsl:if test="c:Collection">
			<xsl:choose>
				<xsl:when test="c:Collection/@xsi:type = 'ts:NI_TDMSReference'">
					<xsl:for-each select="c:Collection">
						<xsl:call-template name="ProcessTDMSReference">
							<xsl:with-param name="level" select="1"/>
							<xsl:with-param name="objectPath" select="$objectPath"/>
							<xsl:with-param name="stepNode" select="$stepNode"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="hasAttributes">
						<xsl:call-template name="HasAttributes">
							<xsl:with-param name="node" select="$stepNode"/>
							<xsl:with-param name="objectPath" select="$objectPath"/>
						</xsl:call-template>
					</xsl:variable>
					<tr class="level:1 state:collapsed">
						<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2}px;">
						<xsl:if test="count(c:Collection/c:Item)>0 or $hasAttributes='true'">
							<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
						</xsl:if>
							<xsl:value-of select="../@ID"/>:
							<!-- Add description of the output parameter or additional result, if present-->
							<xsl:if test="../n1:Description">
								<span style="padding-left:{$gSingleSpaceValue * 2}px;"><br/>(<xsl:value-of select="../n1:Description"/>)</span>
							</xsl:if>
						</td>
					</tr>
					<!-- Check if the processed property has attributes. If yes, then process attributes. -->
					<xsl:if test="$hasAttributes='true'">
						<xsl:call-template name="ProcessAttributes">
							<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
							<xsl:with-param name="node" select="$stepNode"/>
							<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
							<xsl:with-param name="level" select="2"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="not(c:Collection/@xsi:type = 'ts:NI_TDMSReference')">
			<xsl:apply-templates>
				<xsl:with-param name="level" select="1"/>
				<xsl:with-param name="objectPath" select="$objectPath"/>
				<xsl:with-param name="stepNode" select="$stepNode"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<!-- Templates to process step limit-->
	<xsl:template match="n1:TestLimits">
		<xsl:apply-templates select="n1:Limits"/>
	</xsl:template>
	<xsl:template match="n1:Limits">
		<xsl:choose>
			<xsl:when test="count(child::*)!=0">
				<xsl:apply-templates select="c:Expected"/>
				<xsl:apply-templates select="c:SingleLimit"/>
				<xsl:apply-templates select="c:LimitPair"/>
				<xsl:apply-templates select="c:Extension" mode="Limits"/>
			</xsl:when>
			<xsl:otherwise>
				<td/>
				<td/>
				<td/>
				<td/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="c:SingleLimit">
		<xsl:variable name="unit">
			<xsl:call-template name="GetUnit">
				<xsl:with-param name="node" select="c:Datum"/>
			</xsl:call-template>
		</xsl:variable>
		<td/>
		<td align="right">
			<xsl:call-template name="GetDatumValue">
				<xsl:with-param name="datumNode" select="c:Datum"/>
			</xsl:call-template>
			<xsl:value-of select="$unit"/>
		</td>
		<td/>
		<td align="center">
			<xsl:call-template name="GetComparisonTypeText">
				<xsl:with-param name="compText" select="@comparator"/>
			</xsl:call-template>
		</td>
	</xsl:template>
	<xsl:template match="c:LimitPair">
		<xsl:variable name="comparisionType">
			<xsl:choose>
				<xsl:when test="c:Nominal">
					EQT(== +/-)
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(c:Limit[1]/@comparator, c:Limit[2]/@comparator)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="c:Nominal">
				<xsl:apply-templates select="c:Nominal"/>
			</xsl:when>
			<xsl:otherwise>
				<td/>
				<xsl:apply-templates select="c:Limit"/>
			</xsl:otherwise>
		</xsl:choose>
		<td align="center">
			<xsl:call-template name="GetComparisonTypeText">
				<xsl:with-param name="compText" select="$comparisionType"/>
			</xsl:call-template>
		</td>
	</xsl:template>
	<xsl:template match="c:Nominal">
		<xsl:variable name="unit">
			<xsl:call-template name="GetUnit">
				<xsl:with-param name="node" select="c:Datum"/>
			</xsl:call-template>
		</xsl:variable>
		<td align="right">
			<xsl:call-template name="GetDatumValue">
				<xsl:with-param name="datumNode" select="c:Datum"/>
			</xsl:call-template>
			<xsl:value-of select="$unit"/>
		</td>
		<xsl:variable name="thresholdTypeSymbol">
			<xsl:choose>
				<xsl:when test="../../../../n1:Extension/ts:TSLimitProperties/ts:ThresholdType = 'PERCENTAGE'"> %</xsl:when>
				<xsl:when test="../../../../n1:Extension/ts:TSLimitProperties/ts:ThresholdType = 'PPM'"> PPM</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="thresholdTypeNode" select="../../../../n1:Extension/ts:TSLimitProperties/ts:ThresholdType"/>
		<xsl:variable name="limitTypeNode" select="c:Datum/@xsi:type"/>
    <xsl:variable name="nominalNode" select="../../../../n1:Extension/ts:TSLimitProperties/ts:RawLimits/ts:Nominal/@value"/>
    <xsl:variable name="lowNode" select="../../../../n1:Extension/ts:TSLimitProperties/ts:RawLimits/ts:Low/@value"/>
    <xsl:variable name="highNode" select="../../../../n1:Extension/ts:TSLimitProperties/ts:RawLimits/ts:High/@value"/>
		<xsl:variable name="computedLow">
			<xsl:choose>
				<xsl:when test="c:Datum/@xsi:type = 'c:string' or ../c:Limit[1]/c:Datum/@xsi:type = 'c:string' or ../c:Limit[2]/c:Datum/@xsi:type = 'c:string'">
					<xsl:variable name="lowValue">
						<xsl:call-template name="GetDatumValue">
							<xsl:with-param name="datumNode" select="../c:Limit[1]/c:Datum"/>
						</xsl:call-template>
					</xsl:variable>
					(Nominal - <xsl:value-of select="$lowValue"/> <xsl:value-of select="$thresholdTypeSymbol"/>)
				</xsl:when>
        <xsl:when test="../../../../n1:Extension/ts:TSLimitProperties/ts:RawLimits/ts:Nominal/@value and ../../../../n1:Extension/ts:TSLimitProperties/ts:RawLimits/ts:Low/@value">
          <xsl:value-of select="user:GetLimitThresholdValue($thresholdTypeNode, $limitTypeNode, $nominalNode, $lowNode, true())"/>
        </xsl:when>
				<xsl:otherwise>
					IND
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="computedHigh">
			<xsl:choose>
				<xsl:when test="c:Datum/@xsi:type = 'c:string' or ../c:Limit[1]/c:Datum/@xsi:type = 'c:string' or ../c:Limit[2]/c:Datum/@xsi:type = 'c:string'">
					<xsl:variable name="highValue">
						<xsl:call-template name="GetDatumValue">
							<xsl:with-param name="datumNode" select="../c:Limit[2]/c:Datum"/>
						</xsl:call-template>
					</xsl:variable>
					(Nominal + <xsl:value-of select="$highValue"/> <xsl:value-of select="$thresholdTypeSymbol"/>)
				</xsl:when>
        <xsl:when test="../../../../n1:Extension/ts:TSLimitProperties/ts:RawLimits/ts:Nominal/@value and ../../../../n1:Extension/ts:TSLimitProperties/ts:RawLimits/ts:High/@value">
          <xsl:value-of select="user:GetLimitThresholdValue($thresholdTypeNode, $limitTypeNode, $nominalNode, $highNode, false())"/>
        </xsl:when>
        <xsl:otherwise>
          IND
        </xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<td align="right">
			<xsl:value-of select="$computedLow"/>
		</td>
		<td align="right">
			<xsl:value-of select="$computedHigh"/>
		</td>
	</xsl:template>
	<xsl:template match="c:Limit">
		<xsl:variable name="unit">
			<xsl:call-template name="GetUnit">
				<xsl:with-param name="node" select="c:Datum"/>
			</xsl:call-template>
		</xsl:variable>
		<td align="right">
			<xsl:call-template name="GetDatumValue">
				<xsl:with-param name="datumNode" select="c:Datum"/>
			</xsl:call-template>
			<xsl:value-of select="$unit"/>
		</td>
	</xsl:template>
	<xsl:template match="c:Expected">
		<xsl:variable name="unit">
			<xsl:call-template name="GetUnit">
				<xsl:with-param name="node" select="c:Datum"/>
			</xsl:call-template>
		</xsl:variable>
		<td/>
		<td align="right">
			<xsl:call-template name="GetDatumValue">
				<xsl:with-param name="datumNode" select="c:Datum"/>
			</xsl:call-template>
			<xsl:value-of select="$unit"/>
		</td>
		<td/>
		<td align="center">
			<!-- For a TestStand string limit the comparison text shall be 'IgnoreCase' as the Test Results and Session Information schema  doesn't support reporting the TestStand string limit comparison types, such as Case Insensitive and Ignore Case -->
			<xsl:choose>
				<xsl:when test="../../../@ID = 'String'">
					<xsl:text>IgnoreCase</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="GetComparisonTypeText">
						<xsl:with-param name="compText" select="@comparator"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>
	<xsl:template match="c:Extension" mode="Limits">
		<xsl:choose>
			<xsl:when test="ts:TSLimitProperties/ts:IsComparisonTypeLog/@value='true'">
				<td/>
				<td/>
				<td/>
				<td align="center">LOG</td>
			</xsl:when>
			<xsl:otherwise>
				<td/>
				<td/>
				<td/>
				<td/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to process data of container type-->
	<xsl:template match="c:Collection">
		<xsl:param name="level" select="0"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="isFlowControlStep" select="false()"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:apply-templates select="c:Item">
			<xsl:with-param name="level" select="($level) + 1"/>
			<xsl:with-param name="objectPath" select="$objectPath"/>
			<xsl:with-param name="stepNode" select="$stepNode"/>
			<xsl:with-param name="isFlowControlStep" select="$isFlowControlStep"/>
			<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Template to process the contents of a container-->
	<xsl:template match="c:Item">
		<xsl:param name="level" select="0"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="isFlowControlStep" select="false()"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:variable name="isPropObjAttributesContainer">
			<xsl:call-template name="IsPropObjAttributesContainer">
				<xsl:with-param name="itemName" select="@name"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Process if,
               a) Not attributes and 
               b) Not 'ReportText' of flow control step.
		-->
		<xsl:if test="$isPropObjAttributesContainer='false' and not($isFlowControlStep='true' and position()=1)">
			<xsl:variable name="currentObjectPath">
				<xsl:choose>
					<xsl:when test="$objectPath!=''">
						<xsl:value-of select="concat($objectPath,'.',@name)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@name"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="c:Collection/@xsi:type='ts:NI_TDMSReference'">
					<xsl:for-each select="c:Collection">
						<xsl:call-template name="ProcessTDMSReference">
							<xsl:with-param name="level" select="$level"/>
							<xsl:with-param name="objectPath" select="$currentObjectPath"/>
							<xsl:with-param name="stepNode" select="$stepNode"/>
							<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="c:Collection">
						<xsl:variable name="classAttributeValue">
							<xsl:choose>
								<xsl:when test="$level > 1 and not($gGeneratePlainHTML)">trHide</xsl:when>
								<xsl:otherwise>
									<xsl:text/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="hasAttributes">
							<xsl:call-template name="HasAttributes">
								<xsl:with-param name="node" select="$stepNode"/>
								<xsl:with-param name="objectPath" select="$currentObjectPath"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="paddingValue">
							<xsl:choose>
								<xsl:when test="$hasAttributes='true' or count(c:Collection/*) > 0">
									<xsl:value-of select="$gSingleSpaceValue * 2 * ($level)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$gSingleSpaceValue * (2 * ($level) + 1)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="$putAsFlatData=false()">
							<tr class="level:{$level} state:collapsed {$classAttributeValue}">
								<td colspan="{$gFirstColumnSpan}" style="padding-left:{$paddingValue}px;">
									<xsl:if test="$hasAttributes='true' or count(c:Collection/*) > 0">
										<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
									</xsl:if>
									<xsl:value-of select="@name"/>:</td>
							</tr>
							<!-- Check if the processed property has attributes. If yes, then process attributes. -->
						</xsl:if>
						<xsl:if test="$hasAttributes='true'">
							<xsl:choose>
								<xsl:when test="$stepNode/n1:Data">
									<xsl:call-template name="ProcessAttributes">
										<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($currentObjectPath,'.Attributes')]"/>
										<xsl:with-param name="node" select="$stepNode"/>
										<xsl:with-param name="objectPath" select="concat($currentObjectPath,'.Attributes')"/>
										<xsl:with-param name="level" select="($level) + 1"/>
										<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$stepNode/c:Collection">
									<xsl:call-template name="ProcessAttributes">
										<xsl:with-param name="attributesNode" select="$stepNode/c:Collection/c:Item[@name=concat($currentObjectPath,'.Attributes')]"/>
										<xsl:with-param name="node" select="$stepNode"/>
										<xsl:with-param name="objectPath" select="concat($currentObjectPath,'.Attributes')"/>
										<xsl:with-param name="level" select="($level) + 1"/>
										<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates>
						<xsl:with-param name="level" select="$level"/>
						<xsl:with-param name="objectPath" select="$currentObjectPath"/>
						<xsl:with-param name="stepNode" select="$stepNode"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!--Template to process data of basic type-->
	<xsl:template match="c:Datum">
		<xsl:param name="level" select="0"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:variable name="hasAttributes">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="$objectPath"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="datumName">
			<xsl:choose>
				<xsl:when test="../@name">
					<xsl:value-of select="../@name"/>
				</xsl:when>
				<xsl:when test="../../@ID">
					<xsl:value-of select="../../@ID"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- Verifies whether its step 'ReportText' -->
		<xsl:variable name="isReportText">
			<xsl:choose>
				<xsl:when test="$datumName='ReportText' and @xsi:type='c:string'">
					<xsl:choose>
						<xsl:when test="../../@ID and local-name(../../preceding-sibling::*[1])!='TestResult'">
							<xsl:text>True</xsl:text>
						</xsl:when>
						<xsl:when test="../@name and count(../preceding-sibling::*)=0">
							<xsl:text>True</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>False</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>False</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="classAttributeValue">
			<xsl:choose>
				<xsl:when test="$level > 1 and not($gGeneratePlainHTML)">trHide</xsl:when>
				<xsl:otherwise>
					<xsl:text/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="paddingValue">
			<xsl:choose>
				<xsl:when test="$hasAttributes='true'">
					<xsl:value-of select="$gSingleSpaceValue * 2 * ($level)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$gSingleSpaceValue * (2 * ($level) + 1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$putAsFlatData">
				<tr>
					<td style="font-weight:bold;">
						<xsl:choose>
							<xsl:when test="$objectPath!=''">
								<xsl:value-of select="$objectPath"/>:
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$datumName"/>:
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<td>
						<xsl:choose>
							<!-- If step 'ReportText' then assign a specific color coding for the displayed value of 'ReportText'.-->
							<xsl:when test="$isReportText='True'">
								<span>
									<xsl:attribute name="style">color:#FF32CC;</xsl:attribute>
									<xsl:variable name="reportTextValue">
										<xsl:call-template name="GetDatumValue">
											<xsl:with-param name="datumNode" select="."/>
										</xsl:call-template>
									</xsl:variable>
									<xsl:value-of select="$reportTextValue" disable-output-escaping="yes"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="GetDatumValue">
									<xsl:with-param name="datumNode" select="."/>
								</xsl:call-template>
								<xsl:call-template name="GetUnit">
									<xsl:with-param name="node" select="."/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<tr class="level:{$level} state:collapsed {$classAttributeValue}">
					<td style="padding-left:{$paddingValue}px;">
						<xsl:choose>
							<!-- If the current processed property has attributes then add expand/collapse functionality for the property , 
                          as attributes for the property will be added as a child of the processed property.-->
							<xsl:when test="$hasAttributes='true'">
								<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<!-- If step 'ReportText' then assign a specific color coding for the displayed name. -->
							<xsl:when test="$isReportText='True'">
								<span>
									<xsl:attribute name="style">color:#FF32CC;</xsl:attribute>
									<xsl:value-of select="$datumName"/>:
						</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$datumName"/>:</xsl:otherwise>
						</xsl:choose>
						<!-- Add description, if present -->
						<xsl:if test="$level='1' and ../../n1:Description">
								<span style="padding-left:{$gSingleSpaceValue * 2}px;"><br/>(<xsl:value-of select="../../n1:Description"/>)</span>
						</xsl:if>
					</td>
					<td colspan="{$gSecondColumnSpan}">
						<xsl:choose>
							<!-- If step 'ReportText' then assign a specific color coding for the displayed value of 'ReportText'.-->
							<xsl:when test="$isReportText='True'">
								<span>
									<xsl:attribute name="style">color:#FF32CC;</xsl:attribute>
									<xsl:value-of disable-output-escaping="yes" select="user:ReplaceWhitespaceAndNewLine(c:Value, true())"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="GetDatumValue">
									<xsl:with-param name="datumNode" select="."/>
								</xsl:call-template>
								<xsl:call-template name="GetUnit">
									<xsl:with-param name="node" select="."/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
		<!-- If the currently processed property has attributes then process it.-->
		<xsl:if test="$hasAttributes='true'">
			<xsl:choose>
				<xsl:when test="$stepNode/n1:Data">
					<xsl:call-template name="ProcessAttributes">
						<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
						<xsl:with-param name="node" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$stepNode/c:Collection">
					<xsl:call-template name="ProcessAttributes">
						<xsl:with-param name="attributesNode" select="$stepNode/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
						<xsl:with-param name="node" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!--Template to process data of array type-->
	<xsl:template match="c:IndexedArray">
		<xsl:param name="level" select="0"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:variable name="hasAttributes">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="$objectPath"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="classAttributeValue">
			<xsl:choose>
				<xsl:when test="$level > 1 and not($gGeneratePlainHTML)">trHide</xsl:when>
				<xsl:otherwise>
					<xsl:text/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="paddingValue">
			<xsl:choose>
				<xsl:when test="$hasAttributes='true'">
					<xsl:value-of select="$gSingleSpaceValue * 2 * ($level)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$gSingleSpaceValue * (2 * ($level) + 1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$putAsFlatData">
				<tr>
					<td style="font-weight:bold;">
						<xsl:choose>
							<xsl:when test="$objectPath!=''">
								<xsl:value-of select="$objectPath"/>:
					</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="../@name"/>:
						</xsl:otherwise>
						</xsl:choose>
					</td>
					<td>
						<xsl:call-template name="GetArrayValue">
							<xsl:with-param name="arrayNode" select="."/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<tr class="level:{$level} state:collapsed {$classAttributeValue}">
					<td style="padding-left:{$paddingValue}px;">
						<xsl:choose>
							<!-- If the current processed property has attributes then add expand/collapse functionality for the property , 
                             as attributes for the property will be added as a child of the processed property.-->
							<xsl:when test="$hasAttributes='true'">
								<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="../@name">
								<xsl:value-of select="../@name"/>:
						</xsl:when>
							<xsl:when test="../../@ID">
								<xsl:value-of select="../../@ID"/>:
						</xsl:when>
						</xsl:choose>
						<!--Add description, if present.-->
						<xsl:if test="$level='1' and ../../n1:Description">							
							<span style="padding-left:{$gSingleSpaceValue * 2}px;"><br/>(<xsl:value-of select="../../n1:Description"/>)</span>
						</xsl:if>
					</td>
					<td colspan="{$gSecondColumnSpan}">
						<xsl:call-template name="GetArrayValue">
							<xsl:with-param name="arrayNode" select="."/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
		<!-- If the currently processed property has attributes then process it.-->
		<xsl:if test="$hasAttributes='true'">
			<xsl:choose>
				<xsl:when test="$stepNode/n1:Data">
					<xsl:call-template name="ProcessAttributes">
						<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
						<xsl:with-param name="node" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$stepNode/c:Collection">
					<xsl:call-template name="ProcessAttributes">
						<xsl:with-param name="attributesNode" select="$stepNode/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
						<xsl:with-param name="node" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- Template to process attribute of container type -->
	<xsl:template match="c:Collection" mode="Attributes">
		<xsl:param name="level" select="0"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:apply-templates select="c:Item/c:Collection/c:Item[1]" mode="Attributes">
			<xsl:with-param name="level" select="$level + 1"/>
			<xsl:with-param name="stepNode" select="$stepNode"/>
			<xsl:with-param name="objectPath" select="$objectPath"/>
			<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Template to process contents of an attribute of container type-->
	<xsl:template match="c:Item" mode="Attributes">
		<xsl:param name="level" select="0"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:variable name="itemName">
			<xsl:value-of select="substring(@name,0,string-length(@name) - 5)"/>
		</xsl:variable>
		<xsl:variable name="currentObjectPath">
			<xsl:choose>
				<xsl:when test="$objectPath!=''">
					<xsl:value-of select="concat($objectPath,'.',$itemName)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$itemName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="c:Collection/@xsi:type='ts:NI_TDMSReference'">
				<xsl:for-each select="c:Collection">
					<xsl:call-template name="ProcessTDMSReferenceAttribute">
						<xsl:with-param name="level" select="$level"/>
						<xsl:with-param name="stepNode" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="$currentObjectPath"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="c:Collection">
					<xsl:variable name="classAttributeValue">
						<xsl:choose>
							<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
							<xsl:otherwise>
								<xsl:text/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="hasAttributes">
						<xsl:call-template name="HasAttributes">
							<xsl:with-param name="node" select="$stepNode"/>
							<xsl:with-param name="objectPath" select="$currentObjectPath"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="paddingValue">
						<xsl:choose>
							<xsl:when test="$hasAttributes='true' or count(c:Collection/*) > 0">
								<xsl:value-of select="$gSingleSpaceValue * 2 * ($level)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$gSingleSpaceValue * (2 * ($level) + 1)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="$putAsFlatData=false()">
						<tr class="level:{$level} state:collapsed {$classAttributeValue}">
							<td colspan="{$gFirstColumnSpan}" style="padding-left:{$paddingValue}px;">
								<xsl:if test="$hasAttributes='true' or count(c:Collection/*) > 0">
									<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
								</xsl:if>
								<xsl:value-of select="$itemName"/>:</td>
						</tr>
					</xsl:if>
					<xsl:if test="$hasAttributes='true'">
						<xsl:choose>
							<xsl:when test="$stepNode/n1:Data">
								<xsl:call-template name="ProcessAttributes">
									<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($currentObjectPath,'.Attributes')]"/>
									<xsl:with-param name="node" select="$stepNode"/>
									<xsl:with-param name="objectPath" select="concat($currentObjectPath,'.Attributes')"/>
									<xsl:with-param name="level" select="($level) + 1"/>
									<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="$stepNode/c:Collection">
								<xsl:call-template name="ProcessAttributes">
									<xsl:with-param name="attributesNode" select="$stepNode/c:Collection/c:Item[@name=concat($currentObjectPath,'.Attributes')]"/>
									<xsl:with-param name="node" select="$stepNode"/>
									<xsl:with-param name="objectPath" select="concat($currentObjectPath,'.Attributes')"/>
									<xsl:with-param name="level" select="($level) + 1"/>
									<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
								</xsl:call-template>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
				</xsl:if>
				<xsl:apply-templates mode="Attributes">
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="stepNode" select="$stepNode"/>
					<xsl:with-param name="objectPath" select="$currentObjectPath"/>
					<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--Template to process the attribute of basic type-->
	<xsl:template match="c:Datum" mode="Attributes">
		<xsl:param name="level" select="0"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:variable name="classAttributeValue">
			<xsl:choose>
				<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
				<xsl:otherwise>
					<xsl:text/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="hasAttributes">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="$objectPath"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="paddingValue">
			<xsl:choose>
				<xsl:when test="$hasAttributes='true'">
					<xsl:value-of select="$gSingleSpaceValue * 2 * ($level)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$gSingleSpaceValue * (2 * ($level) + 1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$putAsFlatData">
				<tr>
					<td style="font-weight:bold;">
						<xsl:choose>
							<!-- If the current processed property has attributes then add expand/collapse functionality for the property , 
                          as attributes for the property will be added as a child of the processed property.-->
							<xsl:when test="$objectPath!=''">
								<xsl:value-of select="$objectPath"/>:
					</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring(../@name,0,string-length(../@name)-5)"/>:
					</xsl:otherwise>
						</xsl:choose>
					</td>
					<td>
						<xsl:call-template name="GetDatumValue">
							<xsl:with-param name="datumNode" select="."/>
						</xsl:call-template>
						<xsl:call-template name="GetUnit">
							<xsl:with-param name="node" select="."/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<tr class="level:{$level} state:collapsed {$classAttributeValue}">
					<td style="padding-left:{$paddingValue}px;">
						<xsl:choose>
							<!-- If the current processed property has attributes then add expand/collapse functionality for the property , 
                          as attributes for the property will be added as a child of the processed property.-->
							<xsl:when test="$hasAttributes='true'">
								<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
								<xsl:value-of select="substring(../@name,0,string-length(../@name)-5)"/>:
							</xsl:when>
							<xsl:otherwise>
									<xsl:value-of select="substring(../@name,0,string-length(../@name)-5)"/>:
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<td colspan="{$gSecondColumnSpan}">
						<xsl:call-template name="GetDatumValue">
							<xsl:with-param name="datumNode" select="."/>
						</xsl:call-template>
						<xsl:call-template name="GetUnit">
							<xsl:with-param name="node" select="."/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$hasAttributes='true'">
			<xsl:choose>
				<xsl:when test="$stepNode/n1:Data">
					<xsl:call-template name="ProcessAttributes">
						<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
						<xsl:with-param name="node" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$stepNode/c:Collection">
					<xsl:call-template name="ProcessAttributes">
						<xsl:with-param name="attributesNode" select="$stepNode/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
						<xsl:with-param name="node" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- Template to process attribute of array type-->
	<xsl:template match="c:IndexedArray" mode="Attributes">
		<xsl:param name="level" select="0"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:variable name="classAttributeValue">
			<xsl:choose>
				<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
				<xsl:otherwise>
					<xsl:text/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="hasAttributes">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="$objectPath"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="paddingValue">
			<xsl:choose>
				<xsl:when test="$hasAttributes='true'">
					<xsl:value-of select="$gSingleSpaceValue * 2 * ($level)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$gSingleSpaceValue * (2 * ($level) + 1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$putAsFlatData">
				<tr>
					<td style="font-weight:bold;">
						<xsl:choose>
							<!-- If the current processed property has attributes then add expand/collapse functionality for the property , 
                          as attributes for the property will be added as a child of the processed property.-->
							<xsl:when test="$objectPath!=''">
								<xsl:value-of select="$objectPath"/>:
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring(../@name,0,string-length(../@name)-5)"/>:
					</xsl:otherwise>
						</xsl:choose>
					</td>
					<td colspan="{$gSecondColumnSpan}">
						<xsl:call-template name="GetArrayValue">
							<xsl:with-param name="arrayNode" select="."/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<tr class="{$classAttributeValue} level:{$level} state:collapsed">
					<td style="padding-left:{$paddingValue}px;">
						<xsl:choose>
							<!-- If the current processed property has attributes then add expand/collapse functionality for the property , 
                          as attributes for the property will be added as a child of the processed property.-->
							<xsl:when test="$hasAttributes='true'">
								<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
								<xsl:value-of select="substring(../@name,0,string-length(../@name)-5)"/>:
							</xsl:when>
							<xsl:otherwise>
									<xsl:value-of select="substring(../@name,0,string-length(../@name)-5)"/>:
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<td colspan="{$gSecondColumnSpan}">
						<xsl:call-template name="GetArrayValue">
							<xsl:with-param name="arrayNode" select="."/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$hasAttributes='true'">
			<xsl:choose>
				<xsl:when test="$stepNode/n1:Data">
					<xsl:call-template name="ProcessAttributes">
						<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
						<xsl:with-param name="node" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$stepNode/c:Collection">
					<xsl:call-template name="ProcessAttributes">
						<xsl:with-param name="attributesNode" select="$stepNode/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
						<xsl:with-param name="node" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- Template to add unit for a property of basic type-->
	<xsl:template name="GetUnit">
		<xsl:param name="node"/>
		<xsl:choose>
			<xsl:when test="$node/@unit">
				<xsl:text> </xsl:text>
				<xsl:value-of select="$node/@unit"/>
			</xsl:when>
			<xsl:when test="$node/@nonStandardUnit">
				<xsl:text> </xsl:text>
				<xsl:value-of select="$node/@nonStandardUnit"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Template to process TestStand specific information of a step-->
	<xsl:template match="ts:TSStepProperties">
		<xsl:param name="level" select="0"/>
		<!-- Add TestStand specific information to the transformed HTML report only if 'gShowTestStandSpecificInformation' is set to 'true()'-->
		<xsl:if test="$gShowTestStandSpecificInformation">
			<tr class="level:{$level} state:collapsed">
				<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2 * ($level)}px;">
					<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>TestStand Specific Information</td>
			</tr>
			<xsl:variable name="childLevel" select="($level) + 2"/>
			<xsl:variable name="paddingValue" select="2 * $childLevel"/>
			<xsl:variable name="columnEmptyCells">
				<xsl:call-template name="GetStepEmptyCells">
					<xsl:with-param name="noOfEmptyCells" select="$gThirdColumnSpan"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="parentStepName" select="name(../..)"/>
			<xsl:variable name="parentStepID" select="../../@ID"/>
			<xsl:choose>
				<!-- Add step id -->
				<xsl:when test="ts:StepId">
					<xsl:call-template name="AddTSSpecificProperty">
						<xsl:with-param name="level" select="$childLevel"/>
						<xsl:with-param name="paddingValue" select="$paddingValue"/>
						<xsl:with-param name="tsSpecificPropertyName">TestStand Step Id</xsl:with-param>
						<xsl:with-param name="tsSpecificPropertyValue" select="ts:StepId"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$gProcessAsserts">
					<xsl:call-template name="ProcessAssert">
						<xsl:with-param name="assertMessage">
							In template 'ts:TSStepProperties' : TestStand Specific Information - 'TestStand Step Id' not logged in the report for &amp;lt;<xsl:value-of select="$parentStepName"/>&amp;gt; element with ID=&quot;<xsl:value-of select="$parentStepID"/>&quot;
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<!-- Add step type -->
				<xsl:when test="ts:StepType">
					<xsl:call-template name="AddTSSpecificProperty">
						<xsl:with-param name="level" select="$childLevel"/>
						<xsl:with-param name="paddingValue" select="$paddingValue"/>
						<xsl:with-param name="tsSpecificPropertyName">Step Type</xsl:with-param>
						<xsl:with-param name="tsSpecificPropertyValue" select="ts:StepType"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$gProcessAsserts">
					<xsl:call-template name="ProcessAssert">
						<xsl:with-param name="assertMessage">
							In template 'ts:TSStepProperties' : TestStand Specific Information - 'Step Type' not logged in the report for &amp;lt;<xsl:value-of select="$parentStepName"/>&amp;gt; element with ID=&quot;<xsl:value-of select="$parentStepID"/>&quot;
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<!-- Add step group to which the step belongs -->
				<xsl:when test="ts:StepGroup">
					<xsl:call-template name="AddTSSpecificProperty">
						<xsl:with-param name="level" select="$childLevel"/>
						<xsl:with-param name="paddingValue" select="$paddingValue"/>
						<xsl:with-param name="tsSpecificPropertyName">Step Group</xsl:with-param>
						<xsl:with-param name="tsSpecificPropertyValue" select="ts:StepGroup"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$gProcessAsserts">
					<xsl:call-template name="ProcessAssert">
						<xsl:with-param name="assertMessage">
							In template 'ts:TSStepProperties' : TestStand Specific Information - 'Step Group' not logged in the report for &amp;lt;<xsl:value-of select="$parentStepName"/>&amp;gt; element with ID=&quot;<xsl:value-of select="$parentStepID"/>&quot;
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<!-- Add block level of the step-->
				<xsl:when test="ts:BlockLevel">
					<xsl:call-template name="AddTSSpecificProperty">
						<xsl:with-param name="level" select="$childLevel"/>
						<xsl:with-param name="paddingValue" select="$paddingValue"/>
						<xsl:with-param name="tsSpecificPropertyName">Block Level</xsl:with-param>
						<xsl:with-param name="tsSpecificPropertyValue" select="ts:BlockLevel/@value"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$gProcessAsserts">
					<xsl:call-template name="ProcessAssert">
						<xsl:with-param name="assertMessage">
							In template 'ts:TSStepProperties' : TestStand Specific Information - 'Block Level' not logged in the report for &amp;lt;<xsl:value-of select="$parentStepName"/>&amp;gt; element with ID=&quot;<xsl:value-of select="$parentStepID"/>&quot;
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<!-- Identifies whether step caused sequence failure -->
			<xsl:if test="ts:StepCausedSequenceFailure and (ts:StepCausedSequenceFailure/@value='true')">
				<xsl:call-template name="AddTSSpecificProperty">
					<xsl:with-param name="level" select="$childLevel"/>
					<xsl:with-param name="paddingValue" select="$paddingValue"/>
					<xsl:with-param name="tsSpecificPropertyName">Step Caused Sequence Failure</xsl:with-param>
					<xsl:with-param name="tsSpecificPropertyValue">True</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:choose>
				<!-- Add step index-->
				<xsl:when test="ts:Index">
					<xsl:call-template name="AddTSSpecificProperty">
						<xsl:with-param name="level" select="$childLevel"/>
						<xsl:with-param name="paddingValue" select="$paddingValue"/>
						<xsl:with-param name="tsSpecificPropertyName">Index</xsl:with-param>
						<xsl:with-param name="tsSpecificPropertyValue" select="ts:Index/@value"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$gProcessAsserts">
					<xsl:call-template name="ProcessAssert">
						<xsl:with-param name="assertMessage">
							In template 'ts:TSStepProperties' : TestStand Specific Information - 'Index' not logged in the report for &amp;lt;<xsl:value-of select="$parentStepName"/>&amp;gt; element with ID=&quot;<xsl:value-of select="$parentStepID"/>&quot;
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<!-- Add step looping properties, if the step is set to loop-->
			<xsl:apply-templates select="ts:LoopingProperties">
				<xsl:with-param name="level" select="$childLevel"/>
				<xsl:with-param name="paddingValue" select="$paddingValue"/>
				<xsl:with-param name="columnEmptyCells" select="$columnEmptyCells"/>
				<xsl:with-param name="parentStepName" select="$parentStepName"/>
				<xsl:with-param name="parentStepID" select="$parentStepID"/>
			</xsl:apply-templates>
			<!--Add remote server id, if a call to a remote sequence is performed-->
			<xsl:if test="ts:RemoteServerId">
				<xsl:call-template name="AddTSSpecificProperty">
					<xsl:with-param name="level" select="$childLevel"/>
					<xsl:with-param name="paddingValue" select="$paddingValue"/>
					<xsl:with-param name="tsSpecificPropertyName">Remote Server</xsl:with-param>
					<xsl:with-param name="tsSpecificPropertyValue" select="ts:RemoteServerId"/>
				</xsl:call-template>
			</xsl:if>
			<!--Add interactive execution step id, if the step is executed as part of an interactive execution-->
			<xsl:if test="ts:InteractiveExecutionId">
				<xsl:call-template name="AddTSSpecificProperty">
					<xsl:with-param name="level" select="$childLevel"/>
					<xsl:with-param name="paddingValue" select="$paddingValue"/>
					<xsl:with-param name="tsSpecificPropertyName">Interactive Execution #</xsl:with-param>
					<xsl:with-param name="tsSpecificPropertyValue" select="ts:InteractiveExecutionId/@value"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- Template to process Looping step properties -->
	<xsl:template match="ts:LoopingProperties">
		<xsl:param name="level" select="0"/>
		<xsl:param name="paddingValue" select="0"/>
		<xsl:param name="columnEmptyCells" select="''"/>
		<xsl:param name="parentStepName" select="''"/>
		<xsl:param name="parentStepID" select="''"/>
		<xsl:if test="ts:NumLoops">
			<xsl:call-template name="AddTSSpecificProperty">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="paddingValue" select="$paddingValue"/>
				<xsl:with-param name="tsSpecificPropertyName">Number of Iterations</xsl:with-param>
				<xsl:with-param name="tsSpecificPropertyValue">
					<xsl:call-template name="GetDatumValue">
						<xsl:with-param name="datumNode" select="ts:NumLoops"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="ts:NumPassed">
			<xsl:call-template name="AddTSSpecificProperty">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="paddingValue" select="$paddingValue"/>
				<xsl:with-param name="tsSpecificPropertyName">Number of Steps Passed</xsl:with-param>
				<xsl:with-param name="tsSpecificPropertyValue">
					<xsl:call-template name="GetDatumValue">
						<xsl:with-param name="datumNode" select="ts:NumPassed"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="ts:NumFailed">
			<xsl:call-template name="AddTSSpecificProperty">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="paddingValue" select="$paddingValue"/>
				<xsl:with-param name="tsSpecificPropertyName">Number of Steps Failed</xsl:with-param>
				<xsl:with-param name="tsSpecificPropertyValue">
					<xsl:call-template name="GetDatumValue">
						<xsl:with-param name="datumNode" select="ts:NumFailed"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="ts:EndingLoopIndex">
			<xsl:call-template name="AddTSSpecificProperty">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="paddingValue" select="$paddingValue"/>
				<xsl:with-param name="tsSpecificPropertyName">Ending Loop Index</xsl:with-param>
				<xsl:with-param name="tsSpecificPropertyValue">
					<xsl:call-template name="GetDatumValue">
						<xsl:with-param name="datumNode" select="ts:EndingLoopIndex"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="ts:LoopIndex">
			<xsl:call-template name="AddTSSpecificProperty">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="paddingValue" select="$paddingValue"/>
				<xsl:with-param name="tsSpecificPropertyName">Loop Index</xsl:with-param>
				<xsl:with-param name="tsSpecificPropertyValue">
					<xsl:call-template name="GetDatumValue">
						<xsl:with-param name="datumNode" select="ts:LoopIndex"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$gProcessAsserts">
			<xsl:if test="not(ts:EndingLoopIndex) and not(ts:LoopIndex)">
				<xsl:variable name="parentStepNode" select="../../.."/>
				<xsl:call-template name="ProcessAssert">
					<xsl:with-param name="assertMessage">
						In template 'ts:LoopingProperties' : TestStand Specific Information - Neither 'Loop Index' nor 'Ending Loop Index' is logged in the report for &amp;lt;<xsl:value-of select="$parentStepName"/>&amp;gt; element with ID=&quot;<xsl:value-of select="$parentStepID"/>&quot;
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- Template to add TestStand specific property to the transformed HTML report-->
	<xsl:template name="AddTSSpecificProperty">
		<xsl:param name="level" select="0"/>
		<xsl:param name="paddingValue" select="0"/>
		<xsl:param name="tsSpecificPropertyName" select="''"/>
		<xsl:param name="tsSpecificPropertyValue" select="''"/>
		<xsl:variable name="classAttributeValue">
			<xsl:choose>
				<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
				<xsl:otherwise>
					<xsl:text/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr class="level:{$level} state:collapsed {$classAttributeValue}">
			<td style="padding-left:{$gSingleSpaceValue * ($paddingValue)}px;">
				<xsl:value-of select="$tsSpecificPropertyName"/>
			</td>
			<td colspan="{$gSecondColumnSpan}">
				<xsl:value-of select="$tsSpecificPropertyValue"/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="n1:Extension"/>
	<!-- Template that returns the comparison type operator postfixed to the comparison type display string, for a given comparison type display string specified by 'compText'-->
	<xsl:template name="GetComparisonTypeText">
		<xsl:param name="compText"/>
		<xsl:value-of select="$compText"/>
		<xsl:choose>
			<xsl:when test="$compText='EQ'">
				<xsl:text disable-output-escaping="yes">(==)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='NE'">
				<xsl:text disable-output-escaping="yes">(!=)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='GT'">
				<xsl:text disable-output-escaping="yes">(&gt;)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='GE'">
				<xsl:text disable-output-escaping="yes">(&gt;=)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='LT'">
				<xsl:text disable-output-escaping="yes">(&lt;)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='LE'">
				<xsl:text disable-output-escaping="yes">(&lt;=)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='GTLT'">
				<xsl:text disable-output-escaping="yes">(&gt; &lt;)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='GELT'">
				<xsl:text disable-output-escaping="yes">(&gt;= &lt;)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='GELE'">
				<xsl:text disable-output-escaping="yes">(&gt;= &lt;=)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='GTLE'">
				<xsl:text disable-output-escaping="yes">(&gt; &lt;=)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='LTGT'">
				<xsl:text disable-output-escaping="yes">(&lt; &gt;)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='LTGE'">
				<xsl:text disable-output-escaping="yes">(&lt; &gt;=)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='LEGE'">
				<xsl:text disable-output-escaping="yes">(&lt;= &gt;=)</xsl:text>
			</xsl:when>
			<xsl:when test="$compText='LEGT'">
				<xsl:text disable-output-escaping="yes">(&lt;= &gt;)</xsl:text>
			</xsl:when>
			<xsl:when test="$gProcessAsserts">
				<xsl:call-template name="ProcessAssert">
					<xsl:with-param name="assertMessage">
						In template 'GetComparisonTypeText' : Comparison Type &quot;<xsl:value-of select="$compText"/>&quot; is not supported by TestStand. 
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Template returns the color coding for a given step outcome specified by 'status'.-->
	<xsl:template name="GetStatusColor">
		<xsl:param name="status"/>
		<xsl:choose>
			<xsl:when test="$status = 'Passed'">#008000</xsl:when>
			<xsl:when test="$status = 'Done'">#008000</xsl:when>
			<xsl:when test="$status = 'Failed'">#FF0000</xsl:when>
			<xsl:when test="$status = 'Error'">#FF0000</xsl:when>
			<xsl:when test="$status = 'Terminated'">#000080</xsl:when>
			<xsl:when test="$status = 'Running'">#FFCC33</xsl:when>
			<xsl:otherwise>#B98028</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to check whether processed property, specified by 'node', has attributes defined for it or not.-->
	<xsl:template name="HasAttributes">
		<xsl:param name="node"/>
		<xsl:param name="objectPath"/>
		<xsl:choose>
			<xsl:when test="$node/n1:Data">
				<xsl:choose>
					<xsl:when test="$node/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]">
						<xsl:variable name="shouldIncludeAttribute">
							<xsl:call-template name="CheckIfIncludeInReportIsPresentForAttributes">
								<xsl:with-param name="attributeNode" select="$node/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$shouldIncludeAttribute"/>
					</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$node/c:Collection">
				<xsl:choose>
					<xsl:when test="$node/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]">
						<xsl:variable name="shouldIncludeAttribute">
							<xsl:call-template name="CheckIfIncludeInReportIsPresentForAttributes">
								<xsl:with-param name="attributeNode" select="$node/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$shouldIncludeAttribute"/>
					</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to process and add attributes of property-->
	<xsl:template name="ProcessAttributes">
		<xsl:param name="attributesNode"/>
		<xsl:param name="node"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="level"/>
		<xsl:param name="includeAttributesHeader" select="true()"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<xsl:if test="$includeAttributesHeader">
			<xsl:variable name="classAttributeValue">
				<xsl:choose>
					<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
					<xsl:otherwise>
						<xsl:text/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<tr class="level:{$level} state:collapsed {$classAttributeValue}">
				<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2 * ($level)}px;">
					<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>Attributes:
			</td>
			</tr>
		</xsl:if>
		<xsl:for-each select="$attributesNode[1]/c:Collection/c:Item">
			<xsl:variable name="shouldIncludeAttribute">
				<xsl:call-template name="CheckIfIncludeFlagIsSet">
					<xsl:with-param name="flag" select="c:Collection/c:Item[2]/c:Datum/@value"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$shouldIncludeAttribute='true'">
					<xsl:apply-templates select="c:Collection/c:Item[1]" mode="Attributes">
						<xsl:with-param name="level" select="$level + 1"/>
						<xsl:with-param name="stepNode" select="$node"/>
						<xsl:with-param name="objectPath" select="$objectPath"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="c:Collection/c:Item[1]/c:Collection">
						<xsl:variable name="containerFields">
							<xsl:call-template name="ProcessAttributes">
								<xsl:with-param name="attributesNode" select="c:Collection/c:Item[1]"/>
								<xsl:with-param name="node" select="$node"/>
								<xsl:with-param name="objectPath">
									<xsl:choose>
										<xsl:when test="$objectPath!=''">
											<xsl:value-of select="concat($objectPath,'.',@name)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@name"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="level" select="($level) + 1"/>
								<xsl:with-param name="includeAttributesHeader" select="false()"/>
								<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="$containerFields != ''">
							<xsl:variable name="classAttributeValue">
								<xsl:choose>
									<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
									<xsl:otherwise>
										<xsl:text/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<tr class="level:{$level + 1} state:collapsed {$classAttributeValue}">
								<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2 * ($level + 1)}px;">
									<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
									<xsl:value-of select="@name"/>:</td>
							</tr>
							<xsl:copy-of select="$containerFields"/>
						</xsl:if>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!-- Template to process and add step limit attributes, if present -->
	<xsl:template name="ProcessLimitAttributes">
		<xsl:param name="stepNode"/>
		<xsl:param name="limitID"/>
		<xsl:param name="level"/>
		<xsl:variable name="hasLimitsAttr">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="concat($limitID,'.Limits')"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="hasLowAttr">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.Low')"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="hasHighAttr">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.High')"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="hasStringAttr">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.String')"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="hasCompAttr">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.Comp')"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="hasUnitsAttr">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.Units')"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Checks whether any of the following properties has attributes :
                a) Step.Limits
				b) Step.Limits.Low
                c) Step.Limits.High
                d) Step.Limits.String
                e) Step.Comp
				f) Step.Units
		-->
		<xsl:if test="$hasLimitsAttr='true' or  $hasLowAttr='true' or $hasHighAttr='true' or $hasStringAttr='true' or $hasCompAttr='true' or $hasUnitsAttr='true'">
			<tr class="level:1 state:expanded">
				<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2 * ($level)}px;">
					<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>Limits:
				</td>
			</tr>
			<xsl:variable name="indentationValue">
				<xsl:value-of select="2 * ($level) + 1"/>
			</xsl:variable>
			<!-- Add 'Step.Limits' attributes, if present-->
			<xsl:if test="$hasLimitsAttr='true'">
				<xsl:call-template name="ProcessAttributes">
					<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($limitID,'.Limits.Attributes')]"/>
					<xsl:with-param name="node" select="$stepNode"/>
					<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.Attributes')"/>
					<xsl:with-param name="level" select="($level) + 1"/>
				</xsl:call-template>
			</xsl:if>
			<!-- Add 'Step.Limits.Low' attributes, if present-->
			<xsl:if test="$hasLowAttr='true'">
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<tr class="level:{$level + 1} state:collapsed {$classAttributeValue}">
					<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * ($indentationValue)}px;">
						<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>Low:</td>
				</tr>
				<xsl:call-template name="ProcessAttributes">
					<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($limitID,'.Limits.Low.Attributes')]"/>
					<xsl:with-param name="node" select="$stepNode"/>
					<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.Low.Attributes')"/>
					<xsl:with-param name="level" select="($level) + 2"/>
				</xsl:call-template>
			</xsl:if>
			<!-- Add 'Step.Limits.High' attributes, if present-->
			<xsl:if test="$hasHighAttr='true'">
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<tr class="level:{$level + 1} state:collapsed {$classAttributeValue}">
					<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * ($indentationValue)}px;">
						<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>High:</td>
				</tr>
				<xsl:call-template name="ProcessAttributes">
					<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($limitID,'.Limits.High.Attributes')]"/>
					<xsl:with-param name="node" select="$stepNode"/>
					<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.High.Attributes')"/>
					<xsl:with-param name="level" select="($level) + 2"/>
				</xsl:call-template>
			</xsl:if>
			<!-- Add 'Step.Limits.String' attributes, if present-->
			<xsl:if test="$hasStringAttr='true'">
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<tr class="level:{$level + 1} state:collapsed {$classAttributeValue}">
					<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * ($indentationValue)}px;">
						<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>String:</td>
				</tr>
				<xsl:call-template name="ProcessAttributes">
					<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($limitID,'.Limits.String.Attributes')]"/>
					<xsl:with-param name="node" select="$stepNode"/>
					<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.String.Attributes')"/>
					<xsl:with-param name="level" select="($level) + 2"/>
				</xsl:call-template>
			</xsl:if>
			<!-- Add 'Step.Comp' attributes, if present-->
			<xsl:if test="$hasCompAttr='true'">
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<tr class="level:{$level + 1} state:collapsed {$classAttributeValue}">
					<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * ($indentationValue)}px;">
						<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>Comp:</td>
				</tr>
				<xsl:call-template name="ProcessAttributes">
					<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($limitID,'.Limits.Comp.Attributes')]"/>
					<xsl:with-param name="node" select="$stepNode"/>
					<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.Comp.Attributes')"/>
					<xsl:with-param name="level" select="($level) + 2"/>
				</xsl:call-template>
			</xsl:if>
			<!-- Add 'Step.Units' attributes, if present-->
			<xsl:if test="$hasUnitsAttr='true'">
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<tr class="level:{$level + 1} state:collapsed {$classAttributeValue}">
					<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * ($indentationValue)}px;">
						<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>Units:</td>
				</tr>
				<xsl:call-template name="ProcessAttributes">
					<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($limitID,'.Limits.Units.Attributes')]"/>
					<xsl:with-param name="node" select="$stepNode"/>
					<xsl:with-param name="objectPath" select="concat($limitID,'.Limits.Units.Attributes')"/>
					<xsl:with-param name="level" select="($level) + 2"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- Template replaces all occurences of string 'oldSubString', present in string 'inputString', with string 'newSubString'-->
	<xsl:template name="ReplaceSubString">
		<xsl:param name="inputString"/>
		<xsl:param name="oldSubString"/>
		<xsl:param name="newSubString"/>
		<xsl:variable name="head">
			<xsl:value-of select="substring-before($inputString,$oldSubString)"/>
		</xsl:variable>
		<xsl:variable name="tail">
			<xsl:value-of select="substring-after($inputString,$oldSubString)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($tail)=0">
				<xsl:value-of select="$inputString"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="ReplaceSubString">
					<xsl:with-param name="inputString" select="concat($head,$newSubString,$tail)"/>
					<xsl:with-param name="oldSubString" select="$oldSubString"/>
					<xsl:with-param name="newSubString" select="$newSubString"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template adds a given number of <div> HTML tags specified by 'noOfDivTags' -->
	<xsl:template name="OpenDivTags">
		<xsl:param name="noOfDivTags"/>
		<!-- 
				The values that can be held by 'canHide' are
				0 - cannot hide 'div'
                1 - can hide 'div'
                2 - can hide 'div' (This is a special case for controlling the display of postactions present, at a different block level, for sequence call steps)
        -->
		<xsl:param name="canHide" select="1"/>
		<xsl:param name="isRootSequenceTable" select="false()"/>
		<xsl:if test="$noOfDivTags!=0">
			<xsl:text disable-output-escaping="yes">&lt;div class=&quot;</xsl:text>
			<xsl:choose>
				<xsl:when test="$gIndentTables">divIndentUnhide</xsl:when>
				<xsl:otherwise>divWithoutIndentUnhide</xsl:otherwise>
			</xsl:choose>
			<xsl:text disable-output-escaping="yes"> canHide:</xsl:text>
			<xsl:value-of select="$canHide"/>
			<xsl:text disable-output-escaping="yes">&quot;&gt;</xsl:text>
			<xsl:call-template name="OpenDivTags">
				<xsl:with-param name="noOfDivTags" select="$noOfDivTags - 1"/>
				<xsl:with-param name="canHide" select="0"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- Template adds a given number of </div> HTML tags specified by 'noOfDivTags'-->
	<xsl:template name="CloseDivTags">
		<xsl:param name="noOfDivTags"/>
		<xsl:if test="$noOfDivTags!=0">
			<xsl:text disable-output-escaping="yes">&lt;/div&gt;</xsl:text>
			<xsl:call-template name="CloseDivTags">
				<xsl:with-param name="noOfDivTags" select="$noOfDivTags - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- Template to identify whether the given step specified by 'node' is a flow control step or not.-->
	<xsl:template name="IsFlowControlStep">
		<xsl:param name="node"/>
		<xsl:variable name="stepType">
			<xsl:value-of select="$node/n1:Extension/ts:TSStepProperties/ts:StepType"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="starts-with($stepType,'NI_Flow_') and $stepType!='NI_Flow_Else'  and $stepType!='NI_Flow_Break' and $stepType!='NI_Flow_Continue'">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$gProcessAsserts">
			<xsl:if test="not($node/n1:Extension/ts:TSStepProperties/ts:StepType)">
				<xsl:call-template name="ProcessAssert">
					<xsl:with-param name="assertMessage">
						In template 'IsFlowControlStep' : Not possible to determine whether &amp;lt;<xsl:value-of select="name($node)"/>&amp;gt; element with ID=&quot;<xsl:value-of select="$node/@ID"/>&quot; is a TestStand flow control step as 'Step Type' (TestStand Specific Information) for the same is not logged in the report.  
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!--Template returns the value of a given property of basic type, specified by 'datumNode'-->
	<xsl:template name="GetDatumValue">
		<xsl:param name="datumNode"/>
		<xsl:choose>
			<xsl:when test="$datumNode/@xsi:type = 'c:string'">
				<xsl:choose>
					<xsl:when test="$datumNode/c:Value = ''">''</xsl:when>
					<xsl:otherwise>
						<xsl:value-of disable-output-escaping="yes" select="user:ReplaceWhitespaceAndNewLine($datumNode/c:Value, false())"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$datumNode/@xsi:type = 'c:binary'">
				<!-- Here, '0b' is prepended to designate binary representation -->
				<xsl:value-of select="concat('0b',$datumNode/@value)"/>
			</xsl:when>
			<xsl:when test="$datumNode/@xsi:type = 'c:octal'">
				<!-- Here, '0c' is prepended to designate octal representation -->
				<xsl:value-of select="concat('0c',$datumNode/@value)"/>
			</xsl:when>
			<xsl:when test="$datumNode/@xsi:type = 'c:boolean'">
				<xsl:choose>
					<xsl:when test="$datumNode/@value='true'">True</xsl:when>
					<xsl:otherwise>False</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$datumNode/@xsi:type='ts:NI_HyperlinkPath'">
				<xsl:choose>
					<xsl:when test="$datumNode/c:Value = ''">''</xsl:when>
					<xsl:otherwise>
						<a>
							<xsl:attribute name="href"><xsl:value-of select="$datumNode/c:Value"/></xsl:attribute>
							<xsl:value-of select="$datumNode/c:Value"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$datumNode/@xsi:type = 'c:double'">
				<xsl:choose>
					<xsl:when test="@value='NaN'">NAN</xsl:when>
					<xsl:otherwise><xsl:value-of select="$datumNode/@value"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$datumNode/@xsi:type = 'ts:TS_enum'">
				<xsl:if test="$datumNode/ts:IsValid/@value = 'true'">&quot;</xsl:if>
				<xsl:value-of select="ts:EnumValue"/>
				<xsl:if test="ts:IsValid/@value = 'true'">&quot; (<xsl:choose>
						<xsl:when test="ts:NumericValue/@xsi:type = 'c:octal' or ts:NumericValue/@xsi:type = 'ts:TS_octal'">
							<!-- Here, '0c' is prepended to designate octal representation -->
							<xsl:value-of select="concat('0c', ts:NumericValue/@value)"/>
						</xsl:when>
						<xsl:when test="ts:NumericValue/@xsi:type = 'c:binary' or ts:NumericValue/@xsi:type = 'ts:TS_binary'">
							<!-- Here, '0b' is prepended to designate binary representation -->
							<xsl:value-of select="concat('0b', ts:NumericValue/@value)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="ts:NumericValue/@value"/>
						</xsl:otherwise>
					</xsl:choose>)
				</xsl:if>		
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$datumNode/@value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template returns a string consisting of all the array values held by a property of array type, specified by 'arrayNode'-->
	<xsl:template name="GetArrayValue">
		<xsl:param name="arrayNode"/>
		<xsl:choose>
			<xsl:when test="$arrayNode/@xsi:type='c:stringArray'">
				<xsl:for-each select="$arrayNode/c:Element">
					<xsl:call-template name="ReplaceSubString">
						<xsl:with-param name="inputString" select="@position"/>
						<xsl:with-param name="oldSubString" select="','"/>
						<xsl:with-param name="newSubString" select="']['"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="'='"/>
					<xsl:text> </xsl:text>
					&apos;<xsl:if test="c:Value != ''">
						<xsl:value-of disable-output-escaping="yes" select="user:ReplaceWhitespaceAndNewLine(c:Value, false())"/>
					</xsl:if>&apos;
					<br/>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$arrayNode/@xsi:type='c:binaryArray'">
				<xsl:for-each select="$arrayNode/c:Element">
					<xsl:call-template name="ReplaceSubString">
						<xsl:with-param name="inputString" select="@position"/>
						<xsl:with-param name="oldSubString" select="','"/>
						<xsl:with-param name="newSubString" select="']['"/>
						<!-- Here, '0b' is prepended to designate binary representation -->
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="'='"/>
					<xsl:text> </xsl:text>&apos;<xsl:value-of select="concat('0b',@value)"/>&apos;																			
					<br/>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$arrayNode/@xsi:type='c:octalArray'">
				<xsl:for-each select="$arrayNode/c:Element">
					<xsl:call-template name="ReplaceSubString">
						<xsl:with-param name="inputString" select="@position"/>
						<xsl:with-param name="oldSubString" select="','"/>
						<xsl:with-param name="newSubString" select="']['"/>
						<!-- Here, '0c' is prepended to designate octal representation -->
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="'='"/>
					<xsl:text> </xsl:text>&apos;<xsl:value-of select="concat('0c',@value)"/>&apos;
					<br/>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$arrayNode/@xsi:type='c:booleanArray'">
				<xsl:for-each select="$arrayNode/c:Element">
					<xsl:call-template name="ReplaceSubString">
						<xsl:with-param name="inputString" select="@position"/>
						<xsl:with-param name="oldSubString" select="','"/>
						<xsl:with-param name="newSubString" select="']['"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="'='"/>
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="@value='true'">&apos;True&apos;</xsl:when>
						<xsl:otherwise>&apos;False&apos;</xsl:otherwise>
					</xsl:choose>
					<br/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$arrayNode/c:Element">
					<xsl:call-template name="ReplaceSubString">
						<xsl:with-param name="inputString" select="@position"/>
						<xsl:with-param name="oldSubString" select="','"/>
						<xsl:with-param name="newSubString" select="']['"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="'='"/>
					<xsl:text> </xsl:text>&apos;<xsl:value-of select="@value"/>&apos;
					<br/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to adjust the indentation of the table, in case the block level of the currently processed step specified by 'currentNode' is different than its immediate predecessor's block level. -->
	<xsl:template name="HandleIndentationForBlockLevel">
		<xsl:param name="currentNode"/>
		<xsl:variable name="prevSib" select="$currentNode/preceding-sibling::*[1]"/>
		<!-- Get the block level of the previous processed step.-->
		<xsl:variable name="previousBlockLevel">
			<xsl:choose>
				<!-- Check if the current processed step has a predecessor-->
				<xsl:when test="$prevSib/n1:Extension">
					<xsl:value-of select="$prevSib/n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Get the  block level of the current processed step-->
		<xsl:variable name="currentBlockLevel" select="$currentNode/n1:Extension/ts:TSStepProperties/ts:BlockLevel/@value"/>
		<xsl:choose>
			<!-- If the block level of the current processed step is greater than the block level of the previous processed step then
				  a) Close the currently open sequence table.
				  b) Add parent <div> HTML tags for the new sequence table to be created.
			-->
			<xsl:when test="$currentBlockLevel &gt; $previousBlockLevel">
				<xsl:if test="user:isTableOpen()">
					<xsl:value-of select="user:EndTable()" disable-output-escaping="yes"/>
				</xsl:if>
				<xsl:call-template name="OpenDivTags">
					<xsl:with-param name="noOfDivTags" select="$currentBlockLevel - $previousBlockLevel"/>
				</xsl:call-template>
				<br/>
			</xsl:when>
			<!-- If the block level of the previous processed step is greater than the block level of the current processed step then
				  a) Close the currently open sequence table.
				  b) Add </div> HTML tags.
			-->
			<xsl:when test="$previousBlockLevel &gt; $currentBlockLevel">
				<xsl:if test="user:isTableOpen()">
					<xsl:value-of select="user:EndTable()" disable-output-escaping="yes"/>
				</xsl:if>
				<xsl:call-template name="CloseDivTags">
					<xsl:with-param name="noOfDivTags" select="$previousBlockLevel - $currentBlockLevel"/>
				</xsl:call-template>
				<br/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Template to add events for a step -->
	<xsl:template match="n1:Events" mode="Event">
		<xsl:if test="n1:Event[@ID='Error Message']/n1:Data[@name='Error Message']">
			<tr>
				<td style="padding-left:{$gSingleSpaceValue * 2}px;">
					<span style="color:#FF0000;">Error Message</span>
				</td>
				<td colspan="{$gSecondColumnSpan}">
					<xsl:variable name="errCode">
						<xsl:call-template name="GetDatumValue">
							<xsl:with-param name="datumNode" select="n1:Event[@ID='Error Code']/n1:Data[@name='Error Code']/c:Datum"/>
						</xsl:call-template>
					</xsl:variable>
					<span style="color:#FF0000;">
						<xsl:value-of disable-output-escaping="yes" select="user:ReplaceWhitespaceAndNewLine(n1:Event[@ID='Error Message']/n1:Data[@name='Error Message']/c:Datum/c:Value, true())"/> [Error Code: <xsl:value-of select="$errCode"/>]</span>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<xsl:template match="n1:Events"/>
	<xsl:template match="n1:Description"/>
	<!-- Template returns a given number of empty <td> HTML tags, specified by 'noOfEmptyCells'-->
	<xsl:template name="GetStepEmptyCells">
		<xsl:param name="noOfEmptyCells"/>
		<xsl:if test="$noOfEmptyCells!=0">
			<xsl:text>&lt;td&gt;&lt;/td&gt;</xsl:text>
			<xsl:call-template name="GetStepEmptyCells">
				<xsl:with-param name="noOfEmptyCells" select="$noOfEmptyCells - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- Template checks whether the currently processed property is a property attributes container or not.-->
	<xsl:template name="IsPropObjAttributesContainer">
		<xsl:param name="itemName"/>
		<xsl:choose>
			<xsl:when test="contains($itemName, '.')">
				<xsl:choose>
					<!--If the name of the property, specified by 'itemName', ends with '.Attributes' then its assumed to be an attributes container.-->
					<xsl:when test="substring($itemName, string-length($itemName) - 10) = '.Attributes'">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template returns the outcome to be displayed for a step-->
	<xsl:template name="GetOutcome">
		<xsl:param name="outcomeNode"/>
		<xsl:choose>
			<xsl:when test="$outcomeNode/@qualifier">
				<xsl:value-of select="$outcomeNode/@qualifier"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$outcomeNode/@value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template adds the outcome of a step to the transformed HTML report -->
	<xsl:template name="AddStepOutcome">
		<xsl:param name="outcomeNode"/>
		<xsl:variable name="stepOutcome">
			<xsl:call-template name="GetOutcome">
				<xsl:with-param name="outcomeNode" select="$outcomeNode"/>
			</xsl:call-template>
		</xsl:variable>
		<td align="center">
			<span>
				<xsl:attribute name="style">color:<xsl:call-template name="GetStatusColor"><xsl:with-param name="status" select="$stepOutcome"/></xsl:call-template></xsl:attribute>
				<xsl:value-of select="$stepOutcome"/>
			</span>
		</td>
	</xsl:template>
	<!-- Template to add description of a step to the transformed HTML report, if present-->
	<xsl:template name="AddStepDescription">
		<xsl:param name="stepNode"/>
		<xsl:if test="$stepNode/n1:Description">
			<tr class="level:0 state:expanded">
				<td style="padding-left:{$gSingleSpaceValue * 2}px;">Description</td>
				<td colspan="{$gSecondColumnSpan}">
					<xsl:value-of select="$stepNode/n1:Description"/>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<!-- Template to process output parameters and additional results of a step-->
	<xsl:template name="ProcessTestResultElems">
		<xsl:param name="stepNode"/>
		<xsl:variable name="noOfTestDataElems" select="count($stepNode/n1:TestResult/n1:TestData)"/>
		<xsl:if test="$noOfTestDataElems!=0 and $noOfTestDataElems!=count($stepNode/n1:TestResult/n1:TestLimits) and $noOfTestDataElems!=count($stepNode/n1:TestResult/n1:Extension/ts:TSLimitProperties/ts:IsTestMeasurement)">
			<tr class="level:1 state:collapsed">
				<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2}px;">TestResults/Data</td>
			</tr>
			<xsl:apply-templates select="n1:TestResult">
				<xsl:with-param name="processTestResult" select="true()"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<!-- Template to process and add limit data for steps that have multiple limits.-->
	<xsl:template name="ProcessMultiNumericLimits">
		<xsl:param name="stepNode" select="."/>
		<xsl:variable name="hasStepLimits" select="count($stepNode/n1:TestResult/n1:TestLimits) > 1"/>
		<xsl:variable name="hasTestMeasurements" select="count($stepNode/n1:TestResult/n1:Extension/ts:TSLimitProperties/ts:IsTestMeasurement) > 1"/>
		<xsl:if test="$hasStepLimits or $hasTestMeasurements">
			<xsl:variable name="paddingValue" select="4"/>
			<tr class="level:1 state:collapsed">
				<td style="padding-left:{$gSingleSpaceValue * 2}px;">Measurement:</td>
				<td colspan="{$gSecondColumnSpan}"/>
			</tr>
			<xsl:choose>
				<xsl:when test="$hasStepLimits">
					<xsl:for-each select="$stepNode/n1:TestResult/n1:TestLimits">
						<tr class="level:1 state:collapsed">
							<td style="padding-left:{$gSingleSpaceValue * 4}px;">
								<xsl:value-of select="../@ID"/>
							</td>
							<xsl:call-template name="AddStepOutcome">
								<xsl:with-param name="outcomeNode" select="../n1:Outcome"/>
							</xsl:call-template>
							<td align="right">
								<xsl:call-template name="GetDatumValue">
									<xsl:with-param name="datumNode" select="../n1:TestData/c:Datum"/>
								</xsl:call-template>
								<xsl:call-template name="GetUnit">
									<xsl:with-param name="node" select="../n1:TestData/c:Datum"/>
								</xsl:call-template>
							</td>
							<xsl:apply-templates/>
							<!-- Takes care of adding additional empty columns as an impact of user added custom columns-->
							<xsl:if test="$gNoOfCustomColumns > 0">
								<xsl:value-of select="$gMultiNumericLimitEmptyCells" disable-output-escaping="yes"/>
							</xsl:if>
						</tr>
						<!-- Process attributes, if present, for the following limit properties
							  a)  'Step.Limits'
							  b)  'Step.Limits.Low'
							  c)  'Step.Limits.High'
							  d)  'Step.Comp'
							  e)  'Step.Units'
						-->
						<xsl:call-template name="ProcessLimitAttributes">
							<xsl:with-param name="stepNode" select="$stepNode"/>
							<xsl:with-param name="level" select="3"/>
							<xsl:with-param name="limitID" select="../@ID"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$hasTestMeasurements">
					<xsl:for-each select="$stepNode/n1:TestResult/n1:Extension/ts:TSLimitProperties/ts:IsTestMeasurement">
						<xsl:variable name="currTestResultElem" select="../../.."/>
						<tr class="level:1 state:collapsed">
							<td style="padding-left:{$gSingleSpaceValue * 4}px;">
								<xsl:value-of select="$currTestResultElem/@ID"/>
							</td>
							<xsl:call-template name="AddStepOutcome">
								<xsl:with-param name="outcomeNode" select="$currTestResultElem/n1:Outcome"/>
							</xsl:call-template>
							<td align="right">
								<xsl:call-template name="GetDatumValue">
									<xsl:with-param name="datumNode" select="$currTestResultElem/n1:TestData/c:Datum"/>
								</xsl:call-template>
								<xsl:call-template name="GetUnit">
									<xsl:with-param name="node" select="$currTestResultElem/n1:TestData/c:Datum"/>
								</xsl:call-template>
							</td>
							<td/>
							<td/>
							<td/>
							<td/>
							<!-- Takes care of adding additional empty columns as an impact of user added custom columns-->
							<xsl:if test="$gNoOfCustomColumns > 0">
								<xsl:value-of select="$gMultiNumericLimitEmptyCells" disable-output-escaping="yes"/>
							</xsl:if>
						</tr>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- Template to process and add step limit data for steps that have single limit.-->
	<xsl:template name="ProcessSingleLimit">
		<xsl:param name="stepNode"/>
		<xsl:variable name="hasStepLimit">
			<xsl:choose>
				<xsl:when test="$stepNode/n1:TestResult/n1:TestLimits">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="testLimitsNode" select="$stepNode/n1:TestResult/n1:TestLimits"/>
		<xsl:variable name="datumNodeForTestResultWithTestLimits" select="$testLimitsNode/../n1:TestData/c:Datum"/>
		<xsl:variable name="datumNodeForTestResultWithIsMeasFlag" select="$stepNode/n1:TestResult/n1:Extension/ts:TSLimitProperties/ts:IsTestMeasurement/../../../n1:TestData/c:Datum"/>
		<td align="right">
			<xsl:choose>
				<xsl:when test="$hasStepLimit='true'">
					<xsl:call-template name="GetDatumValue">
						<xsl:with-param name="datumNode" select="$datumNodeForTestResultWithTestLimits"/>
					</xsl:call-template>
					<xsl:call-template name="GetUnit">
						<xsl:with-param name="node" select="$datumNodeForTestResultWithTestLimits"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="GetDatumValue">
						<xsl:with-param name="datumNode" select="$datumNodeForTestResultWithIsMeasFlag"/>
					</xsl:call-template>
					<xsl:call-template name="GetUnit">
						<xsl:with-param name="node" select="$datumNodeForTestResultWithIsMeasFlag"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</td>
		<xsl:choose>
			<xsl:when test="$hasStepLimit='true'">
				<xsl:apply-templates select="$testLimitsNode"/>
			</xsl:when>
			<xsl:otherwise>
				<td/>
				<td/>
				<td/>
				<td/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to process an assert message, when an assert condition fails to validate-->
	<xsl:template name="ProcessAssert">
		<xsl:param name="assertMessage"/>
		<xsl:choose>
			<xsl:when test="$gTerminateOnAssert">
				<!-- Terminates the transformation to a HTML report and displays the assert message to the user along with the partially transformed HTML report-->
				<xsl:message terminate="yes">
					<xsl:value-of select="$assertMessage"/>
				</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<!-- Collects an assert message generated for an assert condition that failed to validate. 
                      The collected assert messasge will be shown at the end of the transformed HTML report, as part of an assert table-->
				<xsl:value-of select="user:AddAssert(string($assertMessage))" disable-output-escaping="yes"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to add instances of NI_TDMSReference type-->
	<xsl:template name="ProcessTDMSReference">
		<xsl:param name="level" select="0"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="stepNode"/>
		<xsl:param name="putAsFlatData" select="false()"/>
		<!-- Name of the container will either be in parent Item element or the Parameter/TestResult ID -->
		<xsl:variable name="containerName">
			<xsl:choose>
				<xsl:when test="local-name(..) = 'Item'">
					<xsl:value-of select="../@name"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../../@ID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Except File, if all sub-properties is empty, then NI_TDMSReference should be displayed in single line -->
		<xsl:variable name="shouldCreateContainerIfStringLengthGreaterThanZero">
			<xsl:for-each select="./c:Item[@name!='File']">
				<xsl:value-of select="./c:Datum/c:Value"/>
			</xsl:for-each>
		</xsl:variable>
		<!-- Check if the container has any attributes to be processed -->
		<xsl:variable name="hasAttributes">
			<xsl:call-template name="HasAttributes">
				<xsl:with-param name="node" select="$stepNode"/>
				<xsl:with-param name="objectPath" select="$objectPath"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="paddingValue">
			<xsl:choose>
				<xsl:when test="$hasAttributes='true' or string-length($shouldCreateContainerIfStringLengthGreaterThanZero) > 0">
					<xsl:value-of select="$gSingleSpaceValue * 2 * ($level)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$gSingleSpaceValue * (2 * ($level) + 1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- If NI_TDMSReference is displayed in multiple lines, then display non-empty sub-properties and process its attributes otherwise display value of File as either hyperlink or string -->
		<xsl:choose>
			<xsl:when test="string-length($shouldCreateContainerIfStringLengthGreaterThanZero) > 0">
				<!-- Create a row for the container name and process attributes of the container -->
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="$level > 1 and not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="$putAsFlatData=false()">
					<tr class="level:{$level} state:collapsed {$classAttributeValue}">
						<td colspan="{$gFirstColumnSpan}" style="padding-left:{$paddingValue}px;">
							<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
							<xsl:value-of select="$containerName"/>:
						<!-- Add description, if present -->
							<xsl:if test="$level='1' and ../../n1:Description">
								<span style="padding-left:{$gSingleSpaceValue * 2}px;"><br/>(<xsl:value-of select="../../n1:Description"/>)</span>
							</xsl:if>
						</td>
					</tr>
				</xsl:if>
				<!-- Check if the processed property has attributes. If yes, then process attributes. -->
				<xsl:if test="$hasAttributes='true'">
					<xsl:choose>
						<xsl:when test="$stepNode/n1:Data">
							<xsl:call-template name="ProcessAttributes">
								<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
								<xsl:with-param name="node" select="$stepNode"/>
								<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
								<xsl:with-param name="level" select="($level) + 1"/>
								<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$stepNode/c:Collection">
							<xsl:call-template name="ProcessAttributes">
								<xsl:with-param name="attributesNode" select="$stepNode/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
								<xsl:with-param name="node" select="$stepNode"/>
								<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
								<xsl:with-param name="level" select="($level) + 1"/>
								<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- Process non-empty sub-properites of the container -->
				<xsl:for-each select="./c:Item[@name = 'File'] | ./c:Item[./c:Datum/c:Value != '']">
					<xsl:apply-templates>
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="objectPath" select="concat($objectPath,'.',@name)"/>
						<xsl:with-param name="stepNode" select="$stepNode"/>
						<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- Display the name of the container, insert value of File as either hyperlink or string and process container's attributes-->
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="$level > 1 and not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$putAsFlatData">
						<tr>
							<td style="font-weight:bold;">
									<xsl:value-of select="$objectPath"/>:
							</td>
							<td>
								<xsl:for-each select="./c:Item[@name='File']/c:Datum">
									<xsl:call-template name="GetDatumValue">
										<xsl:with-param name="datumNode" select="."/>
									</xsl:call-template>
									<xsl:call-template name="GetUnit">
										<xsl:with-param name="node" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>				
					</xsl:when>
					<xsl:otherwise>
						<tr class="level:{$level} state:collapsed {$classAttributeValue}">
					<td style="padding-left:{$paddingValue}px;">
						<xsl:choose>
							<!-- If the current processed property has attributes then add expand/collapse functionality for the property , 
								  as attributes for the property will be added as a child of the processed property.-->
							<xsl:when test="$hasAttributes='true'">
								<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="$containerName"/>:
						<!-- Add description, if present -->
						<xsl:if test="$level='1' and ../../n1:Description">
							<span style="padding-left:{$gSingleSpaceValue * 2}px;"><br/>(<xsl:value-of select="../../n1:Description"/>)</span>
						</xsl:if>
					</td>
					<td colspan="{$gSecondColumnSpan}">
						<xsl:for-each select="./c:Item[@name='File']/c:Datum">
							<xsl:call-template name="GetDatumValue">
								<xsl:with-param name="datumNode" select="."/>
							</xsl:call-template>
							<xsl:call-template name="GetUnit">
								<xsl:with-param name="node" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</td>
				</tr>
				
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:if test="$hasAttributes='true'">
					<xsl:choose>
						<xsl:when test="$stepNode/n1:Data">
							<xsl:call-template name="ProcessAttributes">
								<xsl:with-param name="attributesNode" select="$stepNode/n1:Data/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
								<xsl:with-param name="node" select="$stepNode"/>
								<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
								<xsl:with-param name="level" select="($level) + 1"/>
								<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$stepNode/c:Collection">
							<xsl:call-template name="ProcessAttributes">
								<xsl:with-param name="attributesNode" select="$stepNode/c:Collection/c:Item[@name=concat($objectPath,'.Attributes')]"/>
								<xsl:with-param name="node" select="$stepNode"/>
								<xsl:with-param name="objectPath" select="concat($objectPath,'.Attributes')"/>
								<xsl:with-param name="level" select="($level) + 1"/>
								<xsl:with-param name="putAsFlatData" select="$putAsFlatData"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template to add attributes of NI_TDMSReference type-->
	<xsl:template name="ProcessTDMSReferenceAttribute">
		<xsl:param name="level" select="0"/>
		<xsl:param name="objectPath" select="''"/>
		<xsl:param name="stepNode"/>
		<!-- Name of the container will either be in parent Item element or the Parameter/TestResult ID -->
		<xsl:variable name="containerName">
			<xsl:choose>
				<xsl:when test="local-name(..) = 'Item'">
					<xsl:value-of select="substring(../@name,0,string-length(../@name)-5)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../../@ID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Except File, if all sub-properties is empty, then NI_TDMSReference should be displayed in single line -->
		<xsl:variable name="shouldCreateContainerIfStringLengthGreaterThanZero">
			<xsl:for-each select="./c:Item[@name!='File']">
				<xsl:value-of select="./c:Collection/c:Item[1]/c:Datum/c:Value"/>
			</xsl:for-each>
		</xsl:variable>
		<!-- If NI_TDMSReference is displayed in multiple lines, then display non-empty sub-properties otherwise display value of File as either hyperlink or string -->
		<xsl:choose>
			<xsl:when test="string-length($shouldCreateContainerIfStringLengthGreaterThanZero) > 0">
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="$level > 1 and not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<tr class="level:{$level} state:collapsed {$classAttributeValue}">
					<td colspan="{$gFirstColumnSpan}" style="padding-left:{$gSingleSpaceValue * 2 * ($level)}px;">
						<xsl:value-of select="user:GetPropertyExpandCollapseImage(not($gGeneratePlainHTML))" disable-output-escaping="yes"/>
						<xsl:value-of select="$containerName"/>:
						<!-- Add description, if present -->
						<xsl:if test="$level='1' and ../../../../n1:Description">
							<span style="padding-left:{$gSingleSpaceValue * 2}px;"><br/>(<xsl:value-of select="../../../../n1:Description"/>)</span>
						</xsl:if>
					</td>
				</tr>
				<!-- Process non-empty sub-properites of the container -->
				<xsl:for-each select="./c:Item[@name = 'File'] | ./c:Item[./c:Collection/c:Item[1]/c:Datum/c:Value != '']">
					<xsl:apply-templates select="c:Collection/c:Item[1]" mode="Attributes">
						<xsl:with-param name="level" select="($level) + 1"/>
						<xsl:with-param name="stepNode" select="$stepNode"/>
						<xsl:with-param name="objectPath" select="$objectPath"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- Display the name of the container, insert value of File as either hyperlink or string-->
				<xsl:variable name="classAttributeValue">
					<xsl:choose>
						<xsl:when test="$level > 1 and not($gGeneratePlainHTML)">trHide</xsl:when>
						<xsl:otherwise>
							<xsl:text/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<tr class="level:{$level} state:collapsed {$classAttributeValue}">
					<td style="padding-left:{$gSingleSpaceValue * (2 * ($level) + 1)}px;">
						<xsl:value-of select="$containerName"/>:
						<!-- Add description, if present -->
						<xsl:if test="$level='1' and ../../../../n1:Description">
							<span style="padding-left:{$gSingleSpaceValue * 2}px;"><br/>(<xsl:value-of select="../../../../n1:Description"/>)</span>
						</xsl:if>
					</td>
					<td colspan="{$gSecondColumnSpan}">
						<xsl:for-each select="./c:Item[@name='File']/c:Collection/c:Item[1]/c:Datum">
							<xsl:call-template name="GetDatumValue">
								<xsl:with-param name="datumNode" select="."/>
							</xsl:call-template>
							<xsl:call-template name="GetUnit">
								<xsl:with-param name="node" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--This method is used to check if atleast one of the attributes in the collection is marked to be included in the report-->
	<xsl:template name="CheckIfIncludeInReportIsPresentForAttributes">
		<xsl:param name="attributeNode"/>
		<xsl:variable name="result">
			<xsl:for-each select="$attributeNode/c:Collection/c:Item">
				<xsl:variable name="shouldIncludeInReport">
					<xsl:call-template name="CheckIfIncludeFlagIsSet">
						<xsl:with-param name="flag" select="c:Collection/c:Item[2]/c:Datum/@value"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$shouldIncludeInReport='true'">true</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="c:Collection/c:Item[1]/c:Collection">
								<xsl:variable name="includeInReport">
									<xsl:call-template name="CheckIfIncludeInReportIsPresentForAttributes">
										<xsl:with-param name="attributeNode" select="c:Collection/c:Item[1]"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:value-of select="$includeInReport"/>
							</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($result,'true')">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--This method is used to check if a particular attribute is marked to be included in the report-->
	<xsl:template name="CheckIfIncludeFlagIsSet">
		<xsl:param name="flag"/>
		<xsl:variable name="includeFlagHexDigit">
			<xsl:value-of select="substring($flag,string-length($flag)-3,1)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$includeFlagHexDigit='2' or $includeFlagHexDigit='3' or $includeFlagHexDigit='6' or $includeFlagHexDigit='7' or $includeFlagHexDigit='a' or $includeFlagHexDigit='b' or $includeFlagHexDigit='e' or $includeFlagHexDigit='f' or $includeFlagHexDigit='A' or $includeFlagHexDigit='B' or $includeFlagHexDigit='E' or $includeFlagHexDigit='F'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
