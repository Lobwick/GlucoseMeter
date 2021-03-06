using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;
using Toybox.FitContributor as Fit;

class GlucoseMeterView extends Ui.SimpleDataField {
    var glucoseField = null;
    const GLUCOSE_METER_FIELD_ID = 2;

    // Set the label of the data field here.
    function initialize() {
     	SimpleDataField.initialize();
        label = "Glucose";

        //read last values from the Object Store
        var temp=App.getApp().getProperty(OSDATA);
        if(temp!=null) {bgdata=temp;}
        
        var now=Sys.getClockTime();
        var ts=now.hour+":"+now.min.format("%02d");
        Sys.println("From OS: data="+bgdata+" elapsedMinutesMin="+elapsedMinutesMin+" at "+ts);        
        
         glucoseField = createField(
            "Glucose Meter",
            GLUCOSE_METER_FIELD_ID,
            Fit.DATA_TYPE_FLOAT,
            {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"mg/dl"}
        );
        if ((bgdata != null) &&
            bgdata.hasKey("bg")) {
        	glucoseField.setData(bgdata["bg"]);
    	}
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
            //myStr = "sync"+syncCounter+" ";
        } else {
            if ((bgdata != null) &&
                bgdata.hasKey("rawbg")) {
                myStr = bgdata["rawbg"] + " ";
            } else {
                myStr = "";
            }
        }

        if (bgdata != null){
            if (bgdata.hasKey("bg")) {
                myStr = myStr + bgdata["bg"];
                glucoseField.setData(bgdata["bg"]);
            }

            if (bgdata.hasKey("elapsedMills")) {
                var elapsedMills = bgdata["elapsedMills"];
                var myMoment = new Time.Moment(elapsedMills / 1000);
                var elapsedMinutes = Math.floor(Time.now().subtract(myMoment).value() / 60);
                var elapsed = elapsedMinutes.format("%d") + "m";
                if ((elapsedMinutes > 9999) || (elapsedMinutes < -999)) {
                    elapsed = "";
                }
                myStr = myStr + " " + elapsed;
            }

            if (bgdata.hasKey("direction") &&
                bgdata.hasKey("delta")) {
                myStr = myStr + " " + bgdata["delta"] + " " + bgdata["direction"];
            }
        }
        return myStr;
    }

}