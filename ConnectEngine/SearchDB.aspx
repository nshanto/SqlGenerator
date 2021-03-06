﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchDB.aspx.cs" Inherits="ConnectEngine.SearchDB" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Sql query generator</title>
    <script type="text/javascript" src="Scripts/jquery-1.9.1.min.js"></script>
    <script type="text/javascript" src="Scripts/jquery.selectboxes.min.js"></script>
    <link href="Styles/styles.css" rel="stylesheet" />
    <script type="text/javascript">
        var queryString;
        var tables;
        var tLength;
        var numAndDate = [
                "bigint",
                "bit",
                "decimal",
                "int",
                "money",
                "numeric",
                "smallint",
                "smallmoney",
                "tinyint",
                "float",
                "real"
        ];
        var numAndDateCondition = [
                "=",
                "<>",
                ">",
                "<",
                ">=",
                "<=",
                "BETWEEN",
                "NOT BETWEEN"
        ];
        var stringCondition = [
                "LIKE",
                "NOT LIKE",
                "<>",
                "=",
                "BETWEEN",
                "NOT BETWEEN"
        ];
        var wildcard = [
                "%str",
                "str%",
                "%str%",
                "_str",
                "str_",
                "[str]%",
                "%[str]",
                "[!str]%",
                "%[!str]"
        ];
        function GetColumnName()
        {
            $('#wherePortion').empty();
            queryString = "";
            $('#queryTextBox').val(queryString);
            $.ajax({
                type: "POST",
                url: "/SearchDB.aspx/GetCoumls",
                data: "{tableName: '" + $('#tableNameDropDown').val() + "',dbName: '" + $('#dbNameDropDown').val() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    tables = response.d;
                    tLength = tables.length;
                    $("#checkList").empty();
                    $("#checkList").append('<p>SELECT :</p>');
                    $("#checkList").append('<input class="checkTable" type="checkbox"' +
                        'name="tableName" id="test" value="*" onchange="testCheck()" />All');
                    for (var i = 0; i < tLength; i++) {
                        $("#checkList").append('<input class="checkTable" type="checkbox"' +
                        'name="tableName" value="'+tables[i].ColName+'"'+ '" onchange="testCheck()"'+
                        '"/>' + tables[i].ColName);
                    }
                    $("#checkList").append('<br/><input class="dist" id="distinct" type="checkbox"' +
                       'name="distinct" disabled="disabled" value="DISTINCT"' + '" onchange="testCheck()"' +
                       '"/>' + 'DISTINCT');
                }
            });
            
        }
        $(document).ready(function () {
            var watermark = 'Enter maximum value';

            //init, set watermark text and class
            
        });
        function selectAll(elm) {
            if (elm.val() == "*") {
                $('.checkTable').prop("checked", "checked");
            } 
        }
        function GetTableName()
        {
            return $('#tableNameDropDown').val();
        }
        
        function testCheck()
        {
            var checkAny = false;
            $('#distinct').attr('disabled', true);
            $('#whereButton').attr('disabled', true);
            $('#wherePortion').empty();
            $('#textBox').empty();
            queryString = "";
            var str = [];
            $(':input[name="distinct"]:checked').each(function () {
                queryString = "SELECT DISTINCT "
                //alert($(this).val());
            });
            $(':input[name="tableName"]:checked').each(function () {
                checkAny = true;
                $('#distinct').attr('disabled', false);
                $('#whereButton').attr('disabled', false);
                if (queryString.length < 1)
                {
                    queryString = "SELECT ";
                }
                selectAll($(this));
                if ($(this).val() == "*") {
                    str = [];
                    str.push($(this).val());
                    return false;
                }
                else
                {
                    str.push($(this).val());
                }
                //alert($(this).val());
            });
            queryString += str;
            if(queryString.length > 0)
            queryString += " FROM " + GetTableName();
            //$('#queryTextBox').val(queryString);
            if (checkAny == false) {
                queryString = "";
            }
            $("#<%=queryTextBox.ClientID%>").val(queryString);
            
        }
        function WhereButtonClick()
        {
            //var all = "";
            $('#wherePortion').empty();
            $('#textBox').empty();
            $('#wherePortion').append('<p>'+
                '<label>Column Name:</label><br />'+
                '<select id="columnDropDown" class="dropDownListStyles" onchange="GetExpression()"></select>' +
            '</p>');

            $('#wherePortion').append('<p>' +
                '<label>Condition:</label><br />' +
                '<select id="conditionDropDown" class="dropDownListStyles" disabled="disabled" onchange="EnableText()"></select>' +
            '</p>');
            var val = "";
            var text = "";
            $('#columnDropDown').removeOption(/./).addOption('', '---Please Select---');
            for (var i = 0; i < tLength; i++) {
                val = tables[i].DataType;
                text = tables[i].ColName;
                $('#columnDropDown').append(new Option(text, val, true, true));
            }
        }
        function regIsNumber(fData)
        {
            var reg = new RegExp("^[-]?[0-9]+[\.]?[0-9]+$");
            return reg.test(fData)
        }
        function GetExpression()
        {
            $('#conditionDropDown').attr('disabled',false);
            $('#conditionDropDown').empty();
            if (jQuery.inArray($("#columnDropDown option:selected").val(), numAndDate) > 0) {
                
                var itemNumber = numAndDateCondition.length;
                for (var i = 0; i < itemNumber; i++) {
                    $('#conditionDropDown').append(new Option(numAndDateCondition[i], numAndDateCondition[i], true, true));
                }
            }
            else
            {
                var itemNumber = stringCondition.length;
                for (var i = 0; i < itemNumber; i++) {
                    $('#conditionDropDown').append(new Option(stringCondition[i], stringCondition[i], true, true));
                }
            }
        }
        function AndOrButton(buttonType)
        {
            alert(buttonType);
        }
        function ValidateText(valueText)
        {
            var conditionText;
            if (jQuery.inArray($("#columnDropDown option:selected").val(), numAndDate) > 0) {
                var num = /^[-+]?[0-9]+(?:\.[0-9]+)?$/;
                if (num.test(valueText)) {
                    conditionText = valueText;
                }
                else {
                    alert("Please enter valid number in the textbox");
                    return false;
                }
            }
            else {
                conditionText = "'" + valueText + "'"
            }
            return conditionText;
        }
        function TakeData()
        {
            var checkedConditionText;
            if ($('#conditionDropDown').val() == "BETWEEN" || $('#conditionDropDown').val() == "NOT BETWEEN")
            {
                if ($('#val1').val().length == 0 || $('#val2').val().length == 0) {
                    alert("Incomplete Where clause");
                    return false;
                }
                else {
                    checkedConditionText = ValidateText($('#val1').val()) + " AND " + ValidateText($('#val2').val());
                }
            }
            else if ($('#conditionDropDown').val() == "LIKE" || $('#conditionDropDown').val() == "NOT LIKE")
            {
                if ($('#likeValueText').val().length > 0)
                {
                    var str = "'"+$('#wildcardDropDown').val()+"'";
                    checkedConditionText = str.replace('str', $('#likeValueText').val());
                }
                else
                {
                    alert("No value in the textbox");
                    return false;
                }
            }
            else
            {
                if ($('#valueText').val().length > 0) {
                    checkedConditionText = ValidateText($('#valueText').val());
                }
                else {
                    alert("Incomplete Where clause");
                    return false;
                }
            }
            queryString = queryString.split(' WHERE')[0];
            queryString = queryString + " WHERE " + $('#columnDropDown option:selected').text() + " " + $('#conditionDropDown').val() + " " + checkedConditionText;
            $("#<%=queryTextBox.ClientID%>").val(queryString);
        }
        function EnableText()
        {
            $('#textBox').empty();
            //$('#valueText').attr('disabled', false);
            if ($('#conditionDropDown').val() == "BETWEEN" || $('#conditionDropDown').val() == "NOT BETWEEN") {
                //alert("between");
                $('#textBox').append('<p>' +
               '<label>Value 1:</label><br />' +
               '<input id="val1" class="textBoxStyles" title="Enter First Value" type="text" />' +
               '</p>');
                $('#textBox').append('<p id="andOption">' +
               '<label>AND</label>');
                $('#textBox').append('<p>' +
                '<label>Value 2:</label><br />' +
                '<input id="val2" class="textBoxStyles" title="Enter Second Value" type="text" onblur="TakeData()" />' +
                '</p><br/><hr class="hrStyle"/>');
            }
            else if ($('#conditionDropDown').val() == "LIKE" || $('#conditionDropDown').val() == "NOT LIKE")
            {
                $('#textBox').append('<p>' +
                '<label>Value:</label><br />' +
                '<input id="likeValueText" class="textBoxStyles" type="text" onblur="TakeData()" />' +
                '</p><br/>');
                $('#textBox').append('<p>' +
                '<label>Select a wildcard:</label><br />' +
                '<select id="wildcardDropDown" class="dropDownListStyles" onchange="TakeData()"></select>' +
            '</p><hr class="hrStyle"/>');
                var itemNumber = wildcard.length;
                for (var i = 0; i < itemNumber; i++) {
                    $('#wildcardDropDown').append(new Option(wildcard[i], wildcard[i], true, true));
                }

            }
            else {
                $('#textBox').append('<p>' +
                '<label>Value:</label><br />' +
                '<input id="valueText" class="textBoxStyles" type="text" onblur="TakeData()" />' +
                '</p><br/><hr class="hrStyle"/>');
            }
        }
    </script>


    <noscript>
        <meta http-equiv="refresh" content="0; url=JavascriptDisabled.html">
    </noscript>

