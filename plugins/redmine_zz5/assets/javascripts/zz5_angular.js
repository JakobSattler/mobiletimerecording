'use strict';

var zz5App = angular.module('zz5App', [
    'zz5Controllers',
    'zz5Services',
    'angular-loading-bar',
    'ngAnimate',
    'sticky']);

    zz5App.config(['cfpLoadingBarProvider', '$locationProvider', function(cfpLoadingBarProvider, $locationProvider) {
        cfpLoadingBarProvider.includeSpinner = false;
        $locationProvider.html5Mode({
            enabled: true,
            requireBase: false,
            rewriteLinks: false });
    }]);

    zz5App.directive('timeEntryField', function() {
        return {
            // Restrict it to be an attribute in this case
            restrict: 'A',
            // responsible for registering DOM listeners as well as updating the DOM
            link: function(scope, element, attrs) {
                angular.element(element).timeEntry(scope.$eval(attrs.timeEntryField));
            }
        };
    });

    zz5App.directive('myDatepicker', function() {
        return {
            // Restrict it to be an attribute in this case
            restrict: 'A',
            scope: {
                dates: '@dates',
                myDatepickerJumpTo: '&'
            },
            // responsible for registering DOM listeners as well as updating the DOM
            link: function(scope, element, attrs) {
                    var options = '{showOn:"button", buttonImageOnly: true, buttonImage: "/plugin_assets/redmine_zz5/images/calendar.png", ' +
                        'showButtonPanel: true, dateFormat:"yy-mm-dd", firstDay: 1, ' + scope.dates + ', showButtonPanel: true, showWeek: true, ' +
                        'showOtherMonths: true, selectOtherMonths: true}';
                    angular.element(element).datepicker(scope.$eval(options));
                    angular.element(element).datepicker("option", "onSelect",
                        function() {
                            scope.myDatepickerJumpTo();
                        });
            }
        };
    });

    zz5App.directive('myDatepickerFrom', function() {
        return {
            // Restrict it to be an attribute in this case
            restrict: 'A',
            scope: {
                dates: '@dates',
                from: '@from',
                myDatepickerSetFrom: '&'
            },
            // responsible for registering DOM listeners as well as updating the DOM
            link: function(scope, element, attrs) {
                var options = '{showOn:"button", buttonImageOnly: true, buttonImage: "/plugin_assets/redmine_zz5/images/calendar.png", ' +
                    'showButtonPanel: true, dateFormat:"dd-mm-yy", firstDay: 1, ' + scope.dates + ', showButtonPanel: true, showWeek: true, ' +
                    'showOtherMonths: true, selectOtherMonths: true}';
                angular.element(element).datepicker(scope.$eval(options));
                angular.element(element).datepicker("option", "onSelect",
                    function() {
                        scope.myDatepickerSetFrom();
                    });
            }
        };
    });

    zz5App.directive('myDatepickerTo', function() {
        return {
            // Restrict it to be an attribute in this case
            restrict: 'A',
            scope: {
                dates: '@dates',
                to: '@to',
                myDatepickerSetTo: '&'
            },
            // responsible for registering DOM listeners as well as updating the DOM
            link: function(scope, element, attrs) {
                var options = '{showOn:"button", buttonImageOnly: true, buttonImage: "/plugin_assets/redmine_zz5/images/calendar.png", ' +
                    'showButtonPanel: true, dateFormat:"dd-mm-yy", firstDay: 1, ' + scope.dates + ', showButtonPanel: true, showWeek: true, ' +
                    'showOtherMonths: true, selectOtherMonths: true}';
                angular.element(element).datepicker(scope.$eval(options));
                angular.element(element).datepicker("option", "onSelect",
                    function() {
                        scope.myDatepickerSetTo();
                    });
            }
        };
    });

    zz5App.filter('getById', function() {
        return function(input, id) {
            var i=0, len=input.length;
            for (; i<len; i++) {
                console.log("input[i].id: " + input[i].id);
                console.log("id: " + id);
                console.log("---------");
                if (+input[i].issue_id == +id) {
                    return i;
                }
            }
            return -1;
        }
    });


