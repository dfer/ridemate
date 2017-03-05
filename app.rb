require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'base64'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'
require 'redis'
require "erb"
require 'digest' # Для формирования ключа sha1 в Xsolla и md5 при oauth
include ERB::Util

require_relative 'models/myredis'
require_relative 'models/user'

#set :environment, :production
set :sessions, true
set :static, true
set :session_secret, 'super secret ridemate'
disable :protection

# Вспомогательные функции
helpers do
	$r_new = Array.new
	
	$r_new[0] = Redis.new(:host=>"95.213.237.75", :port=>"6441", :password=>'BSDr56dfghj3tdbjg5547yrdgHytrvb54e1')
	$r_new[1] = Redis.new(:host=>"95.213.237.75", :port=>"6441", :password=>'BSDr56dfghj3tdbjg5547yrdgHytrvb54e1')
	$r_new[2] = Redis.new(:host=>"95.213.237.75", :port=>"6441", :password=>'BSDr56dfghj3tdbjg5547yrdgHytrvb54e1')
	$r_new[3] = Redis.new(:host=>"95.213.237.75", :port=>"6441", :password=>'BSDr56dfghj3tdbjg5547yrdgHytrvb54e1')
	
	# Класс прослойка для работы с базой Redis
	# Передаем параметры подключения к старой базе, чтобы можно было передать их родительскому классу
	$r = MyRedis.new
	
	# Используется для ajax-запросов. Запросы не должны быть кросс-доменными
	#URL = 'http://localhost:4567'
	URL = 'http://vlast.ru'
	
	# Базовый путь до картинок и других файлов в облаке
	IMAGE_URL_ALL = 'http://144.76.72.53:100/logist'
	IMAGE_URL_GAME = 'http://144.76.72.53:100/logist/game_cosmoslot'
	
	# Считаем что игрок онлайн, если были действия в последние 30 минут
	ONLINE_TIME = 86400
	
	# Ссылки на счетчики.
	FOOTER_ON_MAIN_PAGES = '</body></html>'
	FOOTER_ON_INDEX_PAGE = '</body></html>'
	
	# Константы с значениями иконок
	ICON_ARROW = '<img src="'+IMAGE_URL_ALL+'/basic_icons/arrow.png" alt="o" height="16" width="16" />'
	ICON_ARROW_UP = '<img src="'+IMAGE_URL_ALL+'/basic_icons/arrow-up.png" alt="o" height="16" width="16" />'
	ICON_NEW = '<img src="'+IMAGE_URL_ALL+'/basic_icons/new.png" alt="o" height="16" width="16" />'
	ICON_NEW2 = '<img src="'+IMAGE_URL_ALL+'/basic_icons/new2.png" alt="o" height="16" width="16" />'
	ICON_NEW_TEXT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/new-text.png" alt="o" height="16" width="16" />'
	ICON_ARROW_DOWN = '<img src="'+IMAGE_URL_ALL+'/basic_icons/arrow-down.png" alt="o" height="16" width="16" />'
	ICON_ARROW_LEFT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/arrow-180.png" alt="o" height="16" width="16" />'
	ICON_FORM = '<img src="'+IMAGE_URL_ALL+'/basic_icons/signup.png" alt="o" height="16" width="16" />'
	ICON_CAR = '<img src="'+IMAGE_URL_ALL+'/basic_icons/car.png" alt="o" height="16" width="16" />'
	ICON_KEY  = '<img src="'+IMAGE_URL_ALL+'/basic_icons/login.png" alt="o" height="16" width="16" />'
	ICON_TRUCK= '<img src="'+IMAGE_URL_ALL+'/basic_icons/truck.png" alt="o" height="16" width="16" />'
	ICON_TRUCK_EMPTY= '<img src="'+IMAGE_URL_ALL+'/basic_icons/truck-empty.png" alt="o" height="16" width="16" />'
	ICON_TASK= '<img src="'+IMAGE_URL_ALL+'/basic_icons/clipboard--plus.png" alt="o" height="16" width="16" />'
	ICON_ABOUT= '<img src="'+IMAGE_URL_ALL+'/basic_icons/question.png" alt="o" height="16" width="16" />'
	ICON_CHART= '<img src="'+IMAGE_URL_ALL+'/basic_icons/chart.png" alt="o" height="16" width="16" />'
	ICON_FIND= '<img src="'+IMAGE_URL_ALL+'/basic_icons/find.png" alt="o" height="16" width="16" />'
	ICON_PLUS= '<img src="'+IMAGE_URL_ALL+'/basic_icons/plus.png" alt="o" height="16" width="16" />'
	ICON_MINUS= '<img src="'+IMAGE_URL_ALL+'/basic_icons/minus.png" alt="o" height="16" width="16" />'
	ICON_PLUS2= '<img src="'+IMAGE_URL_ALL+'/basic_icons/plus-circle.png" alt="o" height="16" width="16" />'
	ICON_BASKET = '<img src="'+IMAGE_URL_ALL+'/basic_icons/basket.png" alt="o" height="16" width="16" />'
	ICON_RUBY = '<img src="'+IMAGE_URL_ALL+'/basic_icons/ruby.png" alt="o" height="16" width="16" />'
	ICON_BONUS = '<img src="'+IMAGE_URL_ALL+'/basic_icons/ruby.png" alt="o" height="16" width="16" />'
	ICON_MONEY = '<img src="'+IMAGE_URL_ALL+'/basic_icons/coins.png" alt="o" height="16" width="16" />'
	ICON_COINS = '<img src="'+IMAGE_URL_ALL+'/basic_icons/coins.png" alt="o" height="16" width="16" />'
	ICON_EXP = '<img src="'+IMAGE_URL_ALL+'/basic_icons/star.png" alt="o" height="16" width="16" />'
	ICON_RELOAD = '<img src="'+IMAGE_URL_ALL+'/basic_icons/arrow-circle.png" alt="o" height="16" width="16" />'
	ICON_FORUM = '<img src="'+IMAGE_URL_ALL+'/basic_icons/books.png" alt="o" height="16" width="16" />'
	ICON_FORUM_READ = '<img src="'+IMAGE_URL_ALL+'/basic_icons/book-open-list.png" alt="o" height="16" width="16" />'
	ICON_FORUM_UNREAD = '<img src="'+IMAGE_URL_ALL+'/basic_icons/book.png" alt="o" height="16" width="16" />'
	ICON_CHAT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/balloon.png" alt="o" height="16" width="16" />'
	ICON_EMAIL = '<img src="'+IMAGE_URL_ALL+'/basic_icons/mails.png" alt="o" height="16" width="16" />'
	ICON_EMAIL_SEND = '<img src="'+IMAGE_URL_ALL+'/basic_icons/mail-send.png" alt="o" height="16" width="16" />'
	ICON_EMAIL_GET = '<img src="'+IMAGE_URL_ALL+'/basic_icons/mail.png" alt="o" height="16" width="16" />'
	ICON_USERS = '<img src="'+IMAGE_URL_ALL+'/basic_icons/users.png" alt="o" height="16" width="16" />'
	ICON_FIGHT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/trophy.png" alt="o" height="16" width="16" />'
	ICON_CLUBS = '<img src="'+IMAGE_URL_ALL+'/basic_icons/foaf.png" alt="o" height="16" width="16" />'
	ICON_GIFT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/present.png" alt="o" height="16" width="16" />'
	ICON_SPEED = '<img src="'+IMAGE_URL_ALL+'/basic_icons/dashboard--plus.png" alt="o" height="16" width="16" />'
	ICON_CLOCK = '<img src="'+IMAGE_URL_ALL+'/basic_icons/clock.png" alt="o" height="16" width="16" />'
	ICON_MAP = '<img src="'+IMAGE_URL_ALL+'/basic_icons/compass.png" alt="o" height="16" width="16" />'
	ICON_OFFICE = '<img src="'+IMAGE_URL_ALL+'/basic_icons/home.png" alt="o" height="16" width="16" />'
	ICON_CITY = '<img src="'+IMAGE_URL_ALL+'/basic_icons/building.png" alt="o" height="16" width="16" />'
	ICON_STOCK = '<img src="'+IMAGE_URL_ALL+'/basic_icons/stock.png" alt="o" height="16" width="16" />'
	ICON_SHOP = '<img src="'+IMAGE_URL_ALL+'/basic_icons/store.png" alt="o" height="16" width="16" />'
	ICON_YES = '<img src="'+IMAGE_URL_ALL+'/basic_icons/tick.png" alt="o" height="16" width="16" />'
	ICON_NO = '<img src="'+IMAGE_URL_ALL+'/basic_icons/cross.png" alt="o" height="16" width="16" />'
	ICON_EXCHANGE = '<img src="'+IMAGE_URL_ALL+'/basic_icons/money-coin.png" alt="o" height="16" width="16" />'
	ICON_PENCIL = '<img src="'+IMAGE_URL_ALL+'/basic_icons/pencil.png" alt="o" height="16" width="16" />'
	ICON_PC = '<img src="'+IMAGE_URL_ALL+'/basic_icons/computer.png" alt="o" height="16" width="16" />'
	ICON_ENERGYDRINK = '<img src="'+IMAGE_URL_ALL+'/basic_icons/battery-charge.png" alt="o" height="16" width="16" />'
	ICON_BUHMAN = '<img src="'+IMAGE_URL_ALL+'/basic_icons/user-detective.png" alt="o" height="16" width="16" />'
	ICON_VIDEO = '<img src="'+IMAGE_URL_ALL+'/basic_icons/film-youtube.png" alt="o" height="16" width="16" />'
	ICON_RADIO = '<img src="'+IMAGE_URL_ALL+'/basic_icons/radio.png" alt="o" height="16" width="16" />'
	ICON_RADAR = '<img src="'+IMAGE_URL_ALL+'/basic_icons/radar.png" alt="o" height="16" width="16" />'
	ICON_CART = '<img src="'+IMAGE_URL_ALL+'/basic_icons/baggage-cart-box.png" alt="o" height="16" width="16" />'
	ICON_BOX = '<img src="'+IMAGE_URL_ALL+'/basic_icons/box.png" alt="o" height="16" width="16" />'
	ICON_MEH = '<img src="'+IMAGE_URL_ALL+'/basic_icons/wrench-screwdriver.png" alt="o" height="16" width="16" />'
	ICON_TO = '<img src="'+IMAGE_URL_ALL+'/basic_icons/wrench.png" alt="o" height="16" width="16" />'
	ICON_OIL = '<img src="'+IMAGE_URL_ALL+'/basic_icons/oil-barrel.png" alt="o" height="16" width="16" />'
	ICON_OIL2 = '<img src="'+IMAGE_URL_ALL+'/basic_icons/beaker.png" alt="o" height="16" width="16" />'
	ICON_COLOR = '<img src="'+IMAGE_URL_ALL+'/basic_icons/spectrum.png" alt="o" height="16" width="16" />'
	ICON_FRIEND_ADD = '<img src="'+IMAGE_URL_ALL+'/basic_icons/user-plus.png" alt="o" height="16" width="16" />'
	ICON_FRIEND_DEL = '<img src="'+IMAGE_URL_ALL+'/basic_icons/user-minus.png" alt="o" height="16" width="16" />'
	ICON_ENERGY = '<img src="'+IMAGE_URL_ALL+'/basic_icons/lightning.png" alt="o" height="16" width="16" />'
	ICON_LICENSE = '<img src="'+IMAGE_URL_ALL+'/basic_icons/license-key.png" alt="o" height="16" width="16" />'
	ICON_LOGIST = '<img src="'+IMAGE_URL_ALL+'/basic_icons/user-green-female.png" alt="o" height="16" width="16" />'
	ICON_FOOD = '<img src="'+IMAGE_URL_ALL+'/basic_icons/food.png" alt="o" height="16" width="16" />'
	ICON_HELI = '<img src="'+IMAGE_URL_ALL+'/basic_icons/heli.png" alt="o" height="16" width="16" />'
	ICON_PAPERBAG = '<img src="'+IMAGE_URL_ALL+'/basic_icons/paper-bag.png" alt="o" height="16" width="16" />'
	ICON_CUTLERY = '<img src="'+IMAGE_URL_ALL+'/basic_icons/cutlery.png" alt="o" height="16" width="16" />'
	ICON_SOAP = '<img src="'+IMAGE_URL_ALL+'/basic_icons/soap.png" alt="o" height="16" width="16" />'
	ICON_BROOM = '<img src="'+IMAGE_URL_ALL+'/basic_icons/broom.png" alt="o" height="16" width="16" />'
	ICON_WATER = '<img src="'+IMAGE_URL_ALL+'/basic_icons/water.png" alt="o" height="16" width="16" />'
	ICON_SPICE = '<img src="'+IMAGE_URL_ALL+'/basic_icons/fire-big.png" alt="o" height="16" width="16" />'
	ICON_CHIEF = '<img src="'+IMAGE_URL_ALL+'/basic_icons/user-white.png" alt="o" height="16" width="16" />'
	ICON_CROWN = '<img src="'+IMAGE_URL_ALL+'/basic_icons/crown.png" alt="o" height="16" width="16" />'
	ICON_GLASS = '<img src="'+IMAGE_URL_ALL+'/basic_icons/glass.png" alt="o" height="16" width="16" />'
	ICON_CAKE = '<img src="'+IMAGE_URL_ALL+'/basic_icons/cake.png" alt="o" height="16" width="16" />'
	ICON_CALC = '<img src="'+IMAGE_URL_ALL+'/basic_icons/e-book-reader.png" alt="o" height="16" width="16" />'
	ICON_PHONE = '<img src="'+IMAGE_URL_ALL+'/basic_icons/mobile-phone.png" alt="o" height="16" width="16" />'
	ICON_COOK = '<img src="'+IMAGE_URL_ALL+'/basic_icons/plate-cutlery.png" alt="o" height="16" width="16" />'
	ICON_CUP = '<img src="'+IMAGE_URL_ALL+'/basic_icons/cup.png" alt="o" height="16" width="16" />'
	ICON_CUT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/cut.png" alt="o" height="16" width="16" />'
	ICON_CUT_PLUS = '<img src="'+IMAGE_URL_ALL+'/basic_icons/cut+.png" alt="o" height="16" width="16" />'
	ICON_LAB = '<img src="'+IMAGE_URL_ALL+'/basic_icons/lab.png" alt="o" height="16" width="16" />'
	ICON_MP3 = '<img src="'+IMAGE_URL_ALL+'/basic_icons/mp3.png" alt="o" height="16" width="16" />'
	ICON_ROBOT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/robot.png" alt="o" height="16" width="16" />'
	ICON_SEAT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/seat.png" alt="o" height="16" width="16" />'
	ICON_SEAT_PLUS = '<img src="'+IMAGE_URL_ALL+'/basic_icons/seat+.png" alt="o" height="16" width="16" />'
	ICON_MINER = '<img src="'+IMAGE_URL_ALL+'/basic_icons/miner.png" alt="o" height="16" width="16" />'
	ICON_WIFI = '<img src="'+IMAGE_URL_ALL+'/basic_icons/wifi.png" alt="o" height="16" width="16" />'
	ICON_HR = '<img src="'+IMAGE_URL_ALL+'/basic_icons/user-black-female.png" alt="o" height="16" width="16" />'
	ICON_BLIST = '<img src="'+IMAGE_URL_ALL+'/basic_icons/user-q.png" alt="o" height="16" width="16" />'
	ICON_BOOKMARK = '<img src="'+IMAGE_URL_ALL+'/basic_icons/bookmark.png" alt="o" height="16" width="16" />'
	ICON_LOGIN = '<img src="'+IMAGE_URL_ALL+'/basic_icons/door-open.png" alt="o" height="16" width="16" />'
	ICON_NAME = '<img src="'+IMAGE_URL_ALL+'/basic_icons/document1.png" alt="o" height="16" width="16" />'
	ICON_CONSULT = '<img src="'+IMAGE_URL_ALL+'/basic_icons/briefcase.png" alt="o" height="16" width="16" />'
	ICON_SAFE = '<img src="'+IMAGE_URL_ALL+'/basic_icons/safe.png" alt="o" height="16" width="16" />'
	ICON_LOTERY = '<img src="'+IMAGE_URL_ALL+'/basic_icons/pcard.png" alt="o" height="16" width="16" />'
	ICON_CALENDAR = '<img src="'+IMAGE_URL_ALL+'/basic_icons/calendar-task.png" alt="o" height="16" width="16" />'
	ICON_PLAN = '<img src="'+IMAGE_URL_ALL+'/basic_icons/folder-smiley.png" alt="o" height="16" width="16" />'
	ICON_ONLINE = '<img src="'+IMAGE_URL_ALL+'/basic_icons/online.png" alt="o" height="16" width="16" />'
	ICON_SHIELD = '<img src="'+IMAGE_URL_ALL+'/basic_icons/085.png" alt="o" height="16" width="16" />'
	ICON_LAMP = '<img src="'+IMAGE_URL_ALL+'/basic_icons/043.png" alt="o" height="16" width="16" />'
	ICON_HELP = '<img src="'+IMAGE_URL_ALL+'/basic_icons/question-white.png" alt="o" height="16" width="16" />'
	# Иконка для PRO-игроков
	ICON_PRO = '<img src="'+IMAGE_URL_ALL+'/basic_icons/pro_16.png" alt="o" height="16" width="33" />'
	
	MESSAGE_MAIN_PAGE = ''
	
	# Функция для вывода верхней части страницы
	def show_top(title)
		if !session['user_id'].nil? and session['user_id'].to_i > 0 then
			#if @user.od_userid > 0 then
			#	text = @user.od_top
			#else
			#	text = ''
			#end
			text = '<div id="okwidget" style="position: absolute; left: 0px; top: 0px;"><!--?xml version="1.0" encoding="utf-8"?--><a style="display:block;height:32px;width:32px;margin:0;padding:0;border:0;border-radius:4px;background:url(http://st.mycdn.me/res/i/custom/widget/back2ok2.png) no-repeat 6px 6px #ed812b;" id="returnToOK" href="http://m.odnoklassniki.ru"> </a></div>'
		else
			text = ''
		end
		
		'<!doctype html>
		<html lang="ru" class="no-js">
		<head>
		<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
		<meta name="language" content="russian, ru, русский" />
		<meta name="robots" content="INDEX, FOLLOW" />
		<meta name="viewport" content="width=device-width" />
		<meta name="keywords" content="Ridemate" />
		<meta name="description" content="Ridemate - найди попутчиков." />
		<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.0/css/bootstrap.min.css">
		<link rel="stylesheet" href="'+IMAGE_URL_GAME+'/bootflat.css">
		<link rel="icon" href="'+IMAGE_URL_GAME+'/fav.png" type="image/png">
		<!-- Bootstrap -->
		<script src="https://code.jquery.com/jquery-2.1.3.min.js"></script>
		<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.0/js/bootstrap.min.js"></script>
		<title>'+title.to_s+'</title>
		</head><body>'+text
	end
	
	def show_title(text)
		'<div class="s-block">
			<div class="block-top">
				<div class="in1">&nbsp;</div>
				<div class="in2">&nbsp;</div>
				<div class="in3">&nbsp;</div>
			</div>
			<div class="block-mid">
				<div class="in1">
					<div class="in2" align="center">'+text.to_s+'</div>
				</div>
			</div>
			<div class="block-bot">
				<div class="in1">&nbsp;</div>
				<div class="in2">&nbsp;</div>
				<div class="in3">&nbsp;</div>
			</div>
		</div>'
	end
	
	# Проверка есть ли такой пользователь
	def authorize(login, password)
		# Найдем userid по login и сравним пароль
		id = $r.get 'user:login:'+login.to_s
		if !id.nil? then 
			password_in_db = $r.hget 'user:'+id.to_s, 'password'
			if password_in_db==Digest::MD5.hexdigest('ZaqlumberwsX'+password).to_s then
				session['user_id'] = id
				
				# Проверям установлены ли ключи для автологина
				if ($r.hget 'user:'+id.to_s, 'autologin_key') == '' then
					$r.hset 'user:'+id.to_s, 'autologin_key', User.create_autologin_key
				end
				
				# Проверяем заблокирован ли игрок
				if ($r.hget 'user:'+id.to_s, 'block') != '' then
					return 'block'
				else
					return true
				end
			end
		end
		return false
	end
	
	# Заменяем угловые скобки на безопасные символы
	# Эта функция используется только при создании/изменении логина у игрока
	def notuse_htmltags(text)
		return text.gsub(/[<>]/) {|s| s=='<' ? '&lt;' : '&gt;'}
	end
	
	# Подстановка смайликов в текст html-теги отображаются корректно
	def insert_smiles_with_html(text)
		for i in 0..$smiles.size-1 do
			while text.include? $smiles[i][0]
				text[$smiles[i][0]]=$smiles[i][1]
			end
		end
		return text
	end
	
	# Подстановка смайликов в текст. html-теги запрещены
	def insert_smiles_without_html(text)
		# Удаляем теги из текста
		text = notuse_htmltags(text)
		# Вставялем смайлики
		return insert_smiles_with_html(text)
	end
	
	# Отображаются только определенные теги <br> <b></b> <a></a> <img />
	# Используем для отображения текста в форумах
	def use_somehtmltags(text)
		text2 = text.gsub(/[<]/) {'&lt;'}

		while i=text2.index('&lt;b>') do # 6 символов <b>
			text2 = text2[0, i]+'<b>'+text2[i+6, text2.size-i-6]
		end
		while i=text2.index('&lt;/b>') do # 7 символов </b>
			text2 = text2[0, i]+'</b>'+text2[i+7, text2.size-i-7]
		end
		while i=text2.index('&lt;a') do # 5 символов <a
			text2 = text2[0, i]+'<a'+text2[i+5, text2.size-i-5]
		end
		while i=text2.index('&lt;/a>') do # 7 символов </a>
			text2 = text2[0, i]+'</a>'+text2[i+7, text2.size-i-7]
		end
		while i=text2.index('&lt;br>') do # 7 символов <br>
			text2 = text2[0, i]+'<br>'+text2[i+7, text2.size-i-7]
		end
		while i=text2.index('&lt;img') do # 7 символов <img
			text2 = text2[0, i]+'<img'+text2[i+7, text2.size-i-7]
		end
		return text2
	end
	
	# Функция определяет есть ли в тексте запрещенные слова
	def tabu_words?(text)
		for i in 0..$tabu_words.size-1 do
			while text.include? $tabu_words[i]
				return true
			end
		end
		return false
	end
	
	# Смещение относительно текущего времени
	def time_delta(time)
		delta=Time.now.to_i-time

		if delta < 60 then
			text = 'менее минуты'
		elsif delta < 3600 then
			result = delta/60
			if result>=5 and result<=20 then
				text = result.to_s+' минут'
			else
				ost = result%10
				if ost==1 then
					text = result.to_s+' минуту'
				elsif ost==2 or ost==3 or ost==4 then
					text = result.to_s+' минуты'
				else
					text = result.to_s+' минут'
				end
			end
		elsif delta < 86400 then
			result = delta/3600
			if result==1 or result==21 then
				text = result.to_s+' час'
			elsif result==2 or result==3 or result==4 or result>=22 then
				text = result.to_s+' часа'
			else
				text = result.to_s+' часов'
			end
		else
			text = 'более суток'
		end
		return text
	end
	
	# Текстовое объяснение сколько времени осталось до указанного момента
	def time_delta_to_moment(time, not_now=false)
		if not_now then
			delta=time
		else
			delta=time-Time.now.to_i
		end

		if delta <= 0 then # Указанно событие уже прошло
			return false
		else
			if delta < 60 then
				text = delta.to_s+' сек'
			elsif delta < 3600 then
				result = delta/60
				if result>=5 and result<=20 then
					text = result.to_s+' минут'
				else
					ost = result%10
					if ost==1 then
						text = result.to_s+' минуту'
					elsif ost==2 or ost==3 or ost==4 then
						text = result.to_s+' минуты'
					else
						text = result.to_s+' минут'
					end
				end
			elsif delta < 86400 then
				result = delta/3600
				if result==1 or result==21 then
					text = result.to_s+' час'
				elsif result==2 or result==3 or result==4 or result>=22 then
					text = result.to_s+' часа'
				else
					text = result.to_s+' часов'
				end
			else
				text = 'более суток'
			end
			return text
		end
	end
	
	# Текстовое детализированное объяснение сколько времени осталось до указанного момента
	# рекурсивная функция
	def time_delta_to_moment_detal(time, not_now=false)
		if not_now then
			delta=time
		else
			delta=time-Time.now.to_i
		end
		
		if delta <= 0 then # Указанно событие уже прошло
			return false
		else
			if delta < 60 then
				text = '1 минута'
			elsif delta < 3600 then
				result = delta/60
				if result>=5 and result<=20 then
					text = result.to_s+' минут'
				else
					ost = result%10
					if ost==1 then
						text = result.to_s+' минуту'
					elsif ost==2 or ost==3 or ost==4 then
						text = result.to_s+' минуты'
					else
						text = result.to_s+' минут'
					end
				end
			elsif delta < 86400 then
				result = delta/3600
				if result==1 or result==21 then
					text = result.to_s+' час'
				elsif result==2 or result==3 or result==4 or result>=22 then
					text = result.to_s+' часа'
				else
					text = result.to_s+' часов'
				end
				# Выясняем сколько минут
				if time_delta_to_moment_detal(time - result*3600, not_now) != false then
					text += ' '+time_delta_to_moment_detal(time - result*3600, not_now)
				end
			else
				# Кол-во дней
				result = delta/86400
				if result==1 or result==21 then
					text = result.to_s+' день'
				elsif result==2 or result==3 or result==4 or result>=22 then
					text = result.to_s+' дня'
				else
					text = result.to_s+' дней'
				end
				# Выясняем сколько часов
				if time_delta_to_moment_detal(time - result*86400, not_now) != false then
					text += ' '+time_delta_to_moment_detal(time - result*86400, not_now)
				end
			end
			return text
		end
	end
	
	# Общее кол-во игроков
	def get_all_users
		return ($r.get 'userid').to_i 
	end
	
	# Функция для работы с упорядоченным множеством, когда мы получаем значения вместе с весом
	def array_withscores(array)
		result, temp, i = Array.new, nil, 1 
		array.each do |a|
			if i == 1 then
				temp, i = a, 2
			else
				result << [temp, a]
				i = 1
			end
		end
		return result
	end
	
	# Функция логирования для отладки игры
	def write_log(text)
		file_log = File.new('log.txt', 'a')
		file_log.puts Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s+' '+text.to_s
		file_log.close
		true
	end
	
	def main_page
		return '/main/'+rand(100_000).to_s
	end
	
	def url_page(page)
		return page #+'/'+rand(100_000).to_s
	end
	
	# Расстояние между координатами в метрах
	RAD_PER_DEG = 0.017453293  #  PI/180
	def haversine_distance(lat1, lon1, lat2, lon2)	
		dlon = lon2 - lon1  
		dlat = lat2 - lat1  
		 
		dlon_rad = dlon * RAD_PER_DEG  
		dlat_rad = dlat * RAD_PER_DEG  
		 
		lat1_rad = lat1 * RAD_PER_DEG  
		lon1_rad = lon1 * RAD_PER_DEG  
		 
		lat2_rad = lat2 * RAD_PER_DEG  
		lon2_rad = lon2 * RAD_PER_DEG  
		 
		a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2  
		c = 2 * Math.asin( Math.sqrt(a))  

		return (6372795 * c).to_i
	end
