package;


import states.InitState;
import mikolka.vslice.components.crash.Logger;
#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end
import openfl.display.FPS;
import mikolka.vslice.components.MemoryCounter;
import mikolka.GameBorder;
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
#if (linux || mac)
import lime.graphics.Image;
#end
#if mobile
import mobile.backend.MobileScaleMode;
import states.CopyState;
#end

#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
class Main extends Sprite
{
	public static final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: InitState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPS;
	public static var memoryCounter:MemoryCounter;
	public static final platform:String = #if mobile "Phones" #else "PCs" #end;

	// Game pre-flixel init code
	// ? This runs before we attempt to precache things
	public static function loadGameEarly()
	{
		#if (linux || mac) // fix the app icon not showing up on the Linux Panel 
		var icon = lime.graphics.Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if TITLE_SCREEN_EASTER_EGG
		if(Date.now().getMonth() == 0 && Date.now().getDate() == 14) Lib.current.stage.window.title = "Friday Night Funkin': Mikolka's Engine";
		#end

		// This requests file access on android (otherwise we will crash later)
		#if android
		StorageUtil.requestPermissions();
		#end

		#if mobile
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		
		#if sys
		Logger.startLogging();
		trace("CWD IS " + StorageUtil.getStorageDirectory());
		#end
		backend.CrashHandler.init();
		trace("Crash handler is up!");

		// This initialises mods
		try
		{
			trace("Pushing global mods");
			#if LUA_ALLOWED
			Mods.pushGlobalMods();
			#end
			trace("Pushing top mod");
			Mods.loadTopMod();
		}
		catch (x:Exception) trace("Something went wrong with mod code: " + x.message);
		

		#if hxvlc
		trace("Starting hxvlc..");
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
		#end
	}

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
	}

	public function new()
	{
		super();
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		trace("Main done it's code");
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		trace("Starting game setup");
		#if (openfl <= "9.2.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
		#else
		if (game.zoom == -1.0)
			game.zoom = 1.0;
		#end

		trace("Initializing save .sol");
		FlxG.save.bind('funkin', CoolUtil.getSavePath(), (rawSave, error) ->
		{
			trace("Couldn't load main save. Attempting to extract");
			try
			{
				var badSave = File.write(StorageUtil.getStorageDirectory() + "/funkin.sol.bad");
				badSave.writeString(rawSave);
				badSave.close();
				trace("Extracted bad save to funkin.sol.bad. Creating new save..");
			}
			catch (x)
			{
				trace(x);
				trace("Failed to backup. Discarding..");
			}
			return
			{
			};
		});

		trace("Loading scores..");
		Highscore.load();

		#if HSCRIPT_ALLOWED
		trace("Hooking up the Iris log functions");
		Iris.warn = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(WARN, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null)
				newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '') + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true)
			{
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true)
			{
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('WARNING: $msgInfo', FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(ERROR, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null)
				newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '') + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true)
			{
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true)
			{
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('ERROR: $msgInfo', FlxColor.RED);
		}
		Iris.fatal = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(FATAL, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null)
				newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '') + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true)
			{
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true)
			{
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('FATAL: $msgInfo', 0xFFBB0000);
		}
		#end

		#if LUA_ALLOWED
		trace("Hooking up Lua");
		Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call));
		#end

		trace("Loading controls");
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		#if mobile
		FlxG.signals.postGameStart.addOnce(() ->
		{
			FlxG.scaleMode = new MobileScaleMode();
		});
		#end

		trace("Loading game objest...");
		var gameObject = new FlxGame(game.width, game.height, #if mobile !CopyState.checkExistingFiles() ? CopyState : #end game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate,
			game.skipSplash, game.startFullscreen);
		// FlxG.game._customSoundTray wants just the class, it calls new from
		// create() in there, which gets called when it's added to stage
		// which is why it needs to be added before addChild(game) here
		@:privateAccess
		gameObject._customSoundTray = mikolka.vslice.components.FunkinSoundTray;

		addChild(gameObject);

		trace("Finishing up..");
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		#if mobile
		FlxG.game.addChild(fpsVar);
		#else
		#if !debug
		var border = new GameBorder();
		addChild(border);
		Lib.current.stage.window.onResize.add(border.updateGameSize);
		#end
		addChild(fpsVar);
		#end
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		if (fpsVar != null)
		{
			fpsVar.visible = ClientPrefs.data.showFPS;
		}

		#if !html5
		// TODO: disabled on HTML5 (todo: find another method that works?)
		memoryCounter = new MemoryCounter(10, 13, 0xFFFFFF);
		#if mobile
		FlxG.game.addChild(memoryCounter);
		#else
		addChild(memoryCounter);
		#end
		if (memoryCounter != null)
		{
			memoryCounter.visible = ClientPrefs.data.showFPS;
		}
		#end

		#if (debug)
		flixel.addons.studio.FlxStudio.create();
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = #if mobile 30 #else 60 #end;
		#if web
		FlxG.keys.preventDefaultKeys.push(TAB);
		#else
		FlxG.keys.preventDefaultKeys = [TAB];
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		#if mobile
		#if android FlxG.android.preventDefaultKeys = [BACK]; #end
		lime.system.System.allowScreenTimeout = ClientPrefs.data.screensaver;
		FlxG.scaleMode = new MobileScaleMode();
		Application.current.window.vsync = ClientPrefs.data.vsync;
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function(w, h)
		{
			if (FlxG.cameras != null)
			{
				for (cam in FlxG.cameras.list)
				{
					if (cam != null && cam.filters != null)
						resetSpriteCache(cam.flashSprite);
				}
			}

			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}
