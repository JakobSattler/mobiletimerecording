$(document).ready(function() {
    userBoxSelectionChanged();
});


function userBoxSelectionChanged() {
    var user_id = $('#user_select_user_id').find(":selected").val();
    logDebug("the user you selected: " + user_id);

    var sendInfo = {
        uid: user_id,
    };

    $.ajax({
        type: "POST",
        url: "/zz5/employment_load",
        data: JSON.stringify(sendInfo),
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function(msg) {
            clearOldTable();
            appendEmploymentTable(msg);
        },
        error: function(msg) {
            alert("Failed to load employments: " + msg);
        }
    });

}

function clearOldTable() {
    var old_table_ref = document.getElementById('employment');
    var old_table_length = old_table_ref.rows.length;

    if (old_table_length > 0) {
        logDebug("old table length: " + old_table_length);
        for (var i = old_table_length - 1; i > 0; i--) {
            logDebug("index: " + i);
            document.getElementById('employment').deleteRow(i);
        }
    }
}

function appendEmploymentTable(jsonData) {
    logDebug("this is the jsonData:" + jsonData);
    var table_length = document.getElementById('employment').rows.length;

    if (table_length <= 1) {
        toggleNoEntries(true);
    }

    //var notice = jsonData.getResponseHeader("X-Flash-Notice");
    var notice = 0;

    $.each(jsonData, function(idx, obj) {
        var employment = obj.employment;

        if (employment != null) {
            toggleNoEntries(false);
            appendEmploymentRow(employment, notice, true);
        }
    });
}

