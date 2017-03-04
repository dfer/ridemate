# Описание конструкций в базе
# user:<userid> - базовая информация по пользователю, хэш с параметрами пользователя
# userid - текущее максимальное значение <userid> для конструкции user:<userid>
# user:od_userid:<social_userid> - поиск <userid> по social_userid пользователя из Одноклассников
# user:vk_userid:<social_userid> - поиск <userid> по social_userid пользователя из ВКонтакте

# Описание параметров игрока:
# id
# login - логин
# password - пароль
# name - имя
# from - Стартовая точка поездки
# to - Конечная точка поездки
# from_time - Время начала поездки туда
# to_time - Время начала поездки оттуда
# day1 - Едет ли по маршруту в пн 0 - нет, 1-да
# day2 - вт
# day3 - ср
# day4 - чт
# day5 - пт
# day6 - сб
# day7 - вс
# model - марка и модель машины
# phone - телефон
# about - Текст о себе
# datefrom - Дата регистрации в приложении
# dateaction - Дата последнего действия
# trips - кол-во поездок
# exp - стаж вождения
# smoke - курит или нет. 0 - нет, 1 - да
# age - возраст
# sex - пол. 0-муж, 1-жен
# social_userid - Id-пользователя в социальной сети
# social - Из какой соц сети пришел человек. Значения ok, vk
# from_x - координата 1 Стартовой точки
# from_y - координата 2 Стартовой точки
# to_x - координата 1 Конечной точки
# to_y - координата 2 Конечной точки

class User
	attr_accessor :id, :login, :name, :from, :to, :from_time, :to_time, :day1, :day2, :day3, :day4, :day5, :day6, :day7, :model, :phone, :about, :datefrom, :dateaction, :trips, :exp, :smoke, :age, :sex, :social_userid, :social, :from_x, :from_y, :to_x, :to_y
	attr_reader :password
	
	def password=(val)
		@password=MD5.new('ZaqridematewsX'+val.to_s).to_s
	end
	
	# Загружаем все данные игрока, кроме его пароля, datefrom(даты регистрации) и текста платежек из Од
	def initialize(id=nil)
		# Если получили корректное значение, то загружаем информацию по игроку
		# Все данные в базе это строки. Поэтому nil быть не может
		if !id.nil? and id.to_i > 0 then
			@id = id.to_i
			
			hash = $r.hmget 'user:'+@id.to_s, 'login', 'name', 'from', 'to', 'from_time', 'to_time', 'day1', 'day2', 'day3', 'day4', 'day5', 'day6', 'day7', 'model', 'phone', 'about', 'datefrom', 'dateaction', 'trips', 'exp', 'smoke', 'age', 'sex', 'social_userid', 'social', 'from_x', 'from_y', 'to_x', 'to_y'
			
			@login = hash[0]
			@name = hash[1]
			@from = hash[2]
			@to = hash[3]
			@from_time = hash[4]
			@to_time = hash[5]
			@day1 = hash[6].to_i
			@day2 = hash[7].to_i
			@day3 = hash[8].to_i
			@day4 = hash[9].to_i
			@day5 = hash[10].to_i
			@day6 = hash[11].to_i
			@day7 = hash[12].to_i
			@model = hash[13]
			@phone = hash[14]
			@about = hash[15]
			@datefrom = hash[16].to_i
			@dateaction = hash[17].to_i
			@trips = hash[18].to_i
			@exp = hash[19].to_i
			@smoke = hash[20].to_i
			@age = hash[21].to_i
			@sex = hash[22].to_i
			@social_userid = hash[23].to_i
			@social = hash[24]
			@from_x = hash[25]
			@from_y = hash[26]
			@to_x = hash[27]
			@to_y = hash[28]
		end
	end
	
	# Создание игрока
	# Параметры, которые мы получаем в user_hash
	# social - код соцсети откуда пришел игрок. Возможные значения vk, ok
	# nickname - имя игрока из соцсети
	# user_id_in_social - id-игрока в соцсети
	# age - возраст игрока
	# email - почта игрока
	# sex - пол игрока 0 - мужчина, или пол не определен, 1 - женщина
	# bday - день рождения в строковом формате
	def create(user_hash)
		time_now_str = Time.now.to_i.to_s
		
		id = ($r.incr 'userid').to_s
		
		$r.hmset 'user:'+id, 
		'login', user_hash[:nickname],
		'name', user_hash[:nickname],
		'datefrom', time_now_str, 
		'dateaction', time_now_str, 
		'trips', '0',  
		'age', user_hash[:age].to_s, 
		'sex', user_hash[:sex].to_s, 
		'social_userid', user_hash[:user_id_in_social].to_s,
		'social',  user_hash[:social]
		
		if user_hash[:social] == 'ok' then
			$r.set 'user:od_userid:'+user_hash[:user_id_in_social].to_s, id
		elsif user_hash[:social] == 'vk' then
			$r.set 'user:vk_userid:'+user_hash[:user_id_in_social].to_s, id
		end
		
		return id
	end
		
	# Записываем в БД все данные игрока
	def save
		# Основной хеш с значениями игрока
		$r.hmset 'user:'+@id.to_s, 'login', @login,
		'name', @name, 
		'from', @from, 
		'to', @to, 
		'from_time', @from_time, 
		'to_time', @to_time, 
		'day1', @day1.to_s, 
		'day2', @day2.to_s, 
		'day3', @day3.to_s, 
		'day4', @day4.to_s, 
		'day5', @day5.to_s, 
		'day6', @day6.to_s, 
		'day7', @day7.to_s, 
		'model', @model, 
		'phone', @phone, 
		'about', @about, 
		'datefrom', @datefrom.to_s, 
		'dateaction', @dateaction.to_s, 
		'trips', @trips.to_s, 
		'exp', @exp.to_s, 
		'smoke', @smoke.to_s, 
		'age', @age.to_s, 
		'sex', @sex.to_s, 
		'social_userid', @social_userid.to_s, 
		'social', @social, 
		'from_x', @from_x, 
		'from_y', @from_y, 
		'to_x', @to_x, 
		'to_y', @to_y
	end
	
	# Перенесем механизм сообщений из session['message'] в базу
	# Возвращаем значение из переменной и заменяем его сразу на пустую строку
	def message
		text = $r.getset 'user:message:'+@id.to_s, ''
		text = '' if text.nil?
		return text
	end
	
	# Записываем значение в базу
	def message=(message)
		$r.set 'user:message:'+@id.to_s, message
	end
	
	# --------------- Отображение данных игрока ------------
	# Формируем список с ссылками которые используются практически на каждой странице
	def show_footer(current_time)
		# Обновляем время последнего действия игрока
		date_now = Time.now.to_i.to_s
		$r.hmset 'user:'+@id.to_s, 'b1', date_now
		$r.zadd 'online', date_now, @id.to_s
		
		if @od_userid > 0 then
			'<div class="c-block large orange" style="text-align:center;color:black;">Ваше имя - '+@login+'<br><br>'+current_time+'</div>'
		end
	end

	# ----------------- Статические методы -----------------
	# Проверяем что такой логин не использовался другими пользователями. true - с такими параметрами пользователя не было
	def User.new?(login)
		if ($r.get 'user:login:'+login.to_s).nil? then
			return true
		else
			return false
		end
	end
	
	# Функция логирования для отладки игры
	def User.write_log(text)
		file_log = File.new('log.txt', 'a')
		file_log.puts Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s+' '+text.to_s
		file_log.close
		true
	end
end