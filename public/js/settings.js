var CANVAS_WIDTH = 1024;
var CANVAS_HEIGHT = 768;

var FPS_TIME      = 1000/24;
var DISABLE_SOUND_MOBILE = true;

var STATE_LOADING = 0;
var STATE_MENU    = 1;
var STATE_HELP    = 1;
var STATE_GAME    = 3;

var GAME_STATE_IDLE         = 0;
var GAME_STATE_SPINNING     = 1;
var GAME_STATE_SHOW_ALL_WIN = 2;
var GAME_STATE_SHOW_WIN     = 3;

var REEL_STATE_START   = 0;
var REEL_STATE_MOVING  = 1;
var REEL_STATE_STOP    = 2;

var ON_MOUSE_DOWN = 0;
var ON_MOUSE_UP   = 1;
var ON_MOUSE_OVER = 2;
var ON_MOUSE_OUT  = 3;
var ON_DRAG_START = 4;
var ON_DRAG_END   = 5;

var REEL_OFFSET_X = 142;
var REEL_OFFSET_Y = 148;

var NUM_REELS = 5;
var NUM_ROWS = 3;
var NUM_SYMBOLS = 10;
var WILD_SYMBOL = 10;
var BONUS_SYMBOL = 9;
var NUM_PAYLINES = 5;
var SYMBOL_SIZE = 140;
var SPACE_BETWEEN_SYMBOLS = 10;
var MAX_FRAMES_REEL_EASE = 16;
var MIN_REEL_LOOPS = 1;
var REEL_DELAY = 0;
var REEL_START_Y = REEL_OFFSET_Y - (SYMBOL_SIZE * 3);
var REEL_ARRIVAL_Y = REEL_OFFSET_Y + (SYMBOL_SIZE * 3);
var TIME_SHOW_WIN = 2000;
var TIME_SHOW_ALL_WINS = 2000;
var MIN_BET = 1;
var MAX_BET = 100;
var TOTAL_MONEY;
var USERID;
var LINES;
var BET;
var MAX_NUM_HOLD = 1;
var UFO_WIDTH = 174;
var UFO_HEIGHT = 248;
var NUM_ALIEN = 3;
var NUM_SYMBOLS_FOR_BONUS = 3;
var PERC_WIN_ALIEN_1 = 50;
var PERC_WIN_ALIEN_2 = 35;
var PERC_WIN_ALIEN_3 = 15;
var SOUNDTRACK_VOLUME = 0.5;