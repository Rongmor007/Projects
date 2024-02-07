def translate_en_ru(fn):
	"""
	Функция для перевода некоторых слов с английского на русский
	"""
	dictionary = {
		'Failed': 'Ошибка',
		'Passed': 'Без замечаний',
		'Skipped': 'Пропущено',
		'Done': 'Без замечаний',
		'None': '',
		'NotStarted' : 'Не запускалась',
		'Aborted' : 'Прервана',
		'GT': '>',
		'LT': '<',
		'GELE': '$\div$',
		'GE': '$\geq',
		'LE': '$\leq$'
				  }
	if callable(fn):
		def translated(*args, **kwargs):
			raw = fn(*args, **kwargs)
			if isinstance(raw, list):
				return [dictionary.get(element, element) for element in raw]
			else:
				return dictionary.get(raw, raw)

		return translated
	else:
		if isinstance(fn, list):
			return [dictionary.get(element, element) for element in raw]
		else:
			return dictionary.get(fn, fn)
			
def escape(fn):
	"""
	Функция для обработки служебных символов (добавляет слэш перед символами, которые latex считает служебными)
	"""
	if callable(fn):
		def escaped(*args, **kwargs):
			raw = fn(*args, **kwargs)
			if isinstance(raw, list):
				return [element.translate(str.maketrans({'_': r'\_{}', '&': r'\&', '"': '"{}'})) for element in raw]
			else:
				return raw.translate(str.maketrans({'_': r'\_{}', '&': r'\&', '"': '"{}'}))

		return escaped
	else:
		if isinstance(fn, list):
			return [element.translate(str.maketrans({'_': r'\_{}', '&': r'\&', '"': '"{}'})) for element in raw]
		else:
			return fn.translate(str.maketrans({'_': r'\_{}', '&': r'\&', '"': '"{}'}))
			
