import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Application.Storage;

class WatchFaceView extends WatchUi.WatchFace {
  private var _drawLayer as Layer;

  private var _hourTextOffsetX as Number;
  private var _hourTextOffsetY as Number;

  private var _minuteTextOffsetX as Number;
  private var _minuteTextOffsetY as Number;

  private var _dateTextOffsetX as Number;
  private var _dateTextOffsetY as Number;

  private var _centerX as Number;
  private var _centerY as Number;

  private var _screenHeight as Number;
  private var _tinyFontHeight as Number;
  private var _labelHeight as Number;
  private var _padding as Number;

  private var _topIcon as BitmapResource?;
  private var _bottomIcon as BitmapResource?;

  private var _topComplication as Number = -1;
  private var _bottomComplication as Number = -1;

  private var _colorId as Number = -1;
  private var _primaryColor as Number = Graphics.COLOR_LT_GRAY;
  private var _secondaryColor as Number = Graphics.COLOR_DK_GRAY;

  private var _batteryIconWidth as Number;
  private var _batteryIconHeight as Number;
  private var _batteryIconPadding as Number;

  private var _daysRemainingShortStr = WatchUi.loadResource(
    Rez.Strings.daysRemainingShort
  );

  private const FONT_HOUR = WatchUi.loadResource(Rez.Fonts.id_font_hour);
  private const FONT_MINUTE = WatchUi.loadResource(Rez.Fonts.id_font_minute);
  private const HOUR_MINUTE_GAP = 8;
  private const AM_PM_GAP = -8;

  public function initialize() {
    WatchFace.initialize();

    var settings = System.getDeviceSettings();
    _screenHeight = settings.screenHeight;

    var hourFontHeight = Graphics.getFontHeight(FONT_HOUR);
    _tinyFontHeight = Graphics.getFontHeight(Graphics.FONT_TINY);
    _labelHeight = _tinyFontHeight;

    _centerX = settings.screenWidth / 2;
    _centerY = settings.screenHeight / 2;

    _hourTextOffsetX = _centerX;
    _hourTextOffsetY = _centerY - hourFontHeight / 2;

    _minuteTextOffsetX = _centerX + HOUR_MINUTE_GAP;
    _minuteTextOffsetY = _hourTextOffsetY + 1;

    _dateTextOffsetX = _centerX + HOUR_MINUTE_GAP;

    _dateTextOffsetY = _hourTextOffsetY + hourFontHeight - _tinyFontHeight + 4;

    _padding = settings.screenHeight / 20;
    _batteryIconWidth = 56;
    _batteryIconHeight = 16;
    _batteryIconPadding = 2;

    _drawLayer = new WatchUi.Layer({
      :locX => 0,
      :locY => 0,
      :width => settings.screenWidth,
      :height => settings.screenHeight,
    });
  }

  private function getIcon(id as Number) as BitmapResource? {
    if (id == WatchFaceApp.COMPLICATION_STEPS) {
      return (
        WatchUi.loadResource($.Rez.Drawables.id_icon_steps) as BitmapResource
      );
    } else if (id == WatchFaceApp.COMPLICATION_HR) {
      return WatchUi.loadResource($.Rez.Drawables.id_icon_hr) as BitmapResource;
    } else if (id == WatchFaceApp.COMPLICATION_KCAL) {
      return (
        WatchUi.loadResource($.Rez.Drawables.id_icon_kcal) as BitmapResource
      );
    }

    return null;
  }

  public function onLayout(dc as Dc) as Void {
    setLayout($.Rez.Layouts.WatchFace(dc));
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    addLayer(_drawLayer);
  }

  public function onShow() as Void {}

  public function onUpdate(dc as Dc) as Void {
    updateWatchOverlay(true);
  }

  public function onPartialUpdate(dc as Dc) as Void {
    updateWatchOverlay(false);
  }

  private function drawBattery(drawLayerDc as Dc, x as Number, y as Number) {
    var systemStats = System.getSystemStats();

    drawLayerDc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);

    var batteryPercentageInPx = (
      (systemStats.battery / 100.0) *
        (_batteryIconWidth - _batteryIconPadding - _batteryIconPadding) +
      0.5
    ).toNumber();

    if (batteryPercentageInPx >= _batteryIconHeight / 2) {
      drawLayerDc.fillRoundedRectangle(
        x,
        y,
        batteryPercentageInPx,
        _batteryIconHeight,
        _batteryIconHeight
      );
    }

