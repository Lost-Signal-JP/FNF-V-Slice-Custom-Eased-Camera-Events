import flixel.math.FlxPoint;
import funkin.ui.FullScreenScaleMode;
import funkin.play.PlayState;
import funkin.play.event.SongEvent;
import funkin.Conductor;

class CustomEaseZoomCamera extends SongEvent
{
  public function new()
  {
    super('CustomEaseZoomCamera', {
      processOldEvents: true
    });
  }

  public static final DEFAULT_ZOOM:Float = 1.0;
  public static final DEFAULT_WIDESCREEN_SCALE:Float = 0.0;
  public static final DEFAULT_DURATION:Float = 4.0;
  public static final DEFAULT_MODE:String = 'direct';

  var someEase:String = null;

  public override function handleEvent(data:SongEventData):Void
  {
    // Does nothing if there is no PlayState camera or stage.
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;

    // Does nothing if we are minimal mode.
    if (PlayState.instance.isMinimalMode) return;

    var zoom:Float = data.getFloat('zoom') ?? DEFAULT_ZOOM;

    var widescreenScaleX:Float = data.getFloat('widescreenScaleX') ?? DEFAULT_WIDESCREEN_SCALE;
    var widescreenScaleY:Float = data.getFloat('widescreenScaleY') ?? DEFAULT_WIDESCREEN_SCALE;

    var scaledZoom:Float = zoom + (zoom * calculateScale(FullScreenScaleMode.wideScale, FlxPoint.get(widescreenScaleX, widescreenScaleY)));

    var duration:Float = data.getFloat('duration') ?? DEFAULT_DURATION;

    var mode:String = data.getString('mode') ?? DEFAULT_MODE;
    var isDirectMode:Bool = mode == 'direct';

    var ease:String = data.getString('ease');
    if(ease == null)
    {
      ease = 'kt';
    }
    var easeDir:String = data.getString('easeDir');

    if (easeDir == null) easeDir = "in";

    var durSeconds = Conductor.instance.stepLengthMs * duration / 1000;
    var calculation = GraphParser.parseEase(ease, easeDir);

    PlayState.instance.tweenCameraZoom(scaledZoom, durSeconds, isDirectMode, calculation);
  }

  function calculateScale(wideScale:FlxPoint, scale:FlxPoint)
  {
    return (wideScale.x - 1) * scale.x + (wideScale.y - 1) * scale.y;
  }

  public override function getTitle():String
  {
    return 'Custom Ease | Zoom Camera';
  }

  function giveEase():String
  {
    for(key in GraphParser.listAllEases().keys())
    {
      someEase = key.get(key);
      break;
    }
  }

  public override function getEventSchema():SongEventSchema
  {
    return [{
      name: 'zoom',
      title: 'Zoom Level',
      defaultValue: DEFAULT_ZOOM,
      min: 0,
      step: 0.05,
      type: 'float',
      units: 'x'
    }, {
      name: 'duration',
      title: 'Duration',
      defaultValue: DEFAULT_DURATION,
      min: 0,
      step: 0.5,
      type: 'float',
      units: 'steps'
    }, {
      name: 'ease',
      title: 'Easing Type',
      defaultValue: 'kt',
      type: 'enum',
      keys: GraphParser.listAllEases()
    }, {
      name: 'easeDir',
      title: 'Easing Direction',
      defaultValue: SongEvent.DEFAULT_EASE_DIR,
      type: 'enum',
      keys: ['In' => 'in', 'Out' => 'out', 'In/Out' => 'inOut']
    }, {
      name: 'advanced',
      title: 'Advanced',
      type: 'frame',
      collapsible: true,
      children: [{
        name: 'mode',
        title: 'Mode',
        defaultValue: DEFAULT_MODE,
        type: 'enum',
        keys: ['Stage zoom' => 'stage', 'Absolute zoom' => 'direct']
      }, {
        name: 'widescreenScaleX',
        title: 'Widescreen Scale X',
        defaultValue: DEFAULT_WIDESCREEN_SCALE,
        min: 0,
        max: 1,
        type: 'float',
        units: 'x'
      }, {
        name: 'widescreenScaleY',
        title: 'Widescreen Scale Y',
        defaultValue: DEFAULT_WIDESCREEN_SCALE,
        min: 0,
        max: 1,
        type: 'float',
        units: 'x'
      }]
    }];
  }
}
