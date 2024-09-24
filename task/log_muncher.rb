include Gem::Text

# @param [String] path
def read_file(path)
  t1 = Time.now
  right_names = {}
  mistake_names = {}
  File.open(path) do |f|    # Читаем из файла результаты голосов построчно
    f.each_line do |line|
      name_with_spaces = line.split('=>')[1].split(' ') # Разделяем сначала строку по символу => , а затем по пробелам для Ф.И.О
      name = ''
      name_with_spaces.each do |element|
        name+=element                            # Собираем из массива слитное написание Ф.И.О
      end
      if name.include? '/[A-Za-z]/'    # Если имя включает любые латинские буквы -> оно неправильное -> кидаем в словарь с плохими именами
        mistake_names[name] = 1
      else
        insert_correct_name(name, right_names)   # Если правильное или содержит пропущенные буквы -> пока кидаем в словарь с правильными именами
      end
    end
  end
  move_names(right_names, mistake_names)
  compare_names(right_names, mistake_names)
  t2 = Time.now
  print(right_names)
  puts "Время работы программы: "+(t2-t1).to_s+" cек"
end

# Вставляет правильные имена в словарь
# @param [Hash] right_names
# @param [String] name
def insert_correct_name(name, right_names)
  if right_names.include? name
    right_names[name]+= 1      # Если такое имя уже есть -> увеличиваем у него кол-во голосов
  else
    right_names[name] = 1
  end
end

# Сравнивает имена из плохого словаря с имена из правильного словаря
# @param [Hash] right_names
# @param [Hash] mistake_names
def compare_names(right_names, mistake_names)
  mistake_names.each_key do |elem_mistake_name|
    right_names.each_key do |elem_right_name|
      if (elem_mistake_name.length - elem_right_name.length).abs < 4    # Если разница в длине больше четырёх, то нет смыслат использовать расстояние Левенштейна
        if levenshtein_distance(elem_mistake_name, elem_right_name) < 5 # Проверяем имена на приблизительное совпадение
          right_names[elem_right_name]+=1                    # Если прошли проверку -> в списке правильных имён прибавляем 1 голос
          break
        end
      end
    end
  end
end

# Перебрасывает имена из одного словаря в другой
# @param [Hash] right_names
# @param [Hash] mistake_names
def move_names(right_names, mistake_names)
  right_names.sort_by{|_,count|-count}.to_h.each_with_index do |(key, value), ind| # Сортируем по возрастанию кол-ва голосов
    if ind>199                    # Т.к. первые 200 человек имеют больше всего голосов -> их имена правильные
      mistake_names[key] = value  # Перебрасываем оставшиеся имена из правильного словаря в словарь с плохими именами
      right_names.delete(key)     # Удаляем из праавильного словаря плохие имена
    end
  end                             # В итоге: правильный словарь - 200 элементов -> это уникальные правильные имена кандидатов
end

# Печать результатов по убыванию кол-ва голосов
# @param [Hash] right_names
def print(right_names)
  right_names.sort_by{|_,count|-count}.each_with_index do |(key, value), ind|
    puts (ind+1).to_s+'.'+key+": => "+ value.to_s
  end
end

read_file('data/log.txt')

# 1.ЗинаидаСемёновнаГромова: => 2153
# 2.КотоваАринаЛаврентьевна: => 2098
# 3.КолесниковМихаилАндреевич: => 2076
# 4.ГурьеваЛюдмилаРомановна: => 2075
# 5.ПахомовВладиславВалентинович: => 2074
# 6.ФомичевВладислав: => 2073
# 7.ТерентьеваЮлияДенисовна: => 2070
# 8.ХаритоновВалерийЭдуардович: => 2070
# 9.КонстантинШиряев: => 2066
# 10.КостинаАннаАркадьевна: => 2065
# 11.ГусевГеннадий: => 2056
# 12.ЕрмаковаНина: => 2055
# 13.СтепанЩукин: => 2054
# 14.КираЛеонидовнаДементьева: => 2053
# 15.ГалкинаЛюдмила: => 2052
# ........................................................
# ........................................................
# ........................................................
# Время работы программы: 72.7681359 cек