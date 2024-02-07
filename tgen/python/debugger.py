import sys
import os
import for_read_xml as conf

# для отладки
template_file_name = r"C:/avs/tgen/tex/KPA.tex"
output_file_name = r"C:/avs/tgen/tex/KPA.gen.tex"
conf_file = r'./in/DWNT_Report_Configuration.xml'
parameters_file = r'./parameters.txt'
data_file = r"C:/avs/tgen/in/Main_20GK-01_Report[9 20 34][07.10.2022]_BIOS 62097204 Test poln.xml"
# data_file = r'.\ts_reports\Main_20GK_[10 15 53][03.03.2022]_62097207.xml'
conf_parser = conf.XMLConfigParser(conf_file)

data_file = os.path.abspath(data_file)
template_file_dir_2 = os.path.dirname(data_file)
report = os.path.basename(data_file)
report = data_file
# print(conf_parser._node.childNodes[1].nodeName)

# получение параметров из командной строки
# список типов заголовков для тестов
list_of_headers = []
# список файлов отчётов TestStand
list_of_reports = []
list_of_reports.append(sys.argv[3])
length_of_argv = len(sys.argv)
# количество отчётов
quantity_of_reports = len(list_of_reports)

list_of_headers=[]
quantity_of_reports = len(list_of_reports)
list_of_headers = {'head1': '%device %serialNumber', 'head2': 'ПСИ. Проверка работоспособности', 'head3': 'Нормальные условия', 'date': '%date'}
type_of_header = ''
count = 1
if __name__ == "__main__":
	# проверка существования файла шаблона
	if not os.path.isfile(template_file_name):
		print('Файл шаблона ' +'\"' + template_file_name + '\"' + ' не существует!')
		sys.exit()

	from datetime import datetime
	import jinja2
	from report_helper import ReportHelper
	import re

	# считывание данных из первого XML-файла
	e = conf.XMLReportParser(list_of_reports[0])
		
	# создание класса для построения отчёта и инициализация его полей
	h = ReportHelper()
	h.set_list_of_headers(list_of_headers)
	
	serial_number = h.exist_result(e.get_uut_serial_number(), precision=0)
	if serial_number == '---':
		serial_number = 'EmptySerialNo'

	template_file_name = os.path.abspath(template_file_name)
	template_file_dir = os.path.dirname(template_file_name)
	template_name = os.path.basename(template_file_name)
	output_file_name = os.path.abspath(output_file_name)
	output_file_dir = os.path.dirname(output_file_name)
	
	# Смена текущего каталога для доступа к дополнительным файлам относительно основного файла отчета
	os.chdir(template_file_dir)

	start_time = datetime.now()

	# latex_jinja_env = jinja2.Environment(
	# 	block_start_string='\BLOCK{',
	# 	block_end_string='}',
	# 	variable_start_string='\VAR{',
	# 	variable_end_string='}',
	# 	comment_start_string='\#{',
	# 	comment_end_string='}',
	# 	line_statement_prefix='%%',
	# 	line_comment_prefix='%#',
	# 	trim_blocks=True,
	# 	autoescape=False,
	# 	loader=jinja2.FileSystemLoader(template_file_dir)
	# )

	# latex_jinja_env.globals['e'] = e
	# latex_jinja_env.globals['h'] = h
	# latex_jinja_env.globals['list_of_reports'] = list_of_reports
	
	# template = latex_jinja_env.get_template(template_name)

number_of_test=e.get_uut_serial_number()
# file_name - что это?
device='BIOS'
date = h.exist_result(h.clean_date(e.get_start_time()))

count_of_symbols_in_central_row = 60
steps = e.get_steps('trc:TestResults/tr:ResultSet', 'SequenceCall', 'Main')
number_of_rows = 8
Step_name = []
Check_power = []
Status_substep = []
High_limits = []
Name_of_sub_step = []
Units_limits = []
test = []
test1 = []
test2 = []
test3 = []
test4 = []
test5 = []
Limits_check = []
Check_power_kits = []
Check_summary_power = []
Check_summary_high_limit = []
Check_summary_low_limit = []
SesAct = []
GetWaveForm = []
WaveFormElem = []