</head>
<body>
    <form id="form1" runat="server">
        
        <div id="mainBody" runat="server">
            <h1 class="header1"> SQL Generator</h1>
            <asp:Panel id="mainContents" runat="server">
                    <asp:Panel ID="AllControls" runat="server">       
                        <div style="float : left; margin-left : 70px; margin-top : 50px;">
                            <asp:Label ID="sqlStatus" runat="server" Text=""></asp:Label>
                            <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
                            <div>
                                <asp:Button ID="connect" CssClass="buttonStyles" runat="server" Text="Connect" OnClick="connect_Click" />
                                <asp:DropDownList ID="dbNameDropDown" runat="server" OnSelectedIndexChanged="dbNameDropDown_SelectedIndexChanged" AutoPostBack="True" CssClass="dropDownListStyles">
                                </asp:DropDownList>
                                <hr class="hrStyle"/>
                            </div>
                            <div class="selectQuery">
                                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                                   <ContentTemplate>
                                       <div>
                                           <p>From :</p>
                                           <asp:DropDownList ID="tableNameDropDown" runat="server" CssClass="dropDownListStyles"></asp:DropDownList>
                                           <div id="checkList" class="selectQuery">
                                           </div>
                                       </div>
                                       </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="dbNameDropDown" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                                       <br />
                                       <hr class="hrStyle"  />
                                       <input id="whereButton" type="button" value="WHERE" disabled="disabled" onclick="WhereButtonClick()" class="buttonStyles" />
                                       <div id ="wherePortion" class="selectQuery">
                                       </div>
                                        <div id="textBox" class="selectQuery">
                                        </div>
                                       <br />
                                        <input id="andButton" type="button" value="AND" onclick="AndOrButton($(this).val())" class="buttonStyles" width="900" />
                                        <input id="orButton" type="button" value="OR" onclick="AndOrButton($(this).val())" class="buttonStyles" />
                                       <div id="andOrPortion">
                                       </div>
                                <br />
                                <hr class="hrStyle" />
                                <div id="outputText">
                                    <p>Query string :</p>
                                    <asp:TextBox ID="queryTextBox" runat="server" Height="46px" TextMode="MultiLine" Width="442px" ViewStateMode="Enabled"></asp:TextBox>
                                    <br /><br />
                                    <asp:Button ID="resultButton" runat="server" Text="Get Result" OnClick="resultButton_Click" CssClass="buttonStyles" />
                                </div>
                                <br />
                                <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:GridView ID="resultGrid" runat="server"></asp:GridView>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="resultButton" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>  
                        </div>
                </asp:Panel>   
            </asp:Panel>
         </div>
    </form>
</body>
</html>