// first inserts row and then builds row column by column
function appendEmploymentRow(employment, notice, append_row) {

    console.log("notice: " + notice);

    if (append_row) {
        logDebug("employment " + employment.id + " for user " + employment.user_id);
    }

    // only add a new row if an existing user is selected
    if (!$('#user_select_user_id').find(":selected").val()) {
        toggleNoEntries(true);
        return;
    }

    var table_ref = document.getElementById('employment').getElementsByTagName('tbody')[0];

    // Insert a row in the table at the last row
    var new_row = table_ref.insertRow(table_ref.rows.length);
    new_row.setAttribute("id", "row-" + table_ref.rows.length);
    new_row.setAttribute("class", "valid-row");
    var row = table_ref.rows.length;

    // Create hidden helper fields with employment id "02", indicating an existing employment
    // and a delete flag, to determine that this employment should be removed from the database
    // when it reaches the server
    var employment_id = document.createElement("input");
    employment_id.setAttribute("id", "employment-id-" + row);
    employment_id.setAttribute("class", "employment-id");
    employment_id.setAttribute("type", "hidden");
    new_row.appendChild(employment_id);

    var delete_me = document.createElement("input");
    delete_me.setAttribute("id", "delete-me-" + row);
    delete_me.setAttribute("class", "delete-me");
    delete_me.setAttribute("type", "hidden");
    new_row.appendChild(delete_me);
    $("#delete-me-" + row + "").val(0);

    // Insert a cell (columun) into row at index 0
    // Build the start date column
    var start_col = new_row.insertCell(0);
    start_col.setAttribute("class", "td-start");

    // Append a text node to the cell
    var date_input = document.createElement("input");
    date_input.setAttribute("id", "start-date-" + row);
    date_input.setAttribute("class", "start-date-datepicker");
    date_input.setAttribute("onblur", "checkEmptyBox(this.id, \"start-error-" + row + "\"), checkDateDuplicate(this.id," + row + ")");
    date_input.setAttribute("onchange", "validateDate(this.id)");
    date_input.setAttribute("onfocus", "setCurrentDate(this.id)");
    date_input.setAttribute("maxlength", "10");
    start_col.appendChild(date_input);

    var error_img_src = document.getElementById("exclamation-img").getAttribute("src");
    var error_img = document.createElement("img");
    error_img.setAttribute("id", "start-error-" + row);
    error_img.setAttribute("class", "start-error-image");
    error_img.setAttribute("src", error_img_src);
    error_img.setAttribute("onmouseover", "this.title");
    error_img.setAttribute("title", start_dupe);
    start_col.appendChild(error_img);

    var datepicker_script = document.createElement("script");
    datepicker_script.type = 'text/javascript';
    var img_src = document.getElementById("calendar-img").getAttribute("src");
    var datepicker_options = '{ dateFormat: \'dd-mm-yy\', showOn: \'button\', buttonImageOnly: true, buttonImage: \'' + img_src;
    datepicker_options += '\', showButtonPanel: true, showWeek: true, showOtherMonths: true, selectOtherMonths: true, constrainInput: true }';
    var code = ' $(function() { $( "#start-date-' + row + '" ).datepicker(' + datepicker_options + '); });';
    datepicker_script.appendChild(document.createTextNode(code));
    start_col.appendChild(datepicker_script);

    var orig_date = document.createElement("input");
    orig_date.setAttribute("id", "orig-start-date-" + row);
    orig_date.setAttribute("class", "orig-date");
    orig_date.setAttribute("type", "hidden");
    new_row.appendChild(orig_date);

    // Build the employment scope column
    var employment_col = new_row.insertCell(1);
    employment_col.setAttribute("class", "td-employment");

    var employment_input = document.createElement("input");
    employment_input.setAttribute("id", "scope-input-" + row);
    employment_input.setAttribute("class", "scope-input");
    employment_input.setAttribute("onblur", "checkEmptyBox(this.id, \"employment-error-" + row + "\"), validateEmployment(this.id)");
    employment_input.setAttribute("maxlength", "5");
    employment_col.appendChild(employment_input);

    var error_img = document.createElement("img");
    error_img.setAttribute("id", "employment-error-" + row);

    if (append_row) {
        error_img.setAttribute("class", "input-error-image");
    } else {
        error_img.setAttribute("class", "new-input-error-image");
    }

    error_img.setAttribute("src", error_img_src);
    error_img.setAttribute("onmouseover", "this.title");
    error_img.setAttribute("title", enter_scope);
    employment_col.appendChild(error_img);

    var script = document.createElement("script");
    script.type = 'text/javascript';
    var code = '$("#scope-input-' + row + '").timeEntry({maxTime: new Date(0, 0, 0, 38, 30, 0), unlimitedHours: true, timeSteps: [1, 15, 0], defaultTime: "00:00:00"});';
    script.appendChild(document.createTextNode(code));
    employment_col.appendChild(script);

    // Build the vacation entitlement column
    var vacation_col = new_row.insertCell(2);
    vacation_col.setAttribute("class", "td-vacation");

    var vacation_input = document.createElement("input");
    vacation_input.setAttribute("id", "vacation-input-" + row);
    vacation_input.setAttribute("class", "vacation-input");
    vacation_input.setAttribute("onfocus", "constrainVacationInput(this.id)");
    vacation_input.setAttribute("onblur", "checkEmptyBox(this.id, \"vacation-error-" + row + "\")");
    vacation_input.setAttribute("maxlength", "8");
    vacation_col.appendChild(vacation_input);

    var error_img = document.createElement("img");
    error_img.setAttribute("id", "vacation-error-" + row);

    if (append_row) {
        error_img.setAttribute("class", "input-error-image");
    } else {
        error_img.setAttribute("class", "new-input-error-image");
    }

    error_img.setAttribute("src", error_img_src);
    error_img.setAttribute("onmouseover", "this.title");
    error_img.setAttribute("title", enter_vacation);
    vacation_col.appendChild(error_img);

    // Build the time carry column
    var time_carry_col = new_row.insertCell(3);
    time_carry_col.setAttribute("class", "td-time-carry");

    var time_carry = "0:00";
    if (append_row) {
        if (employment.time_carry_mm < 10)
            employment.time_carry_mm = "0" + employment.time_carry_mm;

        time_carry = employment.time_carry_hh + ":" + employment.time_carry_mm;

        // if time carry is negative prepend a minus
        if (employment.time_carry_is_neg)
            time_carry = "-" + time_carry;
    }

    var time_carry_input = document.createElement("input");
    time_carry_input.setAttribute("id", "time-carry-input-" + row);
    time_carry_input.setAttribute("class", "time-carry-input");
    time_carry_input.setAttribute("onblur", "checkEmptyBox(this.id, \"carry-error-" + row + "\"), validateCarry(this.id, \"" + time_carry + "\")");
    time_carry_input.setAttribute("onfocus", "constrainCarryInput(this.id)");
    time_carry_input.setAttribute("maxlength", "7");
    time_carry_col.appendChild(time_carry_input);

    // Build the overtime allowance column
    var overtime_col = new_row.insertCell(4);
    overtime_col.setAttribute("class", "td-overtime");

    var overtime_input = document.createElement("input");
    overtime_input.setAttribute("id", "overtime-input-" + row);
    overtime_input.setAttribute("class", "overtime-input");
    overtime_input.setAttribute("onblur", "checkEmptyBox(this.id, \"overtime-error-" + row + "\"), validateOvertime(this.id)");
    overtime_input.setAttribute("maxlength", "5");
    overtime_col.appendChild(overtime_input);

    var error_img = document.createElement("img");
    error_img.setAttribute("id", "overtime-error-" + row);
    error_img.setAttribute("class", "input-error-image");
    error_img.setAttribute("src", error_img_src);
    error_img.setAttribute("onmouseover", "this.title");
    error_img.setAttribute("title", enter_overtime);
    overtime_col.appendChild(error_img);

    var script = document.createElement("script");
    script.type = 'text/javascript';
    var code = '$("#overtime-input-' + row + '").timeEntry({maxTime: new Date(0, 0, 0, 38, 30, 0), unlimitedHours: true, defaultTime: "00:00:00"});';
    script.appendChild(document.createTextNode(code));
    overtime_col.appendChild(script);

    // Build the all in column
    var all_in_col = new_row.insertCell(5);
    all_in_col.setAttribute("class", "td-all-in");

    var all_in_input = document.createElement("input");
    all_in_input.setAttribute("type", "checkbox");
    all_in_input.setAttribute("id", "all-in-input-" + row);
    all_in_input.setAttribute("class", "all-in-input");
    if (append_row && employment.is_all_in) {
        all_in_input.setAttribute("checked", "checked");
    }
    all_in_col.appendChild(all_in_input);


    // Build the trash column
    var trash_col = new_row.insertCell(6);
    trash_col.setAttribute("class", "td-trash");

    var trash_icon = document.createElement("a");
    trash_icon.setAttribute("id", "trash-icon-" + row);
    trash_icon.setAttribute("class", "icon icon-del");
    trash_icon.setAttribute("onclick", "deleteRow(" + row + ");");

    trash_col.appendChild(trash_icon);

    var today = new Date();
    var year = today.getFullYear();
    var month = today.getMonth() + 1;
    var day = today.getDate();

    // if this is no new row then set all the respective values which are different
    if (append_row) {
        $("#employment-id-" + row + "").val(employment.id);

        year = employment.year.toString();
        month = employment.month.toString();
        day = employment.day.toString();

        if (employment.employment_scope_mm == 0) {
            employment.employment_scope_mm = "00";
        }
        var employment_scope = employment.employment_scope_hh + ":" + employment.employment_scope_mm;
        $("#scope-input-" + row + "").val(employment_scope);

        logDebug("vacation entitlement: " + employment.vacation_entitlement);
        $("#vacation-input-" + row + "").val(employment.vacation_entitlement);
        $("#time-carry-input-" + row + "").val(time_carry);

        if (employment.overtime_mm == 0) {
            employment.overtime_mm = "00";
        }
        var overtime = employment.overtime_hh + ":" + employment.overtime_mm;
        $("#overtime-input-" + row + "").val(overtime);
    } else {
        $("#time-carry-input-" + row + "").val("0:00");
        $("#employment-id-" + row + "").val(row * -1);
        $("#overtime-input-" + row + "").val("0:00");
        toggleNoEntries(false);
    }

    if (day < 10) {
        day = '0' + day
    }
    if (month < 10) {
        month = '0' + month
    }
    if (year == 0) {
        year = "000" + year;
    }

    var date = day + "-" + month + "-" + year;
    logDebug("date: " + date);
    $("#start-date-" + row + "").val(date);
    $("#orig-start-date-" + row + "").val(date);
}

