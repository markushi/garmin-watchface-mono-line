import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

class WatchFaceView extends WatchUi.WatchFace {
  private var _drawLayer as Layer;

  private var _hourTextOffsetX as Number;
  private var _hourTextOffsetY as Number;

  private var _minuteTextOffsetX as Number;
  private var _minuteTextOffsetY as Number;

  private var _dateTextOffsetX as Number;
  private var _dateTextOffsetY as Number;

  private var _centerX as Number;
  private var _stepsOffsetY as Number;
  private var _stepsIconOffsetX as Number;
  private var _stepsIconOffsetY as Number;
  private var _batteryOffsetY as Number;

  private var _batteryIconOffsetX as Number;
  private var _batteryIconOffsetY as Number;
  private var _batteryIconWidth as Number;
  private var _batteryIconHeight as Number;
  private var _batteryIconPadding as Number;

  private var _stepIcon as BitmapResource;

  private var _daysRemainingShortStr = WatchUi.loadResource(
    Rez.Strings.daysRemainingShort
  );

  private const FONT_HOUR = WatchUi.loadResource(Rez.Fonts.id_font_hour);
  private const FONT_MINUTE = WatchUi.loadResource(Rez.Fonts.id_font_minute);
  private const HOUR_MINUTE_GAP = 8;

  public function initialize() {
    WatchFace.initialize();

    var settings = System.getDeviceSettings();
    var hourFontHeight = Graphics.getFontHeight(FONT_HOUR);

    var xShift = 18;

    _centerX = settings.screenWidth / 2;

    _hourTextOffsetX = _centerX + xShift;
    _hourTextOffsetY = settings.screenHeight / 2 - hourFontHeight / 2;

    var minuteFontHeight = Graphics.getFontHeight(FONT_MINUTE);
    _minuteTextOffsetX = settings.screenWidth / 2 + HOUR_MINUTE_GAP + xShift;
    _minuteTextOffsetY = _hourTextOffsetY + 1;

    _dateTextOffsetX = settings.screenWidth / 2 + HOUR_MINUTE_GAP + xShift;

    var dateFontHeight = Graphics.getFontHeight(Graphics.FONT_TINY);
    _dateTextOffsetY = _hourTextOffsetY + hourFontHeight - dateFontHeight + 4;

    var tinyFontHeight = Graphics.getFontHeight(Graphics.FONT_TINY);

    _batteryOffsetY = settings.screenHeight / 20;
    _batteryIconOffsetY = _batteryOffsetY + tinyFontHeight;
    _batteryIconWidth = 56;
    _batteryIconHeight = 16;
    _batteryIconPadding = 2;
    _batteryIconOffsetX = _centerX - _batteryIconWidth / 2;

    _stepIcon =
      WatchUi.loadResource($.Rez.Drawables.id_step_icon) as BitmapResource;

    _stepsIconOffsetX = _centerX - _stepIcon.getWidth() / 2;
    _stepsIconOffsetY =
      settings.screenHeight -
      settings.screenHeight / 20 -
      _stepIcon.getHeight();

    _stepsOffsetY = _stepsIconOffsetY - tinyFontHeight;

    _drawLayer = new WatchUi.Layer({
      :locX => 0,
      :locY => 0,
      :width => settings.screenWidth,
      :height => settings.screenHeight,
    });
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

  private function drawBattery(drawLayerDc as Dc) {
    var systemStats = System.getSystemStats();

    var batteryStr;
    if (systemStats.batteryInDays >= 1.0) {
      batteryStr = Lang.format("$1$$2$", [
        (systemStats.batteryInDays + 0.5).toNumber(),
        _daysRemainingShortStr,
      ]);
    } else {
      batteryStr = Lang.format("$1$%", [
        (systemStats.battery + 0.5).toNumber(),
      ]);
    }
    drawLayerDc.drawText(
      _centerX,
      _batteryOffsetY,
      Graphics.FONT_TINY,
      batteryStr,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    drawLayerDc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);

    var batteryPercentageInPx = (
      (systemStats.battery / 100.0) *
        (_batteryIconWidth - _batteryIconPadding - _batteryIconPadding) +
      0.5
    ).toNumber();

    if (batteryPercentageInPx >= _batteryIconHeight/2) {
      drawLayerDc.fillRoundedRectangle(
        _batteryIconOffsetX,
        _batteryIconOffsetY,
        batteryPercentageInPx,
        _batteryIconHeight,
        _batteryIconHeight
      );
    }

    drawLayerDc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_LT_GRAY);

    drawLayerDc.setPenWidth(3);
    drawLayerDc.drawRoundedRectangle(
      _batteryIconOffsetX,
      _batteryIconOffsetY,
      _batteryIconWidth,
      _batteryIconHeight,
      _batteryIconHeight
    );
  }

  private function drawSteps(drawLayerDc as Dc) {
    var activityInfo = ActivityMonitor.getInfo();
    var stepsStr = activityInfo.steps.toString();
    drawLayerDc.drawText(
      _centerX,
      _stepsOffsetY,
      Graphics.FONT_TINY,
      stepsStr,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    drawLayerDc.drawBitmap(_stepsIconOffsetX, _stepsIconOffsetY, _stepIcon);
  }

  private function updateWatchOverlay(isFullUpdate as Boolean) as Void {
    var drawLayerDc = _drawLayer.getDc();
    if (drawLayerDc == null) {
      return;
    }
    var clockTime = System.getClockTime();

    var now = Time.now();
    var info = Gregorian.info(now, Time.FORMAT_MEDIUM);

    var hourString = clockTime.hour.format("%02d");
    var minuteString = clockTime.min.format("%02d");

    var dateStr = Lang.format("$1$, $2$", [
      info.day_of_week,
      info.day,
    ]).toUpper();

    drawLayerDc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
    drawLayerDc.clear();

    drawLayerDc.drawText(
      _hourTextOffsetX,
      _hourTextOffsetY,
      FONT_HOUR,
      hourString,
      Graphics.TEXT_JUSTIFY_RIGHT
    );

    drawLayerDc.drawText(
      _minuteTextOffsetX,
      _minuteTextOffsetY,
      FONT_MINUTE,
      minuteString,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    drawLayerDc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);

    drawLayerDc.drawText(
      _dateTextOffsetX,
      _dateTextOffsetY,
      Graphics.FONT_TINY,
      dateStr,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    drawSteps(drawLayerDc);

    drawBattery(drawLayerDc);
  }

  public function onHide() as Void {
    View.onHide();
  }

  public function onExitSleep() as Void {}

  public function onEnterSleep() as Void {}
}
