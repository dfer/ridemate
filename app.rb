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
	
	# Поиск водителей поблизости
	if @user.step == 2 and @user.role == 0
		@array = []
		
		userid_max = ($r.get 'userid').to_i
		
		for i in 1..userid_max do 
			user = User.new(i)
			if user.role == 1
				@array << {:id=>user.id, :name=>user.name, :from=>user.from, :to=>user.to}
			end
		end
	end
	
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
	
	write_log('from: '+params['from'])
	write_log('from_time_hour: '+params['from_time_hour'])
	write_log('from_time_min: '+params['from_time_min'])
	write_log('to: '+params['to'])
	write_log('to_time_hour: '+params['to_time_hour'])
	write_log('to_time_min: '+params['to_time_min'])
	
	if params['from'].nil? or params['from_time_hour'].nil? or params['from_time_min'].nil? or params['to'].nil? or params['to_time_hour'].nil? or params['to_time_min'].nil?
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
		
		redirect '/main/456'
	end
end

# Вторая форма для регистрации водителя
post '/about_me' do 
	redirect '/login' if session['user_id']=='' || session['user_id']==nil
	@user = User.new(session['user_id'])
	
	write_log('car: '+params['car'])
	write_log('smoke: '+params['smoke'])
	write_log('exp: '+params['exp'])
	write_log('about: '+params['about'])
	
	if params['car'].nil? or params['smoke'].nil? or params['exp'].nil? or params['about'].nil?
		redirect '/main/123'
	else
		if @user.step == 2 and @user.role == 1
			@user.model = params['car']
			@user.smoke = params['smoke']
			@user.exp = params['exp']
			@user.about = params['about']
			@user.step = 3
			
			@user.save
		end
		
		redirect '/main/456'
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

# Генерируем мужское имя
def male_name
	name = ['Август', 'Адам', 'Александр', 'Алексей', 'Анатолий', 'Андрей', 'Антон', 'Аполлинарий', 'Аполлон', 'Аристарх', 'Аркадий', 
	'Арнольд', 'Арсен', 'Арсений', 'Артём', 'Артур', 'Афанасий', 'Бенедикт', 'Богдан', 'Болеслав', 'Боримир', 'Борис', 'Борислав', 
	'Бронислав', 'Булат', 'Вадим', 'Валентин', 'Валерий', 'Вальтер', 'Василий', 'Вениамин', 'Виктор', 'Виссарион', 'Виталий', 'Влад', 
	'Владимир', 'Владислав', 'Володар', 'Вольдемар', 'Вольмир', 'Всеволод', 'Вячеслав', 'Гавриил', 'Галактион', 'Гарри', 'Геннадий', 
	'Георгий', 'Герман', 'Глеб', 'Гордей ', 'Григорий', 'Давид', 'Дамир', 'Даниил', 'Денис', 'Дмитрий', 'Добрыня', 'Дональт', 'Евгений', 
	'Евдоким', 'Егор', 'Ефим', 'Захар', 'Ибрагим', 'Иван', 'Игнатий', 'Игорь', 'Казимир', 'Карл', 'Кирилл', 'Клавдий', 'Клемент', 
	'Лавр', 'Лаврентий', 'Лазарь', 'Ларион', 'Лев', 'Леонид', 'Лука', 'Макар', 'Максим', 'Мирон', 'Мирослав', 'Михаил', 'Модест', 
	'Моисей', 'Натан', 'Наум', 'Нестор', 'Одиссей', 'Октавиан', 'Олег', 'Оскар', 'Павел', 'Пантелеймон', 'Пересвет', 'Петр', 'Прохор', 
	'Савелий', 'Светозар', 'Святослав', 'Семен', 'Серафим', 'Сергей', 'Станислав', 'Степан', 'Тарас', 'Тристан', 'Трифон', 'Трофим', 
	'Федор', 'Феликс', 'Филимон', 'Филипп', 'Харитон', 'Эдуард', 'Эрнест', 'Юлиан', 'Юлий', 'Юпитер', 'Юрий', 'Яков', 'Ян', 'Ярополк', 'Ярослав']
	
	return name[rand(name.size)]
end

def female_name
	name = ['Августа', 'Авдотья', 'Аврора', 'Агата', 'Агния', 'Адель', 'Азалия', 'Алевтина', 'Александра', 'Алёна', 'Алина', 'Алиса', 'Алла', 'Альбина', 
	'Анастасия', 'Анжела', 'Анита', 'Анна', 'Антонина', 'Анфиса', 'Арина', 'Бажена', 'Белла', 'Берта', 'Богдана', 'Валентина', 'Валерия', 
	'Варвара', 'Василиса', 'Васса', 'Венера', 'Вера', 'Вероника', 'Виктория', 'Виола', 'Влада', 'Галина', 'Ганна', 'Гелена', 'Гелла', 'Гертруда', 
	'Глафира', 'Глория', 'Горислава', 'Дана', 'Дарья', 'Дарина', 'Дарьяна', 'Джульетта', 'Диана', 'Дина', 'Ева', 'Евгения', 'Евдокия', 'Екатерина', 
	'Елена', 'Елизавета', 'Ефросиния', 'Жанна', 'Ждана', 'Зарина', 'Зинаида', 'Злата', 'Зоя', 'Иванна', 'Ида', 'Инга', 'Инесса', 'Инна', 'Ираида', 
	'Ирина', 'Капитолина', 'Каролина', 'Катерина', 'Кира', 'Клавдия', 'Клара', 'Клеопатра', 'Кристина', 'Ксения', 'Лада', 'Лариса', 'Леся', 
	'Лидия', 'Лилиана', 'Лилия', 'Любава', 'Любовь', 'Людмила', 'Магдалина', 'Мадлен', 'Майя', 'Мальвина', 'Маргарита', 'Марина', 'Мария', 'Марта', 
	'Марфа', 'Матильда', 'Матрена', 'Милана', 'Милослава', 'Мира', 'Мирослава', 'Надежда', 'Настасья', 'Наталья', 'Нелли', 'Ника', 'Нина', 
	'Нинель', 'Оксана', 'Октавия', 'Олеся', 'Олимпиада', 'Олимпия', 'Ольга', 'Павла', 'Павлина', 'Полина', 'Прасковья', 'Рада', 'Радмила', 'Раиса', 
	'Регина', 'Рената', 'Римма', 'Роза', 'Розалия', 'Розана', 'Ростислава', 'Руслана', 'Руфина', 'Сабина', 'Светлана', 'Светозара', 'Светослава', 
	'Северина', 'Селена', 'Серафима', 'Слава', 'Снежана', 'Софья', 'Стелла', 'Стефания', 'Таира', 'Таисия', 'Тамара', 'Тамила', 'Татьяна', 
	'Ульяна', 'Фаина', 'Элеонора', 'Эльвира', 'Эльмира', 'Эльза', 'Эмма', 'Юлиана', 'Юлия', 'Яна', 'Ярослава']
	
	return name[rand(name.size)]
