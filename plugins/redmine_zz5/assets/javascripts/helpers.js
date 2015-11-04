// function for debug logging
function logDebug(logString) {
    if(true) {
        console.log(logString);
    }
}

// sets the value of the input field to the current time
function setTimeNow(day_element) {
    logDebug("setTimeNow started");
    var now = new Date();
    var value = now.getHours() + ":" + now.getMinutes();
    var day_element_array = day_element.split("_");
    var week_day = day_element_array[0];
    var type = day_element_array[1];
    var input_element = document.getElementById(week_day + "_" + type);

    //set correct value
    input_element.value = value;
    $("#workweek_commit").removeAttr("style");
    if(type == "begin")
    {
        var break_time_element = document.getElementById(week_day + "_break"); 
        break_time_element.value = default_break_duration;
        updateEndTime(week_day);
    }
    
    logDebug("setTimeNow finished");
}

// returns a time object from a given time String "HH:MM"
function getTimeFromTimeString(value) {
    var time_array = value.split(":");
    var t_hours = time_array[0];
    var t_mins = time_array[1];
    var t = new Date();
    t.setHours(t_hours);
    t.setMinutes(t_mins);
    return t;
}

// Rounds down the time to the past 15 minutes
function roundDownTime(day_element, set_calculated_hours) {
    var value = day_element.value;

    // stop validation if no value is set
    if (value == "") {
        if (set_calculated_hours) {
            var day = day_element.id.split("_")[0];
            setActualAndDifferenceHours(day);
        }
        return;
    }

    logDebug("roundDownTime for " + day_element.value);

    var t = getTimeFromTimeString(value);
    var t_m = t.getMinutes() > 9 ? t.getMinutes() : '0' + t.getMinutes();
    var t_h = t.getHours() > 9 ? t.getHours() : '0' + t.getHours();

    day_element.value = t_h + ":" + t_m;

    if (set_calculated_hours) {
        var day = day_element.id.split("_")[0];
        setActualAndDifferenceHours(day);
    }

    logDebug("roundDownTime finished: " + day_element.value);
}

// Rounds up the time to the next 15 minutes
// It also increments the hour, if necessary
function roundUpTime(day_element, set_calculated_hours) {
    var value = day_element.value;

    // stop validation if no value is set
    if (value == "") {
        if (set_calculated_hours) {
            var day = day_element.id.split("_")[0];
            setActualAndDifferenceHours(day);
        }
        return;
    }

    logDebug("roundUpTime started: " + day_element.value);

    var t = getTimeFromTimeString(value);

    var t_m = t.getMinutes() > 9 ? t.getMinutes() : '0' + t.getMinutes();
    var t_h = t.getHours() > 9 ? t.getHours() : '0' + t.getHours();
    t.setSeconds(0); 
    day_element.value = t_h + ":" + t_m;

    if (set_calculated_hours) {
        var day = day_element.id.split("_")[0];
        setActualAndDifferenceHours(day);
    }

    logDebug("roundUpTime finished: " + day_element.value + " Seconds: " + t.getSeconds());
}


