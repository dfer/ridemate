function CInterface(iCurBet,iTotBet,iMoney){
    var _aLinesBut;
    var _aPayline;
    var _oButExit;
    var _oSpinBut;
    var _oInfoBut;
    var _oMoneyBut;
    var _oAddLineBut;
    var _oAudioToggle;
    var _oBetCoinBut;
    var _oMaxBetBut;

    var _oCoinText;
    var _oMoneyText;
    var _oTotalBetText;
    var _oNumLinesText;
    
    this._init = function(iCurBet,iTotBet,iMoney){
        /**/
        var oSprite = s_oSpriteLibrary.getSprite('but_exit');
        //_oButExit = new CGfxButton(CANVAS_WIDTH - (oSprite.width/2) - 20,(oSprite.height/2) + 20,oSprite,true);
        //_oButExit.addEventListener(ON_MOUSE_UP, this._onExit, this);
        /**/
        
        if(DISABLE_SOUND_MOBILE === false || s_bMobile === false){
            _oAudioToggle = new CToggle(CANVAS_WIDTH - (oSprite.width/2) - 20, (oSprite.height/2) + 20,s_oSpriteLibrary.getSprite('audio_icon'));
            _oAudioToggle.addEventListener(ON_MOUSE_UP, this._onAudioToggle, this);
        }
        
        var oSprite = s_oSpriteLibrary.getSprite('spin_but');
        _oSpinBut = new CTextButton(830 + (oSprite.width/2),610 + (oSprite.height/2),oSprite,"","walibi0615bold","#f951aa",22);  
        _oSpinBut.addEventListener(ON_MOUSE_UP, this._onSpin, this);
        
        oSprite = s_oSpriteLibrary.getSprite('info_but');
        _oInfoBut = new CTextButton(28 + (oSprite.width/2),642 + (oSprite.height/2),oSprite,TEXT_INFO,"walibi0615bold","#ffffff",30);        
        _oInfoBut.addEventListener(ON_MOUSE_UP, this._onInfo, this);
        
        oSprite = s_oSpriteLibrary.getSprite('but_lines_bg');
        _oAddLineBut = new CTextButton(194 + (oSprite.width/2),642 + (oSprite.height/2),oSprite,TEXT_LINES,"walibi0615bold","#ffffff",30);
        _oAddLineBut.addEventListener(ON_MOUSE_UP, this._onAddLine, this);
        
        oSprite = s_oSpriteLibrary.getSprite('coin_but');
        _oBetCoinBut = new CTextButton(380 + (oSprite.width/2),642 + (oSprite.height/2),oSprite,TEXT_COIN,"walibi0615bold","#ffffff",30);
        _oBetCoinBut.addEventListener(ON_MOUSE_UP, this._onBet, this);
        
        oSprite = s_oSpriteLibrary.getSprite('but_maxbet_bg');
        _oMaxBetBut = new CTextButton(566 + (oSprite.width/2),642 + (oSprite.height/2),oSprite,TEXT_MAX_BET,"walibi0615bold","#ffffff",30);
        _oMaxBetBut.addEventListener(ON_MOUSE_UP, this._onMaxBet, this);
		
        //-------
        oSprite = s_oSpriteLibrary.getSprite('money_but');
        _oMoneyBut = new CTextButton(25 + (oSprite.width/2), 30 + (oSprite.height/2),oSprite,"","walibi0615bold","#ffffff",30);        
        _oMoneyBut.addEventListener(ON_MOUSE_UP, this._onMoney, this)
        //---
	    
        _oMoneyText = new createjs.Text("$ "+iMoney,"30px walibi0615bold", "#ffffff");
        _oMoneyText.x = 160;
        _oMoneyText.y = 85;
        _oMoneyText.textBaseline = "alphabetic";
        _oMoneyText.lineHeight = 28;
        _oMoneyText.textAlign = "center";
        s_oStage.addChild(_oMoneyText);
        
        
        _oNumLinesText = new createjs.Text(NUM_PAYLINES ,"30px walibi0615bold", "#ffffff");
        _oNumLinesText.x =  284;
        _oNumLinesText.y = CANVAS_HEIGHT - 135;
        _oNumLinesText.shadow = new createjs.Shadow("#000", 2, 2, 2);
        _oNumLinesText.textAlign = "center";
        _oNumLinesText.textBaseline = "alphabetic";
        s_oStage.addChild(_oNumLinesText);
        
        _oCoinText = new createjs.Text(iCurBet,"30px walibi0615bold", "#ffffff");
        _oCoinText.x =  476;
        _oCoinText.y = CANVAS_HEIGHT - 135;
        _oCoinText.shadow = new createjs.Shadow("#000", 2, 2, 2);
        _oCoinText.textAlign = "center";
        _oCoinText.textBaseline = "alphabetic";
        s_oStage.addChild(_oCoinText);

        _oTotalBetText = new createjs.Text(TEXT_BET +": "+iTotBet,"30px walibi0615bold", "#ffffff");
        _oTotalBetText.x = 680;
        _oTotalBetText.y = CANVAS_HEIGHT - 135;
        _oTotalBetText.shadow = new createjs.Shadow("#000", 2, 2, 2);
        _oTotalBetText.textAlign = "center";
        _oTotalBetText.textBaseline = "alphabetic";
        s_oStage.addChild(_oTotalBetText);
        
        oSprite = s_oSpriteLibrary.getSprite('bet_but');
        _aLinesBut = new Array();
        
        //LINE 1
        var oBut = new CBetBut( 95 + oSprite.width/2, 313 + oSprite.height/2,oSprite,true);
        oBut.addEventListenerWithParams(ON_MOUSE_UP, this._onBetLineClicked, this,1);
        _aLinesBut[0] = oBut;
        
        //LINE 2
        oBut = new CBetBut( 95 + oSprite.width/2, 211 + oSprite.height/2,oSprite,true);
        oBut.addEventListenerWithParams(ON_MOUSE_UP, this._onBetLineClicked, this,2);
        _aLinesBut[1] = oBut;
        
        //LINE 3
        oBut = new CBetBut( 95 + oSprite.width/2, 462 + oSprite.height/2,oSprite,true);
        oBut.addEventListenerWithParams(ON_MOUSE_UP, this._onBetLineClicked, this,3);
        _aLinesBut[2] = oBut;
        
        //LINE 4
        oBut = new CBetBut( 95 + oSprite.width/2, 144 + oSprite.height/2,oSprite,true);
        oBut.addEventListenerWithParams(ON_MOUSE_UP, this._onBetLineClicked, this,4);
        _aLinesBut[3] = oBut;

        //LINE 5
        oBut = new CBetBut( 95 + oSprite.width/2, 531 + oSprite.height/2,oSprite,true);
        oBut.addEventListenerWithParams(ON_MOUSE_UP, this._onBetLineClicked, this,5);
        _aLinesBut[4] = oBut;

        _aPayline = new Array();
        for(var k = 0;k<NUM_PAYLINES;k++){
            var oBmp = new createjs.Bitmap(s_oSpriteLibrary.getSprite('payline_'+(k+1) ));
            oBmp.x = 0;
            oBmp.y = 0;
            oBmp.visible = false;
            s_oStage.addChild(oBmp);
            _aPayline[k] = oBmp;
        }
    };
    
    this.unload = function(){
        _oButExit.unload();
        _oButExit = null;
        _oSpinBut.unload();
        _oSpinBut = null;
        _oInfoBut.unload();
        _oInfoBut = null;
        _oAddLineBut.unload();
        _oAddLineBut = null;
        _oBetCoinBut.unload();
        _oBetCoinBut = null;
        _oMaxBetBut.unload();
        _oMaxBetBut = null;
        
        if(DISABLE_SOUND_MOBILE === false){
            _oAudioToggle.unload();
            _oAudioToggle = null;
        }

        s_oStage.removeChild(_oTotalBetText);
        s_oStage.removeChild(_oNumLinesText);
        s_oStage.removeChild(_oMoneyText);
        s_oStage.removeChild(_oCoinText);

        for(var i=0;i<NUM_PAYLINES;i++){
            _aLinesBut[i].unload();
            s_oStage.removeChild(_aPayline[i]);
        }
    };

    this.refreshMoney = function(iMoney){
        _oMoneyText.text = "$ "+iMoney;
    };
    
    this.refreshBet = function(iBet){
        _oCoinText.text = iBet;
    };
    
    this.refreshTotalBet = function(iTotBet){
        _oTotalBetText.text = TEXT_BET +": "+iTotBet;
    };
    
    this.refreshNumLines = function(iLines){
        _oNumLinesText.text = iLines;
        
        for(var i=0;i<NUM_PAYLINES;i++){
            if(i<iLines){
                _aLinesBut[i].setOn();
                _aPayline[i].visible = true;
            }else{
                _aLinesBut[i].setOff();
            }
        }
        
        setTimeout(function(){for(var i=0;i<NUM_PAYLINES;i++){
            _aPayline[i].visible = false;
        }},1000);
    };
    
    this.resetWin = function(){
        _oSpinBut.changeText("");
    };
    
    this.refreshWinText = function(iWin){
        _oSpinBut.changeText(TEXT_WIN + "\n"+iWin);
    };
    
    this.showLine = function(iLine){
        _aPayline[iLine-1].visible = true;
    };
    
    this.hideLine = function(iLine){
        _aPayline[iLine-1].visible = false;
    };
    
    this.hideAllLines = function(){
        for(var i=0;i<NUM_PAYLINES;i++){
            _aPayline[i].visible = false;
        }
    };
    
    this.disableBetBut = function(bDisable){
        for(var i=0;i<NUM_PAYLINES;i++){
            _aLinesBut[i].disable(bDisable);
        }
    };
    
    this.enableGuiButtons = function(){
        _oSpinBut.enable();
        _oMaxBetBut.enable();
        _oBetCoinBut.enable();
        _oAddLineBut.enable();
        _oInfoBut.enable();
    };
	
	this.enableSpin = function(){
		_oSpinBut.enable();
		_oMaxBetBut.enable();
	};
	
	this.disableSpin = function(){
		_oSpinBut.disable();
		_oMaxBetBut.disable();
	};
    
    this.disableGuiButtons = function(){
        _oSpinBut.disable();
        _oMaxBetBut.disable();
        _oBetCoinBut.disable();
        _oAddLineBut.disable();
        _oInfoBut.disable();
    };
    
    this._onBetLineClicked = function(iLine){
        this.refreshNumLines(iLine);
        
        s_oGame.activateLines(iLine);
    };
    
    this._onExit = function(){
        s_oGame.onExit();  
    };
    
    this._onSpin = function(){
        s_oGame.onSpin();
    };
    
    this._onAddLine = function(){
        s_oGame.addLine();
    };
    
    this._onInfo = function(){
        s_oGame.onInfoClicked();
    };
    
    this._onMoney = function(){
        document.location.href = 'http://cosmoslot.ru/payment';
    };
    
    this._onBet = function(){
        s_oGame.changeCoinBet();
    };
    
    this._onMaxBet = function(){
        s_oGame.onMaxBet();
    };
    
    this._onAudioToggle = function(){
        createjs.Sound.setMute(!s_bAudioActive);
    };
    
    s_oInterface = this;
    
    this._init(iCurBet,iTotBet,iMoney);
    
    return this;
}

var s_oInterface;