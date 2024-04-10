import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class SettingsView extends WatchUi.View {
  public var selectedItem as Number = 0;

  public var topComplication as Number = 0;
  public var bottomComplication as Number = 0;
  public var colorId as Number = 0;

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

    colorId = Storage.getValue("color");
    if (colorId == null) {
      colorId = 0;
    }
  }

  public function toggle(direction as Number) {
    if (selectedItem == 0 || selectedItem == 1) {
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
    } else if (selectedItem == 2) {
      // watchface color
      colorId =
        (colorId + direction + WatchFaceApp.COLORS_COUNT) %
        WatchFaceApp.COLORS_COUNT;
      Storage.setValue("color", colorId);
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
    dc.setAntiAlias(true);

    var settings = System.getDeviceSettings();
    var iconGap = settings.screenWidth / 40;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(4);

    var settingRadius = settings.screenWidth / 10;
    var arrowSize = settings.screenWidth / 40;

    var topComplicationCenter = [settings.screenWidth / 2, settingRadius * 2];

    var bottomComplicationCenter = [
      settings.screenWidth / 2,
      settings.screenHeight - settingRadius * 2,
    ];

    var colorSettingCenter = [
      settings.screenWidth / 2,
      settings.screenHeight / 2,
    ];

    var positions =
      [topComplicationCenter, bottomComplicationCenter, colorSettingCenter] as
      Array<Array<Number> >;

    for (var i = 0; i < positions.size(); i++) {
      drawCircle(dc, positions[i], settingRadius);
      dc.setPenWidth(3);
      if (selectedItem == i) {
        rightArrow(
          dc,
          positions[i][0] + settingRadius + iconGap,
          positions[i][1],
          arrowSize
        );
        leftArrow(
          dc,
          positions[i][0] - settingRadius - iconGap,
          positions[i][1],
          arrowSize
        );
      }
    }

    var topBitmap = getBitmapFor(topComplication) as BitmapResource?;
    centerBitmap(dc, topComplicationCenter, topBitmap);

    var bottomBitmap = getBitmapFor(bottomComplication) as BitmapResource?;
    centerBitmap(dc, bottomComplicationCenter, bottomBitmap);

    dc.setColor(WatchFaceApp.getPrimaryColor(colorId), Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(
      colorSettingCenter[0],
      colorSettingCenter[1],
      settingRadius - iconGap
    );
  }

  private function drawCircle(dc as Dc, xy as Array<Number>, radius as Number) {
    dc.drawCircle(xy[0], xy[1], radius);
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
    if (xy[1] < settings.screenHeight / 3) {
      _view.selectedItem = 0;
    } else if (xy[1] > (2 * settings.screenHeight) / 3) {
      _view.selectedItem = 1;
    } else {
      _view.selectedItem = 2;
    }

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
