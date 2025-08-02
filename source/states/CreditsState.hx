package states;

import objects.AttachedSprite;

class CreditsState extends MusicBeatState
{
    var icon:FlxSprite;
    var nameText:FlxText;
    var descBox:FlxSprite;
    var descText:FlxText;
    var prevButton:FlxButton;
    var nextButton:FlxButton;
    var pageText:FlxText;
    var curPage:Int = 0;
    var creditsData:Array<Dynamic>;

    var isTransitioning:Bool = false;
    var transitionTime:Float = 0.4;

        var creditsDataCN:Array<Dynamic> = [
            {name: "Cwy",icon: "Cwy",desc: "主创\n我有点吴语...\n我是vs danke主创纯吴语\n只要6美金即可带走源码",color: "444444",link: "https://space.bilibili.com/3493119353948379?spm_id_from=333.1387.follow.user_card.click"},
            {name: "Star Fison",icon: "Star Fison", desc: "曲师", color: "FF3366", link: "https://example.com"},
            {name: "C-air",icon: "C-air",desc: "曲师",color: "FF3366",link: "https://space.bilibili.com/453936282"},
            {name: "Little_earl",icon: "Little_earl",desc: "曲师",color: "FF3366",link: "https://space.bilibili.com/1388012478?spm_id_from=333.1387.follow.user_card.click"},
			{name: "kurino198",icon: "kurino198",desc: "曲师",color: "FF3366",link: "https://example.com"},
            {name: "fg_animator",icon: "fg_animator",desc: "k帧的",color: "FF3366",link: "https://example.com"},
			{name: "Zozzz",icon: "Zozzz",desc: "k帧的\n所以纯吴语这家伙是怎么感觉这个名字长的?",color: "FF3366",link: "https://space.bilibili.com/3546376229095641"},
			{name: "Who",icon: "Who",desc: "k帧的\n不是你谁呀(雾)",color: "FF3366",link: "https://example.com"},
            {name: "gz",icon: "gz",desc: "k帧的\n瓜子二手车(雾)",color: "FF3366",link: "https://space.bilibili.com/2043246860"},
            {name: "CM",icon: "CM",desc: "画师\n此人不太爱说话",color: "FF3366",link: "https://example.com"},
            {name: "woofwolf",icon: "woofwolf",desc: "画师",color: "FF3366",link: "https://example.com"},
            {name: "yibo",icon: "yibo",desc: "画师\n一波秒了怎么说(雾)",color: "FF3366",link: "https://space.bilibili.com/3546838888090366?spm_id_from=333.1387.follow.user_card.click"},
            {name: "kabin27",icon: "kabin27",desc: "画师",color: "FF3366",link: "https://example.com"},
            {name: "Yike_Forst",icon: "Yike_Forst",desc: "画师",color: "FF3366",link: "https://example.com"},
            {name: "yf",icon: "yf",desc: "画师\n你这贴图怎么弹道偏上(雾)",color: "FF3366",link: "https://space.bilibili.com/3494359978740369"},
            {name: "Molly",icon: "Molly",desc: "画师",color: "FF3366",link: "https://space.bilibili.com/1936357692?spm_id_from=333.1387.follow.user_card.click"},
            {name: "Cwy",icon: "Cwy",desc: "程序员\n哎我去,这不deepseek吗(雾)",color: "FF3366",link: "https://example.com"},
            {name: "枫秋Maple_autumn",icon: "maple",desc: "程序员\n哎,你这新手机从哪里来的?\n哦,这是我从手机店买的(雾)\n那么旧的呢?\n当然是去自己家里放着啦(雾)\n那么闲置的物品该怎么办?\n当然是让他闲置着啦(雾)\n\n正经介绍:你好,我是枫秋,以上的吐槽整活皆为我写的(纯整活心理,无恶意),在此,至少在这个版本截至之前我已经换了四个版本和一个引擎(累死我了)\n另外由于一些问题,按enter进入个人b站页面的功能并不是所以人都有的(因为我不知道他们的b站个人页面链接XD)\n还有,话说就我一个credit名字带中文吗...",color: "FF3366",link: "https://space.bilibili.com/678127937?spm_id_from=333.1007.0.0"},
            {name: "zeeling_A&Q",icon: "Song Haotian",desc: "程序员\ncne专业户(雾)",color: "FF3366",link: "https://space.bilibili.com/628649483?spm_id_from=333.1387.follow.user_card.click"},
            {name: "FGguagua",icon: "FGguagua",desc: "程序员\n呱呱",color: "FF3366",link: "https://example.com"},
            {name: "SourCandy233",icon: "SourCandy233",desc: "程序员\n这糖果有点酸了...",color: "FF3366",link: "https://example.com"},
            {name: "FNF Mobile phone player",icon: "FNF Mobile phone player",desc: "程序员\n嚯,我没什么好说的XD",color: "FF3366",link: "https://example.com"},
            {name: "stone",icon: "stone",desc: "程序员\n有点硬核了(雾)",color: "FF3366",link: "https://example.com"},
            {name: "everyone's friend",icon: "everyone's friend",desc: "程序员\n致敬传奇人脉王好朋友\n所以你不是宣发位吗XD(雾)",color: "FF3366",link: "https://space.bilibili.com/476223644"}
        ];
        
