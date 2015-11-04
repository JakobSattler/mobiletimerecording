// disables the save button
function enableSaveButton() {
    $("#zz5_user_preference_submit").removeAttr("disabled");
}

// enabled the save button
function disableSaveButton() {
    $("#zz5_user_preference_submit").attr("disabled", "disabled");
}

// validates the user preference times
function validate_user_preferences() {

    logDebug("validate_user_preferences, started");
    var isValid = true;
    isValid &= validateTime("default");
    logDebug("validate_user_preferences isValid=" + isValid);

    // show or hide save buttons
    if (isValid) {
        enableSaveButton();
    } else {
        disableSaveButton();
    }

    logDebug("validate_user_preferences, finished");
}

// if document is ready
$(document).ready(function() {
    validate_user_preferences();
});