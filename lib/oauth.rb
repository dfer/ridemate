# Общая точка для входа в игру с помощью oauth-авторизации соц сетей
get '/login' do
	# Пользователь уже в игре
	if session['user_id'].to_i > 0 then
		redirect main_page
	else
		# Если параметр oauth-провайдера не получен, то просто отобразить страницу с кнопками для входа
		if params['type'].nil?
			erb :login_oauth
		else
			# Находим с помощью какого oauth-провайдера пользователь хочет попасть(зарегистрироваться или продолжить играть) в игру
			type = params['type'].to_s
			
			if type == 'vk' then
				redirect "http://oauth.vk.com/authorize?client_id=5027551&display=mobile&redirect_uri=http://vlast.mobi/vk_action&response_type=code"
			elsif type == 'ok' then
				redirect "http://www.odnoklassniki.ru/oauth/authorize?client_id=1148777472&response_type=code&redirect_uri=http://vlast.mobi/ok_action&layout=m&scope="
			else
				redirect '/login'
			end
		end
	end
end

# Выход для меня. Для тестирования игры
get '/logout321' do
	redirect '/login' if session['user_id']=='' || session['user_id']==nil
	@user = User.new(session['user_id'])
	
	session['user_id']=''
	
	redirect '/login'
end

get '/ok_action' do 
	if !params['error'].nil? then
		redirect '/login'
	elsif !params['code'].nil? then
		uri = URI.parse('https://api.odnoklassniki.ru/oauth/token.do?code='+params['code'].to_s+'&client_id=1148777472&client_secret=629A26FCABF82B11FDDE1043&redirect_uri=http://vlast.mobi/ok_action&grant_type=authorization_code')
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Post.new(uri.request_uri)
		response = http.request(request)
		# Получаем {"access_token": "kjdhfldjfhgldsjhfglkdjfg9ds8fg0sdf8gsd8fg", "token_type": "session", "refresh_token": "klsdjhf0e9dyfasduhfpasdfasdfjaspdkfjp"}
		hash = JSON.parse response.body
		
		if hash.include? 'error' then
			redirect '/login'
		elsif hash.include? 'access_token' then
			str_for_sig='application_key=CBAFPJHFEBABABABAmethod=users.getCurrentUser'+Digest::MD5.hexdigest(hash['access_token'].to_s+'629A26FCABF82B11FDDE1043').to_s
			sig=Digest::MD5.hexdigest(str_for_sig).to_s.downcase.to_s

			# Запрос к серверу для получения данных об игроке		
			uri = URI.parse('http://api.odnoklassniki.ru/fb.do?method=users.getCurrentUser&access_token='+hash['access_token'].to_s+'&application_key=CBAFPJHFEBABABABA&sig='+sig)
			request = Net::HTTP::Get.new(uri.request_uri)
			response = Net::HTTP.start(uri.host, uri.port) do |http|
				http.request(request)
			end
			
			# Получили json c данными пользователя
			result_hash = JSON.parse response.body
			
			user_hash = Hash.new
			user_hash[:social] = 'ok'
			user_hash[:nickname] = notuse_htmltags(result_hash["name"].to_s) # Экранируем html-теги в логине игрока
			user_hash[:user_id_in_social] = result_hash["uid"].to_i
			
			user_hash[:age] = result_hash["age"].to_i if result_hash.include? "age"
			
			# Пол игрока
			if result_hash.include? "gender" then
				if result_hash["gender"].to_s == "male" then
					user_hash[:sex] = 0
				elsif result_hash["gender"].to_s == "female" then
					user_hash[:sex] = 1
				else
					user_hash[:sex] = 0 # Если пол не определен, то считаем, что это мужчина
				end
			end
			
			# дата рождения в формате каком-то своем формате
			user_hash[:bday] = result_hash["birthday"].to_s if result_hash.include? "birthday"
			
			# Смотрим может быть игрок уже регистрировался в игре?
			userid = $r.get 'user:od_userid:'+result_hash["uid"].to_i.to_s
		
			if userid.to_i > 0 then
				session['user_id'] = userid.to_s
			else
				user = User.new
				session['user_id'] = user.create(user_hash)
			end
			
			redirect main_page
		else
			redirect '/login'
		end
	else
		redirect '/login'
	end
end

# Обработка входа через Вконтакте
get '/vk_action' do
	if !params['error'].nil? then
		redirect '/login'
	elsif !params['code'].nil? then
		uri = URI.parse('https://oauth.vk.com/access_token?client_id=5027551&client_secret=PmzLqPcZwq4l40jTNlye&redirect_uri=http://vlast.mobi/vk_action&code='+params['code'].to_s)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		# Получаем {"access_token":"697a574c8b9e8a1fda25b0f38ed9c78196ae4473fd7c47ebd9ee836339c1a9f1741877bb4d6ff6919a8d9690db26b","expires_in":86400,"user_id":15929664}
		hash = JSON.parse response.body
		
		if hash.include? 'error' then
			redirect '/login'
		elsif hash.include? 'access_token' and hash.include? 'user_id' then
			# Запрос к серверу для получения данных об игроке
			uri = URI.parse('https://api.vk.com/method/users.get?uids='+hash['user_id'].to_s+'&fields=id,photo_50,city,verified,sex,bdate,country,has_mobile,contacts&access_token='+hash['access_token'].to_s)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			
			# Получили json c данными пользователя
			result_hash = JSON.parse response.body
			
			user_hash = Hash.new
			user_hash[:social] = 'vk'
			user_hash[:nickname] = notuse_htmltags(result_hash["response"][0]["first_name"].to_s+" "+result_hash["response"][0]["last_name"].to_s) # Экранируем html-теги в логине игрока
			user_hash[:user_id_in_social] = result_hash["response"][0]["uid"].to_i
			
			# дата рождения Возвращается в формате DD.MM.YYYY или DD.MM (если год рождения скрыт).
			# Если дата рождения скрыта целиком, поле отсутствует в ответе.
			user_hash[:bday] = result_hash["response"][0]["bdate"].to_s if result_hash["response"][0].include? "bdate"
			
			# 1 — женский; 2 — мужской; 0 — пол не указан.
			if result_hash["response"][0].include? "sex" then
				if result_hash["response"][0]["sex"].to_i == 1 then
					user_hash[:sex] = 1
				else 
					user_hash[:sex] = 0
				end
			end
			
			# Смотрим может быть игрок уже регистрировался в игре?
			userid = $r.get 'user:vk_userid:'+result_hash["response"][0]["uid"].to_i.to_s
		
			if userid.to_i > 0 then
				session['user_id'] = userid.to_s
			else
				user = User.new
				session['user_id'] = user.create(user_hash)
			end
			
			redirect main_page
		else
			redirect '/login'
		end
	else
		redirect '/login'
	end
end