// toggle display of row for no existing entries
// true = display row
// false = hide row
function toggleNoEntries(display) {
    logDebug("display? " + display);

    if (display) {
        $('#no-entries').show();
        $('#no-entries').attr('style', 'text-align: center');
    } else {
        $('#no-entries').hide();
    }
}

function deleteRow(index) {
    logDebug("delete row called with index: " + index + " for table length: " + document.getElementById('employment').rows.length);
    var day = index;
    if (day < 10) {
        day = "0" + day;
    }
    $("#row-" + index + "").hide();
    // also set start-date to some very unlikely value to avoid duplicate date errors
    $("#start-date-" + index + "").val(""+ day + "-07-1969");
    // and set delete flag
    if ($("#employment-id-" + index + "").val() > 0) { // existing employment
        $("#delete-me-" + index + "").val(1);
    } else { // a new employment
        $("#row-" + index + "").attr('class', 'invalid-row');
    }
}

// commits the workdays form if the link "workweek_commit" is not disabled
function saveEmployments(save_not_possible_msg) {

    if (!$('#user_select_user_id').find(":selected").val()) {
        // nothing shall happen in case no valid user is selected!
    } else {
        var row = 0;
        var data = [];
        var errors = false;

        $("tr.valid-row").each(function() {
            var obj = {}

            row++;

            obj.id = $(".employment-id", this).val();
            obj.delete_me = $(".delete-me", this).val();
            obj.user_id = $('#user_select_user_id').find(":selected").val();
            obj.start = $(".start-date-datepicker", this).val();
            obj.employment = $(".scope-input", this).val();
            obj.vacation = $(".vacation-input", this).val();
            logDebug("this is the entered vacation:" + obj.vacation);
            obj.time_carry = $(".time-carry-input", this).val();
            obj.overtime = $(".overtime-input", this).val();
            logDebug("this is the entered overtime:" + obj.overtime);

            if (checkAllDatesForDuplicates(obj.start, obj.id, row)) {
                errors = true;
            }
            if (!$(".all-in-input", this).attr("checked")) {
                obj.all_in = "false";
            } else {
                obj.all_in = "true";
            } 

            if (!obj.employment) {
                $("#employment-error-" + row).css('visibility', 'visible');
                errors = true;
            } else {
                $("#employment-error-" + row).css('visibility', 'hidden');
            }

            if (!obj.vacation) {
                $("#vacation-error-" + row).css('visibility', 'visible');
                errors = true;
            } else {
                $("#vacation-error-" + row).css('visibility', 'hidden');
            }
            
            if (!obj.overtime) {
                errors = true;
            }

            if (errors)
                return;

            data.push(obj);
        });

        if (errors) {
            alert(save_not_possible_msg);
        } else {
            $.ajax({
                type: "POST",
                url: "/zz5/employment_save",
                data: JSON.stringify(data),
                dataType: 'json',
                contentType: "application/json; charset=utf-8",
                success: function(msg) {
                    clearOldTable();
                    appendEmploymentTable(msg);
                },
                error: function(msg) {
                    alert("Failed to load employments: " + msg);
                }
            });
        }
    }
}

