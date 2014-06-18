# coding: utf-8

require 'sinatra'
require 'json'

#главная страница
get '/' do 
	erb :index
end

#хеш с тестами
@@test_hash
#количество тестов
@@kol_testov = 13
#массив из случайно выбранных неповторяющихся вопросов
@@mas_test_number = Array.new(@@kol_testov)
#массив с ответами, -1 если не ответили на вопрос иначе номер ответа
@@mas_test_answer

#считываем файл с тестами 
test_file = File.open('mutaAlim.json',"rb")
@@test_hash = JSON.parse(test_file.read)
test_file.close

#для таблицы результатов
@@not_answer = "Вы не дали ответ"
#количество ответов
@@answers
#количество правильных ответов
@@ball
#процент правильных ответов
@@procent_tru_answers 
#массив в котором хранится рандомный порядок вариантов ответов
@@mas_random_variants

# страничка тестов
get '/test' do 
	if params[:var] == nil
		@@mas_test_answer = Array.new(@@kol_testov) { |i| -1}
		# заносим случайные вопросы в массив @@mas_test_number
		@@mas_test_number[0] = Random.rand(@@test_hash.length)
		@@mas_test_number.each_index do |i| 
			begin
				flag = true
				buf = Random.rand(@@test_hash.length)
				0..i.times do |j|
					if @@mas_test_number[j]==buf
						flag = false
					end
				end
				if flag
					@@mas_test_number[i] = buf
				end
			end until flag==true
		end
		@@test_number = 0;
		
		# заносим случайные варианты ответов в массив @@mas_random_variants
		@@mas_random_variants =  Array.new(@@kol_testov)
		@@mas_random_variants.each_index do |i| 
			@@mas_random_variants[i] = Array.new(@@test_hash[@@mas_test_number[i]]["answers"].size)
		end
		@@mas_random_variants.each_index do |i|
			@@mas_random_variants[i][0] = Random.rand(@@test_hash[@@mas_test_number[i]]["answers"].size)
			@@mas_random_variants[i].each_index do |j|
				begin
					flag = true
					buf = Random.rand(@@test_hash[@@mas_test_number[i]]["answers"].size)
					0..j.times do |k|
						if @@mas_random_variants[i][k]==buf
							flag = false
						end
					end
					if flag
						@@mas_random_variants[i][j] = buf
					end
				end until flag==true
			end
		end
	else
		#сохраняем выбранный вариант ответа в массив @@mas_test_answer
		@@mas_test_answer[@@test_number] = params[:var].to_i
		#если возможно выдаем след вопрос
		if @@test_number != @@kol_testov - 1
			@@test_number += 1
		end
	end
	erb :test
end


# страничка результатов
get '/test/result' do
	@@ball = 0
	@@answers = 0
	#подсчет правильных ответов 
	@@mas_test_answer.each do |i| 
		if i == 0 
			@@ball += 1 
		end
		if i != -1 
			@@answers += 1 
		end
	end
	@@procent_tru_answers = (100/@@kol_testov) * @@ball
	
	erb :result
end

# ссылки на каждый вопрос
get '/test/question/:id' do
	@@test_number = params[:id].to_i - 1
	erb :test
end

# следующий вопрос
get '/test/next' do
	if @@test_number != @@kol_testov - 1
			@@test_number += 1
	end
	erb :test
end

# предыдущий вопрос
get '/test/pred' do
	if @@test_number != 0
			@@test_number -= 1
	end
	erb :test
end
	
# обработка ошибки not_found 
not_found do
     status 404
     "404 ошибка, Not Found, наша любимая))"
end

# перехват данных из url 
get '/:name' do
     "Ассаламу Алейкум, #{params[:name]}." + "\n" +
	"Перед вами тесты для мутаАлимов :-)"
end


__END__
 
@@test
<!DOCTYPE html>
<html>
	<head>
		<title>Тесты</title>
	</head>
	<body>
		<div>
			<h2> Вопрос №<%= @@test_number +1 %> <h2>
			<h3>
				<%= @@test_hash[@@mas_test_number[@@test_number]]["question"] %>
			</h3>    
		</div>
		<p> 
			<form method="get" action="/test">
				<% @@test_hash[@@mas_test_number[@@test_number]]["answers"].each_index do |i| %>
					<input type="radio" name="var" value="<%= @@mas_random_variants[@@test_number][i] %>">
						<%= @@test_hash[@@mas_test_number[@@test_number]]["answers"][@@mas_random_variants[@@test_number][i]] %><Br>
				<% end %>
				<input type="submit" value="Ответить"/>
			</form>
		</p>
		
		<div>
			<input type="button" name="next_question" value="Предыдущий вопрос" onclick="location.href='/test/pred'">
			<% @@mas_test_number.each_index do |i| %>
				<a href='/test/question/<%= i + 1 %>'> № <%= i + 1 %> </a>
			<% end %>
			<input type="button" name="pred_question" value="Следующий вопрос" onclick="location.href='/test/next'"> <Br> <Br> <Br>
		</div>
		
		<input type="button" name="result" value="Завершить тестирование" onclick="location.href='/test/result'">
	</body>
</html>



@@index
<!DOCTYPE html>
<html>
	<head>
		<title>Главная</title>
	</head>
	<body>
		<h1> Ассаламу гIалайкум ва раhматуЛлаhи ва баракатуhу!</h1>    
		<h1> Мира вам, Милости и Благославления Всевышнего!</h1>    
		<h1> Сайт для тестирования базовых знаний</h1>    
		<h2>Описание </h2>
		<div>
			<p>	Этот сайт предназначен для тех кто хочет проверить свои знания. </p> 
		</div>
		<input  value="Начать тест" name="test_begin" onclick="location.href='/test'" type="button">
	</body>
</html>


@@result
<!DOCTYPE html>
<html>
	<head>
		<title>Результат</title>
	</head>
	<body>
		<h1> Результаты вашего теста </h1>    
		
		<div>
			<table  cellspacing="2" border="1" cellpadding="5">
				<tr> <td> № </td> <td> Вопрос </td> <td> Ваш ответ </td> <td> Правильный ответ </td> <tr>
				<% @@mas_test_answer.each_index do |i| %>
					<tr> 
						<td> <%= i+1 %> </td> 
						<td> <%= @@test_hash[@@mas_test_number[i]]["question"] %> </td> 
						<td> <%= 	if (@@mas_test_answer[i] == -1)  
										@@not_answer 
									else @@test_hash[@@mas_test_number[i]]["answers"][@@mas_test_answer[i]] end %> </td>
						<td> <%= @@test_hash[@@mas_test_number[i]]["answers"][0] %> </td> 
					<tr>
				<% end %>
			</table>
		</div>
		<div>
			<h3> Количество тестов =  				<%= @@kol_testov %> </h3>
			<h3> Количество ответов =  	<%= @@answers %> </h3>
			<h3> Количество правильных ответов =  	<%= @@ball %> </h3>
			<h3> Процент правильных ответов =  		<%= @@procent_tru_answers %> %</h3>
		<div>
		<div>
			<p>	Этот сайт предназначен для тех кто хочет проверить свои знания.
			</p> 
		</div>
		<input  value="Пройти снова" name="test_begin" onclick="location.href='/test'" type="button">
	</body>
</html>
