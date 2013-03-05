$(function(){
    // create a datetimepicker with default settings
    var opt = {

            }

            opt.date = {preset : 'date'};
    opt.datetime = { preset : 'datetime', minDate: new Date(2012,3,10,9,22), maxDate: new Date(2014,7,30,15,44), stepMinute: 5  };
    opt.time = {preset : 'time'};
    $("#delivery_scroller").scroller('destroy').scroller($.extend(opt['datetime'], { theme: 'wp', mode: 'scroller', display: 'modal', lang: 'en' }));
    $("#pickup_scroller").scroller('destroy').scroller($.extend(opt['datetime'], { theme: 'wp', mode: 'scroller', display: 'modal', lang: 'en' }));
});