function checkEmptyBox(id, error_icon) {
    logDebug("this id: " + id + " with value: " + $("#" + id + "").val());

    if (!$("#" + id + "").val()) {
        $("#" + error_icon + "").css('visibility', 'visible');
    } else {
        $("#" + error_icon + "").css('visibility', 'hidden');
    }
}

function setCurrentDate(id) {

    // only set the date if text field is blank because we don't want to override the date everytime we click into
    // the text field
    if (!$("#" + id + "").val()) {
        var today = getCurrentDate();
        $("#" + id + "").val(today);
    }
}

function validateDate(id) {
    var validDate = $.datepicker.formatDate("dd-mm-yy", $("#" + id + "").datepicker("getDate"));
    var currentDate = getCurrentDate();
    logDebug("validDate: " + validDate);

    if (validDate == currentDate) {
        if ($("#" + id + "").val() == currentDate) {
            validDate = currentDate;
        } else {
            validDate = $("#orig-" + id + "").val();
        }
    } else {
        $("#orig-" + id + "").val(validDate);
    }

    $("#" + id + "").datepicker("setDate", validDate);
}

function constrainVacationInput(id) {
    $("#" + id + "").keypress(function(event) {
        if (event.which == 8 || event.keyCode == 37 || event.keyCode == 39 || event.keyCode == 46) {
            return true;
        } else if ((event.which != 46 || $(this).val().indexOf('.') != -1) && (event.which < 48 || event.which > 57)) {
            event.preventDefault();
        }
    });
}

