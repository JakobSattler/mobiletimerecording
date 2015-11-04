// if document is ready (site is loaded)
$(document).ready(function() {

    logDebug("loaded project report site");
    $("#period").val(selection);
    comboBoxSelectionChanged();
    initializeDatePickers();
    setProjectSums();

    $(".project-row").click(function() {
        id = $(this).attr("id");
        showOrHideChildren(id);
    });

    $(".issue-row").click(function() {
        id = $(this).attr("id");
        location.href = "/issues/" + id;
    });
});

function setProjectSums() {
    for (var pid in estimated_sum) {


        setValueAndCssClass("#estimated_" + pid, estimated_sum[pid]);
        setValueAndCssClass("#worked_" + pid, worked_sum[pid]);
        setValueAndCssClass("#diff_" + pid, difference[pid]);
        /*
        $('#estimated_' + pid).html(estimated_sum[pid]);
        $('#worked_' + pid).html(worked_sum[pid]);
        $('#diff_' + pid).html(difference[pid]);
        */
    }
}

function setValueAndCssClass(element, sum) {
    logDebug("setValueAndCssClass, " + element + ", sum: " + sum);
    // draw red if needed

    if (sum.indexOf("-") != -1) {
        logDebug("setValueAndCssClass, sum is smaller than zero");
        $(element).addClass("negative-hours");
    }
    $(element).html(sum);
}

function setDates(from_date, to_date) {

    logDebug("setDates with from: " + from_date + ", to:" + to_date + "called");

    $('#from').val(from_date);
    $('#to').val(to_date);
}

function initializeDatePickers() {

    var parts_min_date = min_date.split('-');
    var parts_max_date = max_date.split('-');

    var minDate = new Date(parts_min_date[0], parts_min_date[1] - 1, parts_min_date[2]);
    var maxDate = new Date(parts_max_date[0], parts_max_date[1] - 1, parts_max_date[2]);

    logDebug("min date: " + minDate);
    logDebug("max date: " + maxDate);

    $("#from").datepicker("option", "minDate", minDate);
    $("#from").datepicker("option", "maxDate", maxDate);

    $("#to").datepicker("option", "minDate", minDate);
    $("#to").datepicker("option", "maxDate", maxDate);

}

function restrictFromDatepicker() {
    var from_date = $("#from").val();
    var to_date = $("#to").val();

    logDebug("fromDate: " + from_date);
    logDebug("toDate: " + to_date);

    if (from_date > to_date) {
        if (to_date < min_date) {
            $("#from").val(min_date);
        } else if (to_date > max_date) {
            $("#from").val(max_date);
        } else {
            $("#from").val(to_date);
        }
    }

    if (to_date > max_date) {
        $("#to").val(max_date);
    }

    if (to_date < min_date) {
        $("#to").val(min_date);
    }
}

function restrictToDatepicker() {
    var from_date = $("#from").val();
    var to_date = $("#to").val();

    logDebug("fromDate: " + from_date);
    logDebug("toDate: " + to_date);

    if (from_date > to_date) {
        if (from_date < min_date) {
            $("#to").val(min_date);
        } else if (from_date > max_date) {
            $("#to").val(max_date);
        } else {
            $("#to").val(from_date);
        }
    }

    if (from_date < min_date) {
        $("#from").val(min_date);
    }

    if (from_date > max_date) {
        $("#from").val(max_date);
    }
}

function comboBoxSelectionChanged() {

    var selectedValue = $('#period').find(":selected").val();
    logDebug("the value you selected: " + selectedValue);

    switch (selectedValue) {
        case "all":
            $('#from-box').hide();
            $('#to-box').hide();
            setDates(String(min_date), String(max_date))
            break;
        case "between":
            $('#from-box').show();
            $('#to-box').show();
            break;
        case "greater_or_equal":
            $('#from-box').show();
            $('#to-box').hide();
            $('#to').val(max_date);
            break;
        case "less_or_equal":
            $('#from-box').hide();
            $('#to-box').show();
            $('#from').val(min_date);
            break;
        default:
            logDebug("this shouldn't happen!");
    }
}

function showOrHideChildren(id) {
    //logDebug("showOrHideChildren called with id: " + id);

    //select all elements with data-parent-id=id
    var children = $('label[data-parent-id="project_' + id + '"]');

    logDebug("children: " + children.attr('id'));

    if (children.size() != 0) {
        children.each(function(index) {
            //logDebug("element parent_id: " + $(this).attr('id'));

            var tr = $(this).closest('tr');
            var current_id = $(this).attr('id').split("_")[1];

            //logDebug("current_id: " + current_id);

            if (tr.is(":visible") == true) {

                //hide elements
                tr.hide();

                //hide also children
                hideChildren(current_id);
                setExpandMark(id, true);

            } else {
                //show elements
                tr.show();
                setExpandMark(id, false);
            }
        });
    } else {
        setExpandMark(id, false);
        logDebug("I'm childless, booohooo!");
    }
}

function setExpandMark(id, isPlus) {
    //logDebug("setExpandMark id:" + id + ", isPlus:" + isPlus);

    var oldValue = $("#project_" + id).html();
    oldValue = oldValue.substring(1, (oldValue.length));
    var newValue = oldValue;

    if (isPlus) {
        newValue = "+" + oldValue;
    } else {
        newValue = "-" + oldValue;
    }
    //logDebug("setExpandMark set value: " + newValue);
    $("#project_" + id).html(newValue);
}

function hideChildren(id) {

    //logDebug("hide children called with id : " + id);
    var children = $('label[data-parent-id="project_' + id + '"]');
    //logDebug("project children: " + children);

    if (children.size() != 0) {
        children.each(function(index) {
            //logDebug("element parent_id: " + $(this).attr('id'));
            //logDebug("element parent_id: " + $(this).attr('id'));
            var tr = $(this).closest('tr');
            tr.hide();
            var current_id = $(this).attr('id').split("_")[1];
            hideChildren(current_id);
        });
    }
}