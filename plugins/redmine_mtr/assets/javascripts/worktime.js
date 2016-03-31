/**
 * Created by apus on 20.01.16.
 */
window.onload=function() {

    /*if (!sessionStorage['done']) {
        sessionStorage['done'] = 'yes';
        var actDateStr = document.getElementById("date_label").textContent;
        var newDate = new Date();
        var year = newDate.getFullYear();
        var month = newDate.getMonth()+1;
        var week = newDate.getWeek();
        var day = newDate.getDate();
        document.getElementById("date_label").textContent = newDate.toLocaleDateString();
        document.getElementById("date").value = newDate.toLocaleDateString();
        document.getElementById("year").value = year;
        document.getElementById("week").value = week;
        document.getElementById("day").value = day;
    }*/

}

function changeDate(button){
    var actDateStr = document.getElementById("date_label").textContent;
    var actDateParts = actDateStr.split(".");
    var actDate = new Date(actDateParts[2], actDateParts[1]-1, actDateParts[0]);
    if (button.value === "inc") {
        var newDate = new Date(actDate.getTime() + 86400000);
    }
    else if (button.value === "dec") {
        var newDate = new Date(actDate.getTime() - 86400000);
    }
    document.getElementById("date").value = newDate.toLocaleDateString();
    document.getElementById("year").value = newDate.getFullYear();
    document.getElementById("month").value = newDate.getMonth()+1;
    document.getElementById("week").value = newDate.getWeek();
    document.getElementById("day").value = newDate.getDate();
    document.forms["worktime_form"].submit();
}

Date.prototype.getWeek = function() {
    var onejan = new Date(this.getFullYear(), 0, 1);
    return Math.ceil((((this - onejan) / 86400000) + onejan.getDay() + 1) / 7)-1;
}