class ReportHelper:
	"""
	Помошник составления отчетов
	"""

	def __init__(self):
		self.__list_of_headers = []

	def set_list_of_headers(self, list_of_headers):
		"""
		Установка текущих видов заголовков отчётов
		:param list_of_headers: список словарей, из которых строится заголовок одного отчёта (список)
		"""
		self.__list_of_headers = list_of_headers
		
	def get_header(self, index):
		"""
		Получение словаря из списка словарей заголовоков под индексом index
		:param index: индекс (целое число)
		:return: словарь со строками из нужного заголовка (словарь)
		"""
		return self.__list_of_headers[index]
				
	def add_block(self, orientation, content):
		"""
		Добавление тела таблицы
		:param orientation Ориентация блока, может быть horizontal(горизонтальной) и vertical(вертикальной)
		:param content Содержимое блока в виде массива объектов {data, mode}, где data - массив значений, mode -
		режим вставки
		"""
		# TODO: поменять orientation на enum

		table = []
		modes = []

		# put data in table
		for item in content:
			table.append(item['data'])
			modes.append(item['mode'])

		self.process_content(table, modes, orientation)

		table = {
			'vertical': self.transpose_table,
			'horizontal': self.prepare_horizontal_table
		}[orientation](table)

		result = ''

		for row in table:
			result += ' '.join(row) + ' \\\\'
			if orientation == 'vertical':
				for j in range(len(modes)):
					if modes[j] == 'all':
						result += ' \cline{' + str(j + 1) + '-' + str(j + 1) + '}'
			if orientation == 'horizontal':
				for j in range(len(row)):
					result += ' \cline{' + str(j + 1) + '-' + str(j + 1) + '}'
			result += '\n'

		return result

	# заглушка
	def prepare_horizontal_table(self, table):
		print('prepare_horizontal_table')
		return table

	def transpose_table(self, table):
		"""
		Функция траспонирования таблицы
		:param table: таблица
		:return: транспонированная таблицы
		"""
		print('transpose_table')
		return [list(i) for i in zip(*table)]

	def process_content(self, table, modes, orientation):
		"""
		Внутренняя функция обработки таблицы
		:param table: Таблица
		:param modes: режимы
		:param orientation: ориентация
		:return: latex-представление таблицы
		"""
		{
			'vertical': self.process_vertical,
			'horizontal': self.process_horizontal
		}[orientation](table, modes)

	def process_vertical(self, table, modes):
		"""
		Внутренняя функция для обработки вертикальной таблицы
		:param table: таблицы
		:param modes: режимы для колонок
		:return: latex-представление таблицы
		"""

		for idx, mode in enumerate(modes):
			col = []

			# определение количества элементов в наибольшем списке из table
			max_ = 0
			for item in table:
				if len(item) > max_:
					max_ = len(item)

			# for row in range(len(table[0])):
			for row in range(max_):
				try:
					col.append(table[idx][row])
				except:
					col.append('')

			{
				'all': self.process_all_mode_vertical,
				'first': self.process_first_mode_vertical
			}[mode](col, idx)

			table[idx] = col

	def process_horizontal(self, table, modes):
		"""
		Внутренняя функция для обработки горизонтальной таблицы
		:param table: таблица
		:param modes: режимы для строк
		:return: latex-представление таблицы
		"""
		for idx, mode in enumerate(modes):
			row = table[idx]

			{
				'all': self.process_all_mode_horizontal,
				'first': self.process_first_mode_horizontal
			}[mode](row, idx)

			table[idx] = row

	def process_all_mode_vertical(self, col, idx):
		"""
		 Внутренняя функция для обработки строки при формировании горизонтально-направленного блока с режимом "Все"
		:param col: Колонка
		:param idx: индекс
		:return: latex-код для данной колонки
		"""
		print('process_all_mode_vertical')
		for i, item in enumerate(col):
			col[i] = (('' if idx == 0 else '& ') + item)

	def process_first_mode_vertical(self, col, idx):
		"""
		Внутренняя функция для обработки строки при формировании горизонтально-направленного блока с режимом "Первый"
		:param col: колонка
		:param idx: номер строки
		:return: latex-код для данной колонки
		"""
		print('process_first_mode_vertical')
		for i, item in enumerate(col):
			if i == 0:
				col[i] = (('& ' if idx != 0 else '') + '\\multirow{{{}}}{{*}}{{{}}}'.format(len(col), item))
			else:
				col[i] = ('& ' if idx != 0 else '')

	def process_all_mode_horizontal(self, row, idx):
		"""
		Внутренняя функция для обработки строки при формировании горизонтально-направленного блока
		:param row: строка
		:param idx: индекс
		:return: latex-код для данной строки
		"""
		print('process_all_mode_horizontal')
		for i, item in enumerate(row):
			row[i] = (('' if i == 0 else '& ') + item)

	def process_first_mode_horizontal(self, row, idx):
		"""
		Внутренняя функция для обработки строки при формировании вертикально-направленнонго блока
		:param row: строка
		:param idx: индекс
		:return: latex-код для данной строки
		"""
		print('process_first_mode_vertical')
		for i, item in enumerate(row):
			if i == 0:
				row[i] = '\\multicolumn{{{}}}{{l}}{{{}}}'.format(len(row), item)
			else:
				row[i] = ('')

	def get_color_for_status(self, status):
		"""
		Выставление цвета для статуса
		:param status: статус
		:return: цвет
		"""
		color = {'Passed': 'green',
				 'Failed': 'red',
				 'Skipped': 'cyan',
				 'Done': 'blue'
				 }.get(status, 'white')

		return color

	def add_background_color(self, raw):
		"""
		Добавление фоноового цвета для текста
		:param raw: текст в виде строки или списка
		:return: текст, обернутый в фоновый цвет
		"""
		if isinstance(raw, list):
			colored_list = []
			for element in raw:
				color = self.get_color_for_status(element)
				colored_list.append(r'\colorbox{{0}}{{1}}'.format(color, element))
			return colored_list
		else:
			return self.get_color_for_status(raw)

	def rotate_text(self, grade, text):
		"""
		Поворачивает текст на указанный градус
		:param grade: градус
		:param text: текст
		"""
		result = r'\rotatebox{' + str(grade) + '}{' + text + '}'
		return result

	def add_plots(self, data, title, xlabel, ylabel, grid, height, width, rotate, precision, xmin, xmax, power_of_x_axis=1, min_xlabel=0, interval_of_xlabel=0):
		"""
		Добавление графиков
		:param data: массив словарей ('function':'Название кривой', 'color':'цвет', 'mark':'метка точек', 'coordinates':'координаты (x,y)')
		:param title: заголовок всего графика (строка)
		:param xlabel: название оси Х (строка)
		:param ylabel: название оси Y (строка)
		:param grid: сетка (строка, значения: 'major' - только через основные деления, 'minor' - только через дополнительные деления, 'both', 'none')
		:param height: высота (строка, например '10cm')
		:param width: ширина (строка, например '15cm')
		:param rotate: угол поворота подписей значений на оси OX (строка)
		:param precision: количество знаков после запятой в подписях значений на оси OX (строка)
		:param xmin: начало рассматриваемого отрезка оси OX на графике (строка)
		:param xmax: конец рассматриваемого отрезка оси OX на графике (строка)
		"""
		# пример вызова: add_plots([ ('Function 1', 'blue', 'x', [(1, 3600), (5, 4200)]),
		#                            ('Function 2', 'red', '.', [(1, 3000), (3, 3500), (5, 4000)]) 
		#                          ], 
		#                          'Заголовок Графиков', 'x', 'y', 'major', '10cm', '15cm')
		if isinstance(data, list):
			if xlabel == '' and ylabel == '':
				result = r'\begin{tikzpicture}' + '\n' \
											  r'\begin{axis}[' + '\n' \
																 'title={' + title + '},\n' \
																 'height={' + height + '},\n' \
																 'width={' + width + '},\n' \
																 'grid={' + grid + '},\n' \
																 'xticklabel style={\n' \
																 'rotate=' + rotate + ',\n' \
																 'xmin=' + xmin + ',\n' \
																 'xmax=' + xmax + ',\n' \
																 '/pgf/number format/precision=' + precision + ',\n' \
																 '/pgf/number format/fixed,\n' \
																 '/pgf/number format/fixed zerofill,},\n'
			
			else:
				result = r'\begin{tikzpicture}' + '\n' \
												r'\begin{axis}[' + '\n' \
																	'title={' + title + '},\n' \
																	'xlabel={' + xlabel + '},\n' \
																	'ylabel={' + ylabel + '},\n' \
																	'height={' + height + '},\n' \
																	'width={' + width + '},\n' \
																	'grid={' + grid + '},\n' \
																	'xticklabel style={\n' \
																	'rotate=' + rotate + ',\n' \
																	'xmin=' + xmin + ',\n' \
																	'xmax=' + xmax + ',\n' \
																	'/pgf/number format/precision=' + precision + ',\n' \
																	'/pgf/number format/fixed,\n' \
																	'/pgf/number format/fixed zerofill,},\n'
			
			if min_xlabel != 0 and interval_of_xlabel != 0:
				result += 'xtick={' + str(min_xlabel)
				min_xlabel += interval_of_xlabel
				while min_xlabel <= int(xmax):
					result += ', ' + str(min_xlabel)
					min_xlabel += interval_of_xlabel
				result += '},\n'
			result += ']\n'
			for item in data:
				coord = ''
				for sub_item in item['coordinates']:
					sub_item = list(sub_item)
					sub_item[0] *= power_of_x_axis
					sub_item = tuple(sub_item)
					coord += str(sub_item) + '\n'
				
				if item['function'] == '':
					result += r'\addplot[{smooth}, mark={' + item['mark'] + '}, {' + str(item['color']) + '}]\n' \
																	   'coordinates{' + coord + '};\n'
				else:
					result += r'\addplot[{smooth}, mark={' + item['mark'] + '}, {' + str(item['color']) + '}]\n' \
																	   'coordinates{' + coord + '};\n' \
																								r'\addlegendentry{' + str(
					item['function']) + '}\n'
					
			result += r'\end{axis}' + '\n' \
									  r'\end{tikzpicture}' + '\n'

			return result
		else:
			return 0


	def add_table(self, centering, caption, headers, content):
		"""
		Добавляет таблицу с указанным выравниванием, названием, заголовками и содержимым
		:param centering: выравнивание
		:param caption: название таблицы
		:param headers: заголовки
		:param content: тело таблицы
		"""
		result = ''
		if (not isinstance(centering, list) and not isinstance(headers, list)) or len(content) == 0:
			print('не верный тип заданных параметров!')
			return result
		result = r'\begin{longtabu} to \textwidth{|'

		# добавление выравнивания
		for item in centering:
			if item == 'center':
				result += 'c' + '|'
			if item == 'right':
				result += 'r' + '|'
			if item == 'left':
				result += 'l' + '|'
		result += '}\n' + '\caption{' + caption + r'}\label{tab:1} \\' + '\n \hline \n'

		# добавление заголовков
		head = ''
		for item in headers:
			head += item + '&'  # заменить на переменную head и ее два раза добавить
		head = head[0:len(head) - 1] + r' \\ ' + '\n'
		result += head + \
				  '\endfirsthead \n \hline \n' + \
				  head + \
				  '\endhead \n \hline \n' + \
				  content + \
				  '\hline \n \end{longtabu} \n'

		return result

	def encode(self, decoded_str):
		"""
		Кодирование валидного utf8 в cp1252 для работы с БД
		:param decoded_str: корректно отображаемая кириллица
		:return: cp1252 строка для работы с БД
		"""
		return decoded_str.encode('cp1251').decode('cp1252')

	def decode(self, encoded_str):
		"""
		Раскодирование из UTF-16 в CP1251 для нормального отображения кириллицы
		:param encoded_str: некорректно отображаемая кириллица
		:return: валидный utf8
		"""
		if not isinstance(encoded_str, str):
			return "ERR"

		new_str = ''
		decoded_str = encoded_str.encode().decode().encode('UTF-16LE').decode('cp1251')
		for i in range(len(decoded_str)):
			if i % 2 == 0:
				new_str += decoded_str[i]

		return new_str
	
	def translate_en_to_ru(self, fn):
		"""
		Декоратор для перевода некоторых часто используемых слов
		"""
		dictionary = {
			'Failed': 'Ошибка',
			'Passed': 'Без замечаний',
			'Skipped': 'Пропущено',
			'Done': 'Без замечаний',
			'None': '',
			'NotStarted' : 'Не запускалась',
			'Aborted' : 'Прервана'
		}

		if callable(fn):
			def translated(*args, **kwargs):
				raw = fn(*args, **kwargs)
				if isinstance(raw, list):
					return [dictionary.get(element, element) for element in raw]
				else:
					return dictionary.get(raw, raw)

			return translated
		else:
			if isinstance(fn, list):
				return [dictionary.get(element, element) for element in fn]
			else:
				return dictionary.get(fn, fn)
	
	def get_list_length(self, array):
		if isinstance(array, list):
			return len(array)
		else:
			return "ERR"
	
	def check_comparation_type(self, lo_limit, hi_limit, comp_type, format_string):
		"""
		Функция возвращает словарь из двух отформатированнных пределов измерений, lo_limit - нижний предел, hi_limit - верхний предел.
		Функция нужна для правильного заполения пределов измерений, ввиду того что тестстэнд в случае единичного типа сравнения всегда заполняет только нижний предел.
		:param hi_limit: верхний предел измерения извлеченный из Teststand (строка)
		:param lo_limit: нижний предел измерения извлеченный из Teststand (строка)
		:param comp_type: тип сравнения извлеченный из Teststand (строка)
		:param format_string: строка с модификатором вывода. Например '%.3f'.
		"""
		limits = {'hi_limit':' ', 'lo_limit':' '}
		if hi_limit == None:
			hi_value = ' --- '
		else:
			hi_value = format_string % (float(hi_limit))
		if lo_limit == None:
			lo_value = ' --- '
		else:
			lo_value = format_string % (float(lo_limit))
		if comp_type == None:
			lo_value = ' --- '
			hi_value = ' --- '
		else:
			if comp_type == 'EQ' or comp_type == 'NE':
				hi_value = lo_value
			else:
				if comp_type == 'LT' or comp_type == 'LE' or comp_type == 'LTGT' or comp_type == 'LEGE' or comp_type == 'LEGT' or comp_type == 'LTGE':
					dummy = lo_value
					lo_value = hi_value
					hi_value = dummy
		limits['lo_limit'] = lo_value
		limits['hi_limit'] = hi_value
		return limits
		
	def formatting_float_number(self, numb, precision=3, flags='', number_multiplication=1):
		"""
		Функция форматированного вывода вещественного числа
		:param numb: форматируемое число (вещественное число, целое число или строка, представляющая собой вещественное число)
		:param precision: количество цифр после запятой (целое число)
		:param flags: флаг форматирования (строка) может принимать значения '-' (выравнивание), '+' (вывод числа со знаком даже при положительных числах), '0' (наличие ведущих модулей)
		:param number_multiplication: число, на которое домножается numb (число)
		"""
		result = ('%' + flags + '.' + str(precision) + 'f')%(float(numb) * number_multiplication)
		# удаление знака '-', если округлённое число равно нулю
		if flags == '' and result[0] == '-':
			is_zero = True
			for i in range(1, len(result)):
				if result[i] != '.' and result[i] != '0':
					is_zero = False
					break
			if is_zero:
				result = result[1:]
		return result
	  
	def exist_test(self, seq, index=0):
		"""
		Вывод элемента списка или словаря seq[index], если он существует, иначе вывод длинного тире или непустой строки seq
		:param seq: (список)
		:param index: индекс необходимого элемента (целое число) или ключ словаря (неизменяемый тип)
		"""
		if isinstance(seq, list):
			if len(seq) > index:
				return seq[index]
			else:
				return '---'
		elif isinstance(seq, dict):
			if index in seq:
				return seq[index]
			else:
				return '---'
		elif isinstance(seq, str):
			if seq == '':
				return '---'
			else:
				return seq
		else:
			return seq
	
	@translate_en_ru
	@escape
	def exist_result(self, seq, index=0, precision=2, flags='', number_multiplication=1):
		"""
		Форматированный вывод элемента списка seq[index], если он существует, иначе форматированный вывод переданного в функцию элемента
		:param seq: (список)
		:param index: индекс необходимого элемента (целое число)
		:param precision: количество цифр после запятой (целое число)
		:param flags: флаг форматирования (строка) может принимать значения '-' (выравнивание), '+' (вывод числа со знаком даже при положительных числах), '0' (наличие ведущих модулей)
		:param number_multiplication: число, на которое домножается числовой элемент списка seq[index] (число)
		"""
		dop_numb = self.exist_test(seq, index)
		try:
			numb = self.formatting_float_number(dop_numb, precision, flags, number_multiplication)
		except ValueError:
			numb = dop_numb
		except TypeError:
			numb = dop_numb
		numb = str(numb)
		return numb
	
	def exist_limits (self, dic, key, precision=2, flags='', number_multiplication=1, up=1):
		"""
		Форматированный вывод погрешности или элементов словаря dic
		:param dic: (словарь, имеющий обязательные поля 'hi' и 'lo' для вычисления погрешности)
		:param key: ключ, по которому определяется возвращаемое значение словаря, особое значение 'ocur' означает вывод погрешности значений (строка)
		:param precision: количество цифр после запятой (целое число)
		:param flags: флаг форматирования (строка) может принимать значения '-' (выравнивание), '+' (вывод числа со знаком даже при положительных числах), '0' (наличие ведущих модулей)
		:param number_multiplication: число, на которое домножается считываемый элемент списка предела (число)
		:param up: смещение от номинального значения вверх (число)
		"""
		if isinstance(dic, dict):
			if key == 'ocur':
				limit = self.formatting_float_number(abs(dic['hi'] - dic['lo']) / 2, precision, flags, number_multiplication)
			elif key == 'modified_comp':
				if dic['comp'] == 'LE':
					limit = self.formatting_float_number(0.0, precision, flags) + '$\div$'
				else:
					limit = dic['comp']
			elif key == 'comp' or key == 'units' or key == 'status':
				limit = dic[key]
			elif key == 'median':
				limit = self.formatting_float_number(dic['lo'] + abs(dic['hi'] - dic['lo']) / 2, precision, flags, number_multiplication)
			elif key == 'hi-up':
				limit = self.formatting_float_number(dic['hi'] - up, precision, flags, number_multiplication)
			else:
				limit = self.formatting_float_number(dic[key], precision, flags, number_multiplication)
		else:
			limit = '---'
		return limit
	
	# def number_of_step(self, name_of_step):
	# 	"""
	# 	Функция вывода номера шага испытания из его названия
	# 	:param name_of_step: название шага (строка)
	# 	:return: номер шага (строка)
	# 	"""
	# 	# поиск первой точки
	# 	index = name_of_step.find('.')
	# 	name_of_step = name_of_step[index+1:]
	# 	# поиск второй точки
	# 	index = name_of_step.find('.')
	# 	number = ''
	# 	# при отсутствии символа в строке функция find возвращает значение -1
	# 	if index != -1:
	# 		for i in range(index+1, len(name_of_step)):
	# 			if name_of_step[i].isdigit():
	# 				if name_of_step[i] == '0' and number == '':
	# 					pass
	# 				else:
	# 					number += name_of_step[i]
	# 			else:
	# 				break
	# 	return number
	
	def number_of_step(self, name_of_step):
		"""
		Функция вывода номера шага испытания из его названия
		:param name_of_step: название шага (строка)
		:return: номер шага (строка)
		"""
		# поиск до пробела
		index = name_of_step.find(' ')
		name_of_step = name_of_step[:index]
		# фильтр на номер проверки
		number = name_of_step[-2:]
		if number[0] == '0':
			number = number[-1]
		
		return number


	# def split_name(self, name_of_step):
	# 	"""
	# 	функция разделения имени шага на его номер и название
	# 	:param name_of_step: название шага (строка)
	# 	:return: список из имени полного номера и из имени шага без его номера
	# 	"""
	# 	index = 0
	# 	res = []
	# 	for i in range(0, len(name_of_step)):
	# 		# if name_of_step[i].isdigit() or name_of_step[i] == '.' or name_of_step[i] == ' '
	# 		if name_of_step[i].isalpha():
	# 			index = i
	# 			break
	# 	res.append(name_of_step[:index])    # полный номер шага
	# 	res.append(name_of_step[index:])     # имя шага без номера
	# 	for i in range(len(res[0])-1, 0, -1):
	# 		if res[0][i].isdigit():
	# 			index = i
	# 			break
	# 	res[0] = res[0][:index+1]
	# 	return res


	def split_name(self, name_of_step):
		"""
		функция разделения имени шага на его номер и название
		:param name_of_step: название шага (строка)
		:return: список из имени полного номера и из имени шага без его номера
		"""
		res = []
		res.append(self.number_of_step(name_of_step))    # полный номер шага
		res.append(name_of_step[name_of_step.find(' ') + 1:])     # имя шага без номера
		return res
	

	def number_of_decimal_places(self, number):
		"""
		Функция подсчёта количества десятичных цифр после запятой
		:param number: интересующее число (целое число, вещественное число (float), строка)
		:return: количество цифр после запятой (целое число)
		"""
		if isinstance(number, int):
			return 0
		if isinstance(number, float):
			number = str(number)
		if not isinstance(number, str):
			return -1
		index1 = number.find('.')
		# если дано целое число в виде строки
		if index1 == -1:
			return 0
		index2 = number.find('e')
		length = len(number)
		# если вещественное число представлено не в экспоненциальном виде
		if index2 == -1:
			return length - index1 - 1
		# если вещественное число представлено в экспоненциальном виде
		else:
			return (index2 - index1 - 1) + int(number[index2+2:])
	
	def sort_list_of_steps(self, seq):
		"""
		Функция сортировки списка словарей шагов тестирования методом пузырька
		:param seq: список словарей шагов тестирования (список)
		"""
		length_of_list = len(seq)
		for j in range(1, length_of_list):
			for i in range(0, length_of_list - j):
				if int(self.number_of_step(seq[i]['step_name'])) > int(self.number_of_step(seq[i+1]['step_name'])):
					mem = seq[i+1].copy()
					seq[i+1] = seq[i].copy()
					seq[i] = mem.copy()
					
	def split_on_rows(self, text, numb_of_symbols_in_row):
		"""
		Функция разбиения предложения на строки по numb_of_symbols_in_row символов без переноса слов
		:param text: предложение для разбиения (строка) не содержит двойных пробелов, пробелов в начале и в конце предложения, символов \t и \n
		:param numb_of_symbols_in_row: максимально возможное количество символов в одной строке
		:return: список, первый элемента которого указывает количество получившихся строк, второй элемент - список из получившихся строк
		"""
		length_of_text = len(text)
		if length_of_text <= numb_of_symbols_in_row:
			return [1, [text]]
		else:
			res = [0, []]
			mem_index_down = 0
			mem_index_median = 0
			mem_index_up = 0
			for i in range(0, length_of_text):
				if text[i] == ' ':
					mem_index_median = mem_index_up
					mem_index_up = i
					if mem_index_up - mem_index_down >= numb_of_symbols_in_row:
						if mem_index_up - mem_index_down == numb_of_symbols_in_row:
							mem_index_median = mem_index_up
						else:
							# когда слово больше заданного количества символов
							if mem_index_median + 1 == mem_index_down or mem_index_median == mem_index_down:
								return [-1, []]
						res[0] += 1
						res[1].append(text[mem_index_down:mem_index_median])
						mem_index_down = mem_index_median + 1
				else:
					if i == length_of_text - 1:
						# единица прибавляется, так как i и mem_index_down входят в слово
						if i - mem_index_down + 1 > numb_of_symbols_in_row:
							# когда самое первое или самое последнее слово больше заданного количества символов
							if mem_index_up == mem_index_down or i - mem_index_up > numb_of_symbols_in_row:
								return [-1, []]
							else:
								res[0] += 2
								res[1].append(text[mem_index_down:mem_index_up])
								res[1].append(text[mem_index_up+1:])
						else:
							res[0] += 1
							res[1].append(text[mem_index_down:])
			return res
			
	def add_multirow_command_in_rows(self, list_of_rows):
		"""
		Функция добавления команды \multirow к каждому строковому элементу списка, остальные элементы в списке пропускаются
		:param list_of_rows: список, к строковым элементам которого нужно добавить команду \multirow
		"""
		if isinstance(list_of_rows, list):
			for i in range(0, len(list_of_rows)):
				if isinstance(list_of_rows[i], str):
					list_of_rows[i] = '\\multirow{2}{*}{' + list_of_rows[i] + '}'
   
	def split_on_rows_with_max_count_rows(self, text, numb_of_symbols_in_row, max_count_of_rows):
		"""
		Функция разбиения и размещения полученных после разбиения текста text строк среди доступных строк, количество которых равно max_count_of_rows.
		:param text: предложение для разбиения (строка)
		:param numb_of_symbols_in_row: максимально возможное количество символов в одной строке
		:param max_count_of_rows: доступное количество строк
		:return: список, первый элемент которого указывает на необходимость использования \multirow в LaTeX в каждой выводимой строке (при 0 использовать \multirow не нужно,
		при 1 использовать \multirow нужно). Второй элемент состоит из списка строк длиной max_count_of_rows, в которые вводятся строки из text
		"""
		internal_split = self.split_on_rows(text, numb_of_symbols_in_row)
		res = [0, []]
		for i in range (0, max_count_of_rows):
			res[1].append('')
		# если text не влазит в доступные строки
		if max_count_of_rows < internal_split[0]:
			res[0] = -1
			return res
		mid_of_available_rows = int((max_count_of_rows - 1) / 2)
		mid_of_text_rows = int((internal_split[0] - 1) / 2)
		offset_from_center = 0
		offset_to_right_of_center = 0
		offset_to_left_of_center = 0
		if internal_split[0] % 2 == 1:
			if max_count_of_rows % 2 == 0:
				res[0] = 1
				self.add_multirow_command_in_rows(internal_split[1])
			res[1][mid_of_available_rows] = internal_split[1][mid_of_text_rows]
			offset_from_center = 1
		elif max_count_of_rows % 2 == 1:
			res[0] = 1
			self.add_multirow_command_in_rows(internal_split[1])
			offset_to_left_of_center = 1
		else:
			offset_to_right_of_center = 1
		for i in range(0, internal_split[0] // 2):
			res[1][mid_of_available_rows - offset_from_center - offset_to_left_of_center] = internal_split[1][mid_of_text_rows - offset_from_center]
			res[1][mid_of_available_rows + offset_from_center + offset_to_right_of_center] = internal_split[1][mid_of_text_rows + offset_from_center + offset_to_right_of_center + offset_to_left_of_center]
			offset_from_center += 1
		return res
		
	def clean_date(self, date_and_time):
		"""
		В XML файле даты хранятся с английской буквой "T" между датой и временем, а также с миллисекундами.
		Это функция убирает эти данные из строки.
		:param date_and_time: дата и время из XML (строка)
		:return: отформатированнные дата и время
		"""
		if isinstance(date_and_time, str):
			date_and_time = date_and_time.replace('T', ' ')
			dot_index = date_and_time.find('.')
			if dot_index != -1:
				date_and_time = date_and_time[:date_and_time.index('.')]
		return date_and_time
	
	def check_status_count(self, list_elem):
		"""
		Применимо для списка, составленного методом translate_en_to_ru
		Подсчитывает количество элементов в списке
		:param list_elem: (список), переведенный на русский
		:return: (строка)
		"""
		if isinstance(list_elem, list):
			self.list_elem = list_elem
			failed = 'Ошибка:' + str(list_elem.count('Ошибка'))
			failed2 = ' Пропущено:' + str(list_elem.count('Пропущено'))
			return failed + failed2

	def status_of_substeps(self, list_elem, key = 1):
		"""
		Возвращает форматированный вид списка успешных проверок
		В случае, если не переведен на русский, то переведется
		:param list_elem: (список)
		:param key = 1: при key = 1 выполняется преобразование списка в одну строку. При любом другом значении не выполняется и возвращается переведенный список 
		:return: при key = 0 (список) или при key = 1 (cтрока)
		"""
		if isinstance(list_elem, list):
			self.list_elem = list_elem
			list_elem = self.translate_en_to_ru(list_elem)
			if key == 1:
				temporary = [step for step in list_elem if step != 'Без замечаний']
				if len(temporary) > 0:
					list_elem = temporary
					list_elem = self.check_status_count(list_elem)               
				else:
					list_elem = list_elem[0]
			return list_elem

	def power_for_kits(self, list_elem, maximum = 0, key = 0):
		"""
		Разбивает список строчных значений списка на количество == 2
		:param list_elem: (список)
		:param key: (числовой) - условие для сортировки списка по порядку (!=0)
		:param maximum: (числовой) - условие для вычисления максимума (!=0)
		:return: (список) со значениями максимума каждого интервала
		"""
		self.list_elem = list_elem
		# Максимум
		if isinstance(list_elem, list) and len(list_elem) // 2 and maximum != 0 and key == 0:
			Check_power_kits = [max([step for step in list_elem[:(len(list_elem)//2):]])] + [max([step for step in list_elem[-1:(len(list_elem)//2)-1:-1]])]

		# Без порядка
		if isinstance(list_elem, list) and len(list_elem) // 2 and maximum == 0 and key == 0:
			Check_power_kits = [step for step in list_elem[:(len(list_elem)//2):]], [step for step in list_elem[-1:(len(list_elem)//2)-1:-1]]

		# По порядку
		if isinstance(list_elem, list) and len(list_elem) // 2 and maximum == 0 and key != 0:
			Check_power_kits = [step for step in list_elem[:(len(list_elem)//2):]], [step for step in list_elem[(len(list_elem)//2):(len(list_elem))]]
		
		return Check_power_kits
		

	def file_exist(self, number):
		'''
		Проверка на существование файла с номером проверки и что проверка не пропущена
		:param number: (числовое)
		:return: True, если файл существует. False, если нет
		'''
		self.number = number
		import os.path
		# with open('Kpa'+number+'.tex') as file:
		#     return True
		return os.path.isfile('bios' + number + '_20gk' + '.tex')
	
	def abs_difference(self, high, low):
		'''
		Разница между значениями в абсолюте
		:param high: верхнее значение
		:param low: нижнее значение
		:return: абсолютное значение разницы между верхним и нижним значениями
		'''
		self.high = high
		self.low = low
		if isinstance(high, str) and isinstance(low, str):
			high = float(high.replace(',', '.'))
			low = float(low.replace(',', '.'))
			# Вычисление разницы во флоате, округление до 4-х символов после запятой и перевод в строку с заменой . на ,
			absolute = str(round((abs(high - low)), 4)).replace('.', ',')
			return absolute

	def main_gk (self, gk):
		'''
		Функция возвращает значение %%GK для определения версии bios
		:param gk: строка файла, в которой ищется нужная версия
		:return: (пример) 20GK или 50GK
		'''
		import os
		import re as r
		self.gk = gk
		main = os.path.abspath(gk)
		name = os.path.basename(main)
		rg = r'[0-9]{2}GK'
		gk = r.search(rg, name)
		# Временный костыль
		if gk == None:
			gk = ['50GK']
		return gk[0]

	def telemetry(self, current, delta):
		'''
		:param current: список измеренных токов
		:param delta: список значений падения
		'''
		telemetry = []
		current = [i.replace(',', '.') for i in current]
		if isinstance(current, list) and isinstance(delta, list) and len(current) == len(delta):
			for step in range(len(current)):
				if delta[step][0:1] == '+':
					cost = float(current[step])
					percent = float(delta[step][2:])
					result = round(cost + (cost / 100 * percent), 3)
					telemetry.append(str(result).replace('.', ','))
				if delta[step][0:1] == '-':
					cost = float(current[step])
					percent = float(delta[step][2:])
					result = round(cost - (cost / 100 * percent), 3)
					telemetry.append(str(result).replace('.', ','))
			return telemetry