end

def streets
	name = ['1-й Верхний переулок',
'1-й Муринский проспект',
'1-й Озерковский переулок',
'1-й Предпортовый проезд',
'1-й Рабфаковский переулок',
'1-й Рыбацкий проезд',
'1-я Алексеевская улица',
'1-я Березовая аллея',
'1-я Жерновская улица',
'1-я Конная Лахта улица',
'1-я Красноармейская улица',
'1-я Никитинская улица',
'1-я Полевая улица',
'1-я Поперечная улица',
'1-я Советская улица',
'1-я Утиная улица',
'10-я Красноармейская улица',
'10-я Советская улица',
'11-я Красноармейская улица',
'12-я Красноармейская улица',
'13-я Красноармейская улица',
'2-й Верхний переулок',
'2-й Луч улица',
'2-й Муринский проспект',
'2-й Озерковский переулок',
'2-й Предпортовый проезд',
'2-й Рыбацкий проезд',
'2-я Алексеевская улица',
'2-я Березовая аллея',
'2-я Жерновская улица',
'2-я Комсомольская улица',
'2-я Конная Лахта улица',
'2-я Красноармейская улица',
'2-я Никитинская улица',
'2-я Полевая улица',
'2-я Поперечная улица',
'2-я Советская улица',
'2-я Утиная улица',
'3-й Верхний переулок',
'3-й Озерковский переулок',
'3-й Предпортовый проезд',
'3-й Рыбацкий проезд',
'3-я Жерновская улица',
'3-я Конная Лахта улица',
'3-я Красноармейская улица',
'3-я Поперечная улица',
'3-я Советская улица',
'4-й Верхний переулок',
'4-й Предпортовый проезд',
'4-й Рыбацкий проезд',
'4-я Жерновская улица',
'4-я Красноармейская улица',
'4-я Поперечная улица',
'4-я Советская улица',
'5-й Верхний переулок',
'5-й Предпортовый проезд',
'5-й Рыбацкий проезд',
'5-я Жерновская улица',
'5-я Красноармейская улица',
'5-я Поперечная улица',
'5-я Советская улица',
'6-й Верхний переулок',
'6-й Предпортовый проезд',
'6-й Рыбацкий проезд',
'6-я Жерновская улица',
'6-я Красноармейская улица',
'6-я Поперечная улица',
'6-я Советская улица',
'7-й Верхний переулок',
'7-й Предпортовый проезд',
'7-я Красноармейская улица',
'7-я Поперечная улица',
'7-я Советская улица',
'8-й Верхний переулок',
'8-й Рыбацкий проезд',
'8-я Красноармейская улица',
'8-я Поперечная улица',
'8-я Советская улица',
'9-я Красноармейская улица',
'9-я Советская улица',
'Абросимова улица',
'Авангардная улица',
'Авиаконструкторов проспект',
'Авиационная улица',
'Аврова улица',
'Австрийская площадь',
'Автобусная улица',
'Автобусный переулок',
'Автовская улица',
'Автогенная улица',
'Автомобильная улица',
'Агатов переулок',
'Адмирала Трибуца улица',
'Адмирала Черокова улица',
'Адмиралтейский проезд',
'Адмиралтейский проспект',
'Адмиральский проезд',
'Азовская улица',
'Азовский переулок',
'Академика Байкова улица',
'Академика Глушко алеея',
'Академика Иоффе площадь',
'Академика Климова площадь',
'Академика Константинова улица',
'Академика Крылова улица',
'Академика Лебедева улица',
'Академика Лихачева алеея',
'Академика Лихачева площадь',
'Академика Павлова улица',
'Академика Сахарова площадь',
'Академика Шиманского улица',
'Академический переулок',
'Аккуратова улица',
'Актерский проезд',
'Александра Блока улица',
'Александра Матросова улица',
'Александра Невского площадь',
'Александра Невского улица',
'Александра Ульянова улица',
'Александровская линия',
'Александровская улица',
'Александровский переулок',
'Александровской Фермы проспект',
'Алтайская улица',
'Альпийский переулок',
'Амурская улица',
'Английский проспект',
'Андреевская улица',
'Аникушинская аллея',
'Анисимовская дорога',
'Аннинское шоссе',
'Антоненко переулок',
'Антонова-Овсеенко улица',
'Антоновская улица',
'Апраксин переулок',
'Апрельская улица',
'Аптекарский переулок',
'Аптекарский проспект',
'Арктическая улица',
'Арсенальная улица',
'Арсеньевский переулок',
'Артиллерийская улица',
'Артиллерийский переулок',
'Асафьева улица',
'Астраханская улица',
'Атаманская улица',
'Афанасьевская улица',
'Афонская улица',
'Аэродромная улица',
'Бабанова улица',
'Бабушкина улица',
'Бадаева улица',
'Байконурская улица',
'Бакунина проспект',
'Балканская площадь',
'Балканская улица',
'Балтийская улица',
'Балтийских Юнг площадь',
'Балтийского вокзала площадь',
'Балтфлота площадь',
'Банковский переулок',
'Барклаевская улица',
'Бармалеева улица',
'Барочная улица',
'Баррикадная улица',
'Басков переулок',
'Бассейная улица',
'Батайский переулок',
'Батарейная дорога',
'Беговая улица',
'Безымянная улица',
'Белградская улица',
'Белевский проспект',
'Белинского площадь',
'Белинского улица',
'Беломорская улица',
'Белоостровская улица',
'Белорусская улица',
'Белоусова улица',
'Белы Куна улица',
'Белышева улица',
'Береговая улица',
'Березовая улица',
'Беринга улица',
'Бестужевская улица',
'Бехтерева площадь',
'Бехтерева улица',
'Библиотечный переулок',
'Биржевая линия',
'Биржевая площадь',
'Биржевой переулок',
'Биржевой проезд',
'Благодатная улица',
'Благоева улица',
'Блохина улица',
'Бобруйская улица',
'Богатырский проспект',
'Бойцова переулок',
'Боковая аллея',
'Бокситогорская улица',
'Болотная улица',
'Большая аллея',
'Большая Горская улица',
'Большая Десятинная улица',
'Большая Зеленина улица',
'Большая Конюшенная улица',
'Большая линия',
'Большая Монетная улица',
'Большая Морская улица',
'Большая Московская улица',
'Большая Озерная улица',
'Большая Подьяческая улица',
'Большая Пороховская улица',
'Большая Посадская улица',
'Большая Пушкарская улица',
'Большая Разночинная улица',
'Большая Яблоновка',
'Большевиков проспект',
'Большеохтинский проспект',
'Большой Васильевского острова проспект',
'Большой Казачий переулок',
'Большой Петроградской стороны проспект',
'Большой Сампсониевский проспект',
'Большой Смоленский проспект',
'Бонч-Бруевича улица',
'Боровая улица',
'Бородин переулок',
'Бородинская улица',
'Боткинская улица',
'Боцманская улица',
'Братская улица',
'Брестский бульвар',
'Бринько переулок',
'Броневая улица',
'Бронницкая улица',
'Брюсовская улица',
'Брянская улица',
'Брянцева улица',
'Бугский переулок',
'Будапештская улица',
'Булавского улица',
'Бумажная улица',
'Буренина улица',
'Бурцева улица',
'Бутлерова улица',
'Бухарестская улица',
'Быковская улица',
'Вавиловых улица',
'Вагонный проезд',
'Вазаский переулок',
'Вакуленчука улица',
'Ванеева улица',
'Варваринская улица',
'Варфоломеевская улица',
'Варшавская площадь',
'Варшавская улица',
'Варшавский проезд',
'Васенко улица',
'Васи Алексеева улица',
'Васильковая улица',
'Ватутина улица',
'Введенская улица',
'Введенский канал',
'Веденеева улица',
'Вербная улица',
'Верейская улица',
'Верности улица',
'Вертолетная улица',
'Верхняя улица',
'Веры Слуцкой улица',
'Весельная улица',
'Весенняя улица',
'Ветеранов проспект',
'Взлетная улица',
'Виленский переулок',
'Виндавская улица',
'Винокурцевский проезд',
'Витебская площадь',
'Витебская улица',
'Витебская-Сортировочная улица',
'Витебский проспект',
'Витковского улица',
'Владимирская площадь',
'Владимирский проспект',
'Внуковская улица',
'Водопроводная улица',
'Водопроводный переулок',
'Военная улица',
'Военных Медиков площадь',
'Воздухоплавательная улица',
'Вознесенский проспект',
'Возрождения улица',
'Вокзальный проезд',
'Волго-Донской проспект',
'Волжский переулок',
'Волковский проспект',
'Володи Ермака улица',
'Волоколамский переулок',
'Волховский переулок',
'Волхонское шоссе',
'Волынкин переулок',
'Волынский переулок',
'Вольновская улица',
'Воронежская улица',
'Воронинский проезд',
'Ворошилова улица',
'Воскова улица',
'Воскресенский проезд',
'Восстания площадь',
'Восстания улица',
'Всеволода Вишневского улица',
'Всеволожская улица',
'Выборгская улица',
'Выборгское шоссе',
'Высоковольтная улица',
'Вяземский переулок',
'Вязовая улица',
'Гаванская улица',
'Гаврская улица',
'Гагаринская улица',
'Газовая улица',
'Гаккелевская улица',
'Галерная улица',
'Галерный проезд',
'Галстяна улица',
'Гамбургская площадь',
'Гангутская улица',
'Гапсальская улица',
'Гаражный проезд',
'Гастелло улица',
'Гатчинская улица',
'Гатчинское шоссе',
'Гданьская улица',
'Гдовская улица',
'Гельсингфорсская улица',
'Генерала Симоняка улица',
'Генерала Хрулева улица',
'Геологическая улица',
'Герасимовская улица',
'Героев проспект',
'Гжатская улица',
'Гидротехников улица',
'Главная улица',
'Гладкова улица',
'Глазурная улица',
'Глеба Успенского улица',
'Глинки улица',
'Глиняная улица',
'Глухарская улица',
'Глухая Зеленина улица',
'Глухоозерское шоссе',
'Головкинская улица',
'Гомельская а улица',
'Гончарная улица',
'Горная улица',
'Гороховая улица',
'Госпитальная улица',
'Гражданская улица',
'Гражданский проспект',
'Гранитная улица',
'Граничная улица',
'Графова улица',
'Графский переулок',
'Графский проезд',
'Графтио улица',
'Гренадерская улица',
'Греческая площадь',
'Греческий проспект',
'Грибакиных улица',
'Грибалевой улица',
'Гривцова переулок',
'Гродненский переулок',
'Громова улица',
'Грота улица',
'Грузинская улица',
'Грузовой проезд',
'Губина улица',
'Гусева улица',
'Дальневосточный проспект',
'Даля улица',
'Дачный т проспект',
'Двинская улица',
'Двинский переулок',
'Дворцовая площадь',
'Дворцовый проезд',
'Девятого Января проспект',
'Дегтярева улица',
'Дегтярная улица',
'Дегтярный переулок',
'Декабристов переулок',
'Декабристов улица',
'Демонстрационный проезд',
'Демьяна Бедного улица',
'Депутатская улица',
'Державинский переулок',
'Дерптский переулок',
'Десантников улица',
'Детская улица',
'Джамбула переулок',
'Джона Рида улица',
'Диагональная улица',
'Дибуновская улица',
'Дивенская улица',
'Димитрова улица',
'Динамо проспект',
'Динамовская улица',
'Диспетчерская улица',
'Дмитрия Устинова улица',
'Дмитровский переулок',
'Днепровский переулок',
'Днепропетровская улица',
'Доблести улица',
'Добровольцев улица',
'Добролюбова проспект',
'Добрушская улица',
'Дойников переулок',
'Доктора Короткова улица',
'Долгоозерная улица',
'Домодедовская улица',
'Домостроительная улица',
'Донская улица',
'Достоевского улица',
'Дрезденская улица',
'Дровяная улица',
'Дровяной переулок',
'Друскеникский переулок',
'Дубленский переулок',
'Дубовая аллея',
'Дубровская улица',
'Дудко улица',
'Думская улица',
'Дунайский проспект',
'Дыбенко улица',
'Евгеньевская улица',
'Евдокима Огнева улица',
'Европы площадь',
'Егорова улица',
'Екатерининский проспект',
'Елагинский проспект',
'Еленинская улица',
'Еленинский проезд',
'Елецкая улица',
'Елизаветинская улица',
'Елизарова проспект',
'Елисеевская улица',
'Ельницкая улица',
'Емельянова улица',
'Енотаевская улица',
'Есенина улица',
'Ефимова улица',
'Жака Дюкло улица',
'Ждановская улица',
'Железноводская улица',
'Железнодорожная улица',
'Железнодорожный проспект',
'Жени Егоровой улица',
'Жертв Девятого Января я улица',
'Жукова улица',
'Жуковского улица',
'Забайкальская улица',
'Заводская улица',
'Загородная улица',
'Загородный проспект',
'Загребский бульвар',
'Задворная улица',
'Зайцева улица',
'Замковая улица',
'Замшина улица',
'Замятин переулок',
'Заневская площадь',
'Заневский проспект',
'Заозерная улица',
'Западная аллея',
'Заповедная улица',
'Запорожская улица',
'Заречная улица',
'Зарубинская улица',
'Заславская улица',
'Заставская улица',
'Заусадебная улица',
'Захаров переулок',
'Захарьевская улица',
'Заячий переулок',
'Звездная улица',
'Звенигородская улица',
'Зверинская улица',
'Здоровцева улица',
'Зеленая улица',
'Зеленогорская улица',
'Земледельческая улица',
'Земледельческий переулок',
'Зенитчиков улица',
'Зеркальный переулок',
'Зины Портновой улица',
'Зодчего Росси улица',
'Зои Космодемьянской улица',
'Зольная улица',
'Зоологический переулок',
'Зотовский проспект',
'Зубковская улица',
'Ивана Фомина улица',
'Ивана Черных улица',
'Ивановская улица',
'Ижорская улица',
'Измайловский проспект',
'Ильюшина улица',
'Индустриальный проспект',
'Инженерная улица',
'Иностранный переулок',
'Институтский переулок',
'Институтский проспект',
'Инструментальная линия',
'Инструментальная улица',
'Ириновский проспект',
'Иркутская улица',
'Исаакиевская площадь',
'Искровский проспект',
'Искусств площадь',
'Исполкомская улица',
'Испытателей проспект',
'Итальянская улица',
'Кавалергардская улица',
'Кадетская линия',
'Кадетский переулок',
'Казанская площадь',
'Казанская улица',
'Казначейская улица',
'Калинина площадь',
'Калинина улица',
'Калинкин переулок',
'Калужский переулок',
'Калязинская улица',
'Каменноостровский проспект',
'Камская улица',
'Камчатская улица',
'Камышинская улица',
'Камышовая улица',
'Канареечная улица',
'Канатная улица',
'Канонерская улица',
'Кантемировская улица',
'Капитана Воронина улица',
'Капитанская улица',
'Капсюльное шоссе',
'Караваевская улица',
'Караваевский переулок',
'Караванная улица',
'Карбышева улица',
'Карельский переулок',
'Карла Либкнехта улица',
'Карла Фаберже площадь',
'Карпатская улица',
'Карпинского улица',
'Карповский переулок',
'Карташихина улица',
'Касимовская улица',
'Каховского переулок',
'Кваренги переулок',
'Кемеровская улица',
'Кемская улица',
'Керченский переулок',
'Кибальчича улица',
'Киевская улица',
'КИМа проспект',
'Кингисеппское шоссе',
'Кирилловская улица',
'Киришская улица',
'Кировская площадь',
'Кировская улица',
'Кирочная улица',
'Кирпичный переулок',
'Кленовая улица',
'Климов переулок',
'Клиническая улица',
'Клинский проспект',
'Клочков переулок',
'Клубный переулок',
'Ключевая улица',
'Книпович улица',
'Ковалевская улица',
'Ковенский переулок',
'Кожевенная линия',
'Козлова улица',
'Козловский переулок',
'Кокушкин переулок',
'Коли Томчака улица',
'Коллонтай улица',
'Колодезная улица',
'Колокольная улица',
'Коломенская улица',
'Коломяжский проспект',
'Колпинская улица',
'Колпинский переулок',
'Колхозная улица',
'Кольская улица',
'Кольцова улица',
'Комарова улица',
'Комендантская площадь',
'Комендантский проспект',
'Комиссара Смирнова улица',
'Коммуны улица',
'Композиторов улица',
'Комсомола улица',
'Комсомольская площадь',
'Кондратенко улица',
'Кондратьевский проспект',
'Конная площадь',
'Конная улица',
'Конногвардейский бульвар',
'Конногвардейский переулок',
'Коннолахтинская дорога',
'Коннолахтинский проспект',
'Константина Заслонова улица',
'Константиновский переулок',
'Константиновский проспект',
'Константиноградская улица',
'Конституции площадь',
'Конторская улица',
'Конюшенная площадь',
'Конюшенный переулок',
'Корабельная улица',
'Кораблестроителей улица',
'Корнеева улица',
'Королева проспект',
'Короленко улица',
'Корпусная улица',
'Корякова улица',
'Косая линия',
'Косинова улица',
'Космонавтов проспект',
'Костромская улица',
'Костромской проспект',
'Костюшко улица',
'Косыгина проспект',
'Котельникова алеея',
'Котина улица',
'Котовского улица',
'Красина улица',
'Красноармейская улица',
'Красноборский переулок',
'Красногвардейская площадь',
'Красногвардейский переулок',
'Красного Курсанта переулок',
'Красного Курсанта улица',
'Красного Текстильщика улица',
'Красноградский переулок',
'Краснодонская улица',
'Краснопутиловская улица',
'Красносельская улица',
'Красносельское шоссе',
'Красных Зорь бульвар',
'Красных Партизан улица',
'Красуцкого улица',
'Кременчугская улица',
'Крестовский проспект',
'Кржижановского улица',
'Кричевский переулок',
'Кронверкская улица',
'Кронверкский проспект',
'Кронштадтская площадь',
'Кронштадтская улица',
'Кропоткина улица',
'Круглый переулок',
'Круговая улица',
'Крупской улица',
'Крыленко улица',
'Крылова переулок',
'Крюкова улица',
'Кубанская улица',
'Кубанский переулок',
'Кубинская улица',
'Кузнецова проспект',
'Кузнецовская улица',
'Кузнечный переулок',
'Куйбышева улица',
'Кулибина площадь',
'Культуры площадь',
'Культуры проспект',
'Купчинская улица',
'Куракина улица',
'Курляндская улица',
'Курская улица',
'Курчатова улица',
'Курятная линия',
'Кустарный переулок',
'Кустодиева улица',
'Кушелевская дорога',
'Лабораторная улица',
'Лабораторный проспект',
'Лабутина улица',
'Лаврский проезд',
'Лагерное шоссе',
'Лагоды улица',
'Лазаретный переулок',
'Лазо улица',
'Ланская улица',
'Ланское шоссе',
'Лапинский проспект',
'Латышских Стрелков улица',
'Лахтинская улица',
'Лахтинский проспект',
'Левашовский проспект',
'Лени Голикова улица',
'Ленина площадь',
'Ленина проспект',
'Ленина улица',
'Ленинградское шоссе',
'Ленинский проспект',
'Ленская улица',
'Ленсовета улица',
'Лермонтовский переулок',
'Лермонтовский проспект',
'Лесная улица',
'Леснозаводская улица',
'Лесоовая улица парк',
'Лессига алеея',
'Летняя аллея',
'Летчика Пилютова улица',
'Либавский переулок',
'Лиговский переулок',
'Лиговский проспект',
'Лидинская улица',
'Лизы Чайкиной улица',
'Лисичанская улица',
'Лиственная улица',
'Литейный проспект',
'Литераторов улица',
'Литовская улица',
'Лифляндская улица',
'Лодейнопольская улица',
'Лодыгина переулок',
'Ломаная аллея',
'Ломаная улица',
'Ломовская улица',
'Ломоносова переулок',
'Ломоносова площадь',
'Ломоносова улица',
'Лопатина улица',
'Лоцманская улица',
'Луговая улица',
'Лужская улица',
'Луначарского проспект',
'Лыжный переулок',
'Льва Мациевича площадь',
'Льва Толстого площадь',
'Льва Толстого улица',
'Львиный переулок',
'Львовская улица',
'Люблинский переулок',
'Люботинский проспект',
'Магнитогорская улица',
'Майков переулок',
'Макаренко переулок',
'Макулатурный проезд',
'Малая Балканская улица',
'Малая Бухарестская улица',
'Малая Горская улица',
'Малая Гребецкая улица',
'Малая Зеленина улица',
'Малая Карпатская улица',
'Малая Каштановая аллея',
'Малая Конюшенная улица',
'Малая Митрофаньевская улица',
'Малая Монетная улица',
'Малая Морская улица',
'Малая Московская улица',
'Малая Объездная улица',
'Малая Озерная улица',
'Малая Подьяческая улица',
'Малая Посадская улица',
'Малая Пушкарская улица',
'Малая Разночинная улица',
'Малая Садовая улица',
'Малодетскосельский проспект',
'Малоохтинский проспект',
'Малыгина улица',
'Малый Васильевского острова проспект',
'Малый Казачий переулок',
'Малый Петроградской стороны проспект',
'Малый Сампсониевский проспект',
'Манежная площадь',
'Манежный переулок',
'Манчестерская улица',
'Марата улица',
'Мариинская улица',
'Мариинский проезд',
'Маринеско улица',
'Маркина улица',
'Марсово поле',
'Мартыновская улица',
'Маршала Блюхера проспект',
'Маршала Говорова улица',
'Маршала Жукова проспект',
'Маршала Захарова улица',
'Маршала Казакова улица',
'Маршала Мерецкова улица',
'Маршала Новикова улица',
'Маршала Тухачевского улица',
'Масляный канал',
'Масляный переулок',
'Мастерская улица',
'Матвеева переулок',
'Матвеевский переулок',
'Матисов переулок',
'Матроса Железняка улица',
'Матюшенко улица',
'Маяковского улица',
'Мгинская улица',
'Мебельная улица',
'Мебельный проезд',
'Медиков проспект',
'Межозерная улица',
'Мезенская улица',
'Мелитопольский переулок',
'Мельничная улица',
'Мельничный переулок',
'Менделеевская линия',
'Менделеевская улица',
'Меншиковский проспект',
'Металлистов проспект',
'Метростроевцев улица',
'Мечникова проспект',
'Миллионная улица',
'Минеральная улица',
'Минский переулок',
'Мира улица',
'Миргородская улица',
'Миронова улица',
'Митавский переулок',
'Митрофаньевский тупик',
'Митрофаньевское шоссе',
'Михайлова улица',
'Михайловская улица',
'Михайловский переулок',
'Михайловский проезд',
'Мичманская улица',
'Мичуринская улица',
'Можайская улица',
'Можайского улица',
'Моисеенко улица',
'Молдагуловой улица',
'Молодежный переулок',
'Мончегорская улица',
'Моравский переулок',
'Морская улица',
'Морской переулок',
'Морской Пехоты улица',
'Морской проспект',
'Морской Славы площадь',
'Москательная линия',
'Москательный переулок',
'Московская площадь',
'Московские Ворота площадь',
'Московский проспект',
'Московское шоссе',
'Мостовая улица',
'Моховая улица',
'Мошков переулок',
'Мраморный переулок',
'Мужества площадь',
'Мурзинская улица',
'Муринская дорога',
'Мучной переулок',
'Мытнинская площадь',
'Мытнинская улица',
'Мышкинская улица',
'Мясная улица',
'Набережная улица',
'Наличная улица',
'Наличный переулок',
'Нарвский проспект',
'Народная улица',
'Народного Ополчения проспект',
'Наставников проспект',
'Науки проспект',
'Нахимова улица',
'Невельская улица',
'Невзоровой улица',
'Невский проспект',
'Нежинская улица',
'Нейшлотский переулок',
'Некрасова улица',
'Неманский переулок',
'Непокоренных проспект',
'Нестерова переулок',
'Нефтяная дорога',
'Нижне-Каменская улица',
'Нижняя Полевая улица',
'Никольская площадь',
'Никольская улица',
'Никольский переулок',
'Новаторов бульвар',
'Новая улица',
'Новгородская улица',
'Ново-Александровская улица',
'Ново-Никитинская улица',
'Ново-Рыбинская улица',
'Новоалександровская улица',
'Новобелицкая улица',
'Новоизмайловский проспект',
'Новоколомяжский проспект',
'Новоладожская улица',
'Новолитовская улица',
'Новомалиновская дорога',
'Новоовсянниковская улица',
'Новороссийская улица',
'Новорощинская улица',
'Новоселов улица',
'Новосельковская улица',
'Новосибирская улица',
'Новосильцевский переулок',
'Новостроек улица',
'Новоутиная улица',
'Новочеркасский проспект',
'Оборонная улица',
'Обручевых улица',
'Обуховская площадь',
'Обуховской Обороны проспект',
'Объездное шоссе',
'Одесская улица',
'Одоевского улица',
'Озерковский проспект',
'Озерная улица',
'Озерной переулок',
'Окраинная улица',
'Олеко Дундича улица',
'Олонецкая улица',
'Ольги Берггольц улица',
'Ольги Форш улица',
'Ольгина улица',
'Ольминского улица',
'Ольховая улица',
'Омская улица',
'Онежский проезд',
'Опочинина улица',
'Оптиков улица',
'Опытная улица',
'Ораниенбаумская улица',
'Орбели улица',
'Орджоникидзе улица',
'Ординарная улица',
'Оренбургская улица',
'Орловская улица',
'Орловский переулок',
'Оружейника Федорова улица',
'Осипенко улица',
'Оскаленко улица',
'Остоумова улица',
'Островского площадь',
'Остропольский переулок',
'Отважных улица',
'Отечественная улица',
'Охотничий переулок',
'Очаковская улица',
'Павлоградский переулок',
'Панфилова улица',
'Парадная улица',
'Парашютная улица',
'Парголовская улица',
'Парковая улица',
'Партизана Германа улица',
'Партизанская улица',
'Парусная улица',
'Пархоменко проспект',
'Пасторова улица',
'Патриотов проспект',
'Певческий переулок',
'Пеньковая улица',
'Первомайская улица',
'Первомайский проспект',
'Перевозная улица',
'Перевозный переулок',
'Передовиков улица',
'Перекопская улица',
'Перекупной переулок',
'Перинная линия',
'Перфильева улица',
'Песковский переулок',
'Песочная улица',
'Пестеля улица',
'Петергофское шоссе',
'Петра Смородина улица',
'Петровская коса',
'Петровская площадь',
'Петровская улица',
'Петровский переулок',
'Петровский проспект',
'Петроградская улица',
'Петрозаводская улица',
'Петрозаводское шоссе',
'Петропавловская улица',
'Печатника Григорьева улица',
'Печорская улица',
'Пилотов улица',
'Пинегина улица',
'Пинский переулок',
'Пионерская площадь',
'Пионерская улица',
'Пионерстроя улица',
'Пирогова переулок',
'Писарева улица',
'Пискаревский проспект',
'Планерная улица',
'Пловдивская улица',
'Плуталова улица',
'Пляжевая улица',
'Победы площадь',
'Победы улица',
'Поварской переулок',
'Пограничника Гарькавого улица',
'Подводника Кузьмина улица',
'Подвойского улица',
'Подгорная улица',
'Подковырова улица',
'Подольская улица',
'Подрезова улица',
'Подъездной переулок',
'Поклонногорская улица',
'Покрышева улица',
'Полевая аллея',
'Полевая Сабировская улица',
'Полевая улица',
'Полиграфмашевский проезд',
'Поликарпова алеея',
'Политехническая улица',
'Полозова улица',
'Полтавская улица',
'Полтавский проезд',
'Полюстровский проспект',
'Полярников улица',
'Помяловского улица',
'Поперечная улица',
'Портовая улица',
'Поселковая улица',
'Потапова улица',
'Потемкинская улица',
'Почтамтская улица',
'Почтамтский переулок',
'Поэтический бульвар',
'Правды улица',
'Пражская улица',
'Прачечный переулок',
'Предпортовая улица',
'Преображенская площадь',
'Прибалтийская площадь',
'Прибрежная улица',
'Придорожная аллея',
'Прилукская улица',
'Примакова улица',
'Приморская улица',
'Приморский проспект',
'Приморское шоссе',
'Провиантская улица',
'Прогонная улица',
'Прогонный переулок',
'Прожекторная улица',
'Прокофьева улица',
'Пролетарский проспект',
'Пролетарской Диктатуры площадь',
'Пролетарской Диктатуры улица',
'Промышленная улица',
'Просвещения проспект',
'Профессора Ивашенцова улица',
'Профессора Качалова улица',
'Профессора Попова улица',
'Прудковский переулок',
'Прядильный переулок',
'Прямой проспект',
'Псковская улица',
'Пугачева улица',
'Пудожская улица',
'Пулковская улица',
'Пулковское шоссе',
'Пушкарский переулок',
'Пушкинская улица',
'Пятилеток проспект',
'Рабочий переулок',
'Рабфаковская улица',
'Радищева переулок',
'Радищева улица',
'Раевского проспект',
'Раздельная улица',
'Разъезжая улица',
'Ракитовская улица',
'Расстанная улица',
'Расстанный переулок',
'Расстанный проезд',
'Растрелли площадь',
'Рашетова улица',
'Ревельский переулок',
'Революции шоссе',
'Резная улица',
'Резной переулок',
'Рейсовая улица',
'Ремесленная улица',
'Рентгена улица',
'Репина площадь',
'Репина улица',
'Репищева улица',
'Репнинская улица',
'Республиканская улица',
'Речная улица',
'Решетникова улица',
'Ржевская площадь',
'Ржевская улица',
'Рижская улица',
'Рижский проспект',
'Римского-Корсакова проспект',
'Рихарда Зорге улица',
'Рогачевский переулок',
'Розенштейна улица',
'Роменская улица',
'Ропшинская улица',
'Российский проспект',
'Рощинская улица',
'Рубежная улица',
'Рубинштейна улица',
'Руднева улица',
'Рузовская улица',
'Румянцевская площадь',
'Руставели улица',
'Ручьевская дорога',
'Рыбацкая улица',
'Рыбацкий проспект',
'Рыбинская улица',
'Рылеева улица',
'Рюхина улица',
'Рябиновая улица',
'Рябовское шоссе',
'Рядовая улица',
'Рязанский переулок',
'Сабировская улица',
'Саблинская улица',
'Савиной улица',
'Савушкина улица',
'Садовая улица',
'Салова улица',
'Салтыковская дорога',
'Самойловой улица',
'Санаторная аллея',
'Санкт-Петербургское шоссе',
'Сантьяго-де-Куба улица',
'Саперный переулок',
'Саратовская улица',
'Сахарный переулок',
'Свеаборгская улица',
'Светлановская площадь',
'Светлановский проспект',
'Свечной переулок',
'Свирская улица',
'Севастопольская улица',
'Севастьянова улица',
'Северная дорога',
'Северная площадь',
'Северный проспект',
'Сегалева улица',
'Седова улица',
'Семеновская площадь',
'Семеновская улица',
'Сенатская площадь',
'Сенная площадь',
'Сергея Марго улица',
'Сергея Тюленина переулок',
'Сергиевская улица',
'Сердобольская улица',
'Серебристый бульвар',
'Серебряков переулок',
'Серпуховская улица',
'Сестрорецкая улица',
'Сибирская улица',
'Сивков переулок',
'Сизова проспект',
'Сикейроса улица',
'Сикорского площадь',
'Симонова улица',
'Синявинская улица',
'Сиреневый бульвар',
'Ситцевая улица',
'Скачков переулок',
'Складская улица',
'Складской проезд',
'Скобелевский проспект',
'Славы проспект',
'Славянская улица',
'Слепушкина переулок',
'Слободская улица',
'Смоленская улица',
'Смольного улица',
'Смольный проезд',
'Смольный проспект',
'Смолячкова улица',
'Собчака площадь',
'Советский переулок',
'Советский проспект',
'Солдата Корзуна улица',
'Солдатский переулок',
'Солидарности проспект',
'Солнечная улица',
'Соломахинский проезд',
'Солунская улица',
'Соляной переулок',
'Сомов переулок',
'Сортировочная-Московская улица',
'Сосновая улица',
'Сосновский проспект',
'Софийская улица',
'Софьи Ковалевской улица',
'Социалистическая улица',
'Сочинская улица',
'Союза Печатников улица',
'Союзный проспект',
'Спасский переулок',
'Спортивная улица',
'Среднегаванский проспект',
'Среднеохтинский проспект',
'Средний проспект',
'Средняя аллея',
'Средняя Колтовская улица',
'Средняя Подьяческая улица',
'Средняя улица',
'Ставропольская улица',
'Старо-Муринская улица',
'Старо-Петергофский проспект',
'Старобельская улица',
'Старого Театра площадь',
'Стародеревенская улица',
'Старообрядческая улица',
'Староорловская улица',
'Старопутиловский вал',
'Старорусская улица',
'Стартовая улица',
'Старцева улица',
'Стасовой улица',
'Стахановцев улица',
'Стачек площадь',
'Стачек проспект',
'Стеклянная улица',
'Степана Разина улица',
'Степановский проезд',
'Стойкости улица',
'Столярный переулок',
'Стрелковая улица',
'Стрельбищенская улица',
'Стрельнинская улица',
'Стремянная улица',
'Строителей улица',
'Студенческая улица',
'Суворовская площадь',
'Суворовский проспект',
'Суздальский проспект',
'Суконная линия',
'Сухопутный переулок',
'Счастливая улица',
'Съезжинская улица',
'Сызранская улица',
'Сытнинская площадь',
'Сытнинская улица',
'Таврическая улица',
'Таврический переулок',
'Талалихина переулок',
'Таллинская улица',
'Таллинское шоссе',
'Тамбасова улица',
'Тамбовская улица',
'Таможенный переулок',
'Танкиста Хрустицкого улица',
'Тарасова улица',
'Татарский переулок',
'Ташкентская улица',
'Тбилисская улица',
'Тверская улица',
'Театральная аллея',
'Театральная площадь',
'Телеграфная улица',
'Тележная улица',
'Тележный переулок',
'Тельмана улица',
'Тепловозная улица',
'Технологическая площадь',
'Тимуровская улица',
'Типанова улица',
'Титова улица',
'Тифлисская улица',
'Тихая улица',
'Тихомировская улица',
'Тихорецкий проспект',
'Ткачей улица',
'Тобольская улица',
'Товарищеский проспект',
'Товарный переулок',
'Токсовская улица',
'Толмачева улица',
'Толмачевская улица',
'Торговый переулок',
'Тореза проспект',
'Торжковская улица',
'Торфяная дорога',
'Тосина улица',
'Травяная улица',
'Тракторная улица',
'Трамвайный проспект',
'Транспортный переулок',
'Трезини площадь',
'Трефолева улица',
'Троицкая площадь',
'Троицкий проспект',
'Троллейбусный проезд',
'Труда площадь',
'Труда улица',
'Тульская улица',
'Туполевская улица',
'Турбинная улица',
'Тургенева площадь',
'Тургеневский переулок',
'Туристская улица',
'Турку улица',
'Тучков переулок',
'Тютчевская улица',
'Тюшина улица',
'Угловой переулок',
'Ударников проспект',
'Удельный проспект',
'Уездный проспект',
'Ульяны Громовой переулок',
'Уманский переулок',
'Уральская улица',
'Урюпин переулок',
'Усыскина переулок',
'Уткин проспект',
'Уточкина улица',
'Уфимская улица',
'Учебный переулок',
'Учительская улица',
'Ушинского улица',
'Ушковская улица',
'Фабричная улица',
'Фаворского улица',
'Фарфоровская улица',
'Фарфоровский пост',
'Фаянсовая улица',
'Федоровская улица',
'Федосеенко улица',
'Феодосийская улица',
'Фермское шоссе',
'Филологический переулок',
'Финляндский переулок',
'Финляндский проспект',
'Финский переулок',
'Фокина улица',
'Фонарный переулок',
'Фонтанная улица',
'Фруктовая линия',
'Фрунзе улица',
'Фуражный переулок',
'Фурштатская улица',
'Фучика улица',
'Харченко улица',
'Харьковская улица',
'Хасанская улица',
'Хвойная улица',
'Херсонская улица',
'Херсонский проезд',
'Химиков улица',
'Хлопина улица',
'Хохрякова улица',
'Хошимина улица',
'Хрустальная улица',
'Художников проспект',
'Цветочная улица',
'Цимбалина улица',
'Цимлянская улица',
'Циолковского улица',
'Чайковского улица',
'Чапаева улица',
'Чапыгина улица',
'Чебоксарский переулок',
'Чекистов улица',
'Челябинская улица',
'Червонного Казачества улица',
'Черкасова улица',
'Черниговская улица',
'Чернова улица',
'Черноморский переулок',
'Чернорецкий переулок',
'Чернышевский проезд',
'Чернышевского площадь',
'Чернышевского проспект',
'Черняховского улица',
'Чехова улица',
'Чистяковская улица',
'Чкаловский проспект',
'Чугунная улица',
'Чудновского улица',
'Шаврова улица',
'Шамшева улица',
'Шарова улица',
'Шателена улица',
'Шатерная улица',
'Шаумяна проспект',
'Шафировский проспект',
'Шведский переулок',
'Швецова улица',
'Шевченко площадь',
'Шевченко улица',
'Шелгунова улица',
'Шепетовская улица',
'Шереметьевская улица',
'Шипкинский переулок',
'Шишкина улица',
'Шишмаревский переулок',
'Шкапина улица',
'Шкиперский проток',
'Школьная улица',
'Шлиссельбургский проспект',
'Шлиссельбургское шоссе',
'Шостаковича улица',
'Шотландская улица',
'Шотмана улица',
'Шпалерная улица',
'Штурманская улица',
'Шуваловский проспект',
'Щепяной переулок',
'Щербаков переулок',
'Щербакова улица',
'Электропультовцев улица',
'Эмануиловская улица',
'Энгельса проспект',
'Энергетиков проспект',
'Энтузиастов проспект',
'Эриванская улица',
'Эскадронный переулок',
'Эсперов переулок',
'Эсперова улица',
'Эстонская улица',
'Южная аллея',
'Южная дорога',
'Южное шоссе',
'Юннатов тупик',
'Юннатов улица',
'Юризанская улица',
'Юрия Гагарина проспект',
'Яблочкова улица',
'Яблочная площадь',
'Ягодный проезд',
'Якобштадтский переулок',
'Яковская улица',
'Якорная улица',
'Якубовича улица',
'Ялтинская улица',
'Ярослава Гашека улица',
'Ярославская улица',
'Ярославский проспект',
'Яхтенная улица']
	
	return name[rand(name.size)]
