import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class SettingsView extends WatchUi.View {
  public var selectedItem as Number = 0;

  public var topComplication as Number = 0;
  public var bottomComplication as Number = 0;

  private var _stepIcon =
    WatchUi.loadResource($.Rez.Drawables.id_icon_steps) as BitmapResource;
  private var _hrIcon =
    WatchUi.loadResource($.Rez.Drawables.id_icon_hr) as BitmapResource;
  private var _kcalIcon =
    WatchUi.loadResource($.Rez.Drawables.id_icon_kcal) as BitmapResource;
  private var _battIcon =
    WatchUi.loadResource($.Rez.Drawables.id_icon_batt) as BitmapResource;

  public function initialize() {
    View.initialize();

    topComplication = Storage.getValue("c.top");
    if (topComplication == null) {
      topComplication = WatchFaceApp.COMPLICATION_BATT; // batt
    }
    bottomComplication = Storage.getValue("c.bottom");
    if (bottomComplication == null) {
      bottomComplication = WatchFaceApp.COMPLICATION_STEPS; // steps
    }
  }

  public function toggle(direction as Number) {
    var id = selectedItem == 0 ? topComplication : bottomComplication;
    // prevent underflow when direction is negative
    id =
      (id + direction + WatchFaceApp.COMPLICATIONS_COUNT) %
      WatchFaceApp.COMPLICATIONS_COUNT;

    if (selectedItem == 0) {
      topComplication = id;
      Storage.setValue("c.top", topComplication);
    } else {
      bottomComplication = id;
      Storage.setValue("c.bottom", bottomComplication);
    }
  }
  public function onPrevious() {
    toggle(-1);
  }

  public function onNext() {
    toggle(1);
  }

  public function onUpdate(dc as Dc) as Void {
    dc.clearClip();
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();

    var settings = System.getDeviceSettings();
    var iconGap = settings.screenWidth / 40;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(4);

    var complicationRadius = settings.screenWidth / 8;
    var arrowSize = settings.screenWidth / 40;

    var topComplicationCenter = [
      settings.screenWidth / 2,
      complicationRadius * 2,
    ];

    var bottomComplicationCenter = [
      settings.screenWidth / 2,
      settings.screenHeight - complicationRadius * 2,
    ];

    dc.drawCircle(
      topComplicationCenter[0],
      topComplicationCenter[1],
      complicationRadius
    );

    dc.drawCircle(
      bottomComplicationCenter[0],
      bottomComplicationCenter[1],
      complicationRadius
    );

    dc.setPenWidth(3);
    if (selectedItem == 0) {
      rightArrow(
        dc,
        topComplicationCenter[0] + complicationRadius + iconGap,
        topComplicationCenter[1],
        arrowSize
      );
      leftArrow(
        dc,
        topComplicationCenter[0] - complicationRadius - iconGap,
        topComplicationCenter[1],
        arrowSize
      );
    } else if (selectedItem == 1) {
      rightArrow(
        dc,
        bottomComplicationCenter[0] + complicationRadius + iconGap,
        bottomComplicationCenter[1],
        arrowSize
      );
      leftArrow(
        dc,
        bottomComplicationCenter[0] - complicationRadius - iconGap,
        bottomComplicationCenter[1],
        arrowSize
      );
    }

    var topBitmap = getBitmapFor(topComplication) as BitmapResource?;
    centerBitmap(dc, topComplicationCenter, topBitmap);

    var bottomBitmap = getBitmapFor(bottomComplication) as BitmapResource?;
    centerBitmap(dc, bottomComplicationCenter, bottomBitmap);
  }

  private function getBitmapFor(id as Number) as BitmapResource? {
    if (id == WatchFaceApp.COMPLICATION_NONE) {
      return null;
    } else if (id == WatchFaceApp.COMPLICATION_STEPS) {
      return _stepIcon;
    } else if (id == WatchFaceApp.COMPLICATION_HR) {
      return _hrIcon;
    } else if (id == WatchFaceApp.COMPLICATION_KCAL) {
      return _kcalIcon;
    } else if (id == WatchFaceApp.COMPLICATION_BATT) {
      return _battIcon;
    }
    return null;
  }

  private function centerBitmap(
    dc as Dc,
    xy as Array<Number>,
    bitmap as BitmapResource?
  ) {
    if (bitmap == null) {
      return;
    }

    dc.drawBitmap(
      xy[0] - bitmap.getWidth() / 2,
      xy[1] - bitmap.getHeight() / 2,
      bitmap
    );
  }

  private function leftArrow(
    dc as Dc,
    x as Number,
    y as Number,
    size as Number
  ) as Void {
    dc.drawLine(x - size, y, x, y - size);
    dc.drawLine(x - size, y, x, y + size);
  }

  private function rightArrow(
    dc as Dc,
    x as Number,
    y as Number,
    size as Number
  ) as Void {
    dc.drawLine(x, y - size, x + size, y);
    dc.drawLine(x, y + size, x + size, y);
  }
}

class SettingsDelegate extends WatchUi.BehaviorDelegate {
  private var _view as SettingsView;

  //! Constructor
  //! @param view The InputView to operate on
  public function initialize(view as SettingsView) {
    BehaviorDelegate.initialize();
    _view = view;
  }

  public function onTap(evt as ClickEvent) {
    var xy = evt.getCoordinates();

    var settings = System.getDeviceSettings();
    _view.selectedItem = xy[1] < settings.screenHeight / 2 ? 0 : 1;

    WatchUi.requestUpdate();

    return true;
  }

  public function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
    return true;
  }

  public function onSwipe(evt as SwipeEvent) {
    var direction = evt.getDirection();
    if (WatchUi.SWIPE_DOWN == direction) {
    } else if (WatchUi.SWIPE_UP == direction) {
    } else if (WatchUi.SWIPE_LEFT == direction) {
      _view.onPrevious();
    } else if (WatchUi.SWIPE_RIGHT == direction) {
      _view.onNext();
    }

    WatchUi.requestUpdate();
    return true;
  }

  public function onMenu() as Boolean {
    return false;
  }
}
