function restrictDatePickerMinDate(datepicker_id, minDate) {
    logDebug("restrictDatePickerStartDate for '#" + datepicker_id + "', minDate: '" + minDate + "'");
    var dp = $('#' + datepicker_id);
    var parts = minDate.split('-');

    logDebug("object: " + dp.name);
    logDebug("parts: " + parts);

    dp.datepicker("option", "minDate", new Date(parts[0], parts[1] - 1, parts[2]));
    logDebug("restrictDatePickerStartDate finished");
}

function restrictDatePickerMaxDate(datepicker_id, maxDate) {
    logDebug("restrictDatePickerMaxDate for " + datepicker_id + ", maxDate: " + maxDate);
    var dp = $('#' + datepicker_id);
    var parts = maxDate.split('-');

    logDebug("object: " + dp.name);
    logDebug("parts: " + parts);

    dp.datepicker("option", "maxDate", new Date(parts[0], parts[1] - 1, parts[2]));
    logDebug("restrictDatePickerMaxDate finished");
}


function updateDatePickerRestrictions(user_id) {
    logDebug("updateDatePickerRestrictions called with user id:" + user_id);

    var tmp_first_date = first_date[user_id];
    var tmp_last_date = last_date[user_id];

    logDebug("tmp_first_date for user: " + tmp_first_date);

    $("#start_date").datepicker('enable');
    $("#end_date").datepicker('enable');

    if (tmp_first_date != 0 && tmp_last_date != 0) {
        restrictDatePickerMinDate("start_date", tmp_first_date);
        restrictDatePickerMaxDate("start_date", tmp_last_date);
        restrictDatePickerMinDate("end_date", tmp_first_date);
        restrictDatePickerMaxDate("end_date", tmp_last_date);
    } else {
        $("#start_date").datepicker('disable');
        $("#end_date").datepicker('disable');
    }

    logDebug("updateDatePickerRestrictions finished");
}

function updateDatePicker(user_id) {
    logDebug("updateDatePicker, user id: "+ user_id);
}


// if document is ready
$(document).ready(function() {
    logDebug('page ready...');

    //check for select box and bind change listener for admin view
    var selectBox = $('#user_select_user_id');
    if (selectBox != null) {

        selectBox.change(function() {

            var user_id = $(this).val();
            logDebug("selection changed to user id: " + user_id);
            updateDatePickerRestrictions(user_id);
        });
    }

    //bind change listener on #start_date
    var start = $('#start_date');
    if (start != null) {

        start.change(function() {

            // adjust minDate for #end_start
            var date = $(this).val();
            logDebug("start date changed to : " + date);
            restrictDatePickerMinDate("end_date", date);
        });
    }

    //bind change listener on #end_date
    var end = $('#end_date');
    if (end != null) {

        end.change(function() {

            // adjust minDate for #end_start
            var date = $(this).val();
            logDebug("end date changed to : " + date);
            restrictDatePickerMaxDate("start_date", date);
        });
    }

});