dump = e.sort_list_of_steps(steps)
for step in steps:
	step_name = h.exist_result(e.get_step_name(step))
	number = h.number_of_step(step_name)
	step_status = h.exist_result(e.get_step_status(step))
	print()
	"""
	7
	"""
	# if number == '7':
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	current_step_name = h.split_name(step_name)
	# 	Limits_check = []
	# 	Check_Power = []
	# 	Status_substep = []
	# 	Limits_check = []
	# 	for step in substeps:
	# 		sub_step_name = e.get_step_name(step)
	# 		subs = [step]
	# 		limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
	# 		# dump = Check_Power.append(limits)
	# 		print(h.exist_result(e.get_step_name(step)))
	# 		dump = Check_Power.append(limits[0]['result'])
	# 		print(Check_Power)
	# 		dump = Status_substep.append(h.translate_en_to_ru(e.get_step_status(step)))
	# 		dump = Limits_check.append(limits[0]['lo'])
	# 	print()
	"""
	6
	"""
	# if number == '6':
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	current_step_name = h.split_name(step_name)
	# 	lo_limit = []
	# 	Max_amp = []
	# 	Status_substep = []
	# 	for step in substeps:
	# 		subs = [step]
	# 		limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
	# 		# print(h.exist_result(e.get_step_name(step)))
	# 		dump = Max_amp.append(limits[0]['result'])
	# 		dump = Status_substep.append(h.translate_en_to_ru(e.get_step_status(step)))
	# 		dump = lo_limit.append(limits[0]['lo'])
	# 		test = filter(Status_substep, 'Успешно')
	# 	Status_substep = h.status_of_substeps(Status_substep)
	# 	print()
	"""
	10
	"""
	# if number =='10':
	# 	Low_limits = []
	# 	test = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		sub_step_name = e.get_step_name(step)
	# 		test.append(sub_step_name)
	# 		dump = test.append(sub_step_name)
	# 		child_elem = e.get_child_elements_by_tag_name(step, 'tr:TestResult')
	# 		subs = [step]
	# 		limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
	# 		if limits[0]['units'] == 'Ом':
	# 			dump = Limits_check.append(limits)

	# 			dump = Step_name.append(h.exist_result(e.get_step_name(step)))

	# 			dump = Name_of_sub_step.append(e.get_step_name(child_elem[-1]))

	# 			dump = Check_power.append(limits[0]['result'])

	# 			dump = Status_substep.append(h.translate_en_to_ru(e.get_step_status(step)))

	# 			dump = Low_limits.append(limits[0]['lo'])
	# 	Check_power = h.power_for_kits(Check_power, key=1)
	# 	print()
	"""
	12
	"""
	# if number =='12':
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	current_step_name = h.split_name(step_name)
	# 	time_react = []
	# 	status_react = []
	# 	Low_limits = []
	# 	High_limits = []
	# 	status_substep = []
	# 	time_react_lim_hi = []
	# 	time_react_lim_lo = []
	# 	for step in substeps:
	# 		sub_step_name = e.get_step_name(step)
	# 		child_elem = e.get_child_elements_by_tag_name(step, 'tr:TestResult')
	# 		subs = [step]
	# 		limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
	# 		# if limits[0]['hi'] == '30,0':
	# 		if sub_step_name == 'Check Current':
	# 			dump = Step_name.append(e.get_step_name(step))
	# 			dump = Check_power.append(limits[0]['result'])
	# 			dump = status_substep.append(h.translate_en_to_ru(e.get_step_status(step)))
	# 			dump = Low_limits.append(limits[0]['lo'])
	# 			dump = High_limits.append(limits[0]['hi'])
	# 		# if limits[0]['hi'] == '10,0' and limits[0]['lo'] == '1,5':
	# 		if sub_step_name == 'Check Pulse Duration':
	# 			dump = time_react.append(limits[0]['result'])
	# 			dump = status_react.append(h.translate_en_to_ru(e.get_step_status(step)))
	# 			dump = time_react_lim_hi.append(limits[0]['hi'])
	# 			dump = time_react_lim_lo.append(limits[0]['lo'])

	# 	Check_power = h.power_for_kits(Check_power, key=1)
	# 	Check_power = [Check_power[0][-6:], Check_power[1][-6:]]
	# 	time_react = h.power_for_kits(time_react, key=1)
	# 	time_react = [time_react[0][-6:], time_react[1][-6:]]
	# 	status_substep = h.power_for_kits(status_substep, key=1)
	# 	status_substep = [status_substep[0][-6:], status_substep[1][-6:]]
	# 	status_react = h.power_for_kits(status_react, key=1)
	# 	status_react = [status_react[0][-6:], status_react[1][-6:]]
	# 	# time_react = h.power_for_kits(time_react, maximum = 1)
	# 	# status_react = h.power_for_kits(status_react)
	# 	# status_react_main = h.status_of_substeps(status_react[0])
	# 	# status_react_res = h.status_of_substeps(status_react[1])
  
	# 	# status_substep = h.power_for_kits(status_substep)
	# 	# status_substep_main = h.status_of_substeps(status_substep[0])
	# 	# status_substep_res = h.status_of_substeps(status_substep[1])
	# 	# Check_power_kits = h.power_for_kits(Check_power, maximum = 1)

	# 	print()
	"""
	11
	"""
	# if number == '11':
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	current_step_name = h.split_name(step_name)
	# 	Low_limits = []
	# 	for step in substeps:
	# 		sub_step_name = e.get_step_name(step)
	# 		child_elem = e.get_child_elements_by_tag_name(step, 'tr:TestResult')
	# 		subs = [step]
	# 		limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
	# 		dump = Name_of_sub_step.append(e.get_step_name(child_elem[-1]))
	# 		dump = Step_name.append(e.get_step_name(step))
	# 		dump = Check_power.append(limits[0]['result'])
	# 		dump = Status_substep.append(h.translate_en_to_ru(e.get_step_status(step)))
	# 		dump = Low_limits.append(limits[0]['lo'])
	# 		# dump = High_limits.append(limits[0], 'hi')
	# 		dump = Units_limits.append(limits[0]['units'])
	# 		maximum = max(Check_power)
	# 	test = h.power_for_kits(Status_substep)
	# 	Status_substep2 =  h.status_of_substeps(Status_substep)
	# 	Status_substep =  h.status_of_substeps(Status_substep, key=0)
	# 	Status_substep = h.power_for_kits(Status_substep)
	# 	print()


	"""
	8
	"""
	# Общее потребление БИОС
	summary_power_bios = []
	summary_power_limits_lo_bios = []
	summary_power_limits_hi_bios = []
	summary_power_status_bios = []
	
	# Потребление БИОС при макс. нагрузке
	check_summary_power_bios = []
	check_summary_high_limit_bios = []
	check_summary_low_limit_bios = []
	check_summary_status_bios = []
 
	# Точность измерения тока при равномерной нагрузке
	limits_check_evenly = []
	step_name_evenly = []
	check_power_evenly = []
	status_substep_evenly = []
	low_limits_evenly = []
	hi_limits_evenly = []
	fall_channel_evenly = []
 
	# Точность измерения тока при максимальной нагрузке
	check_power_max = []
	status_substep_max = []
	fall_channel_max = []

	names_of_limits = ['Check Summary Power', 'Check LoadLine Current with TM Values', 'Check LoadLine Current With DWNT TM Values','DMM Measure']
	# Списки для заполнения таблиц
	kits = ['Основной комплект', 'Резервный комплект']
	names_of_headers = ['Общее потребление БИОС', 'Потребление БИОС при максимальной нагрузке на каналы', 'Точность измерения тока на шинах питания при максимальной нагрузке на шине', 'Точность измерения тока на шинах питания при равномерно распределенной по каналам допустимой нагрузке']
	names_of_headers2 = ['Максимальный процент по всем линиям при проверке 15,5 А на все линии', 'Максимальный процент по всем линиям при проверке 4 А на 4 линии', 'Максимальный процент по всем линиям при проверке 4 А на 4 линии']
	range_of_channels = ['К1-4', 'К5-8', 'К9-12', 'К13-16', 'К17-20', 'К21-24', 'К25-26']
	channel = ['K']

	if number == '8':
		substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
		# Подшаги для максимального процента
		substeps2 = e.get_substeps(step, 'AdditionalResults', 'Main')
		# Подшаги для Eval Procent Switched Channel Точность измерения тока при максимальной нагрузке
		# substeps3 = e.get_substeps(step, 'Statement', 'Main')
		# for i in substeps3:
		# 	test2.append(e.get_step_name(i))

		current_step_name = h.split_name(step_name)
		for step in substeps:
			sub_step_name = e.get_step_name(step)
			dump = test.append(sub_step_name)
			# child_elem = e.get_child_elements_by_tag_name(step, 'tr:TestResult')
			subs = [step]

			# Общее потребление БИОС
			if sub_step_name == names_of_limits[0] and e.get_value_of_attribute_by_parent_node_and_internal_path(step, 'tr:Extension/ts:TSStepProperties/ts:BlockLevel', 'value') == '1':
				limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
				dump = summary_power_bios.append(limits[0]['result'])
				dump = summary_power_limits_lo_bios.append(limits[0]['lo'])
				dump = summary_power_limits_hi_bios.append(limits[0]['hi'])
				dump = summary_power_status_bios.append(e.get_step_status(step))
	
			# Потребление БИОС при макс. нагрузке
			if sub_step_name == names_of_limits[0] and e.get_value_of_attribute_by_parent_node_and_internal_path(step, 'tr:Extension/ts:TSStepProperties/ts:BlockLevel', 'value') == '2':
				limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
				dump = check_summary_power_bios.append(limits[0]['result'])
				dump = check_summary_high_limit_bios.append(limits[0]['hi'])
				dump = check_summary_low_limit_bios.append(limits[0]['lo'])
				dump = check_summary_status_bios.append(e.get_step_status(step))

			# Точность измерения тока при равномерной нагрузке
			if sub_step_name == names_of_limits[1] and e.get_value_of_attribute_by_parent_node_and_internal_path(step, 'tr:Extension/ts:TSStepProperties/ts:BlockLevel', 'value') == '2':
				limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
				dump = check_power_evenly.append(limits[0]['result'])
				dump = status_substep_evenly.append(e.get_step_status(step))
				dump = low_limits_evenly.append(limits[0]['lo'])
				dump = hi_limits_evenly.append(limits[0]['hi'])

			# Падения на каналах для точности измерения тока при равномерной нагрузке
			if sub_step_name == names_of_limits[3] and e.get_value_of_attribute_by_parent_node_and_internal_path(step, 'tr:Extension/ts:TSStepProperties/ts:BlockLevel', 'value') == '2':
				test_result_evenly = e.get_child_elements_by_tag_name(step, 'tr:TestResult')
				dump = fall_channel_evenly.append(e.get_prop_of_numeric_limit_without_name(step, test_result_evenly[1]))

			# Точность измерения тока при максимальной нагрузке
			if sub_step_name == names_of_limits[2] and e.get_value_of_attribute_by_parent_node_and_internal_path(step, 'tr:Extension/ts:TSStepProperties/ts:BlockLevel', 'value') == '3':
				limits = e.get_numeric_limits(subs, (e.get_step_name(step)))
				dump = check_power_max.append(limits[0]['result'])
				dump = status_substep_max.append(e.get_step_status(step))
			# Падения на каналах для точности измерения тока при максимальной нагрузке
			if sub_step_name == names_of_limits[3] and e.get_value_of_attribute_by_parent_node_and_internal_path(step, 'tr:Extension/ts:TSStepProperties/ts:BlockLevel', 'value') == '3':
				test_result_max = e.get_child_elements_by_tag_name(step, 'tr:TestResult')
				dump = fall_channel_max.append(e.get_prop_of_numeric_limit_without_name(step, test_result_max[1]))

		# Значения максимального процента по всем линиям
		max_proc_result= e.get_prop(substeps2, 'Output Max Procent', 'c:Value', key = 1)

		# Телеметрия при равномерной нагрузке
		telemetry_evenly = h.telemetry(check_power_evenly, fall_channel_evenly)
		# Телеметрия при максимальной нагрузке
		telemetry_max = h.telemetry(check_power_max, fall_channel_max)
  
		# Перевод проверок
		summary_power_status_bios = h.status_of_substeps(summary_power_status_bios, key=0)
		check_summary_status_bios = h.status_of_substeps(check_summary_status_bios, key=0)
		status_substep_evenly = h.status_of_substeps(status_substep_evenly, key=0)
		status_substep_max = h.status_of_substeps(status_substep_max, key=0)
  
		# Разбитие результатов проверок
		summary_power_bios = h.power_for_kits(summary_power_bios, key=1)
		check_summary_power_bios = h.power_for_kits(check_summary_power_bios, key=1)
		check_power_evenly = h.power_for_kits(check_power_evenly, key=1)
		check_power_max = h.power_for_kits(check_power_max, key=1)
		fall_channel_evenly = h.power_for_kits(fall_channel_evenly, key=1)
		fall_channel_max = h.power_for_kits(fall_channel_max, key=1)
		telemetry_evenly = h.power_for_kits(telemetry_evenly, key=1)
		telemetry_max = h.power_for_kits(telemetry_max, key=1)

		# Разбитие статусов проверок
		check_summary_status_bios = h.power_for_kits(check_summary_status_bios, key=1)
		status_substep_evenly = h.power_for_kits(status_substep_evenly, key=1)
		status_substep_max = h.power_for_kits(status_substep_max, key=1)

		print()
	'''
	graphs
	'''
