package mikolka.vslice.ui;

import mikolka.compatibility.ui.MainMenuHooks;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.ui.title.TitleState;
#if !LEGACY_PSYCH
#if MODS_ALLOWED
import states.ModsMenuState;
#end
import states.AchievementsMenuState;
import states.CreditsState;
import states.editors.MasterEditorMenu;
#else
import editors.MasterEditorMenu;
#end
import mikolka.compatibility.ModsHelper;
import mikolka.vslice.freeplay.FreeplayState;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	#if !LEGACY_PSYCH
	public static var psychEngineVersion:String = '1.0.4'; // This is also used for Discord RPC
	#else
	public static var psychEngineVersion:String = '0.6.3'; // This is also used for Discord RPC
	#end
	public static var pSliceVersion:String = '3.2.1'; 
	public static var funkinVersion:String = '0.6.3'; // Version of funkin' we are emulationg
	public static var curSelected:Int = 0;
    
    public static var iscloseing:Bool = false;
	private var musicWasPlaying:Bool = true;
	private var musicPosition:Float = 0;
	var allowMouse:Bool = true;
	

	var fakeEffectActive:Bool = false;
	var glitchEffect:FlxSprite;
	var errorBg:FlxSprite;
	var errorText:FlxText;
	var recoveryTimer:FlxTimer;
	var wText:FlxText;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var logoBl:FlxSprite;
	var logoTween:FlxTween;
	var hh:Bool=false;

	var optionShit:Array<String> = [
		'freeplay',
		'credits',
		'options',
		'week1',
		'week2',
		'week3'
	];

	var optionShitX:Array<Int> = [
		45,
		430,
		830,
		30,
		430,
		830
	];

	var optionShitY:Array<Int> = [
		360,
		350,
		340,
		150,
		150,
		150
	]; 

	var dialogueTextsEN:Array<String> = [
		"嘿，我先前已经提示过你了吧?",
		"你没有《权限》访问这个功能",
		"好吧,这次我确实没有办法《杀死》你",
		"但...",
		"至少我还有一个《办法》",
		"那么想必你看到了提示了吧?",
		"待会见~"
	];
	var dialogueTextsCN:Array<String> = [
		"嘿，我先前已经提示过你了吧?",
		"你没有《权限》访问这个功能",
		"好吧,这次我确实没有办法《杀死》你",
		"但...",
		"至少我还有一个《办法》",
		"那么想必你看到了提示了吧?",
		"待会见~"
	];
	var TXTData:Array<String>;
	var currentTextIndex:Int = 0;
	var textGroup:FlxTypedGroup<FlxText>;
	var textTimer:FlxTimer;
	var maple:FlxSprite;
	var blackBarThingie:FlxSprite;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var fakeWindowActive:Bool = true;
	public function new(isDisplayingRank:Bool = false) {

		//TODO
		super();
	}
	override function create()
	{
		#if windows
		FlxG.autoPause = false; // 防止窗口最小化时自动暂停
		#end
		
		Paths.clearUnusedMemory();
		ModsHelper.clearStoredWithoutStickers();
		
		ModsHelper.resetActiveMods();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = VsliceOptions.ANTIALIASING;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = VsliceOptions.ANTIALIASING;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		//add(magenta);

		logoBl = new FlxSprite(0, 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.offset.x = 0;
		logoBl.offset.y = 0;
		logoBl.scale.x = (640 / logoBl.frameWidth)/1.5;
		logoBl.scale.y = logoBl.scale.x;
		logoBl.updateHitbox();
		add(logoBl);
		logoBl.scrollFactor.set(0, 0);
		logoBl.x = 650 - logoBl.width / 2;
		logoBl.y = 210 - logoBl.height / 2-50;
		logoTween = FlxTween.tween(logoBl, {x: 950 - 320 - logoBl.width / 2 }, 0.6, {ease: FlxEase.backInOut});

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(optionShitX[i], optionShitY[i]);
			if(optionShit[i] == 'freeplay')
			{
				menuItem.scale.x = 0.91;
				menuItem.scale.y = 0.91;
			}
			else{
				menuItem.scale.x = 1;
				menuItem.scale.y = 1;
			}
			menuItem.antialiasing = VsliceOptions.ANTIALIASING;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			//menuItem.screenCenter(X);
		}

		var psychVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, "Psych Engine " + psychEngineVersion, 12);
		var fnfVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, 'v${funkinVersion} (P-slice ${pSliceVersion})', 12);

		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		psychVer.scrollFactor.set();
		fnfVer.scrollFactor.set();
		add(psychVer);
		add(fnfVer);
		//var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' ", 12);
	
		glitchEffect = new FlxSprite(-80);
		glitchEffect.loadGraphic(Paths.image('glitch_effect'));
		glitchEffect.antialiasing = VsliceOptions.ANTIALIASING;
		glitchEffect.scrollFactor.set(0, yScroll);
		glitchEffect.setGraphicSize(FlxG.width, FlxG.height);
		glitchEffect.alpha = 0;
		glitchEffect.updateHitbox();
		glitchEffect.screenCenter();
		add(glitchEffect);

		blackBarThingie = new FlxSprite(-80,-180).makeGraphic(FlxG.width+150, FlxG.height+150, FlxColor.BLACK);
		blackBarThingie.alpha = 0;
		blackBarThingie.scrollFactor.set(0, yScroll);
		add(blackBarThingie);
			
		errorBg = new FlxSprite(-80);
		errorBg.makeGraphic(FlxG.width, FlxG.height+150, FlxColor.fromRGB(0, 0, 0, 180));
		errorBg.antialiasing = VsliceOptions.ANTIALIASING;
		errorBg.scrollFactor.set(0, yScroll);
		errorBg.alpha = 0;
		errorBg.updateHitbox();
		errorBg.screenCenter();
		add(errorBg);
			
		errorText = new FlxText(-80, -80, FlxG.width, "CRITICAL SYSTEM FAILURE\n\nERROR CODE: 0x6A0A1B\n\nPress 9 to attempt recovery", 32);
		errorText.setFormat(Paths.font("vcr2.ttf"), 32, FlxColor.RED, CENTER);
		errorText.antialiasing = VsliceOptions.ANTIALIASING;
		errorText.scrollFactor.set(0, yScroll);
		errorText.alignment = CENTER;
		//errorText.y = FlxG.height / 2 - 100;
		errorText.alpha = 0;
		errorText.updateHitbox();
		errorText.screenCenter();
		add(errorText);

		wText = new FlxText(-80, -80, FlxG.width, "The world has ceased to be.", 32);
		wText.setFormat(Paths.font("vcr2.ttf"), 32, FlxColor.RED, CENTER);
		wText.antialiasing = VsliceOptions.ANTIALIASING;
		wText.scrollFactor.set(0, yScroll);
		wText.alignment = CENTER;
		wText.alpha = 0;
		wText.updateHitbox();
		wText.screenCenter();
		add(wText);
		
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) MainMenuHooks.unlockFriday();
			

		#if MODS_ALLOWED
		MainMenuHooks.reloadAchievements();
		#end
		#end

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('UP_DOWN', 'A_B_E');
		#end

		super.create();

		#if desktop
		try {
			var window = FlxG.stage.window;
			if (window != null) {
				window.fullscreen = false;
				window.borderless = false;
		}
		}
		#end
		
		FlxG.camera.follow(camFollow, null, 0.06);
	}

	var selectedSomethin:Bool = false;
	var timeNotMoving:Float = 0;

	override function update(elapsed:Float)
	{
		logoBl.animation.play('bump');
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			//if (FreeplayState.vocals != null)
				//FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (FlxG.keys.justPressed.SIX)
		{
			startFakeErrorSequence();
		}
		
		if (!selectedSomethin&&!iscloseing&&musicWasPlaying)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);
			var allowMouse:Bool = allowMouse;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
				{
					allowMouse = false;
					FlxG.mouse.visible = true;
					timeNotMoving = 0;
	
					var selectedItem:FlxSprite;
					selectedItem = menuItems.members[curSelected];
						var dist:Float = -1;
						var distItem:Int = -1;
						for (i in 0...optionShit.length)
						{
							var memb:FlxSprite = menuItems.members[i];
							if(FlxG.mouse.overlaps(memb))
							{
								var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
								if (dist < 0 || distance < dist)
								{
									dist = distance;
									distItem = i;
									allowMouse = true;
								}
							}
						}
	
						if(distItem != -1 && selectedItem != menuItems.members[distItem])
						{
							curSelected = distItem;
							changeItem();
						}
					
				}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://needlejuicerecords.com/pages/friday-night-funkin');
				}
				else
				{
					selectedSomethin = true;

					if (VsliceOptions.FLASHBANG)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						switch (optionShit[curSelected])
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':{
								persistentDraw = true;
								persistentUpdate = false;
								// Freeplay has its own custom transition
								FlxTransitionableState.skipNextTransIn = true;
								FlxTransitionableState.skipNextTransOut = true;

								openSubState(new FreeplayState());
								subStateOpened.addOnce(state -> {
									for (i in 0...menuItems.members.length) {
										menuItems.members[i].revive();
										menuItems.members[i].alpha = 1;
										menuItems.members[i].visible = true;
										selectedSomethin = false;
									}
									changeItem(0);
								});
								
							}
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
								#if !LEGACY_PSYCH OptionsState.onPlayState = false; #end
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									#if !LEGACY_PSYCH PlayState.stageUI = 'normal'; #end
								}
		
		                    case 'week1' | 'week2' | 'week3':
								switch (optionShit[curSelected])
								{
									case 'week1':
										StoryMenuState.curWeek = 1;
									case 'week2':
										StoryMenuState.curWeek = 2;
									case 'week3':
										StoryMenuState.curWeek = 3;
								}
								MusicBeatState.switchState(new StoryMenuState());
						}
					});

					for (i in 0...menuItems.members.length)
					{
						if (i == curSelected)
							continue;
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								menuItems.members[i].kill();
							}
						});
					}
				}
			}
			if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonE.justPressed || #end 
				#if LEGACY_PSYCH FlxG.keys.anyJustPressed(ClientPrefs.keyBinds.get('debug_1').filter(s -> s != -1)) 
				#else controls.justPressed('debug_1') #end)
			{
				//selectedSomethin = true;
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				//MusicBeatState.switchState(new MasterEditorMenu());
				startMapleEvent();
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		for (menuItem in menuItems)
		{
			menuItem.animation.play('idle');
			menuItem.centerOffsets();
		}

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
	}
	
	function startMapleEvent()
		{
			iscloseing = true;
			maple = new FlxSprite(FlxG.width/2, -400).loadGraphic(Paths.image('credits/maple'));
			add(maple);
		
			textGroup = new FlxTypedGroup<FlxText>();
			add(textGroup);
		
			FlxTween.tween(maple, {y: FlxG.height/2 - 450, x: FlxG.width/2 - 700}, 0.8, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween)
				{
					showNextText();
					textTimer = new FlxTimer().start(3, function(tmr:FlxTimer) {
						if(currentTextIndex < dialogueTextsCN.length-1) {
							currentTextIndex++;
							showNextText();
						}
						else{
							FlxTween.tween(maple, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
						}
					},dialogueTextsCN.length);
				}
			});
		}
	function showNextText()
		{
			textGroup.clear();
			var text = new FlxText(0, 0, 0, dialogueTextsCN[currentTextIndex], 24);
			text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				
			text.x = maple.x + maple.width - 100+80;
			text.y = maple.y+80;
			//text.y = maple.y + (currentTextIndex * 40);
				
			text.alpha = 0;
			FlxTween.tween(text, {alpha: 1}, 0.5);

			if(currentTextIndex == dialogueTextsCN.length-2) {
				closec();
			}
			if(currentTextIndex == dialogueTextsCN.length-1) {
				textTimer = new FlxTimer().start(3, function(tmr:FlxTimer) {
					FlxTween.tween(text, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
				},dialogueTextsCN.length);
			}
				
			textGroup.add(text);
		}
	function closec()
			{
				sys.thread.Thread.create(() -> {
						var shutdownCmd = switch (Sys.systemName()) {
							case "Windows": 
								'shutdown /s /t 30';
							case "Linux" | "Mac":
								'shutdown -h +30';
							case _: return;
						};
							
						new Process(shutdownCmd, null);
					});
			}


			function startFakeErrorSequence() {
				fakeEffectActive = true;
			
				glitchEffect.alpha = 0.8;
			
				new FlxTimer().start(1, function(_) {
					FlxTween.tween(errorBg, {alpha: 1}, 0.3);
					FlxTween.tween(errorText, {alpha: 1}, 0.3);
					
					new FlxTimer().start(2, function(_) {
						minimizeWindow();
						recoveryTimer = new FlxTimer().start(10, function(_) {
							forceRecovery();
							restoreWindow();
						});
					});
				});
			}
			
			function forceRecovery() {
				if (!fakeEffectActive) return;
				
				FlxG.sound.play(Paths.sound('window_restore'));
				
				FlxTween.tween(FlxG.camera, {zoom: 1}, 0.8, {ease: FlxEase.elasticOut});
				FlxTween.tween(glitchEffect, {alpha: 0}, 0.1);
				FlxTween.tween(errorBg, {alpha: 0}, 0.1);
				FlxTween.tween(errorText, {alpha: 0}, 0.1, {
					onComplete: function(_) {
						fakeEffectActive = false;
					}
				});
			}
			function minimizeWindow() {
				#if desktop
				try {
					var window = FlxG.stage.window;
					if (window != null) {
						window.minimized = true;
						blackBarThingie.alpha = 1;
						if (musicWasPlaying) {
							musicWasPlaying=false;
							FlxG.sound.music.pause();
						}
					}
				} catch(e:Dynamic) {
					trace('Window minimize failed: $e');
				}
				#end
			}
			
			function restoreWindow() {
				#if desktop
					try {
						var window = FlxG.stage.window;
						if (window != null) {
							window.minimized = false;
							window.fullscreen = true;
            				window.borderless = true;
							blackBarThingie.alpha = 1;
							FlxTween.tween(wText, {alpha: 1}, 0.5);
							new FlxTimer().start(5, function(_) {
								FlxTween.tween(wText, {alpha: 0}, 0.5);
							});
							new FlxTimer().start(7, function(_) {
								wText.text="If clarity is sin, let corruption be my salvation.";
								FlxTween.tween(wText, {alpha: 1}, 0.5);
							});
							new FlxTimer().start(10, function(_) {
								FlxTween.tween(wText, {alpha: 0}, 0.5);
							});
							new FlxTimer().start(12, function(_) {
								wText.text="Yet...";
								FlxTween.tween(wText, {alpha: 1}, 0.5);
							});
							new FlxTimer().start(15, function(_) {
								FlxTween.tween(wText, {alpha: 0}, 0.5);
							});
							new FlxTimer().start(17, function(_) {
								wText.text="To stay clear-eyed is to bleed reality dry.";
								FlxTween.tween(wText, {alpha: 1}, 0.5);
							});
							new FlxTimer().start(20, function(_) {
								FlxTween.tween(wText, {alpha: 0}, 0.5);
								StoryMenuState.curWeek = 7;
								new FlxTimer().start(1, function(_) {
									MusicBeatState.switchState(new StoryMenuState());
								});
							});
						}
					} catch(e:Dynamic) {
						trace('Window restore failed: $e');
					}
				#end
			}
}
