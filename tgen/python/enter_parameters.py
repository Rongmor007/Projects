import os
# import sys
import re as r
import codecs
from tkinter import Tk, filedialog

root_window = Tk()		# создание главного окна
root_window.withdraw()	# сокрытие главного окна
list_of_parameters_out = []
list_of_parameters_in = []
isCancel = False
s = 'y'
count_reports = 0
temp = r'C:/avs/tgen/python/temp'
init_dir = r'C:/avs/tgen/in'
reg = r'/\b\w{2}\b/'

if not os.path.exists(init_dir):
	os.mkdir('C:/avs/tgen/in')
if not os.path.exists(temp):
	os.mkdir('C:/avs/tgen/python/temp')
while s == 'y':
	print('Выберите файл отчёта TestStand.\n')
	dlg = filedialog.Open(parent = root_window, title = 'Выберите файл отчёта TestStand', initialdir = init_dir, defaultextension = '*.xml', filetypes = [('Файлы отчётов', '*.xml')], multiple = True)
	file_name = dlg.show()	# показ диалогового окна
	if file_name != '':
		for line in file_name:
			print('Выбран файл: ' + line)
			list_of_parameters_in.append(line + '\n')
			lt = r.findall(reg, line)
			line = line.replace(lt[0], '/out/')
			list_of_parameters_out.append(line + '\n')
		
		# h = input('Введите тип нужного заголовка для отчёта (для пропуска данного шага нажмите ENTER): ')
		# if h == '':
		#     print('Тип заголовка будет определяться по конфигурационному файлу.')
		# else:
		#     print('Введённый тип заголовка: ' + h)
		#     list_of_parameters_out.append(h + '\n')
		# s = input('Вы хотите создать ещё один отчёт? Введите "y", если да.
		# Если нет, можно ввести любые другие символы или сразу нажать ENTER: ')
		# file_name = ''
		# count_reports += 1
		
		s = ''
	else:
		mes = 'Файл отчёта TestStand не был выбран.'
		if len(list_of_parameters_out) > 0:
			print(mes + ' Будут сгенерированы отчёты только по ранее выбранным файлам.')
		else:
			print(mes + ' Отмена генерации отчётов...\n')
			isCancel = True
		s = 'n'

input_file = codecs.open('C:/avs/tgen/python/temp/parameters_in.txt',  'w', 'utf-8')
output_file = codecs.open('C:/avs/tgen/python/temp/parameters_out.txt',  'w', 'utf-8')

if isCancel:
	output_file.write('')
	input_file.write('')
else:
	# запись всего списка в файл с русскими символами
	input_file.writelines(list_of_parameters_in)
	output_file.writelines(list_of_parameters_out)
	
input_file.close()
output_file.close()

if len(list_of_parameters_out) > 0:
	print('Параметры успешно введены. Пожалуйста, подождите... Отчёт формируется.\n')
