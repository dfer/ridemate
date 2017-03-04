function CGame(oData){
    var _bUpdate = false;
    var _bCanHoldColumns;
    var _bBonus;
    var _iCurState;
    var _iCurReelLoops;
    var _iNextColToStop;
    var _iNumReelsStopped;
    var _iLastLineActive;
    var _iTimeElaps;
    var _iCurWinShown;
    var _iCurBet;
    var _iTotBet;
    var _iMoney;
    var _iNumIndexHold;
    var _iNumAlienInBonus = 0;
    var _aMovingColumns;
    var _aStaticSymbols;
    var _aWinningLine;
    var _aReelSequence;
    var _aFinalSymbolCombo;
    var _aHoldText;
    var _aHitAreaColumn;
    var _aSelectCol;
    var _aIndexColumnHold;
    var _oReelSound;
    var _oCurSymbolWinSound;
    var _oBg;
    var _oFrontSkin;
    var _oInterface;
    var _oPayTable = null;
    var _oBonusPanel;
    
    this._init = function(){
        _iCurState = GAME_STATE_IDLE;
        _bCanHoldColumns = true;
        _iCurReelLoops = 0;
        _iNumReelsStopped = 0;
        _iNumIndexHold = 0;
        
        _aReelSequence = new Array(0,1,2,3,4);
        _iNextColToStop = _aReelSequence[0];
        
        _iMoney = TOTAL_MONEY;
        _iCurBet = BET;
        _iLastLineActive = LINES;
        _iTotBet = _iCurBet * _iLastLineActive;
        
        /*
        // Загружаем данные о фишках, линиях и ставках конкретного игрока
        $.ajax({
                url: 'http://cosmoslot.ru/get_user_info?userid='+USERID,
                //url: 'http://localhost:4567/get_user_info?userid='+USERID,
                async: false,
                timeout: 3000,
                success: function(data) {
                    var from_server = data.split(",");
                    _iMoney = parseInt(from_server[1]);
                    _iCurBet = parseInt(from_server[2]);
                    _iLastLineActive = parseInt(from_server[3]);
                    _iTotBet = _iCurBet * _iLastLineActive;
                    
                    _oInterface = new CInterface(_iCurBet,_iTotBet,_iMoney);
                },
                error: function() {
                    document.location.href = 'http://cosmoslot.ru/main?t=012';
                }
        });
        */
        
        _aFinalSymbolCombo = new Array();
        for(var i=0;i<NUM_ROWS;i++){
            _aFinalSymbolCombo[i] = new Array();
            for(var j=0;j<NUM_REELS;j++){
                _aFinalSymbolCombo[i][j] = 0;
            }
        }
        
        s_oTweenController = new CTweenController();
        
        _oBg = createBitmap(s_oSpriteLibrary.getSprite('bg_game'));
        s_oStage.addChild(_oBg);

        this._initReels();

        _oFrontSkin = createBitmap(s_oSpriteLibrary.getSprite('mask_slot'));
        s_oStage.addChild(_oFrontSkin);

        _oInterface = new CInterface(_iCurBet,_iTotBet,_iMoney);
        this._initStaticSymbols();
        
        this._initHitAreaColumn();
        
        _oBonusPanel = new CBonusPanel();
        _oPayTable = new CPayTablePanel();
		
        _bUpdate = true;
        
        this.activateLines(LINES);
    };
    
    this.unload = function(){
        createjs.Sound.stop();
		s_oSoundTrack = null;
        
        s_oStage.removeChild(_oBg);
        s_oStage.removeChild(_oFrontSkin);
        _oInterface.unload();
        _oPayTable.unload();
        
        for(var k=0;k<_aMovingColumns.length;k++){
            _aMovingColumns[k].unload();
        }
        
        for(var i=0;i<NUM_ROWS;i++){
            for(var j=0;j<NUM_REELS;j++){
                _aStaticSymbols[i][j].unload();
            }
        } 
        
        _oBonusPanel.unload();
    };
    
    this._initReels = function(){  
        var iXPos = REEL_OFFSET_X;
        var iYPos = REEL_OFFSET_Y;
        
        var iCurDelay = 0;
        _aMovingColumns = new Array();
        for(var i=0;i<NUM_REELS;i++){ 
            _aMovingColumns[i] = new CReelColumn(i,iXPos,iYPos,iCurDelay);
            _aMovingColumns[i+NUM_REELS] = new CReelColumn(i+NUM_REELS,iXPos,iYPos + (SYMBOL_SIZE*NUM_ROWS),iCurDelay );
            iXPos += SYMBOL_SIZE + SPACE_BETWEEN_SYMBOLS;
            iCurDelay += REEL_DELAY;
        }
        
    };
    
    this._initStaticSymbols = function(){
        var iXPos = REEL_OFFSET_X;
        var iYPos = REEL_OFFSET_Y;
        _aStaticSymbols = new Array();
        for(var i=0;i<NUM_ROWS;i++){
            _aStaticSymbols[i] = new Array();
            for(var j=0;j<NUM_REELS;j++){
                var oSymbol = new CStaticSymbolCell(i,j,iXPos,iYPos);
                _aStaticSymbols[i][j] = oSymbol;
                
                iXPos += SYMBOL_SIZE + SPACE_BETWEEN_SYMBOLS;
            }
            iXPos = REEL_OFFSET_X;
            iYPos += SYMBOL_SIZE;
        }
    };
    
    this._initHitAreaColumn = function(){
        _aIndexColumnHold = new Array();
        _aSelectCol = new Array();
        iX = 136;
        iY = 144;
        for(var j=0;j<NUM_REELS;j++){
            var oSelect = createBitmap( s_oSpriteLibrary.getSprite('hold_col'));
            oSelect.x = iX;
            oSelect.y = iY;
            oSelect.visible = false;
            s_oStage.addChild(oSelect);
            
            iX += 150;
            
            _aSelectCol.push(oSelect);
            _aIndexColumnHold[j] = false;
        }
        
        _aHoldText = new Array();
        _aHitAreaColumn = new Array();
        
        var iX = 141;
        var iY = 148;
        var oSprite = s_oSpriteLibrary.getSprite('hit_area_col');
        for(var i=0;i<NUM_REELS;i++){
            var oText = new createjs.Text(TEXT_HOLD,"22px walibi0615bold", "#fa72b9");
            oText.visible = false;
            oText.x = iX + oSprite.width/2;
            oText.y = iY + oSprite.height - 20;
            oText.shadow = new createjs.Shadow("#000", 1, 1, 2);
            oText.textAlign = "center";
            s_oStage.addChild(oText);
            _aHoldText[i] = oText;
            
            var oHitArea = new CGfxButton(iX + (oSprite.width/2),iY +(oSprite.height/2),oSprite);
            oHitArea.setVisible(false);
            oHitArea.addEventListenerWithParams(ON_MOUSE_UP, this._onHitAreaCol, this,{index:i});
            
            iX += 150;
            
            _aHitAreaColumn.push(oHitArea);
        }  
    };
    
    this._generateRandSymbols = function() {
        var aRandSymbols = new Array();
        for (var i = 0; i < NUM_ROWS; i++) {
                var iRandIndex = Math.floor(Math.random()* s_aRandSymbols.length);
                aRandSymbols[i] = s_aRandSymbols[iRandIndex];
        }

        return aRandSymbols;
    };
    
    this.reelArrived = function(iReelIndex,iCol) {
        if(_iCurReelLoops>MIN_REEL_LOOPS ){
            
            if (_iNextColToStop === iCol) {
                
                if (_aMovingColumns[iReelIndex].isReadyToStop() === false) {
                    var iNewReelInd = iReelIndex;
                    if (iReelIndex < NUM_REELS) {
                            iNewReelInd += NUM_REELS;
                            
                            _aMovingColumns[iNewReelInd].setReadyToStop();
                            
                            _aMovingColumns[iReelIndex].restart(new Array(_aFinalSymbolCombo[0][iReelIndex],
                                                                          _aFinalSymbolCombo[1][iReelIndex],
                                                                          _aFinalSymbolCombo[2][iReelIndex]), true);
                            
                    }else {
                            iNewReelInd -= NUM_REELS;
                            _aMovingColumns[iNewReelInd].setReadyToStop();
                            
                            _aMovingColumns[iReelIndex].restart(new Array(_aFinalSymbolCombo[0][iNewReelInd],
                                                                          _aFinalSymbolCombo[1][iNewReelInd],
                                                                          _aFinalSymbolCombo[2][iNewReelInd]), true);    
                    }
                    
                }
            }else {
                    _aMovingColumns[iReelIndex].restart(this._generateRandSymbols(),false);
            }   
        }else {    
            _aMovingColumns[iReelIndex].restart(this._generateRandSymbols(), false);
            if(iReelIndex === 0){
                _iCurReelLoops++;
            }
            
        }
    };
    
    this.increaseReelLoops = function(){
        _iCurReelLoops += 2;
    };
    
    this.stopNextReel = function() {
        _iNumReelsStopped++;
        if(_iNumReelsStopped%2 === 0){
            
            if(DISABLE_SOUND_MOBILE === false || s_bMobile === false){
                createjs.Sound.play("reel_stop",{volume:0.3});
            }
            
            _iNextColToStop = _aReelSequence[_iNumReelsStopped/2];
            
            if (_iNumReelsStopped === (NUM_REELS*2) ) {
                this._endReelAnimation();
            }
        }    
    };
    
    this._endReelAnimation = function(){
        if(DISABLE_SOUND_MOBILE === false || s_bMobile === false){
            _oReelSound.stop();
        }

        _iCurReelLoops = 0;
        _iNumReelsStopped = 0;
        _iNextColToStop = _aReelSequence[0];
        
        for(var k=0;k<NUM_REELS;k++){
            _aIndexColumnHold[k] =  false;
            _aSelectCol[k].visible = false;
            _aMovingColumns[k].setHold(false);
            _aMovingColumns[k+NUM_REELS].setHold(false);
        }
        
        _iNumIndexHold = 0;
        
        var iTotWin = 0;
        //INCREASE MONEY IF THERE ARE COMBOS
        if(_aWinningLine.length > 0){
            //HIGHLIGHT WIN COMBOS IN PAYTABLE
            for(var i=0;i<_aWinningLine.length;i++){
                _oPayTable.highlightCombo(_aWinningLine[i].value,_aWinningLine[i].num_win);
                
                if(_aWinningLine[i].line !== -1){
                    _oInterface.showLine(_aWinningLine[i].line);
                }
                var aList = _aWinningLine[i].list;
                for(var k=0;k<aList.length;k++){
                    _aStaticSymbols[aList[k].row][aList[k].col].show(aList[k].value);
                }
                iTotWin += _aWinningLine[i].amount;
            }

			iTotWin *=_iCurBet;
			
            _iMoney += iTotWin;
            
            if(iTotWin>0){
                _oInterface.refreshMoney(_iMoney);
                _oInterface.refreshWinText(iTotWin);
            }
            _iTimeElaps = 0;
            _iCurState = GAME_STATE_SHOW_ALL_WIN;
            
            if(DISABLE_SOUND_MOBILE === false || s_bMobile === false){
                _oCurSymbolWinSound = createjs.Sound.play("win");
            }
        }else{
            if(_bCanHoldColumns){
                this.enableColumnHitArea();
            }
            _iCurState = GAME_STATE_IDLE;
        }
        
        if(_bCanHoldColumns === false){
            _bCanHoldColumns = true;
        }
        
        if(_bBonus === false){
            _oInterface.disableBetBut(false);
            _oInterface.enableGuiButtons();
        }

        $(s_oMain).trigger("end_bet",[_iMoney,iTotWin]);
    };

    this.hidePayTable = function(){
        _oPayTable.hide();
    };
    
    this._showWin = function(){
        var iLineIndex;
        if(_iCurWinShown>0){ 
            if(DISABLE_SOUND_MOBILE === false || s_bMobile === false){
                _oCurSymbolWinSound.stop();
            }
            
            if(_aWinningLine[_iCurWinShown-1].line !== -1){
                iLineIndex = _aWinningLine[_iCurWinShown-1].line;
                _oInterface.hideLine(iLineIndex);
            }
            var aList = _aWinningLine[_iCurWinShown-1].list;
            for(var k=0;k<aList.length;k++){
                _aStaticSymbols[aList[k].row][aList[k].col].stopAnim();
            }
        }
        
        if(_iCurWinShown === _aWinningLine.length){
            _iCurWinShown = 0;
        }
        
        if(_aWinningLine[_iCurWinShown].line !== -1){
            iLineIndex = _aWinningLine[_iCurWinShown].line;
            _oInterface.showLine(iLineIndex);
        }

        var aList = _aWinningLine[_iCurWinShown].list;
        for(var k=0;k<aList.length;k++){
            _aStaticSymbols[aList[k].row][aList[k].col].show(aList[k].value);
        }
            
        _iCurWinShown++;
    };
    
    this._hideAllWins = function(){
        for(var i=0;i<_aWinningLine.length;i++){
            var aList = _aWinningLine[i].list;
            for(var k=0;k<aList.length;k++){
                _aStaticSymbols[aList[k].row][aList[k].col].stopAnim();
            }
        }
        
        _oInterface.hideAllLines();

        _iTimeElaps = 0;
        _iCurWinShown = 0;
        _iTimeElaps = TIME_SHOW_WIN;
        _iCurState = GAME_STATE_SHOW_WIN;
        
        if(_bBonus){
            _oBonusPanel.show(_iNumAlienInBonus);
        }
    };
    
    this.enableColumnHitArea = function(){
        for(var i=0;i<NUM_REELS;i++){
            _aHoldText[i].visible = true;
            _aHitAreaColumn[i].setVisible(true);
        }
    };

    this.disableColumnHitArea = function(){
        for(var i=0;i<NUM_REELS;i++){
            _aHoldText[i].visible = false;
            _aHitAreaColumn[i].setVisible(false);
        }
    };
    
    this.activateLines = function(iLine){
        _iLastLineActive = iLine;
        this.removeWinShowing();
		
		var iNewTotalBet = _iCurBet * _iLastLineActive;

		_iTotBet = iNewTotalBet;
		_oInterface.refreshTotalBet(_iTotBet);
		_oInterface.refreshNumLines(_iLastLineActive);
		
		
		if(iNewTotalBet>_iMoney){
			_oInterface.disableSpin();
		}else{
			_oInterface.enableSpin();
		}
    };
	
    this.addLine = function(){
        if(_iLastLineActive === NUM_PAYLINES){
            _iLastLineActive = 1;  
        }else{
            _iLastLineActive++;    
        }
		
		var iNewTotalBet = _iCurBet * _iLastLineActive;

		_iTotBet = iNewTotalBet;
		_oInterface.refreshTotalBet(_iTotBet);
		_oInterface.refreshNumLines(_iLastLineActive);
		
		
		if(iNewTotalBet>_iMoney){
			_oInterface.disableSpin();
		}else{
			_oInterface.enableSpin();
		}
    };
    
    // Установка ставки в игре
    this.changeCoinBet = function(){
        if (_iCurBet == 10) {
            _iCurBet = 15;
        } else if (_iCurBet == 15) {
            _iCurBet = 20;
        } else if (_iCurBet == 20) {
            _iCurBet = 25;
        } else if (_iCurBet == 25) {
            _iCurBet = 50;
        } else if (_iCurBet == 50) {
            _iCurBet = 100;
        } else if (_iCurBet == 100) {
            _iCurBet = 1;
        } else {
            _iCurBet += 1;       
        }
        
        var iNewBet = _iCurBet;
        var iNewTotalBet = iNewBet * _iLastLineActive;
        
        _iTotBet = iNewTotalBet;
        _oInterface.refreshBet(_iCurBet);
        _oInterface.refreshTotalBet(_iTotBet);
        
        // Проверка осталась от старой версии функции
        if (iNewBet>MAX_BET){
            _iCurBet = MIN_BET;
            _iTotBet = _iCurBet * _iLastLineActive;
            _oInterface.refreshBet(_iCurBet);
            _oInterface.refreshTotalBet(_iTotBet);
            iNewTotalBet = _iTotBet;
        }
        
        if (iNewTotalBet > _iMoney) {
            _oInterface.disableSpin();
        }else{
            _oInterface.enableSpin();
        }
    };
    
    this.onMaxBet = function(){
        var iNewBet = MAX_BET;
		_iLastLineActive = NUM_PAYLINES;
        
        var iNewTotalBet = iNewBet * _iLastLineActive;

		_iCurBet = MAX_BET;
		_iTotBet = iNewTotalBet;
		_oInterface.refreshBet(_iCurBet);
		_oInterface.refreshTotalBet(_iTotBet);
		_oInterface.refreshNumLines(_iLastLineActive);
        
		if(iNewTotalBet>_iMoney){
			document.location.href = 'http://cosmoslot.ru/payment';
            //_oInterface.disableSpin();
		}else{
			_oInterface.enableSpin();
			this.onSpin();
		}
    };
    
    this._onHitAreaCol = function(oParam){
        var iIndexCol = oParam.index;
        if(_aIndexColumnHold[iIndexCol] === true){
            _aIndexColumnHold[iIndexCol] =  false;
            _aSelectCol[iIndexCol].visible = false;
            _aHoldText[iIndexCol].visible = true;
            
            _iNumIndexHold--;
            
            _aMovingColumns[iIndexCol].setHold(false);
            _aMovingColumns[iIndexCol+NUM_REELS].setHold(false);
            
        }else if(_iNumIndexHold < MAX_NUM_HOLD){
            _aIndexColumnHold[iIndexCol] =  true;
            _iNumIndexHold++; 
            _aSelectCol[iIndexCol].visible = true;
            _aHoldText[iIndexCol].visible = false;
            _aMovingColumns[iIndexCol].setHold(true);
            _aMovingColumns[iIndexCol+NUM_REELS].setHold(true);
            
            if(DISABLE_SOUND_MOBILE === false || s_bMobile === false){
                createjs.Sound.play("press_hold");
            }
        }
        
        _bCanHoldColumns = false;
    };
    
    this.removeWinShowing = function(){
        _oPayTable.resetHighlightCombo();
        
        _oInterface.resetWin();
        
        for(var i=0;i<NUM_ROWS;i++){
            for(var j=0;j<NUM_REELS;j++){
                _aStaticSymbols[i][j].hide();
            }
        }
        
        for(var k=0;k<_aMovingColumns.length;k++){
            _aMovingColumns[k].activate();
        }
        
        _iCurState = GAME_STATE_IDLE;
    };
    
    this.endBonus = function(iBonus){

        _iMoney += iBonus;
        _oInterface.refreshMoney(_iMoney);
        
        _oInterface.disableBetBut(false);
        _oInterface.enableGuiButtons();
    };
    
    this.onSpin = function(){
        // Если игрок пытается играть при отсутствии денег, то перенаправить его в платежку
        if(_iMoney < _iTotBet){
            document.location.href = 'http://cosmoslot.ru/payment';
        } else {
            if(DISABLE_SOUND_MOBILE === false || s_bMobile === false){
                if(_oCurSymbolWinSound){
                    _oCurSymbolWinSound.stop();
                }
                _oReelSound = createjs.Sound.play("reels",{volume:0.3});
            }
            
            // Попытка получить данные, которые у нас в данный момент на игровом поле
            var field_info = "";
            var hold_number = 0;
            
            for(var j=0; j<NUM_REELS; j++){
                if(_aMovingColumns[j].isHold() == true){
                    hold_number = j+1;
                }
            }
            
            field_info += hold_number+",";
            
            for(var i=0;i<NUM_ROWS;i++){
                for(var j=0;j<NUM_REELS;j++){
                    field_info += _aFinalSymbolCombo[i][j]+",";
                }
            }
            // Данные о деньгах
            field_info += _iMoney+","+_iLastLineActive+","+_iCurBet+","+USERID;
            
            this.disableColumnHitArea();
            _oInterface.disableBetBut(true);
            this.removeWinShowing();
            
            $.ajax({
                url: 'http://cosmoslot.ru/ajax_test?fi='+field_info,
                //url: 'http://localhost:4567/ajax_test?fi='+field_info,
                async: true,
                timeout: 5000,
                beforeSend: function() {
                    _oInterface.hideAllLines();
                    _oInterface.disableGuiButtons();
                    _iMoney -= _iTotBet;
                    _oInterface.refreshMoney(_iMoney);

                    _iCurState = GAME_STATE_SPINNING;
                },
                success: function(data) {
                    if (data == 'false') {
                        document.location.href = 'http://cosmoslot.ru/main?t=123';
                    }
                    var from_server = data.split(",");
                    
                    for(var i=0;i<NUM_ROWS;i++){
                        for(var j=0;j<NUM_REELS;j++){
                            _aFinalSymbolCombo[i][j] = parseInt(from_server[i*5+j]);
                        }
                    }
                    
                    // Ниже код из generateFinalSymbols
                    //CHECK IF THERE IS ANY COMBO
                    _aWinningLine = new Array();
                    for(var k=0;k<_iLastLineActive;k++){
                        var aCombos = s_aPaylineCombo[k];
                        
                        var aCellList = new Array();
                        // Получаем первый символ в линии
                        var iValue = _aFinalSymbolCombo[aCombos[0].row][aCombos[0].col];
                        if(iValue !== BONUS_SYMBOL){
                            var iNumEqualSymbol = 1;
                            var iStartIndex = 1;
                            // Сохраняем первый символ в массив
                            aCellList.push({row:aCombos[0].row,col:aCombos[0].col,value:_aFinalSymbolCombo[aCombos[0].row][aCombos[0].col]});
                            
                            // Смотрим, если первый символ является WILD, то есть ли следующие такие же?
                            while(iValue === WILD_SYMBOL && iStartIndex<NUM_REELS){
                                iNumEqualSymbol++;
                                iValue = _aFinalSymbolCombo[aCombos[iStartIndex].row][aCombos[iStartIndex].col];
                                aCellList.push({row:aCombos[iStartIndex].row,col:aCombos[iStartIndex].col,value:_aFinalSymbolCombo[aCombos[iStartIndex].row][aCombos[iStartIndex].col]});
                                iStartIndex++;
                            }

                            for(var t=iStartIndex;t<aCombos.length;t++){
                                if(_aFinalSymbolCombo[aCombos[t].row][aCombos[t].col] === iValue || _aFinalSymbolCombo[aCombos[t].row][aCombos[t].col] === WILD_SYMBOL){
                                    if(_aFinalSymbolCombo[aCombos[t].row][aCombos[t].col] === BONUS_SYMBOL){
                                        break;
                                    }
                                    iNumEqualSymbol++;

                                    aCellList.push({row:aCombos[t].row,col:aCombos[t].col,value:_aFinalSymbolCombo[aCombos[t].row][aCombos[t].col]});
                                }else{
                                    break;
                                }
                            }
                            
                            if(s_aSymbolWin[iValue-1][iNumEqualSymbol-1] > 0){
                                _aWinningLine.push({line:k+1,amount:s_aSymbolWin[iValue-1][iNumEqualSymbol-1],num_win:iNumEqualSymbol,value:iValue,list:aCellList});
                            }
                        }
                    }
                    
                    //CHECK IF THERE IS BONUS
                    _bBonus = false;
                    _iNumAlienInBonus = 0;
                    var aBonusSymbols = new Array();
                    for(var i=0;i<NUM_ROWS;i++){
                        for(var j=0;j<NUM_REELS;j++){
                            if( _aFinalSymbolCombo[i][j] === BONUS_SYMBOL){
                                aBonusSymbols.push({row:i,col:j,value:_aFinalSymbolCombo[i][j]});
                                _iNumAlienInBonus++;
                            }
                        }
                    }
                    
                    if(_iNumAlienInBonus >= NUM_SYMBOLS_FOR_BONUS){
                        _aWinningLine.push({line:-1,amount:0,num_win:_iNumAlienInBonus,value:BONUS_SYMBOL,list:aBonusSymbols});
                        
                        if(_iNumAlienInBonus>5){
                            _iNumAlienInBonus = 5; 
                        }
                        
                        _bBonus = true;
                    }
                },
                error: function() {
                    document.location.href = 'http://cosmoslot.ru/main?t=456';
                }
            });
        }
    };
    
    this.onInfoClicked = function(){
        if(_iCurState === GAME_STATE_SPINNING){
            return;
        }
        
        if(_oPayTable.isVisible()){
            _oPayTable.hide();
        }else{
            _oPayTable.show();
        }
    };

    this.onExit = function(){
        this.unload();
        s_oMain.gotoMenu();
        $(s_oMain).trigger("restart");
    };
    
    this.getState = function(){
        return _iCurState;
    };
    
    this.update = function(){
        if(_bUpdate === false){
            return;
        }
        
        switch(_iCurState){
            case GAME_STATE_SPINNING:{
                for(var i=0;i<_aMovingColumns.length;i++){
                    _aMovingColumns[i].update(_iNextColToStop);
                }
                break;
            }
            case GAME_STATE_SHOW_ALL_WIN:{
                    _iTimeElaps += s_iTimeElaps;
                    if(_iTimeElaps> TIME_SHOW_ALL_WINS){  
                        this._hideAllWins();
                    }
                    break;
            }
            case GAME_STATE_SHOW_WIN:{
                _iTimeElaps += s_iTimeElaps;
                if(_iTimeElaps > TIME_SHOW_WIN){
                    _iTimeElaps = 0;

                    this._showWin();
                }
                break;
            }
        }
    };
    
    s_oGame = this;
    USERID = oData.userid;
    TOTAL_MONEY = oData.money;
    LINES = oData.lines;
    BET = oData.bet;
    
    new CSlotSettings();
    
    this._init();
}

var s_oGame;
var s_oTweenController;