# 	findSesAct = e.get_elements('tr:SessionAction', parent_node=step)
# 	dump = e.get_element_by_name(list_of_elements=findSesAct, necessary_name='Get Waveform Parameters', isNeedOneElement=False, isUsingPath=False)
# 	GetWaveForm.append(dump)
	
# # dump = e.get_elements('tr:Data/c:Collection/c:Item', parent_node=GetWaveForm[11][0])
# # dump = e.get_elements('c:Collection/c:Item', parent_node=dump[1])
# # dump = e.get_elements('c:IndexedArray/ts:Element', parent_node=dump[2])
# # for i in range(len(dump)):
# #     u = '{:.4f}'.format(float(e.get_first_attribute(dump[i], 'value')))
# #     WaveFormElem.append((i, float(u)))

# # dummy = dict(function='', color = 'blue', mark='.', coordinates = WaveFormElem)
# # wtr = h.add_plots([dummy], '', 'Время, мкс', 'Напряжение, В', 'major', '7cm', '15cm', '0', '0', '0', '100', power_of_x_axis=1000000, min_xlabel=0, interval_of_xlabel=10)
# print()

# # Работа с функцией, позволяющей компилировать tex
# test = e.get_session_action(steps)
# test2 = e.get_waveform_params(test[11][0])
# dummey = dict(function='', color = 'blue', mark='.', coordinates = test2)
# test3 = e.get_waveform_params(test[11][1])
# dummy = dict(function='', color = 'blue', mark='.', coordinates = test3)
# wtty = h.add_plots([dummey, dummy], '', 'Время, мкс', 'Напряжение, В', 'major', '7cm', '15cm', '0', '0', '0', '200', power_of_x_axis=1000, min_xlabel=0, interval_of_xlabel=10)
# print()
	'''
	1
	'''
	# if number == '1':
	# 	Status = h.translate_en_to_ru(e.get_step_status(step))
	# 	print()
	'''
	2
	'''
	# if number == '2':
	# 	temp_status = []
	# 	substeps = e.get_substeps(step, 'AdditionalResults', 'Main')
	# 	current_step_name = h.split_name(step_name)
	# 	# for step in substeps:
	# 	substep_status = e.get_element_by_name(necessary_name='Write Source Voltage', list_of_elements=substeps, isNeedOneElement=False, isUsingPath=False)
	# 	# for i in range(len(WriteSourVolt)):
	# 	WrSrcVlt = e.get_prop(substeps, 'Write Source Voltage', "Напряжение")
	# 	for step in substep_status:
	# 		temp_status.append(e.get_step_status(step))
	# 	status_substep = h.status_of_substeps(temp_status, key=0)
	# print()
	'''
	9
	'''
	# if number == '9':
	# 	temp_status = []
	# 	substeps = e.get_elements('tr:TestGroup/tr:SessionAction', step)
	# 	time = e.get_prop(substeps, 'Ready Time Logging', 'Время готовности БИОС')
	# 	temp_status = e.get_step_status(step)
	# 	status_substep = h.status_of_substeps([temp_status], key=0)
	# 	print()
	'''
	14
	'''
	# if number == '14':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	chain1 = e.get_numeric_limit(substeps[0])
	# 	chain2 = e.get_numeric_limit(substeps[1])
	# 	for step in substeps[2:]:
	# 		results.append(e.get_numeric_limit(step))
	# 		temp_status = e.get_step_status(step)
	# 		status_substep.append(temp_status)
	# 	status_substep = h.status_of_substeps(status_substep, key = 0)
	# 	test = chain1['result']
	# 	results = h.power_for_kits(results, key=1)
	# 	status_substep = h.power_for_kits(status_substep)
	# 	for step in range(len(results[0])):
	# 		test = results[0][step]['result']
	# 	print()
	'''
	15
	'''
	# if number == '15':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		results.append(e.get_numeric_limit(step))
	# 		temp_status = e.get_step_status(step)
	# 		status_substep.append(temp_status)
	# 	status_substep = h.status_of_substeps(status_substep, key = 0)
	# 	print(results[0]['result'])
	# 	print(results[0]['lo'])
	# 	print(results[0]['hi'])

	# 	print()
	'''
	17
	'''
	# if number == '17':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		results.append(e.get_numeric_limit(step))
	# 		temp_status = e.get_step_status(step)
	# 		status_substep.append(temp_status)
	# 	status_substep = h.status_of_substeps(status_substep, key = 0)
	# 	results = h.power_for_kits(results, key = 1)
	# 	status_substep = h.power_for_kits(status_substep, key=1)
	# 	print(results[0][0]['result'])
	# 	print(results[0][0]['lo'])
	# 	print(results[0][0]['hi'])

	# 	print()
	'''
	18
	'''
	# if number == '18':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		results.append(e.get_numeric_limit(step))
	# 		temp_status = e.get_step_status(step)
	# 		status_substep.append(temp_status)
	# 	status_substep = h.status_of_substeps(status_substep, key = 0)
	# 	results = h.power_for_kits(results, key = 1)
	# 	status_substep = h.power_for_kits(status_substep, key=1)
	# 	amplitude = h.status_of_substeps(status_substep[0], key = 1)
	# 	duration = h.status_of_substeps(status_substep[0], key = 1)
	# 	print(results[0][0]['result'])
	# 	print(results[0][0]['lo'])
	# 	print(results[0][0]['hi'])
	# 	print()
	'''
	19
	'''
	# if number == '19':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		results.append(e.get_numeric_limit(step))
	# 		temp_status = e.get_step_status(step)
	# 		status_substep.append(temp_status)
	# 	status_substep = h.status_of_substeps(status_substep, key = 0)
	# 	results = h.power_for_kits(results, key = 1)
	# 	status_substep = h.power_for_kits(status_substep, key=1)
	# 	print(results[0][0]['result'])
	# 	print(results[0][0]['lo'])
	# 	print(results[0][0]['hi'])
	# 	print()
 
	'''
	20
	'''
	# if number == '20':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		results.append(e.get_numeric_limit(step))
	# 		temp_status = e.get_step_status(step)
	# 		status_substep.append(temp_status)
	# 	status_substep = h.status_of_substeps(status_substep, key = 0)
	# 	results = h.power_for_kits(results, key = 1)
	# 	status_substep = h.power_for_kits(status_substep, key=1)
	# 	print(results[0][0]['result'])
	# 	print(results[0][0]['lo'])
	# 	print(results[0][0]['hi'])
	# 	print()
	'''
	3
	'''
	# if number == '3':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		results.append(e.get_numeric_limit(step))
	# 		status_substep.append(h.translate_en_to_ru(e.get_step_status(step)))
	# 	print()
	'''
	5
	'''
	# if number == '5':
	# 	results = []
	# 	status_substep = []
	# 	# child_elem = e.get_child_elements_by_tag_name(step, 'tr:SessionAction')
	# 	# for step in child_elem:
	# 	# 	test = e.get_first_attribute(step, 'name')
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		test = e.get_first_attribute(step, 'name')
	# 		if test == 'Check Pulse Duration':
	# 			results.append(e.get_numeric_limit(step, key=1))
	# 			status_substep.append(h.translate_en_to_ru(e.get_step_status(step)))
	# 	print()
	'''
	23
	'''
	# if number == '23':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		results.append(e.get_numeric_limit(step))
	# 		temp_status = e.get_step_status(step)
	# 		status_substep.append(temp_status)
	# 	status_substep = h.status_of_substeps(status_substep, key = 0)

	# 	results = h.power_for_kits(results, key = 1)
	# 	status_substep = h.power_for_kits(status_substep, key=1)
	# print()
	'''
	24
	'''
	# if number == '24':
	# 	results = []
	# 	status_substep = []
	# 	substeps = e.get_substeps(step, 'NumericLimitTest', 'Main')
	# 	for step in substeps:
	# 		results.append(e.get_numeric_limit(step, prec=2))
	# 		temp_status = e.get_step_status(step)
	# 		status_substep.append(temp_status)
	# 	status_substep = h.status_of_substeps(status_substep, key = 0)

	# 	results = h.power_for_kits(results, key = 1)
	# 	status_substep = h.power_for_kits(status_substep, key=1)
	# print()
	"""
	test2 = [step for step in Status_substep if step != 'Успешно']
	
	Тоже самое, что и:

	for step in Status_substep:
		if step != 'Успешно':
			dump = test.append(step)
		# if len(test) > 0:
		# 	Status_substep = test
		# 	Status_substep = h.check_status_count(Status_substep)
		# else:
		# 	Status_substep = Status_substep[0]
		# print(Status_substep)
	"""
		# Status_substep = ['Failed', 'Passed']
		# Status_substep2 = h.status_of_substeps(Status_substep, key=1)
		# print()
