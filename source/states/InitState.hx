package states;

import mikolka.vslice.ui.title.TitleState;
import flixel.input.keyboard.FlxKey;
import mikolka.vslice.ui.disclaimer.TextWarnings.FlashingState;
import mikolka.vslice.ui.disclaimer.TextWarnings.OutdatedState;
import mikolka.vslice.components.ScreenshotPlugin;
import openfl.utils.Assets as OpenFlAssets;
#if VIDEOS_ALLOWED
#if hxvlc
import hxvlc.flixel.*;
import hxvlc.util.*;
#end
#end

class InitState extends MusicBeatState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    var mustUpdate:Bool = false;
	public static var updateVersion:String = '';

	override function create()
	{
		super.create();

		persistentUpdate = true;
		persistentDraw = true;
		FlxG.mouse.visible = false;

		#if (cpp && windows)
		trace("Fixing DPI aware:");
		backend.Native.fixScaling();
		#end

		trace("Loading game settings");
		ClientPrefs.loadPrefs();

		trace("Loading translations");
		Language.reloadPhrases();

		trace("Setting some save related values");
		if (FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			// trace('LOADED FULLSCREEN SETTING!!');
		}
		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}
		
		#if TOUCH_CONTROLS_ALLOWED
		trace("Loading mobile data");
		MobileData.init();
		#end

		//* FIRST INIT! iNITIALISE IMPORTED PLUGINS
		ScreenshotPlugin.initialize();
		
		new FlxTimer().start(0.15, function(tmr:FlxTimer)
		{
	        startVideo('start');
	    });
	}

	#if CHECK_FOR_UPDATES
	function fetchUpdateData()
	{
		if (ClientPrefs.data.checkForUpdates)
		{
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/mikolka9144/P-Slice/master/gitVersion.txt");

			http.onData = function(data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.pSliceVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if (updateVersion != curVersion)
				{
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function(error)
			{
				trace('error: $error');
			}

			http.request();
		}
	}
	#end
	
	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED

		var filepath:String = Paths.video(name);
		#if sys
		if(!NativeFileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			qqqeb();
			return;
		}

		var video:FlxVideo = new FlxVideo();
		FlxG.addChildBelowMouse(video);
		video.load(filepath);
		video.play();
		video.onEndReached.add(function()
		{
			video.dispose();
			FlxG.removeChild(video);
			qqqeb();
			return;
		}, true);

		#else
		FlxG.log.warn('Platform not supported!');
		qqqeb();
		return;
		#end
	}
	
	public function qqqeb()
	{
	    if (FlxG.save.data.flashing == null)
		{
			controls.isInSubstate = false;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState(new TitleState()));
		}
        #if CHECK_FOR_UPDATES
        else if (mustUpdate){
            MusicBeatState.switchState(new OutdatedState(updateVersion,new TitleState()));
        }
        #end
		else
		{
				#if FREEPLAY
				MusicBeatState.switchState(new FreeplayState());
				#elseif CHARTING
				MusicBeatState.switchState(new ChartingState());
				#else
				MusicBeatState.switchState(new TitleState());
				#end
		}
	}
}
