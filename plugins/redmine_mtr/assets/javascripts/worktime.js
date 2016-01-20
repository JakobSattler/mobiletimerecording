/**
 * Created by apus on 20.01.16.
 */

function changeDate(button){
        var actDateStr = document.getElementById("date").textContent;
        var actDateParts = actDateStr.split(".");
        var actDate = new Date(actDateParts[2], actDateParts[1]-1, actDateParts[0]);
        if (button.value === "inc") {
            var newDate = new Date(actDate.getTime() + 86400000);
        }
        else if (button.value === "dec") {
            var newDate = new Date(actDate.getTime() - 86400000);
        }
        document.getElementById("date").textContent = newDate.toLocaleDateString();
}