var zz5Controllers = angular.module('zz5Controllers', ['ngDialog']);
 
    zz5Controllers.controller('WorkdayCtrl', ['$scope', '$sce', '$filter', '$log', '$document', '$timeout', '$location', 'Data', 'Day', 'TimeEntry', 'Project', 'AbsenceBlock', 'Issue', 'ngDialog',
        function ($scope, $sce, $filter, $log, $document, $timeout, $location, Data, Day, TimeEntry, Project, AbsenceBlock, Issue, ngDialog) {
            $scope.init = function(json_data) {
                $scope.loading_init = true;
                $scope.data = Data.query(json_data, function(data) {
                    $scope.days = data.days;
                    $scope.issues = data.issues;
                    $scope.project_tree = data.project_tree;
                    $scope.misc_data = data.misc_data;
                    $scope.absences = data.absences;

                    for(var i = 0; i < $scope.project_tree.length; i++) {
                        $scope.tree.push({name: $scope.project_tree[i], nodes: [], issues: []});
                    }
                    var date = $scope.createDatepickerDateFromString($scope.days[0].date);
                    $(".week-picker").datepicker('setDate', date);

                    $scope.initTimes();

                    $scope.loading_init = false;
                }, function(data) {
                    alert("Your are probably not allowed to view this data.");
                });

                $scope.loadActivities(activity_arr);
                $scope.focused = false;
                $scope.initTicketSearch();
                $scope.saved = false;
                $scope.children_projects = "";
                $scope.weekview = is_weekview;
                $scope.alt_worktimes = is_alt_worktimes;
                $scope.tree = [];
                $scope.showTicketWarning = false;
                $scope.duplicate_tickets = "";
                $scope.duplicate_tickets_text = duplicate_tickets_text;
                $scope.projects = projects;
            };

            $scope.loadData = function(year, week, day) {

                var json_data = {"year": year, "week": week, "day": day};
                $scope.loading = true;
                $scope.data = Data.query(json_data, function(data) {
                    $scope.days = data.days;
                    $scope.issues = data.issues;
                    $scope.project_tree = data.project_tree;
                    $scope.misc_data = data.misc_data;
                    $scope.absences = data.absences;
                    var date = $scope.createDatepickerDateFromString($scope.days[0].date);
                    $(".week-picker").datepicker('setDate', date);
                    $scope.initTimes();
                    $scope.loading = false;

                    if($scope.weekview == true) {
                        $location.path($scope.misc_data.year + "/" + $scope.misc_data.week);
                    } else {
                        $location.path($scope.misc_data.year + "/" + $scope.misc_data.week + "/" + $scope.misc_data.day);
                    }

                }, function(data) {
                    alert("Your are probably not allowed to view this data.");
                });
            };

            $scope.initTimes = function () {
                $scope.sums = {
                    actual: "00:00",
                    difference: "00:00",
                    project: "00:00",
                    target: "00:00",
                    carry: "00:00"
                };

                for(var j = 0; j < $scope.days.length; j++) {

                    var absence_time = $scope.days[j].absence_time;
                    if($scope.days[j].absence_reason == 5) {
                        absence_time = "00:00";
                    }

                    $scope.days[j].actual_hours = "00:00";

                    if($scope.alt_worktimes) {
                        for (var l = 0; l < $scope.days[j].begin_end_times.length; l++) {
                            $scope.days[j].actual_hours = $scope.time_addition($scope.days[j].actual_hours, $scope.time_difference($scope.days[j].begin_end_times[l].end, $scope.days[j].begin_end_times[l].begin));
                        }
                        $scope.days[j].actual_hours = $scope.time_addition($scope.days[j].actual_hours, absence_time);
                    } else {
                        var last_index = $scope.days[j].begin_end_times.length-1;
                        $scope.days[j].actual_hours = $scope.time_addition($scope.time_difference($scope.days[j].break, $scope.time_difference($scope.days[j].begin_end_times[last_index].end, $scope.days[j].begin_end_times[0].begin)), absence_time);
                    }

                    $scope.sums.actual = $scope.time_addition($scope.sums.actual, $scope.days[j].actual_hours);
                    $scope.sums.target = $scope.time_addition($scope.sums.target, $scope.days[j].target);

                    var result = "00:00";
                    for (var i = 0; i < $scope.issues.length; i++) {
                        for (var k = 0; k < $scope.issues[i].time_entries[j].bb.length; k++) {
                            result = $scope.time_addition(result, $scope.issues[i].time_entries[j].bb[k].hours);
                        }
                    }
                    $scope.days[j].project_hours = result;
                    $scope.sums.project = $scope.time_addition($scope.sums.project, $scope.days[j].project_hours);
                    $scope.days[j].time_difference = $scope.toTime($scope.toSeconds($scope.days[j].actual_hours) - $scope.toSeconds($scope.days[j].target));
                    $scope.sums.difference = $scope.toTime($scope.toSeconds($scope.sums.difference) + $scope.toSeconds($scope.days[j].time_difference));
                    $scope.days[j].saved = true;

                    $scope.checkAbsenceTime($scope.days[j]);

                    if ($scope.toSeconds($scope.days[j].project_hours) > $scope.toSeconds($scope.time_difference($scope.days[j].actual_hours, absence_time))) {
                        $scope.days[j].project_warning = false;
                        $scope.days[j].actual_warning = true;
                    } else if ($scope.toSeconds($scope.days[j].project_hours) < $scope.toSeconds($scope.time_difference($scope.days[j].actual_hours, absence_time))) {
                        $scope.days[j].actual_warning = false;
                        $scope.days[j].project_warning = true;
                    } else {
                        $scope.days[j].project_warning = false;
                        $scope.days[j].actual_warning = false;
                    }
                }
            };

            $scope.computeTabindex = function(day_index, time_index) {
              return day_index * 3 + time_index;
            };

            $scope.loadProjects = function(pid, d) {
                if(d.nodes.length == 0 && d.issues.length == 0) {
                    var json_data = {
                        "year": $scope.misc_data.year,
                        "ww": $scope.misc_data.week,
                        "pid": pid
                    };
                    $scope.projects = Project.query(json_data, function(data) {
                        $scope.children_projects = data.projects;
                        $scope.project_tree_issues = data.time_entries;
                        for(var i = 0; i < $scope.children_projects.length; i++) {
                            d.nodes.push({name: $scope.children_projects[i], nodes: [], issues: []});
                        }
                        for(var i = 0; i < $scope.project_tree_issues.length; i++) {
                            d.issues.push({name: $scope.project_tree_issues[i], nodes: []});
                        }
                    });
                }
                else {
                    d.nodes = [];
                    d.issues = [];
                }
            };

            // pass old_value and field to do some basic checks whether to save or not!!!
            $scope.saveAbsence = function(day_data, old_time, old_reason) {
                var json_data = {
                    "date": day_data.date,
                    "absence_time": day_data.absence_time,
                    "absence_reason": day_data.absence_reason
                };

                $scope.time = Day.save_absence.send(json_data,
                    function (data) {
                        $scope.saved = true;
                        day_data.time_carry = data.carry;
                        $scope.misc_data.vac_entitlement = data.vacation;
                    },
                    function (data) {
                        alert("Error while saving. Please try again!");
                        $scope.saved = false;

                        day_data.absence_time = old_time;
                        day_data.absence_reason = old_reason;

                        if($scope.alt_workimes) {
                            $scope.calculateMultipleActualHours(day_data);
                        } else {
                            $scope.calculateSingleActualHours(day_data);
                        }
                    });
            };

            $scope.saveSingleWorktime = function(day, type, old_begin, old_end, old_break) {

                switch(type) {
                    case "begin":
                        if((day.begin_end_times[0].begin == "" && old_begin == day.begin_end_times[0].begin) || old_begin == day.begin_end_times[0].begin) {
                            return;
                        }
                        break;
                    case "end":
                        if(old_end == day.begin_end_times[day.begin_end_times.length-1].end) {
                            return;
                        }
                        break;
                    case "break":
                        if(old_break == day.break) {
                            return;
                        }
                        break;
                    default:
                        break;
                }


                var json_data = {
                    "date": day.date,
                    "id": day.begin_end_times[0].id,
                    "type": type,
                    "begin": day.begin_end_times[0].begin,
                    "end": day.begin_end_times[day.begin_end_times.length-1].end,
                    "break": day.break
                };

                $scope.time = Day.save_single_worktime.send(json_data,
                    function (data) {
                        $scope.saved = true;
                        day.time_carry = data.carry;
                        day.begin_end_times[0].id = data.be_id
                    },
                    function (data) {
                        alert("Error while saving. Please try again!");
                        $scope.saved = false;

                        day.begin_end_times[0].begin = old_begin;
                        day.begin_end_times[day.begin_end_times.length-1].end = old_end;
                        day.break = old_break;

                        $scope.calculateSingleActualHours(day);
                    });
            };

            $scope.saveMultipleWorktime = function(day, index, old_begin, old_end, old_break) {
                if(day.begin_end_times[index].begin == "" && old_begin == day.begin_end_times[index].begin) {
                    return;
                }

                var json_data = {
                    "date": day.date,
                    "id": day.begin_end_times[index].id,
                    "begin": day.begin_end_times[index].begin,
                    "end": day.begin_end_times[index].end,
                    "break": day.break
                };

                $scope.time = Day.save_multiple_worktime.send(json_data,
                    function (data) {
                        $scope.saved = true;
                        day.time_carry = data.carry;
                        day.begin_end_times[index].id = data.be_id
                    },
                    function (data) {
                        alert("Error while saving. Please try again!");
                        $scope.saved = false;

                        day.begin_end_times[index].begin = old_begin;
                        day.begin_end_times[index].end = old_end;
                        day.break = old_break;

                        $scope.calculateMultipleActualHours(day);
                    });
            };

            $scope.addWorktimesRow = function() {
                var worktimes = $scope.days[0].begin_end_times;
                worktimes.push({id: 0, begin: '', end: ''});
            };

            $scope.removeWorktimesRow = function(index) {
                var worktimes = $scope.days[0].begin_end_times;
                var json_data = {   "id": worktimes[index].id,
                    "date": $scope.days[0].date
                };

                $scope.time = Day.delete_worktime.send(json_data,
                    function(data) {
                        $scope.saved = true;
                    });

                worktimes.splice(index, 1);
            };

            $scope.setAbsenceType = function (day, day_id, absence_id, old_reason, old_duration) {
                var selected_Absence = angular.element($("#" + day_id + "_selectedAbsence"));
                var url = "/plugin_assets/redmine_zz5/images/" + absence_id + ".png";
                selected_Absence.attr("src", url);

                var absence_types = angular.element($("#" + day_id + "-absence-reason-select"));
                absence_types.attr("ng-show", "false");

                if(absence_id == old_reason) {
                    return;
                } else if (absence_id == -1 && old_reason == "") {
                    return;
                }

                if (absence_id != "-1") {
                    day.absence_reason = absence_id;
                    $scope.setAbsenceTime(day, day_id);
                }
                else {
                    day.absence_time = "";
                    day.absence_reason = "";
                    day.absence_warning = false;
                }

                if($scope.alt_worktimes) {
                    $scope.calculateMultipleActualHours(day);
                } else {
                    $scope.calculateSingleActualHours(day);
                }

                var old_absence_values = [old_duration, old_reason];
                $scope.saveAbsence(day, old_absence_values);
            };

            $scope.saveAbsenceTime = function (day, old_duration, old_reason) {
                if(day.absence_time != old_duration) {
                    var old_absence_values = [old_duration, old_reason];
                    $scope.saveAbsence(day, old_absence_values);
                }
            };

            $scope.saveTimeEntry = function(time_entry, old_value, field, day, old_begin, old_end, old_break, old_project_hours,
                                                old_activity, old_comment) {

                if(typeof day != "undefined") {
                    var old_day_values = [old_begin, old_end, old_break, old_project_hours];
                } else {
                    var old_day_values = [];
                }

                switch(field) {
                    case 'hours':
                        var old_te_values = [old_activity, old_comment];
                        if(time_entry.hours != old_value && time_entry.hours != '' && time_entry.new == true) {

                            if(time_entry.activity_id == '-1') {
                                time_entry.activity_id = "16";
                            }

                            $scope.sendSave(time_entry, day, old_value, field, old_day_values, old_te_values);
                        } else if (time_entry.hours != old_value && time_entry.hours == '' && time_entry.new == false) {
                            $scope.sendSave(time_entry, day, old_value, field, old_day_values, old_te_values);
                            time_entry.comment = "";
                            time_entry.activity_id = "-1";
                        } else if (time_entry.hours != old_value && time_entry.new == false) {
                            $scope.sendSave(time_entry, day, old_value, field, old_day_values, old_te_values);
                        }
                        break;

                    case 'activity':
                        if(time_entry.activity_id != old_value && time_entry.hours != '')
                            $scope.sendSave(time_entry, day, old_value, field, old_day_values);
                        break;

                    case 'comment':
                        if(time_entry.comment != old_value && time_entry.hours != '') {
                            $scope.sendSave(time_entry, day, old_value, field, old_day_values);
                        }
                        break;

                    default:
                        break;
                }
            };

            $scope.sendSave = function(time_entry, day, old_value, field, old_day_values, old_te_values) {
                var json_data = { "data": {
                    "id": time_entry.time_id,
                    "issue_id": time_entry.issue_id,
                    "hours": time_entry.hours,
                    "comment": time_entry.comment,
                    "activity": time_entry.activity_id,
                    "new": time_entry.new,
                    "date": time_entry.date
                    }
                };

                var answer = TimeEntry.save.send(json_data,
                    function(data) {
                        $scope.saved = true;
                        time_entry.time_id = data.id;
                        if(time_entry.hours == "" || time_entry.hours == "00:00") {
                            time_entry.new = true;
                        } else {
                            time_entry.new = false;
                        }
                        if(typeof day != "undefined" && !$scope.alt_workimes && field == 'hours') {
                            if(day.begin_end_times[0].id == 0) {
                                $scope.saveSingleWorktime(day, "begin", old_day_values[0], old_day_values[1], old_day_values[2]);
                            } else {
                                $scope.saveSingleWorktime(day, "end", old_day_values[0], old_day_values[1], old_day_values[2]);
                            }
                        }
                    },
                    function (data) {
                        alert("Error while saving. Please try again!");
                        $scope.saved = false;

                        switch(field) {
                            case 'hours':
                                time_entry.hours = old_value;
                                time_entry.activity_id = old_te_values[0];
                                time_entry.comment = old_te_values[1];
                                day.project_hours = old_day_values[3];
                                break;

                            case 'activity':
                                time_entry.activity_id = old_value;
                                break;

                            case 'comment':
                                time_entry.comment = old_value;
                                break;

                            default:
                                break;
                        }

                        if($scope.alt_worktimes) {
                            $scope.calculateMultipleActualHours(day);
                        } else {
                            day.begin_end_times[0].begin = old_day_values[0];
                            day.begin_end_times[day.begin_end_times.length-1].end = old_day_values[1];
                            day.break = old_day_values[2];
                            $scope.calculateSingleActualHours(day);
                        }
                    });
            };

            $scope.jumpToDate = function () {

                var date    = $(".week-picker").val();
                var year    = date.split("-")[0];
                var week    = $.datepicker.iso8601Week(new Date(date));

                if (week == 1 && date.split("-")[2] >= 29) {
                    year = parseInt(year) + 1;
                }
                var day     = $(".week-picker").datepicker('getDate').getUTCDay() + 1;

                if($scope.weekview) {
                    $scope.loadData(year, week, -1);
                } else {
                    $scope.loadData(year, week, day);
                }
            };


            $scope.createDatepickerDateFromString = function(string) {

                var date_parts = string.split("-");
                date_parts[1] = date_parts[1] - 1;

                return new Date(date_parts[2], date_parts[1], date_parts[0]);
            };

            // iso8601 states that week 1 of new year contains the 1st thursday of the new year
            $scope.goForward = function(date, day) {
                if($scope.weekview && typeof date != 'undefined') {
                    var next_year = $filter('date')(date, 'yyyy');
                    var next_week = $.datepicker.iso8601Week(new Date(date));

                    if(next_week == 1 && date.split("-")[2] >= 29) {
                        next_year = parseInt(next_year) + 1;
                    }

                    $scope.loadData(next_year, next_week, -1);
                } else if (!$scope.weekview && typeof date != 'undefined') {
                    var next_year = $filter('date')(date, 'yyyy');
                    var next_week = $.datepicker.iso8601Week(new Date(date));
                    var next_day = day + 1;

                    if(next_day > 7) {
                        next_day  = 1;
                    }

                    if(next_week >= 52 && date.split("-")[2] <= 6) {
                        next_year =  parseInt(next_year) - 1;
                    }

                    $scope.loadData(next_year, next_week, next_day);
                }
            };

            // iso8601 states that week 1 of new year contains the 1st thursday of the new year
            $scope.goBack = function(date, day) {
                if(is_weekview && typeof date != 'undefined') {
                    var prev_year = $filter('date')(date, 'yyyy');
                    var prev_week = $.datepicker.iso8601Week(new Date(date));

                    if(prev_week == 1 && date.split("-")[2] >= 29) {
                        prev_year = parseInt(prev_year) + 1;
                    }
                    //nextWeek = +$filter('date')(new Date(date.getFullYear(), date.getMonth(), date.getDate()), 'ww', 'UTC')
                    $scope.loadData(prev_year, prev_week, -1);
                } else if (!$scope.weekview && typeof date != 'undefined') {
                    var prev_year = $filter('date')(date, 'yyyy');
                    var prev_week = $.datepicker.iso8601Week(new Date(date));
                    var prev_day = day - 1;

                    if(prev_day == 0) {
                        prev_day = 7;
                    }

                    if(prev_week == 1 && date.split("-")[2] >= 29) {
                        prev_year =  parseInt(prev_year) + 1;
                    }

                    $scope.loadData(prev_year, prev_week, prev_day);
                }
            };

            // week/day navigation with left/right arrow keys
            $document.bind("keydown", function(event) {
                if(event.which === 37 && !$scope.focused) {
                    $scope.goBack($scope.misc_data.day_prev, $scope.misc_data.day);
                } else if(event.which === 39 && !$scope.focused) {
                    $scope.goForward($scope.misc_data.day_next, $scope.misc_data.day)
                }
            });

            $scope.getDateFromDateString = function(day) {
                var parts = day.split('-');
                // Note: months are 0-based
                return new Date(parts[2], parts[1]-1, parts[0]);  
            };

            $scope.isWeekend = function(day) {

                var date_to_check = $scope.getDateFromDateString(day);

                if(date_to_check.getDay() == 0 || date_to_check.getDay() == 6) {
                    return true;
                }
                return false;
            };

            $scope.isActualDay = function(day) {
                
                var actualDay = new Date();
                var date_to_check = $scope.getDateFromDateString(day);


                if(actualDay.getMonth() == date_to_check.getMonth() && 
                    actualDay.getFullYear() == date_to_check.getFullYear() &&
                    actualDay.getDate() == date_to_check.getDate()) {
                    return true;
                }
                return false;
            };

            $scope.getCSSClass = function(day) {
                var isActualDay = $scope.isActualDay(day.date);
                var isWeekend = $scope.isWeekend(day.date);

                if(isActualDay) {
                    return 'wd-title-actual';
                }

                if(isWeekend || day.holiday_name != "") {
                    return 'wd-title-we';
                }

                return 'wd-title';

            };

            $scope.setDisabled = function(id, begin) {
                var parts = id.split('_');
                var day_id = parts[0];
                var time_id = parts[1];
                var begin_time = begin;
                if(begin_time == "") {
                    if(time_id == 'end' || time_id == 'break') {
                        return true;
                    }
                }

                // absence time field
                if (parts.length == 3) {
                    var absence_reason = angular.element($("#" + day_id + "_" + time_id + "_reason")).val();

                    if(absence_reason == "") {
                        return true;
                    }
                }

                return false;
            };

            $scope.setBeginEndTime = function(day, type) {
                if ($scope.alt_worktimes) {
                    return;
                }

                if (type == "begin") {
                    if (day.begin_end_times[0].begin == "") {

                        var default_begin = $scope.toSeconds(default_work_start);
                        var default_break = $scope.toSeconds(default_break_duration);

                        var end_time = default_break + default_begin;
                        if(end_time > 86340) {
                            end_time = 86340;
                        }
                        day.begin_end_times[0].begin = default_work_start;
                        // hacky wacky $timeout to propagate changes of model (end, break) to view
                        $timeout(function() {
                            day.break = default_break_duration;
                            day.begin_end_times[day.begin_end_times.length-1].end = $scope.toTime(end_time);
                        });
                    }
                }
            };

            $scope.validateBeginEndTimes = function (day, type, index) {

                if(type == "end") {
                    var s_begin = $scope.toSeconds(day.begin_end_times[index].begin);
                    var s_end = $scope.toSeconds(day.begin_end_times[day.begin_end_times.length-1].end);
                    var s_break = $scope.toSeconds(day.break);

                    if (s_begin > s_end) {
                        return true;
                    } else if (s_end - s_begin - s_break < 0 && !$scope.alt_worktimes) {
                        return true;
                    }
                } else if (type == "break" && day.break == "" && (day.begin_end_times[index].begin != "" || day.begin_end_times[day.begin_end_times.length-1].end != "")) {
                    return true
                }
                return false;
            };

            $scope.validateMultipleBeginEndTimes = function (day, type, index) {

                var s_begin_validate = $scope.toSeconds(day.begin_end_times[index].begin);
                var s_end_validate = $scope.toSeconds(day.begin_end_times[index].end);

                for(var i = 0; i < day.begin_end_times.length; i++) {
                    if (i == index) {
                        continue;
                    }

                    var s_begin = $scope.toSeconds(day.begin_end_times[i].begin);
                    var s_end = $scope.toSeconds(day.begin_end_times[i].end);

                    if(type == "begin" && s_begin_validate >= s_begin && s_begin_validate <= s_end && s_begin_validate != "") {
                        return true;
                    } else if (type == "end" && s_end_validate >= s_begin && s_end_validate <= s_end && s_end_validate != "") {
                        return true;
                    }
                }

                return false;
            };

            // if called from a time entry ng-change it is important that project hours are calculated first!
            $scope.updateSingleEndTime = function (day, type) {
                if ($scope.alt_worktimes) {
                    return;
                }

                $timeout(function () {
                    var calculated_end_time = $scope.toSeconds(day.begin_end_times[0].begin) +
                        $scope.toSeconds(day.project_hours) +
                        $scope.toSeconds(day.break);

                    if(day.begin_end_times[0].begin != "" && type != "end"){
                        if(calculated_end_time > 86340) {
                            calculated_end_time = 86340;
                        }
                        day.begin_end_times[day.begin_end_times.length - 1].end = $scope.toTime(calculated_end_time);

                    } else if (day.begin_end_times[0].begin == "" && type == "time_entry") {
                        day.begin_end_times[0].begin = default_work_start;
                        day.break = default_break_duration;

                        calculated_end_time = $scope.toSeconds(day.begin_end_times[0].begin) +
                        $scope.toSeconds(day.project_hours) +
                        $scope.toSeconds(day.break);

                        day.begin_end_times[day.begin_end_times.length - 1].end = $scope.toTime(calculated_end_time);
                    } else if (type != "end") {
                        day.break = "";
                        day.begin_end_times[day.begin_end_times.length - 1].end = "";
                        day.begin_end_times[day.begin_end_times.length - 1].end = "";
                    }
                });
            };

            // if called from a time entry ng-change it is important that project hours are calculated first!
            $scope.updateMultipleEndTime = function (day, type) {
                if ($scope.alt_worktimes) {
                    return;
                }

                $timeout(function () {
                    var calculated_end_time = $scope.toSeconds(day.begin_end_times[0].begin) +
                                                $scope.toSeconds(day.project_hours) +
                                                $scope.toSeconds(day.break);

                    if(day.begin_end_times[0].begin != "" && type != "end"){
                        if(calculated_end_time > 86340) {
                            calculated_end_time = 86340;
                        }
                            day.begin_end_times[0].end = $scope.toTime(calculated_end_time);

                    } else if (day.begin_end_times[0].begin == "" && type == "time_entry") {
                        day.begin_end_times[0].begin = default_work_start;
                        day.break = default_break_duration;

                        calculated_end_time = $scope.toSeconds(day.begin_end_times[0].begin) +
                            $scope.toSeconds(day.project_hours) +
                            $scope.toSeconds(day.break);

                        day.begin_end_times[0].end = $scope.toTime(calculated_end_time);
                    } else if (type != "end") {
                            day.break = "";
                            day.begin_end_times[0].end = "";
                    }
                });
            };

            $scope.calculateSingleActualHours = function(day) {
                $timeout(function () {
                    var old_actual = $scope.toSeconds(day.actual_hours);
                    var absence_time = day.absence_time;

                    if(day.absence_reason == 5) {
                        absence_time = "00:00";
                    }

                    var worktimes = day.begin_end_times;

                    var actual = $scope.time_difference($scope.time_difference(worktimes[worktimes.length-1].end, worktimes[0].begin), day.break);
                    day.actual_hours = $scope.time_addition(actual, absence_time);

                    var diff = $scope.toSeconds(day.actual_hours) - old_actual;
                    $scope.sums.actual = $scope.toTime($scope.toSeconds($scope.sums.actual) + diff);

                    if ($scope.toSeconds(day.project_hours) > $scope.toSeconds($scope.time_difference(day.actual_hours, absence_time))) {
                        day.project_warning = false;
                        day.actual_warning = true;
                    } else if ($scope.toSeconds(day.project_hours) < $scope.toSeconds($scope.time_difference(day.actual_hours, absence_time))) {
                        day.actual_warning = false;
                        day.project_warning = true;
                    } else {
                        day.project_warning = false;
                        day.actual_warning = false;
                    }
                });
            };

            $scope.calculateMultipleActualHours = function(day) {
                    $timeout(function () {
                        var old_actual = $scope.toSeconds(day.actual_hours);
                        var absence_time = day.absence_time;

                        if(day.absence_reason == 5) {
                            absence_time = "00:00";
                        }
                        // TODO compute actual hours of all begin/ends!!!

                        var actual = "00:00";
                        var worktimes = day.begin_end_times;

                        for(var i = 0; i < worktimes.length; i++) {
                                actual = $scope.time_addition(actual, $scope.time_difference(worktimes[i].end, worktimes[i].begin));
                        }

                        day.actual_hours = $scope.time_addition(actual, absence_time);

                        var diff = $scope.toSeconds(day.actual_hours) - old_actual;
                        $scope.sums.actual = $scope.toTime($scope.toSeconds($scope.sums.actual) + diff);

                        if ($scope.toSeconds(day.project_hours) > $scope.toSeconds($scope.time_difference(day.actual_hours, absence_time))) {
                            day.project_warning = false;
                            day.actual_warning = true;
                        } else if ($scope.toSeconds(day.project_hours) < $scope.toSeconds($scope.time_difference(day.actual_hours, absence_time))) {
                            day.actual_warning = false;
                            day.project_warning = true;
                        } else {
                            day.project_warning = false;
                            day.actual_warning = false;
                        }
                    });
            };

            // if called from a time entry: ng-change it is important that project hours are calculated first!
            $scope.calcProjectHours = function(new_value, day, old_value) {
                $timeout(function() {
                    var diff = $scope.toSeconds(new_value) - $scope.toSeconds(old_value);
                    day.project_hours = $scope.toTime($scope.toSeconds(day.project_hours) + diff);
                    $scope.sums.project = $scope.toTime($scope.toSeconds($scope.sums.project) + diff);

                    if($scope.toSeconds(day.project_hours) > $scope.toSeconds($scope.time_difference(day.actual_hours, day.absence_time))) {
                        day.project_warning = false;
                        day.actual_warning = true;
                    } else if ($scope.toSeconds(day.project_hours) < $scope.toSeconds($scope.time_difference(day.actual_hours, day.absence_time))) {
                        day.actual_warning = false;
                        day.project_warning = true;
                    } else {
                        day.project_warning = false;
                        day.actual_warning = false;
                    }
                });
            };

            $scope.calcDifference = function(day) {
                $timeout(function (){
                    var old_value = $scope.toSeconds(day.time_difference);
                    day.time_difference = $scope.toTime($scope.toSeconds(day.actual_hours) - $scope.toSeconds(day.target));
                    var diff = $scope.toSeconds(day.time_difference) - old_value;
                    $scope.sums.difference = $scope.toTime($scope.toSeconds($scope.sums.difference) + diff);
                });
            };



            $scope.setAbsenceTime = function (day, day_id) {
                var worked = angular.element($("#" + day_id + "_zz5_project_time")).html();
                worked = $scope.toSeconds(worked);
                var target = angular.element($("#" + day_id + "_zz5_target_time")).html();
                target = $scope.toSeconds(target);
                var absence_time = target - worked;

                if(absence_time < 0 ) {
                    day.absence_time = "00:00"
                } else {
                    day.absence_time = $scope.toTime(absence_time);
                }


            };

            $scope.checkAbsenceTime = function (day) {

                $timeout(function () {
                var absence_reason = day.absence_reason;
                var worked = day.project_hours;
                var absence = day.absence_time;
                var target = day.target;
                var result = $scope.toSeconds(target) - $scope.toSeconds(worked) - $scope.toSeconds(absence);

                if (absence_reason == "" && absence == 0) {
                    day.absence_warning = false;
                    return;
                }

                if (absence_reason != "4" || (absence_reason == "4" && absence > target))
                {
                    if(result < 0 || absence < 0) {
                        day.absence_warning = true;
                        return;
                    } else {
                        day.absence_warning = false;
                        return;
                    }
                }

                day.absence_warning = false;
                return;
                });
            };

            $scope.checkModified = function(old_value, new_value) {
                if(old_value != new_value) {
                    return true;
                } else {
                    return false;
                }
            };

            $scope.checkBeginTime = function(row) {
                if(row.begin == "") {
                    row.begin = row.end;
                } else if ($scope.toSeconds(row.end) - $scope.toSeconds(row.begin) < 0 && row.end != "") {
                    row.begin = row.end;
                }
            };

            $scope.checkEndTime = function(row) {
                if(row.end == "") {
                    row.end = row.begin;
                } else if ($scope.toSeconds(row.end) - $scope.toSeconds(row.begin) < 0) {
                    row.end = row.begin;
                } else if (row.begin == "") {
                    row.end = "";
                }
            };

            $scope.checkWorkedHours = function(row) {
                row.worked = $scope.time_difference(row.end, row.begin);
            };

            $scope.clearAbsenceType = function(day) {
                if(day.absence_time == "") {
                    day.absence_reason = "";
                    day.absence_warning = false;
                }
            };

            $scope.validProjectHours = function(day) {
                var day_entries = angular.element($(":input[data-times-id^='" + day.id + "']"));
                var sum = 0;
                day_entries.each(function(idx) {
                    sum += $scope.toSeconds($(this).val());
                });

                if (sum > 86340) {
                    return true;
                }

                var begin = day.begin;
                var end = day.end;
                var break_time = day.break;

                var result = "00:00";
                if (begin != "" && end != "" && break_time != "") {
                    result = $scope.time_difference(break_time, $scope.time_difference(end, begin));
                }

                if($scope.toSeconds(result) != sum) {
                    return true;
                }

                return false;
            };

            $scope.validActualHours = function (day) {
                var begin = day.begin;
                var end = day.end;
                var break_time = day.break;
                var absence = day.absence_time;

                var result = "00:00";
                if (begin != "" && end != "" && break_time != "") {
                    result = $scope.time_difference(break_time, $scope.time_difference(end, begin));
                }

                if(absence != "") {
                    result = $scope.time_addition(result, absence);
                }

                // 86340sec == 23h59m
                if ($scope.toSeconds(result) > 86340)  {
                    return true;
                }

                return false;
            };

            $scope.time_difference = function (a, b) {
                var difference = Math.abs($scope.toSeconds(a) - $scope.toSeconds(b));

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
            };

            // Calculates the time difference (a - b)
            // Example: 08:00 + 02:00 = 10:00
            $scope.time_addition = function (a, b) {
                var difference = Math.abs($scope.toSeconds(a) + $scope.toSeconds(b));

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
            };

            // Calculates and sets the difference hours of the given day element.
            // The difference is the target working hours minus the actual working hours.
            //
            // @day: the day for which the difference hours shall be set (monday, tuesday, ...)
            $scope.setDifferenceHours = function (day) {
                var s_actual_time = angular.element($("#" + day + "_zz5_actual_time")).html();
                var s_target_time = angular.element($("#" + day + "_zz5_target_time")).html();
                var result = "--:--";

                if (s_target_time != "" && s_actual_time != "") {
                    if ($scope.toSeconds(s_actual_time) - $scope.toSeconds(s_target_time) >= 0) {
                        result = $scope.time_difference(s_actual_time, s_target_time);
                    } else {
                        result = "-" + $scope.time_difference(s_actual_time, s_target_time);
                    }
                }
                return result;
            };

            // Returns the seconds of a time string "HH:MM" as number or "-HH:MM".
            $scope.toSeconds = function (time) {
                if(typeof time === "undefined") {
                    return 0;
                }

                time = time.toString();
                var time_str = time;
                var appendMinus = false;

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
            };

            $scope.toTime = function (seconds) {
                var sec = seconds;
                var appendMinus = false;

                if (seconds < 0) {
                    sec = -1 * seconds;
                    appendMinus = true;
                }

                var result = [
                    Math.floor(sec / 3600), // an hour has 3600 seconds
                    Math.floor((sec % 3600) / 60) // a minute has 60 seconds
                ];

                // 0 padding and concatation
                result = result.map(function(v) {
                    return v < 10 ? '0' + v : v;
                }).join(':');

                if (appendMinus) {
                    return "-" + result;
                }

                return result;
            };


            $scope.loadActivities = function(activity_arr) {
                $scope.activity_array = activity_arr;
            };

            $scope.getActivityname = function(id) {
                for(var i = 0; i < $scope.activity_array.length; i++) {
                    if($scope.activity_array[i].id == id) {
                        return $scope.activity_array[i].value;
                    }
                }
                return "";
            };

            $scope.checkActivityID = function(hours, id) {
                if(hours != "" && id == "-1") {
                    return default_activity_id;
                }
                else if(hours == "") {
                    return "-1";
                }
                return id;
            };

            $scope.hasFocus = function() {
                $scope.focused = true;
            };

            $scope.lostFocus = function() {
                $scope.focused = false;
            };

            $scope.openTicketPopup = function(time_entries, issue, day) {
                $scope.showPopup = true;
                var new_scope = $scope.$new();
                new_scope.time_entries = time_entries;
                new_scope.issue = issue;
                new_scope.day = day;

                var new_dialog = ngDialog.open({
                    template: 'ticketPopup',
                    scope: new_scope,  className: 'ticket-popup ngdialog-theme-default'
                });
            };

            $scope.openAbsencePopup = function() {
                $scope.showPopup = true;

                var new_dialog = ngDialog.open({
                    template: 'absencePopup',
                    scope: $scope,
                    className: 'absence-popup ngdialog-theme-default'
                });
            };

            $scope.addTimeEntry = function(time_entries_for_day) {
                var te_day_id = time_entries_for_day[0].day_id;
                var te_issue_id = time_entries_for_day[0].issue_id;
                var te_date = time_entries_for_day[0].date;
                time_entries_for_day.push({time_id: te_day_id, hours: '', activity_id: '-1', comment: '', issue_id: te_issue_id, new: true, date: te_date});
            };

            $scope.removeTimeEntry = function(time_entries_for_day, index) {

                var json_data = { "id": time_entries_for_day[index].time_id
                };

                $scope.time = TimeEntry.delete.send(json_data,
                    function(data) {
                        $scope.saved = true;
                    }, function(data) {
                        $scope.saved = false;
                    });

                time_entries_for_day.splice(index, 1);
            };

            $scope.initTicketSearch = function () {
                $('#ticket-search-box').tokenInput('/zz5/tickets.json', 
                                                    {crossDomain: false,
                                                     preventDuplicates: true,
                                                     tokenFormatter: function(item) 
                                                         { return "<li><p title='" + item[this.propertyToSearch] + "'>" + item[this.propertyToSearch].substring(0, 12) + "...</p></li>" },
                                                     hintText: hint_text,
                                                     noResultsText: no_results_text,
                                                     searchingText: searching_text,
                                                     tokenLimit: 3,
                                                     minChars: 2,
                                                     onDelete: function () {
                                                            if (angular.element($('#ticket-search-box')).tokenInput("get").length == 0) {
                                                                $scope.displayTicketAddButton(false);
                                                            }
                                                        }, 
                                                     onAdd: function () {
                                                            $scope.displayTicketAddButton(true);
                                                        }
                                                     });
            };

            $scope.displayTicketAddButton = function (display) {
                if(display) {
                    angular.element($(".submit-button")).attr("style", "visibility:visible");
                } else {
                    angular.element($(".submit-button")).attr("style", "visibility:hidden");
                }
            };

            $scope.addTicketsToFavorites = function() {
                var tickets = angular.element($('#ticket-search-box')).tokenInput("get");
                var no_of_days = $scope.days.length;
                var existing_tickets = [];
                var time_entries = "";

                for(var i = 0; i < tickets.length; i++) {

                    var issue_id = tickets[i].id;
                    var present_element = angular.element($("#favorite-issue-" + issue_id));
                    if(present_element.length != 0) {
                        existing_tickets.push(tickets[i]);
                        continue;
                    }

                    var full_name = tickets[i].name.substr(tickets[i].name.indexOf(" ") + 1);
                    var full_name_parts = full_name.split(":");
                    var ticket_name = full_name_parts[1];

                    // !hacky-wacky!
                    // in case length == 3 we just assume a ":" is present in the ticket's name
                    if (full_name_parts.length >= 3) {
                        for(var i = 2; i < full_name_parts.length; i++) {
                            ticket_name += ": " + full_name_parts[i];
                        }
                    }
                    ticket_name = ticket_name.replace(/\\\(/g, '(');
                    ticket_name = ticket_name.replace(/\\\)/g, ')');
                    ticket_name = ticket_name.replace(/\\plus/g, '+');
                    ticket_name = ticket_name.replace(/\\q_mark/g, '?');
                    ticket_name = ticket_name.replace(/\\asterisk/g, '*');

                    var project_names = full_name_parts[0];

                    /*if (typeof $scope.issues[0] != "undefined") {
                        no_of_days = $scope.issues[0].time_entries.length;
                    }*/

                    time_entries = new Array();
                    for(var j = 0; j < no_of_days; j++) {
                        var day = $scope.days[j].name; // WHERE FROM?!?!?!?
                        var date = $scope.days[j].date;

                        var bb = new Array();

                        bb.push({time_id: j, hours: "", activity_id: "-1", comment: "", issue_id: issue_id, new: true, date: date});

                        //time_entries_for_day.push({time_id: te_day_id, hours: '', activity_id: '-1', comment: '', issue_id: te_issue_id, new: true, date: te_date});
                        time_entries.push({id: j, day: day, bb: bb});
                    }

                    var issue = {issue_id: issue_id, issue_subject: ticket_name, project_name: project_names, time_entries: time_entries};

                    $scope.removeTicket(issue, false);
                    //check if ticket has existing time entries on server for relevant time frame and load the respective data
                    $scope.loadTicket(issue, $scope.days[0].date, $scope.days[$scope.days.length-1].date);
                    $scope.issues.unshift(issue);
                }

                angular.element($('#ticket-search-box')).tokenInput("clear");
                angular.element($('.token-input-dropdown')).hide();

                // handle display of duplicate tickets notification
                // and add duplicate tickets to the top of the list
                var string = "";
                var dupe_issues = [];
                for (var k = 0; k < existing_tickets.length; k++) {
                    var found_idx = $filter('getById')($scope.issues, existing_tickets[k].id);
                    if (found_idx != -1) {
                         dupe_issues.push($scope.issues[found_idx]);
                        $scope.issues.splice(found_idx, 1);
                    };

                    string += "#" + existing_tickets[k].id;

                    if (k != existing_tickets.length - 1) {
                        string += ", "
                    }
                }

                $timeout(function() {
                    for(var j = 0; j < dupe_issues.length; j++) {
                        var dupe_issue = dupe_issues[j];
                        $scope.issues.unshift(dupe_issue);
                    }
                }, 1000);

                $scope.duplicate_tickets = string;

                if (string != "") {
                    $timeout(function () {
                        $scope.showTicketWarning = true;
                    },1000);
                };

                $timeout(function () {
                        $scope.showTicketWarning = false;
                },6000);
            };

            $scope.calculateWeekTimes = function (index, message) {
                if(index == "zz5_time_difference")
                {
                    return $scope.calculateWeekDifference(index, message);
                }
                var selector = angular.element($("#week_" + index));
                var week_sum = 0;
                for (var i = 0; i < 7; i++) {
                    var value = angular.element($("#" + i + "_" + index)).html();
                    week_sum += $scope.toSeconds(value);
                }
                selector.attr("title", message);
                week_sum = $scope.toTime(week_sum);
                return week_sum;
            };

            $scope.calculateWeekDifference = function(index, message) {
                var selector = angular.element($("#week_" + index));
                var target = angular.element($("#week_zz5_target_time")).html();
                var actual = angular.element($("#week_zz5_actual_time")).html();
                var week_diff = $scope.toSeconds(actual) - $scope.toSeconds(target);
                selector.attr("title", message);
                return $scope.toTime(week_diff);
            };

            $scope.addToSearchBox = function (issue_id, issue_subject, project_name) {
                var name = issue_id + ": " + project_name + ": "  + issue_subject;
                $('#ticket-search-box').tokenInput("add", {id: issue_id, name: name});
            };

            $scope.openTree = function () {
                var new_dialog = ngDialog.open({
                    template: 'projectTree',
                    scope: $scope, className: 'project-tree ngdialog-theme-default'
                });
            };

            $scope.saveLongAbsences = function(id, from, to) {
                if(id != "" && from != "" && to != "") {
                    var json_data = {
                        "id": id,
                        "from": from,
                        "to": to
                    };

                    var answer = AbsenceBlock.save(json_data,
                        function() {
                            $scope.loadData(data.year, data.week, data.day);
                        });
                }
            };

            $scope.setFromDate = function () {

                var from_parts = $("#from-picker").val().split("-");
                var to_parts = $("#to-picker").val().split("-");

                var from = new Date(from_parts[2], (from_parts[1] - 1), from_parts[0]);
                var to = new Date(to_parts[2], (to_parts[1] - 1), to_parts[0]);

                if(from > to) {
                    $timeout(function () {
                        $scope.absences.to_date = $("#from-picker").val();
                    });
                }

                $scope.absences.from_date = $("#from-picker").val();
            };

            $scope.setToDate = function () {

                var from_parts = $("#from-picker").val().split("-");
                var to_parts = $("#to-picker").val().split("-");

                var from = new Date(from_parts[2], (from_parts[1] - 1), from_parts[0]);
                var to = new Date(to_parts[2], (to_parts[1] - 1), to_parts[0]);

                if(from > to) {
                    $timeout(function () {
                        $scope.absences.from_date = $("#to-picker").val();
                    });
                }

                $scope.absences.to_date = $("#to-picker").val();
            };

            $scope.handlePinnedTicket = function (issue)  {
                var json_data = { "data": {
                    "issue_id": issue.issue_id,
                    "pinned": !issue.pinned
                    }
                };

                var answer = Issue.pin.send(json_data,
                    function(data) {
                        $scope.saved = true;
                        issue.pinned = !issue.pinned;
                    },
                    function (data) {
                        alert("Error while saving. Please try again!");
                        $scope.saved = false;
                    });
            };

            $scope.removeTicket = function (issue, remove)  {

                var json_data = { "data": {
                    "issue_id": issue.issue_id,
                    "remove": remove
                    }
                };

                var answer = Issue.remove.send(json_data,
                    function(data) {
                        $scope.saved = true;

                        if (remove) {
                            var index = $scope.issues.indexOf(issue);
                            $scope.issues.splice(index, 1);
                        }
                    },
                    function (data) {
                        alert("Error while saving. Please try again!");
                        $scope.saved = false;
                    });
            };

            $scope.loadTicket = function(issue, begin_date, end_date) {
                //console.log("loadIssue, issue: " + issue.issue_id);

                var json_data = { "data": {
                    "issue_id": issue.issue_id,
                    "begin_date": begin_date,
                    "end_date": end_date
                    }
                };

                var answer = Issue.load.send(json_data,
                    function(data) {
                        if(issue.time_entries == "") {
                            var time_entries = new Array();

                            for(var j = 0; j < data.time_entries.length; j++) {
                                var bb = new Array();
                                bb.push({time_id: j, hours: "", activity_id: "-1", comment: "", issue_id: "", new: true, date: ""});

                                //time_entries_for_day.push({time_id: te_day_id, hours: '', activity_id: '-1', comment: '', issue_id: te_issue_id, new: true, date: te_date});
                                time_entries.push({id: j, day: "", bb: bb});
                            }

                            issue = {issue_id: "", issue_subject: "", project_name: "", time_entries: time_entries};
                        }

                        for(var i = 0; i < data.time_entries.length; i++) {
                            issue.time_entries[i].bb[0].time_id = data.time_entries[i].bb[0].time_id;
                            issue.time_entries[i].bb[0].hours = data.time_entries[i].bb[0].hours;
                            issue.time_entries[i].bb[0].activity_id = data.time_entries[i].bb[0].activity_id;
                            issue.time_entries[i].bb[0].comment = data.time_entries[i].bb[0].comment;
                            issue.time_entries[i].bb[0].issue_id = data.time_entries[i].bb[0].issue_id;
                            issue.time_entries[i].bb[0].new = data.time_entries[i].bb[0].new;
                            issue.time_entries[i].bb[0].date = data.time_entries[i].bb[0].date;

                            for(var j = 1; j < data.time_entries[i].bb.length; j++) {
                                issue.time_entries[i].bb.push({time_id: data.time_entries[i].bb[j].time_id,
                                    hours: data.time_entries[i].bb[j].hours, activity_id: data.time_entries[i].bb[j].activity_id,
                                    comment: data.time_entries[i].bb[j].comment, issue_id: data.time_entries[i].bb[j].issue_id,
                                    new: data.time_entries[i].bb[j].new, date: data.time_entries[i].bb[j].date});
                            }
                        }

                        issue.tracker = data.tracker;
                    },
                    function (data) {
                        alert("Error while saving. Please try again!");

                    });
            };

            $scope.loading_init = true;
            $scope.init(data);
        }
    ]);