// validates the set time for the given day
//
// @day: the day to validate (monday, tuesday, ...)
function validateTime(day) {
    logDebug("validateTime for " + day);

    var isValid = true;

    var t_begin = document.getElementById(day + "_begin").value;
    logDebug("valdiateTime BEGINTIME " +  t_begin);
    var t_end = document.getElementById(day + "_end").value;
    logDebug("valdiateTime ENDTIME " +  t_end);
    var t_break = document.getElementById(day + "_break").value;
    logDebug("valdiateTime BREAKTIME " +  t_break);

    // hide all errors of this day
    hideErrors(day);

    // validate the plausibility of the absence reason and absence duration
    var absence_reason = $("#" + day + "_absence_reason").val();
    var absence_duration = $("#" + day + "_absence_time").val();
    var target_time = $("#" + day + "_zz5_target_time").html();
    var actual_time = $("#" + day + "_zz5_actual_time").html();

    logDebug("validateTime, absence_reason: '" + absence_reason + "'");
    logDebug("validateTime, absence_duration: '" + absence_duration + "'");

    if(toSeconds(t_end) >= toSeconds("24:00"))
    {
        document.getElementById(day + "_end").value = "23:59";
        t_end = document.getElementById(day + "_end").value;
    }
    if (absence_reason != " ") {
        if (absence_duration == "") {
            logDebug("validateTime, absence duration is invalid");
            showError(document.getElementById(day + "_absence_error"), invalid_absence_duration_error_msg);
            return false;
        }

        var week_day_target_time = toSeconds(target_time);
        var week_day_absence_time = toSeconds(absence_duration);
        logDebug("validateTime, week_day_target_time: " + week_day_target_time);
        logDebug("validateTime, week_day_absence_time: " + week_day_absence_time);

        if (!checkAbsenceTime(day)) {
            return false;
        }
    }

    // check for empty times
    if (t_begin == "") {
        showError(document.getElementById(day + "_begin_error"), begin_empty_error_msg);
        isValid &= false;
    }
    if (t_end == "") {
        showError(document.getElementById(day + "_end_error"), end_empty_error_msg);
        isValid &= false;
    }
    if (t_break == "") {
        showError(document.getElementById(day + "_break_error"), break_empty_error_msg);
        isValid &= false;
    }

    // if all times are empty, the day is valid
    if (t_begin == "" && t_end == "" && t_break == "") {
        hideErrors(day);
        isValid = true;
        logDebug("validateTime, all times are empty");
        return isValid;
    }

    logDebug("validateTime, working hours: " + t_begin + " - " + t_end + ", break: " + t_break);

    // validate the plausability of the entered times
    if (t_begin != "" && t_end != "") {
        if((toSeconds(t_end) - toSeconds(t_begin) - toSeconds(t_break)) == 0) {
            isValid = true;
            return isValid;
        }
        else if ((toSeconds(t_end) - toSeconds(t_begin)) < 0) {
            showError(document.getElementById(day + "_begin_error"), worktime_error_msg);
            showError(document.getElementById(day + "_end_error"), worktime_error_msg);
            isValid &= false;
            return isValid;
        }
    }

    // validate the plausability of the entered times, inclduing the break
    if (t_begin != "" && t_end != "" && t_break != "") {
        if ((toSeconds(t_end) - toSeconds(t_begin) - toSeconds(t_break)) < 0) {
            //show error
            showError(document.getElementById(day + "_break_error"), worktime_error_msg);
            isValid &= false;
            return isValid;
        }

        
        var calc_actual_time = toSeconds(t_begin) + toSeconds(actual_time) + toSeconds(t_break);
        logDebug("calc_actual_time : " + (toSeconds(t_end)).toString() + " " + calc_actual_time.toString());
        if(calc_actual_time > toSeconds(t_end))
        {
            showError(document.getElementById(day + "_end_error"), worktime_error_msg);
            logDebug("show end error message");
            isValid &= false;
            return isValid;
        }
    }
    return isValid;
}

// Hides all errors of a given day.
function hideErrors(day) {
    logDebug("hideErrors for " + day);

    hideError(document.getElementById(day + "_begin_error"));
    hideError(document.getElementById(day + "_end_error"));
    hideError(document.getElementById(day + "_break_error"));
    hideError(document.getElementById(day + "_absence_error"));
}

// sets the visibility to visible of the warn_element and
// sets the tooltip-text
function showError(warn_element, text) {
    if (warn_element != null) {
        warn_element.style.visibility = "visible";
        warn_element.title = text;
    }
}

// sets the visibility to hiden of the warn_element
function hideError(warn_element) {
    if (warn_element != null) {
        warn_element.style.visibility = "hidden";
    }
}

function toDate(date_string) {
    var parts = date_string.split('-');
    // new Date(year, month [, day [, hours[, minutes[, seconds[, ms]]]]])
    return new Date(parts[0], parts[1] - 1, parts[2]); // Note: months are 0-based
}

// Determines where the user has clicked and executes the corresponding statement.
function setBeginEndTime(clicked_id) {
    var day_element = document.getElementById(clicked_id);
    var id_array = day_element.id.split("_");
    var week_day = id_array[0];
    var type = id_array[1];

    if (day_element.value == "") {
        if (type == "begin")
        {
            day_element.value = default_work_start;
            var break_time_element = document.getElementById(week_day + "_break"); 
            break_time_element.value = default_break_duration;
            updateEndTime(week_day);
            $("#workweek_commit").removeAttr("style"); 
        }
        if (type == "end") {
            day_element.value = default_end_work;
        }
        if (type == "break") {
            day_element.value = default_break_duration;
        }
        day_element.select();
    }
}

// Returns the seconds of a time string "HH:MM" as number or "-HH:MM".
function toSeconds(time) {
    if(typeof time === "undefined") {
        return 0;
    }

    time = time.toString();
    var time_str = time;
    var appendMinus = false;

    console.log ("time: " + time);

    if (time_str.length == 0)
    {
        return 0;
    }
    
    if (time_str.indexOf("-") != -1) {
        time = time_str.substring(1, time_str.length);
        appendMinus = true;
    }

    // Extract hours, minutes and seconds
    var parts = time.split(':');
    // compute  and return total seconds
    var result = parts[0] * 3600 + // an hour has 3600 seconds
        parts[1] * 60; // a minute has 60 seconds

    if (appendMinus) {
        return -1 * result;
    }

    return result;
}