'''
headers
'''
# headers_of = []
# number_of_rows = 0 
# one_header=''
# count_of_share_rows = 0
# global_counter = 0
# e.set_node(list_of_reports[0])
# number_of_test = e.get_uut_serial_number()
# device = 'КПА'
# h.exist_result(h.clean_date(e.get_start_time()))
# list_of_headers = {'head1': '%device %serialNumber', 'head2': 'ПСИ. Проверка работоспособности', 'head3': 'Нормальные условия', 'date': '%date', 'gk' : '%gk'}
# gk = 'Main-20GK'
# one_header = ' '
# list_of_gk = ['20GK']
# words = list_of_headers['head1'].split()
# for word in words:
# 	if word == '%serialNumber':
# 		if number_of_test != '':
# 			one_header = one_header + '№' + number_of_test
# 		else:
# 			one_header = one_header + '№' + '---'
# 	elif word == '%device':
# 		one_header = one_header + device
# 	elif word == '%date':
# 		if date != '':
# 			one_header = one_header + date|string
# 		else:
# 			one_header = one_header + '---'
# 	else:
# 		one_header = one_header + word
  
# headers_of.append(one_header)
# one_header=''
# words = list_of_headers['head2'].split()
# for word in words:
# 	if word == '%serialNumber':
# 		if number_of_test != '':
# 			one_header = one_header + '№' + number_of_test
# 		else:
# 			one_header = one_header + '№' + '---'
# 	elif word == '%device':
# 		one_header = one_header + device
# 	elif word == '%date':
# 		if date != '':
# 			one_header = one_header + date|string
# 		else:
# 			one_header = one_header + '---'
# 	else:
# 		one_header = one_header + word
  
