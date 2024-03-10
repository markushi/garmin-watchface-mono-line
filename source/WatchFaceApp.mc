import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class WatchFaceApp extends Application.AppBase {
  public function initialize() {
    AppBase.initialize();
  }

  public function onStart(state as Dictionary?) as Void {}

  public function onStop(state as Dictionary?) as Void {}

  public function getInitialView() {
    return [new $.WatchFaceView()];
  }
}