// Calculates the time difference (a - b)
// Example: 10:00 - 02:00 = 08:00
function time_difference(a, b) {
    var difference = Math.abs(toSeconds(a) - toSeconds(b));

    // format time differnece
    var result = [
        Math.floor(difference / 3600), // an hour has 3600 seconds
        Math.floor((difference % 3600) / 60), // a minute has 60 seconds
    ];

    // 0 padding and concatation
    result = result.map(function(v) {
        return v < 10 ? '0' + v : v;
    }).join(':');
    return result;
}

// Calculates the time difference (a - b)
// Example: 08:00 + 02:00 = 10:00
function time_addition(a, b) {
    var difference = Math.abs(toSeconds(a) + toSeconds(b));

    // format time differnece
    var result = [
        Math.floor(difference / 3600), // an hour has 3600 seconds
        Math.floor((difference % 3600) / 60), // a minute has 60 seconds
    ];

    // 0 padding and concatation
    result = result.map(function(v) {
        return v < 10 ? '0' + v : v;
    }).join(':');
    return result;
}

// Calculates and sets the actual working hours of the given day.
//
// @day: the day for which the actual hours shall be set (monday, tuesday, ...)
function setActualHours(day) {
    logDebug("setActualHours for " + day);

    var actual_time_label = document.getElementById(day + "_zz5_actual_time");
    var s_begin = document.getElementById(day + "_begin").value;
    var s_end = document.getElementById(day + "_end").value;
    var s_break = document.getElementById(day + "_break").value;
    var s_absence = document.getElementById(day + "_absence_time").value;
    var s_absence_type = document.getElementById(day + "_absence_reason").value;


    var result = "00:00";

    logDebug("setActualHours, begin: " + s_begin + ", end: " + s_end + ", break: " + s_break + ", absence: " + s_absence);

    if (s_begin != "" && s_end != "" && s_break != "") {
        result = time_difference(s_break, time_difference(s_end, s_begin));
    }

    if (s_absence != "" && (s_absence_type != absence_types["zz5_absence_comp_time"])) {
        result = time_addition(result, s_absence);
    }

    if (s_end != "" || s_break != "")
    {
        $("#" + day + "_end").removeAttr("disabled");
        $("#" + day + "_break").removeAttr("disabled");
    }

    if(s_begin == "") {
        $("#" + day + "_begin").val("");
        $("#" + day + "_end").removeAttr("value");
        $("#" + day + "_break").removeAttr("value");
        $("#" + day + "_end").attr("disabled", "disabled");
        $("#" + day + "_break").attr("disabled", "disabled");
        logDebug("setActualHours, disable fields!");
    }
    actual_time_label.innerHTML = result;
}


// Calculates and sets the difference hours of the given day element.
// The difference is the target working hours minus the actual working hours.
//
// @day: the day for which the difference hours shall be set (monday, tuesday, ...)
function setDifferenceHours(day) {
    logDebug("setDifferenceHours for " + day);

    var diff_time_label = document.getElementById(day + "_zz5_time_difference");
    var s_actual_time = document.getElementById(day + "_zz5_actual_time").innerHTML;
    var s_target_time = document.getElementById(day + "_zz5_target_time").innerHTML;
    var result = "--:--";

    logDebug("setDifferenceHours, actual: " + s_actual_time + ", target: " + s_target_time);

    if (s_target_time != "" && s_actual_time != "") {
        if (toSeconds(s_actual_time) - toSeconds(s_target_time) >= 0) {
            result = time_difference(s_actual_time, s_target_time);
        } else {
            result = "-" + time_difference(s_actual_time, s_target_time);
        }
    }

    diff_time_label.innerHTML = result;
}


// A wrapper for the function calls to setTargetHours(day) and setDifferenceHours(days).
//
// @day: the week day (monday, tuesday, ...)
function setActualAndDifferenceHours(day) {
    setActualHours(day);
    setDifferenceHours(day);
}


function setAbsenceTypeSelected(absence_id, day) {
    $("#" + day + "_absence_reason option").each(function() {
        if ($(this).val() == absence_id) {
            $(this).prop("selected", true);
        }
    });

}

// returns a time string from the given time in seconds
// negative values result append the "-" prefix to the time
function toTime(seconds) {
    var sec = seconds;
    var appendMinus = false;

    if (seconds < 0) {
        sec = -1 * seconds;
        appendMinus = true;
    }

    var result = [
        Math.floor(sec / 3600), // an hour has 3600 seconds
        Math.floor((sec % 3600) / 60), // a minute has 60 seconds
    ];

    // 0 padding and concatation
    result = result.map(function(v) {
        return v < 10 ? '0' + v : v;
    }).join(':');

    if (appendMinus) {
        return "-" + result;
    }

    return result;
}

function getCurrentDate() {

    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; //January is 0!
    var yyyy = today.getFullYear();

    if (dd < 10) {
        dd = '0' + dd;
    }

    if (mm < 10) {
        mm = '0' + mm;
    }

    return today = dd + "-" + mm + '-' + yyyy;
}