var zz5Services = angular.module('zz5Services', ['ngResource']);

    zz5Services.factory('Data', ['$resource', '$http', '$log', function($resource){
        return $resource('/zz5/load_data', {}, {
            query: {method:'POST', params:{}, isArray:false,
                withCredentials:true,
                headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
        });
    }]);

    zz5Services.factory('Day', ['$resource', '$http', '$log', function($resource){
        return {    save_single_worktime: $resource('/zz5/save_single_worktime', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                            withCredentials:true, ignoreLoadingBar: true,
                            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                     }),
                    save_multiple_worktime: $resource('/zz5/save_multiple_worktime', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                            withCredentials:true, ignoreLoadingBar: true,
                            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                    }),
                    delete_worktime: $resource('/zz5/delete_worktime', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                            withCredentials:true, ignoreLoadingBar: true,
                            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                    }),
                    save_absence: $resource('/zz5/save_absence', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                            withCredentials:true, ignoreLoadingBar: true,
                            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                    })
        };
    }]);

    zz5Services.factory('TimeEntry', ['$resource', '$http', '$log', function($resource){
        return {    save: $resource('/zz5/save_te', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                                withCredentials:true, ignoreLoadingBar: true,
                                headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                        }),
                    delete: $resource('/zz5/delete_te', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                            withCredentials:true, ignoreLoadingBar: true,
                            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                    })
        };
    }]);

    zz5Services.factory('Project', ['$resource', '$http', '$log', function($resource){
        return $resource('/zz5/zz5projects', {}, {
            query: {method:'POST', params:{}, isArray:false,
            withCredentials:true,
            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
        });
    }]);

    zz5Services.factory('AbsenceBlock', ['$resource', '$http', '$log', function($resource){
        return $resource('/zz5/saveblock', {}, {
            save: {method:'POST', params:{}, isArray:false,
                withCredentials:true,
                headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
        });
    }]);

    zz5Services.factory('Issue', ['$resource', '$http', '$log', function($resource){
        return {    pin: $resource('/zz5/pin_issue', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                            withCredentials:true, ignoreLoadingBar: true,
                            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                    }),
                    remove: $resource('/zz5/remove_issue', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                            withCredentials:true, ignoreLoadingBar: true,
                            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                    }),
                    load: $resource('/zz5/load_issue', {}, {
                        send: { method:'POST', params:{}, isArray:false,
                            withCredentials:true, ignoreLoadingBar: true,
                            headers:{'Content-Type': 'application/json; charset=utf-8', 'X-CSRF-Token': window.csrfToken, 'X-Requested-With': 'XMLHttpRequest'}}
                    })
        };
    }]);