    drawLayerDc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_LT_GRAY);

    drawLayerDc.setPenWidth(3);
    drawLayerDc.drawRoundedRectangle(
      x,
      y,
      _batteryIconWidth,
      _batteryIconHeight,
      _batteryIconHeight
    );
  }

  private function drawComplication(
    drawLayerDc as Dc,
    id as Number,
    icon as BitmapReference?,
    x as Number,
    y as Number,
    iconX as Number,
    iconY as Number
  ) {
    if (id == WatchFaceApp.COMPLICATION_NONE) {
      return;
    }

    var activityInfo = ActivityMonitor.getInfo();

    var label = "" as String;
    if (id == WatchFaceApp.COMPLICATION_STEPS) {
      // steps
      label = activityInfo.steps.toString();
    } else if (id == WatchFaceApp.COMPLICATION_HR) {
      // hr
      var hr = Activity.getActivityInfo().currentHeartRate;
      if (hr != null) {
        label = hr.toString();
      } else {
        var heartRateHistory = Toybox.ActivityMonitor.getHeartRateHistory(
          1,
          true
        );
        var heartRateSample = heartRateHistory.next();
        if (
          heartRateSample != null &&
          heartRateSample.heartRate != Toybox.ActivityMonitor.INVALID_HR_SAMPLE
        ) {
          label = heartRateSample.heartRate.toString();
        }
      }
    } else if (id == WatchFaceApp.COMPLICATION_KCAL) {
      // calories
      label = activityInfo.calories.toString();
    } else if (id == WatchFaceApp.COMPLICATION_BATT) {
      // battery
      var systemStats = System.getSystemStats();
      if (systemStats.batteryInDays >= 1.0) {
        label = Lang.format("$1$$2$", [
          (systemStats.batteryInDays + 0.5).toNumber(),
          _daysRemainingShortStr,
        ]);
      } else {
        label = Lang.format("$1$%", [(systemStats.battery + 0.5).toNumber()]);
      }
    }

    drawLayerDc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
    drawLayerDc.drawText(
      x,
      y,
      Graphics.FONT_TINY,
      label,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    if (id == WatchFaceApp.COMPLICATION_BATT) {
      // battery
      drawBattery(drawLayerDc, iconX - _batteryIconWidth / 2, iconY);
    } else if (icon != null) {
      drawLayerDc.drawBitmap(iconX - icon.getWidth() / 2, iconY, icon);
    }
  }

  private function drawTimeAndDate(drawLayerDc as Dc) {
    var settings = System.getDeviceSettings();
    var is24Hour = settings.is24Hour;

    var clockTime = System.getClockTime();

    var now = Time.now();
    var info = Gregorian.info(now, Time.FORMAT_MEDIUM);
    var hour = clockTime.hour;
    var hourString;
    if (is24Hour) {
      hourString = hour.format("%02d");
    } else {
      hour = hour % 12;
      if (hour == 0) {
        hourString = "12";
      } else {
        hourString = hour.format("%d");
      }
    }
    var minuteString = clockTime.min.format("%02d");

    var dateStr = Lang.format("$1$, $2$", [
      info.day_of_week,
      info.day,
    ]).toUpper();

    var hourWidth =
      drawLayerDc.getTextWidthInPixels(hourString, FONT_HOUR) +
      HOUR_MINUTE_GAP / 2;

    var minuteWidth =
      drawLayerDc.getTextWidthInPixels(minuteString, FONT_MINUTE) +
      HOUR_MINUTE_GAP / 2;

    var xShift = (hourWidth - minuteWidth) / 2;

    drawLayerDc.setColor(_primaryColor, Graphics.COLOR_BLACK);

    drawLayerDc.drawText(
      _hourTextOffsetX + xShift,
      _hourTextOffsetY,
      FONT_HOUR,
      hourString,
      Graphics.TEXT_JUSTIFY_RIGHT
    );

    drawLayerDc.drawText(
      _minuteTextOffsetX + xShift,
      _minuteTextOffsetY,
      FONT_MINUTE,
      minuteString,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    drawLayerDc.setColor(_secondaryColor, Graphics.COLOR_BLACK);

    if (!is24Hour) {
      var amPmX =
        _hourTextOffsetX -
        hourWidth -
        drawLayerDc.getTextWidthInPixels("M", Graphics.FONT_TINY) / 2 -
        HOUR_MINUTE_GAP +
        xShift;

      var txt = clockTime.hour >= 12 ? "P" : "A";

      drawLayerDc.drawText(
        amPmX,
        _hourTextOffsetY,
        Graphics.FONT_TINY,
        txt,
        Graphics.TEXT_JUSTIFY_CENTER
      );
      drawLayerDc.drawText(
        amPmX,
        _hourTextOffsetY + _tinyFontHeight + AM_PM_GAP,
        Graphics.FONT_TINY,
        "M",
        Graphics.TEXT_JUSTIFY_CENTER
      );
    }

    drawLayerDc.drawText(
      _dateTextOffsetX + xShift,
      _dateTextOffsetY,
      Graphics.FONT_TINY,
      dateStr,
      Graphics.TEXT_JUSTIFY_LEFT
    );
  }

  private function updateWatchOverlay(isFullUpdate as Boolean) as Void {
    var drawLayerDc = _drawLayer.getDc();
    if (drawLayerDc == null) {
      return;
    }

    var newTop = Storage.getValue("c.top");
    if (newTop == null) {
      newTop = 4;
    }
    if (_topComplication != newTop) {
      _topComplication = newTop;
      _topIcon = getIcon(_topComplication);
    }

    var newBottom = Storage.getValue("c.bottom");
    if (newBottom == null) {
      newBottom = 1;
    }
    if (_bottomComplication != newBottom) {
      _bottomComplication = newBottom;
      _bottomIcon = getIcon(_bottomComplication);
    }

    var newColorId = Storage.getValue("color");
    if (newColorId == null) {
      newColorId = 0;
    }
    if (_colorId != newColorId) {
      _colorId = newColorId;
      _primaryColor = WatchFaceApp.getPrimaryColor(_colorId);
      _secondaryColor = WatchFaceApp.getSecondaryColor(_colorId);
    }
    

    drawLayerDc.setColor(_primaryColor, Graphics.COLOR_BLACK);
    drawLayerDc.clear();

    // top complication
    drawComplication(
      drawLayerDc,
      _topComplication,
      _topIcon,
      _centerX,
      _padding,
      _centerX,
      _padding + _labelHeight
    );

    // bottom complication
    drawComplication(
      drawLayerDc,
      _bottomComplication,
      _bottomIcon,
      _centerX,
      // assume 40px height of icons
      _screenHeight - _padding - _labelHeight - 40,
      _centerX,
      _screenHeight - _padding - _labelHeight
    );

    drawTimeAndDate(drawLayerDc);
  }

  public function onHide() as Void {
    View.onHide();
  }

  public function onExitSleep() as Void {}

  public function onEnterSleep() as Void {}
}
