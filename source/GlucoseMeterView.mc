using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;
using Toybox.FitContributor as Fit;

class GlucoseMeterView extends Ui.DataField {
    var glucoseField = null;
    const GLUCOSE_METER_FIELD_ID = 2;
	var label;
	var array = new [189];
	var curPos = 0;
	var HRmin = 0;
	var HRmax = 120;

    // Set the label of the data field here.
    function initialize() {
     	DataField.initialize();
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
    	
    	
    	for (var i = 0; i < array.size(); ++i) {
            array[i] = 0;
        }
        curPos = 0;
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
    
    function drawGraph(dc, array){
    	var ii;
    	var scaling;
    	for (var i = 0; i < array.size() && array[i] > 0; ++i) {
    		Sys.println("array["+i+"]="+array[i]);
        	ii = curPos-1-i;
        	if(ii < 0) {
        		ii = ii + array.size();
        	}
        	if(array[ii] >=0) {
				//dc.setColor(arrayColours[arrayHRZone[ii]], Gfx.COLOR_TRANSPARENT);
				scaling = (array[ii] - HRmin).toFloat() / (HRmax - HRmin).toFloat();
				if(scaling > 1) {
					scaling = 1;
				} else if(scaling < 0) {
					scaling = 0;
				}
				Sys.println("print line");
				Sys.println(" i : " + i + " scaling : " + scaling);
				dc.drawLine(201-i, 140, 201-i, (140-80*scaling).toNumber());
			}
        }
    }
    
    function onUpdate(dc) {
    	Sys.println("totototototo");
    	array[0] = 120;    	
    	drawGraph(dc, array);
    }

}