function constrainCarryInput(id) {
    $("#" + id + "").keypress(function(event) {
        logDebug("index of \"-\" = " + $(this).val().indexOf('-'));
        if (event.which == 8 || event.keyCode == 37 || event.keyCode == 39 || event.keyCode == 46) {
            return true;
        } else if ((event.which != 58 || $(this).val().indexOf(':') != -1) && (event.which < 48 || event.which > 57) &&
            (event.which != 45 || $(this).val().indexOf('-') == 0 || $(this).val().indexOf('-') != -1)) {
            event.preventDefault();
        }
    });
}

function validateCarry(id, old_value) {
    if (!$("#" + id + "").val()) {
        $("#" + id + "").val("0:00");
    }

    var patt = /(^-?[0-9]{1,4}:[0-5][0-9]$)|(^-?[0-9]{1,4}$)|(^-?[0-9]{1,4}:[0-9]$)/;
    var ok = patt.test($("#" + id + "").val());

    if (ok) {
        patt = /(^-?[0-9]{1,4}$)/;
        ok = patt.test($("#" + id + "").val())
        if (ok) {
            var hours = $("#" + id + "").val();
            hours = hours + ":00";
            $("#" + id + "").val(hours);
        }

        patt = /(^-?[0-9]{1,4}:[0-9]$)/;
        ok = patt.test($("#" + id + "").val());
        if (ok) {
            var time = $("#" + id + "").val();
            time = time.split(":");
            var new_time = time[0] + ":" + "0" + time[1];
            $("#" + id + "").val(new_time);
        }
    } else {
        if (!old_value) {
            old_value = "0:00";
        }

        $("#" + id + "").val(old_value);
    }
}

function validateEmployment(id) {
    var value = toSeconds($("#" + id + "").val());
    var max_value = toSeconds("38:30");
    logDebug("validateEmployment, value: " + value + " max_value: " + max_value);
    if (value > max_value) {
        $("#" + id + "").val("38:30");
    }
}

function checkDateDuplicate(id, row) {
    $("tr.valid-row").each(function() {
        if ($("#" + id + "").val() == $(".start-date-datepicker", this).val() && $("#employment-id-" + row).val() != $(".employment-id", this).val()) {
            $("#start-error-" + row).css('visibility', 'visible');
            $(".start-error-image", this).css('visibility', 'visible');
            //$("#start-error-" + row).attr('class', 'dupe-row');
            //$(".start-error-image", this).attr('class', 'dupe-row');
            logDebug("make me visible: #start-error-" + row);
        }
    });
}

function checkAllDatesForDuplicates(date, id, row) {
    var errors = false;
    $("tr.valid-row").each(function() {
        if (date == $(".start-date-datepicker", this).val() && id != $(".employment-id", this).val()) {
            $("#start-error-" + row).css('visibility', 'visible');
            $(".start-error-image", this).css('visibility', 'visible');
            errors = true;
            return;
        }
    });

    if (errors) {
        return true;
    } else {
        return false;
    }
}

function validateOvertime(id) {
    var value = toSeconds($("#" + id + "").val());
    var max_value = toSeconds("38:30");
    logDebug("validateOvertime, value: " + value + " max_value: " + max_value);
    if (value > max_value) {
        $("#" + id + "").val("38:30");
    }
}