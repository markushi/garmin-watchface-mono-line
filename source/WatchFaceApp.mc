import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class WatchFaceApp extends Application.AppBase {

  public static var COMPLICATIONS_COUNT = 5;
  
  public static var COMPLICATION_NONE = 0;
  public static var COMPLICATION_STEPS = 1;
  public static var COMPLICATION_HR = 2;
  public static var COMPLICATION_KCAL = 3;
  public static var COMPLICATION_BATT = 4;

  public function initialize() {
    AppBase.initialize();
  }

  public function onStart(state as Dictionary?) as Void {}

  public function onStop(state as Dictionary?) as Void {}

  public function getInitialView() as Array<Views or InputDelegates>? {
    return [new $.WatchFaceView()] as Array<Views>;
  }

  public function getSettingsView() as Array<Views or InputDelegates>? {
    var settingsView = new $.SettingsView();
    return (
      [settingsView, new $.SettingsDelegate(settingsView)] as
      Array<Views or InputDelegates>
    );
  }
}