# headers_of.append(one_header)
# one_header=''
# words = list_of_headers['head3'].split()
# for word in words:
# 	if word == '%serialNumber':
# 		if number_of_test != '':
# 			one_header = one_header + '№' + number_of_test
# 		else:
# 			one_header = one_header + '№' + '---'
# 	elif word == '%device':
# 		one_header = one_header + device
# 	elif word == '%date':
# 		if date != '':
# 			one_header = one_header + date|string
# 		else:
# 			one_header = one_header + '---'
# 	else:
# 		one_header = one_header + word
  
# headers_of.append(one_header)
# one_header=''
# words = list_of_headers['date'].split()
# for word in words:
# 	if word == '%serialNumber':
# 		if number_of_test != '':
# 			one_header = one_header + '№' + number_of_test
# 		else:
# 			one_header = one_header + '№' + '---'
# 	elif word == '%device':
# 		one_header = one_header + device
# 	elif word == '%date':
# 		if date != '':
# 			one_header = one_header + str(date)
# 		else:
# 			one_header = one_header + '---'
# 	else:
# 		one_header = one_header + word

# one_header=''
# words = list_of_headers['gk'].split()
# for word in words:
# 	if word == '%serialNumber':
# 		if number_of_test != '':
# 			one_header = one_header + '№' + number_of_test
# 		else:
# 			one_header = one_header + '№' + '---'
# 	elif word == '%device':
# 		one_header = one_header + device
# 	elif word == '%gk':
# 		one_header = one_header + list_of_gk[0]
# 	elif word == '%date':
# 		if date != '':
# 			one_header = one_header + str(date)
# 		else:
# 			one_header = one_header + '---'
# 	elif word == '%gk':
# 		one_header = one_header + gk
# 	else:
# 		one_header = one_header + word

# print()