    override function create()
    {
        super.create();

        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
        persistentUpdate = true;
        FlxG.mouse.visible = true;

        creditsData = creditsDataCN;
        
        var bg = new FlxBackdrop(Paths.image('menuBG'));
        bg.velocity.set(-30, -30);
        add(bg);
        
        icon = new FlxSprite(50,50).makeGraphic(300, 300, FlxColor.TRANSPARENT);
        add(icon);
        
        nameText = new FlxText(50, 360, 300, "", 24);
        nameText.setFormat(Paths.font("vcr2.ttf"), 36, FlxColor.WHITE, CENTER);
        add(nameText);
        
        descBox = new FlxSprite(400, 50);
        descBox.makeGraphic(FlxG.width - 450, FlxG.height - 100, FlxColor.fromRGB(40, 40, 40, 200));
        descBox.scrollFactor.set();
        add(descBox);
        
        descText = new FlxText(descBox.x + 20, descBox.y + 20, descBox.width - 40, "", 24);
        descText.setFormat(Paths.font("vcr2.ttf"), 28, FlxColor.WHITE, LEFT);
        descText.autoSize = false;
        descText.wordWrap = true;
        add(descText);

        function setupButton(btn:FlxButton, x:Float, y:Float) {
            btn.setPosition(x, y);
            btn.setGraphicSize(300,60);
            btn.updateHitbox();
            
            var label = new FlxText(0, 0, 200, btn.label.text, 24);
            label.fieldWidth = btn.width;
            label.autoSize = false;
            label.wordWrap = false;
            label.offset.y = -5; 
            label.setFormat(Paths.font("vcr2.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
            btn.label = label;
            
            // 悬停效果
            btn.onOver.callback = function() {
                FlxTween.color(btn, 0.2, FlxColor.WHITE, 0x4488CCFF);
            };
            
            btn.onOut.callback = function() {
                FlxTween.color(btn, 0.2, 0x4488CCFF, FlxColor.WHITE);
            };
        }

        prevButton = new FlxButton(0, 0, "上一页", function() changePage(-1));
        nextButton = new FlxButton(0, 0, "下一页", function() changePage(1));

        setupButton(prevButton, 50, 450);
        setupButton(nextButton, 50, 520);
        add(prevButton);
        add(nextButton);

        pageText = new FlxText(50, 600, 300, "Page 1/" + creditsData.length, 24);
        pageText.setFormat(Paths.font("vcr2.ttf"), 24, FlxColor.WHITE, CENTER);
        add(pageText);

        #if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'A_B');
		#end

        updateContent();
    }

    function updateContent()
    {
        var data = creditsData[curPage];
        
        icon.makeGraphic(300, 300, FlxColor.TRANSPARENT);

        if(data.icon != null && data.icon != ""){
            icon.loadGraphic(Paths.image('credits/${data.icon}'));
            icon.setGraphicSize(300, 300);
            icon.updateHitbox();
        }
        
        nameText.text = data.name;
        if(data.color != null){
            var color = FlxColor.fromString('#' + data.color);
            nameText.color = (color != null) ? color : FlxColor.WHITE;
        }
        
        descText.text = data.desc;
        
        prevButton.visible = curPage > 0;
        nextButton.visible = curPage < creditsData.length - 1;

        pageText.text = "Page " + (curPage + 1) + "/" + creditsData.length;
    }

    function changePage(change:Int)
    {
        if (isTransitioning) return;
    
        isTransitioning = true;
        FlxG.sound.play(Paths.sound('scrollMenu'));
        
        FlxTween.tween(icon, {alpha: 0, x: icon.x - 50}, transitionTime/2, {ease: FlxEase.quadOut});
        FlxTween.tween(nameText, {alpha: 0}, transitionTime/2);
        FlxTween.tween(descBox, {alpha: 0}, transitionTime/2); 
        FlxTween.tween(descText, {alpha: 0}, transitionTime/2, {
            onComplete: function(_) {
                curPage = FlxMath.wrap(curPage + change, 0, creditsData.length - 1);
                updateContent();

                icon.x += 150;
                nameText.y += 20;
                descBox.y -= 30;
                
                FlxTween.tween(icon, {alpha: 1, x: icon.x - 100}, transitionTime, {ease: FlxEase.quadOut});
                FlxTween.tween(nameText, {alpha: 1, y: nameText.y - 20}, transitionTime, {ease: FlxEase.quadOut});
                FlxTween.tween(descBox, {alpha: 1, y: descBox.y + 30}, transitionTime, {ease: FlxEase.quadOut});
                FlxTween.tween(descText, {alpha: 1}, transitionTime, {
                    onComplete: function(_) {
                        isTransitioning = false;
                    }
                });
            }
        });
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (FlxG.keys.justPressed.LEFT) changePage(-1);
        if (FlxG.keys.justPressed.RIGHT) changePage(1);
        if (FlxG.keys.justPressed.ENTER #if TOUCH_CONTROLS_ALLOWED || touchPad.buttonA.justPressed #end) FlxG.openURL(creditsData[curPage].link);

        if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
        
        /*if(FlxG.mouse.justPressed && descBox.overlapsPoint(FlxG.mouse.getPosition())){
            FlxG.openURL(creditsData[curPage].link);
        }*/
    }
}