end

# Добавление тестовых пользователей
get '/users_add' do 
	for i in 1..10 do
		age = rand(10)+17
		
		if i % 2 == 0
			nickname = male_name
			sex = '0' # мужчина
			image = 'https://static.pasha.pw/logist/game_garage/mans/'+rand(8).to_s+'_0.png'
		else
			nickname = female_name
			sex = '1'
			image = 'https://static.pasha.pw/logist/game_garage/girls/'+rand(14).to_s+'_0.png'
		end
		
		user = User.new
		user_hash = {:nickname =>nickname, :age=>age.to_s, :sex=>sex, :image_url=>image}
		id = user.create(user_hash)
		user = User.new(id)
		user.role = 1
		user.step = 3
		
		user.from = streets+', '+(rand(10)+1).to_s
		user.to = streets+', '+(rand(10)+1).to_s
		
		# Находим координаты адресов, которые предоставил пользователь
		url = URI::encode('https://geocode-maps.yandex.ru/1.x/?format=json&geocode=Санкт-Петербург, '+user.from)
	
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
		url = URI::encode('https://geocode-maps.yandex.ru/1.x/?format=json&geocode=Санкт-Петербург, '+user.to)
	
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
		
		user.from_time = '0'+(rand(3)+7).to_s+':00'
		user.to_time = (rand(3)+18).to_s+':00'
		
		array = from_xy.split(' ')
		user.from_x = array[0]
		user.from_y = array[1]
		
		array = to_xy.split(' ')
		user.to_x = array[0]
		user.to_y = array[1]
		
		cars = ['Форд', 'БМВ', 'Ауди', 'Шкода', 'Киа', 'Рено', 'Ваз', 'Шевроле', 'Трактор']
				
		user.model = cars[rand(cars.size)]
		user.smoke = rand(2)
		user.exp = rand(3)+1
		user.trips = rand(20)
		user.step = 3
		
		user.save
	end
	
	'ok'
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