end

#------------------------ Код проекта -----------
before do
	cache_control :no_cache, :must_revalidate, :max_age => 0
end

# Главная страница игры
get '/main/:t' do
	redirect '/login' if session['user_id']=='' || session['user_id']==nil
	@user = User.new(session['user_id'])
	
	# Отмечаем, что игрок онлайн
	$r.zadd 'online', Time.now.to_i.to_s, @user.id.to_s
	
	erb :main
end

get '/next/:id' do
	redirect '/login' if session['user_id']=='' || session['user_id']==nil
	@user = User.new(session['user_id'])
	
	if params['id'].nil?
		redirect '/main/123'
	end
	
	id = params['id'].to_i
	
	if id < 1 or id > 2
		redirect '/main/123'
	end
	
	if @user.step == 0
		@user.step = 1
		
		if id == 1
			@user.role = 0
		elsif id == 2
			@user.role = 1
		end
		
		@user.save
	end
	
	erb :main
end

post '/trip' do 
	redirect '/login' if session['user_id']=='' || session['user_id']==nil
	@user = User.new(session['user_id'])
	
	if !params['from'].nil? and !params['from_time_hour'].nil? and !params['from_time_min'].nil? and !params['to'].nil? and !params['to_time_hour'].nil? and !params['to_time_min'].nil?
		redirect '/main/123'
	else
		# Находим координаты адресов, которые предоставил пользователь
		url = URI::encode('https://geocode-maps.yandex.ru/1.x/?format=json&geocode=Санкт-Петербург, '+params['from'])
	
		begin
			uri = URI.parse(url)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			http.open_timeout = 2 # in seconds
			http.read_timeout = 2 # in seconds	
			response = http.request(Net::HTTP::Get.new(uri.request_uri))
			text = response.body
			
			# Разбираем json
			json_text = JSON.parse text
			# 30.314548 59.969547
			from_xy = json_text['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['Point']['pos'].to_s
		rescue Timeout::Error
			return false
		end
		
		# Находим координаты адресов, которые предоставил пользователь
		url = URI::encode('https://geocode-maps.yandex.ru/1.x/?format=json&geocode=Санкт-Петербург, '+params['to'])
	
		begin
			uri = URI.parse(url)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			http.open_timeout = 2 # in seconds
			http.read_timeout = 2 # in seconds	
			response = http.request(Net::HTTP::Get.new(uri.request_uri))
			text = response.body
			
			# Разбираем json
			json_text = JSON.parse text
			# 30.314548 59.969547
			to_xy = json_text['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['Point']['pos'].to_s
		rescue Timeout::Error
			return false
		end
		
		# Сохраняем маршрут, который ввел пользователь
		@user.from = params['from']
		@user.to = params['to']
		@user.from_time = params['from_time_hour']+':'+params['from_time_min']
		@user.to_time = params['to_time_hour']+':'+params['to_time_min']
		
		array = from_xy.split(' ')
		@user.from_x = array[0]
		@user.from_y = array[1]
		
		array = to_xy.split(' ')
		@user.to_x = array[0]
		@user.to_y = array[1]
		
		@user.step = 2
		
		@user.save
	end
end

# Расстояние в метрах
get '/len_test' do 
	url = URI::encode('https://geocode-maps.yandex.ru/1.x/?format=json&geocode=Санкт-Петербург, Медиков проспект, 5')
	
	begin
		uri = URI.parse(url)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		http.open_timeout = 2 # in seconds
		http.read_timeout = 2 # in seconds	
		response = http.request(Net::HTTP::Get.new(uri.request_uri))
		text = response.body
		
		# Разбираем json
		json_text = JSON.parse text
		# 30.314548 59.969547
		json_text['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['Point']['pos'].to_s
		
		
	rescue Timeout::Error
		return false
	end
end

# Авторизация в игре с помощью кнопок соцсетей
require_relative 'lib/oauth.rb'

get '/' do
	redirect '/login'
end

# Обработка любых иных запросов к сайту
get '/*' do
	''
end