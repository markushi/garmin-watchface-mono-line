import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class WatchFaceApp extends Application.AppBase {
  public static var COMPLICATIONS_COUNT = 5;

  public static var COMPLICATION_NONE = 0;
  public static var COMPLICATION_STEPS = 1;
  public static var COMPLICATION_HR = 2;
  public static var COMPLICATION_KCAL = 3;
  public static var COMPLICATION_BATT = 4;

  public static var COLORS_COUNT = 7;

  public static function getColor(id as Number) as Number {
    var color = Graphics.COLOR_LT_GRAY;
    switch (id) {
      case 0:
        color = Graphics.COLOR_LT_GRAY;
        break;
      case 1:
        color = 0x00aa00;
        break;
      case 2:
        color = 0x55aaff;
        break;
      case 3:
        color = 0xffaa55;
        break;
      case 4:
        color = 0x00ffaa;
        break;
      case 5:
        color = 0x005555;
        break;
      case 6:
        color = 0xff55aa;
        break;
    }

    return color;
  }

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
