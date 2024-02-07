import sys
import os
import for_read_xml as conf
import codecs
from report_helper import ReportHelper

# для отладки
template_file_name = r"C:/avs/tgen/tex/KPA.tex"
output_file_name = r"C:/avs/tgen/tex/KPA.gen.tex"
conf_file = r'C:/avs/tgen/python/DWNT_Report_Configuration.xml'
headers = r'C:/avs/tgen/python/temp/headers.txt'
data_file = r'C:/avs/tgen/in/Main_20GK-01_Report[9 20 34][07.10.2022]_BIOS 62097204 Test poln.xml'
conf_parser = conf.XMLConfigParser(conf_file)

# получение параметров из командной строки
# список типов заголовков для тестов
list_of_headers = []
# список файлов отчётов TestStand
list_of_reports = []
list_of_gk = []
length_of_argv = len(sys.argv)

# создание класса для построения отчёта и инициализация его полей
h = ReportHelper()

if length_of_argv > 3:
	template_file_name = sys.argv[1]
	output_file_name = sys.argv[2]
	first = 3
	# если используется запуск файла через bat-файл
	if sys.argv[3] == 'bat':
		first = 4
		# считывание параметров с файла (последний символ - это символ переноса строки, поэтому он удаляется)
		for line in codecs.open('C:/avs/tgen/python/temp/param_in.txt', 'r', 'utf-8'):
			sys.argv.append(line[:-1])
		# переопределение длины списка параметров
		length_of_argv = len(sys.argv)
		# если все параметры были опущены при ручном вводе в bat-файле
		if length_of_argv == 4:
			print('Не один из файлов отчёта TestStand не был выбран. Отмена генерации отчётов...\n')
			sys.exit()
	for dop_i in range(first, length_of_argv):
		# во всех отчётах TestStand в имени файла стоит '.'
		if sys.argv[dop_i].find('.') == -1:
			# если считывается недостающий заголовок отчёта
			if len(list_of_reports) - len(list_of_headers) == 1:
				list_of_headers.append(sys.argv[dop_i])
		else:
			# если заголовок предыдущего отчёта не был указан
			if len(list_of_reports) > len(list_of_headers):
				# пустая строка означает, что заголовок отчёта должен считываться с конфигурационного файла
				list_of_headers.append('')
			if os.path.isfile(sys.argv[dop_i]):
				list_of_reports.append(sys.argv[dop_i])
				list_of_gk.append(h.main_gk(sys.argv[dop_i]))
				print(sys.argv[dop_i])
			else:
				print(
					'Файла отчёта TestStand ' + sys.argv[
						dop_i] + ' не существует, поэтому на его основе отчёт генерироваться не будет!'
					)
	if len(list_of_reports) > len(list_of_headers):
		list_of_headers.append("")
	# после ошибок в аргументах размерность списка генериуемых отчётов могла стать недостаточной
	if len(list_of_reports) == 0:
		print('Ни один аргумент не передан правильно! Отмена генерации отчётов...\n')
		sys.exit()
else:
	print('Ошибка заполнения аргументов! Отмена генерации отчётов...\n')
	sys.exit()

# количество отчётов
quantity_of_reports = len(list_of_reports)
# считывание параметров для заголовков
for dop_i in range(quantity_of_reports):
	type_of_header = list_of_headers[dop_i]
	list_of_headers[dop_i] = {'head1': '%device %serialNumber', 'head2': 'ПСИ. Проверка работоспособности',
							  'head3': 'Нормальные условия', 'date': '%date', 'gk': '%gk'}
	conf_parser.get_params_for_header(list_of_headers[dop_i], type_of_header)

if __name__ == "__main__":
	# проверка существования файла шаблона
	if not os.path.isfile(template_file_name):
		print('Файл шаблона ' + '\"' + template_file_name + '\"' + ' не существует!')
		sys.exit()

	from datetime import datetime
	import jinja2
	from report_helper import ReportHelper

	# считывание данных из первого XML-файла
	e = conf.XMLReportParser(list_of_reports[0])

	# h1 = ReportHelper()
	h.set_list_of_headers(list_of_headers)

	serial_number = h.exist_result(e.get_uut_serial_number(), precision=0)
	if serial_number == '---':
		serial_number = 'EmptySerialNo'
	# блок записи данных, используемых при формировании 
	# имени файла при генерации через bat-файлы
	if sys.argv[3] == 'bat':
		start_time_of_test = h.exist_result(h.clean_date(e.get_start_time()))
		if start_time_of_test == '---':
			start_time_of_test = 'EmptyStartDate EmptyStartTime'
		name_parameters = start_time_of_test.replace(' ', '\n')
		headers_param = open(headers, 'w')
		# запись строки в файл
		headers_param.write(name_parameters)
		headers_param.close()

	template_file_name = os.path.abspath(template_file_name)
	template_file_dir = os.path.dirname(template_file_name)
	template_name = os.path.basename(template_file_name)
	output_file_name = os.path.abspath(output_file_name)
	output_file_dir = os.path.dirname(output_file_name)
	output_name = os.path.basename(output_file_name)

	# Смена текущего каталога для доступа к дополнительным файлам относительно основного файла отчета
	os.chdir(template_file_dir)

	start_time = datetime.now()

	latex_jinja_env = jinja2.Environment(
		block_start_string='\BLOCK{',
		block_end_string='}',
		variable_start_string='\VAR{',
		variable_end_string='}',
		comment_start_string='\#{',
		comment_end_string='}',
		line_statement_prefix='%%',
		line_comment_prefix='%#',
		trim_blocks=True,
		autoescape=False,
		loader=jinja2.FileSystemLoader(template_file_dir)
	)

	latex_jinja_env.globals['e'] = e
	latex_jinja_env.globals['h'] = h
	latex_jinja_env.globals['list_of_reports'] = list_of_reports
	latex_jinja_env.globals['list_of_gk'] = list_of_gk

	template = latex_jinja_env.get_template(template_name)

	try:
		os.makedirs(output_file_dir)
	except OSError as exception:
		pass
	finally:
		print('Compiling ' + output_name)
		output = open(output_file_name, 'w', encoding="utf-8")
		output.write(template.render())
		output.close()
		print('Completed (in', round((datetime.now() - start_time).total_seconds(), 3), 'seconds).')
		print(output_file_dir, output_file_name, template_file_dir, template_file_name, template_name)
		print('Serial Number:', serial_number)
else:
	print()
