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

  public static function getPrimaryColor(id as Number) as Number {
    var color = Graphics.COLOR_LT_GRAY;
    switch (id) {
      case 0:
        // gray
        color = 0xAAAAAA;
        break;
      case 1:
        // green
        color = 0xAAFF00;
        break;
      case 2:
        // blue
        color = 0x0055FF;
        break;
      case 3:
        // orange
        color = 0xFFAA00;
        break;
      case 4:
        // emerald
        color = 0x00ffaa;
        break;
      case 5:
        // washed out green
        color = 0x005555;
        break;
      case 6:
        // pink
        color = 0xff55aa;
        break;
    }

    return color;
  }

 public static function getSecondaryColor(id as Number) as Number {
    var color = Graphics.COLOR_LT_GRAY;
    switch (id) {
      case 0:
        // gray
        color = 0x555555;
        break;
      case 1:
        // green
        color = 0x005500;
        break;
      case 2:
        // blue
        color = 0x0000AA;
        break;
      case 3:
        // orange
        color = 0xAA5500;
        break;
      case 4:
        // emerald
        color = 0x005555;
        break;
      case 5:
        // washed out green
        color = 0x555555;
        break;
      case 6:
        // pink
        color = 0xFFAAAA;
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
