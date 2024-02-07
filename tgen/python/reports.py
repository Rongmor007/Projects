import os
import sys
import codecs

file1 = open('C:/avs/tgen/python/temp/parameters_in.txt')
file2 = open('C:/avs/tgen/python/temp/parameters_out.txt')
while True:
	counter1 = codecs.open('C:/avs/tgen/python/temp/param_in.txt', 'w', 'utf-8')
	counter2 = codecs.open('C:/avs/tgen/python/temp/param_out.txt', 'w', 'utf-8')
	line1 = file1.readline()
	line2 = file2.readline()
	if (line1 or line2) == '':
		break
	counter1.write(line1)
	counter2.write(line2)
	counter1.close()
	counter2.close()
	if os.stat(line1[:-1]).st_size < 1:
		print(f'Файл {line1[:-1]} пустой\n')
	else:
		print(f'\nPrepare to compile file {line1}\n')
		os.system('C:/avs/tgen/python/BuildTemplateDWNTMulti.bat')
	
# Закрытие файлов
counter1.close()
counter2.close()
file1.close()
file2.close()

os.system('C:/avs/tgen/python/delete_.txt.bat')

i = input("\nPress 'Enter' to close console:\t")
sys.exit()