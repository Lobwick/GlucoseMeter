using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;

class GlucoseMeterView extends Ui.SimpleDataField {

    // Set the label of the data field here.
    function initialize() {
     	SimpleDataField.initialize();
        label = "Nightscout";

        //read last values from the Object Store
        var temp=App.getApp().getProperty(OSDATA);
        if(temp!=null) {bgdata=temp;}
        
        var now=Sys.getClockTime();
        var ts=now.hour+":"+now.min.format("%02d");
        Sys.println("From OS: data="+bgdata+" elapsedMinutesMin="+elapsedMinutesMin+" at "+ts);        
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
       // See Activity.Info in the documentation for available information.
        var myStr = "Implementation error";
        
        if (!canDoBG) {
            myStr = "Device unsupported ";
        } /*else if (setupReqd) {
            myStr = "Setup required ";
        }*/ else if (!cgmSynced) {
            myStr = "sync"+syncCounter+" ";
        } else {
            if ((bgdata != null) &&
                bgdata.hasKey("rawbg")) {
                myStr = bgdata["rawbg"] + " ";
            } else {
                myStr = "";
            }
        }

        if ((bgdata != null) &&
            bgdata.hasKey("bg")) {
            myStr = myStr + bgdata["bg"];
        }

        if ((bgdata != null) &&
            bgdata.hasKey("elapsedMills")) {
            var elapsedMills = bgdata["elapsedMills"];
            var myMoment = new Time.Moment(elapsedMills / 1000);
            var elapsedMinutes = Math.floor(Time.now().subtract(myMoment).value() / 60);
            var elapsed = elapsedMinutes.format("%d") + "m";
            if ((elapsedMinutes > 9999) || (elapsedMinutes < -999)) {
                elapsed = "";
            }
    
            myStr = myStr + " " + elapsed;
        }

        if ((bgdata != null) &&
            bgdata.hasKey("direction") &&
            bgdata.hasKey("delta")) {
            myStr = myStr + " " + bgdata["delta"] + " " + bgdata["direction"];
        }

        return myStr;
    }

}