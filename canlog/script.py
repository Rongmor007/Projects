import os
import sys
import math
import datetime as dt
import re as r
import pandas as pd
import xlsxwriter
from tkinter import filedialog as fd

def findDown (package, sndAdrHex, runDownDic, dicDwn):
	rg = r'\b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2}'
	lt = r.findall(rg, package)
	d = list(lt[0])
	dict = {sndAdrHex : d}
	rs = r'\[\d+:\d{2}:\d{2},\d{3}\]'
	ls = r.findall(rs, package)
	dr = ls[0][1:len(ls[0])-1]
	dat = {sndAdrHex : dr}
	if dict[sndAdrHex][1] == '5' and dict[sndAdrHex][1] != runDownDic[sndAdrHex][1]:
		dicDwn = ({'sndAdr': sndAdrHex, 'bool': True } )
		# print(lt, sndAdrHex, runDownDic[sndAdrHex], sep='\n')
		# print()

	
	runDownDic.update({sndAdrHex : d})

	return dicDwn, runDownDic, dat


def processID(id):
	id = id.removeprefix('0x')
	intID = int.from_bytes(bytes.fromhex(id), byteorder='big', signed=False)

	isArr = (intID >> 28) & 0x0001
	snd = (intID >> 22) & 0x003F
	rcv = (intID >> 16) & 0x003F
	attr = (intID >> 8) & 0x00FF

	if isArr:
		arrSgn = (attr >> 4) & 0x00F
		arrCnt = attr & 0x000F
		cOp = intID & 0x00FF
	else:
		arrSgn = 0
		arrCnt = 0
		cOp = intID & 0x0FFF

	return { 
		'isArr':	isArr,		# is command (0) or array (1) packet type
		'sndAdr':	snd,		# sender CAN Node
		'rcvAdr':	rcv,		# Receiver CAN Node
		'attr':		attr,		# attribute code
		'arrSgn':	arrSgn,	# Sign of attribute
		'arrCnt':	arrCnt,	# array counter
		'codeOp':	cOp		# code of Operation
	}


def extractData(prm):
	# regexp = r'\s\b[0-9A-F]{2}\b'
	rg = r'\[\d+:\d{2}:\d{2},\d{3}\]'
	lt = r.findall(rg, prm)
	time = str((lt[0]).strip('[]'))
	# time = time[:len(time)-4]

	rg = r'\b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2}'
	lt = r.findall(rg, prm)
	als = lt[0]
	if len(als) < 7:
		return None

	s = als[0 : 11 ]
	b = bytes.fromhex( s )
	curSpeed = int.from_bytes(b, byteorder='little', signed=True)

	s = als[12 : 17 ]
	b = bytes.fromhex( s )
	mUpr = int.from_bytes(b, byteorder='little', signed=True)
	mUpr = '{:.4f}'.format((mUpr * 3.04 * math.pi * 5) / 960)
	mUpr = float(mUpr)

	s = als[len(als)-5 : len(als)]
	b = bytes.fromhex( s )
	counter = int.from_bytes(b, byteorder='little', signed=False)
	
	# return time, curSpeed, mUpr, counter
	return { 
		'time': time, 
		'curSpeed': curSpeed, 
		'mUpr': mUpr, 
		'counter': counter
		}


def evalMreal(pSpeed, pCounter, p):
	intSpd = p['curSpeed']
	intCnt = p['counter']

	difCnt = intCnt - pCounter

	mReal = float(intSpd - pSpeed)
	mReal = (mReal * (5.0 * math.pi * 0.304) )/ 4096.0

	if difCnt > 0:
		mReal = mReal / float(difCnt)

	# 75/(2^14) об/мин
	speed = (float(intSpd) * 75.0) / float(2 ** 14)
	prevSpd = (float(pSpeed) * 75.0) / float(2 ** 14)

	# if (speed - prevSpd > 0 and speed > 6500):
	if prevSpd > 6500:
		prevCur = True
	else:
		prevCur = False

	# if (speed - prevSpd < 0 and speed < -6500):
	if prevSpd < -6500:
		timeDownEnd = True
	else:
		timeDownEnd = False

	return { 
		'speed': speed, 
		'mReal': mReal , 
		'prevCur': prevCur, 
		'timedownEnd' : timeDownEnd
		}


def tmpr(line, sndAdrHex):
	rg = r'\b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2} \b[0-9A-F]{2}'
	lt = r.findall(rg, line)
	als = lt[0]
	rg = r'\[\d+:\d{2}:\d{2},\d{3}\]'
	lg = r.findall(rg, line)
	time = str(lg[0].strip('[]'))
	# time = time[:-4]

	s = als[ 12 : 14 ]
	b = bytes.fromhex( s )
	coreTemp = int.from_bytes(b, byteorder='little', signed=True)

	s = als[ 15 : 17 ]
	b = bytes.fromhex( s )
	motorTemp = int.from_bytes(b, byteorder='little', signed=True)

	coreTemp = float('{:.1f}'.format((coreTemp * (-0.88)) + 147.5)) # .replace('.', ',')
	motorTemp = float('{:.1f}'.format((motorTemp * 1) + 0)) # .replace('.', ',')

	return {
		'time' : time, 
		'coreTemp' : coreTemp, 
		'motorTemp' : motorTemp, 
		'sndAdrHex' : sndAdrHex
		}


def writeTemp(temperature, fileDescXlsxWorkSheetTemp, sndAddrsTemp, dictCounterRowTemp):
	column = 0
	if dictCounterRowTemp[sndAddrsTemp.index(temperature['sndAdrHex'])] == 0:
		fileDescXlsxWorkSheetTemp[sndAddrsTemp.index(temperature['sndAdrHex'])].write(0, 0, 'Время')
		fileDescXlsxWorkSheetTemp[sndAddrsTemp.index(temperature['sndAdrHex'])].write(0, 1, "Температура микроконтроллера C'")
		fileDescXlsxWorkSheetTemp[sndAddrsTemp.index(temperature['sndAdrHex'])].write(0, 2, "Температура корпуса электродвигателя C'")
		dictCounterRowTemp[sndAddrsTemp.index(temperature['sndAdrHex'])] += 1

	fileDescXlsxWorkSheetTemp[sndAddrsTemp.index(temperature['sndAdrHex'])].write(dictCounterRowTemp[sndAddrsTemp.index(temperature['sndAdrHex'])], column, temperature['time'])
	fileDescXlsxWorkSheetTemp[sndAddrsTemp.index(temperature['sndAdrHex'])].write(dictCounterRowTemp[sndAddrsTemp.index(temperature['sndAdrHex'])], column + 1, temperature['coreTemp'])
	fileDescXlsxWorkSheetTemp[sndAddrsTemp.index(temperature['sndAdrHex'])].write(dictCounterRowTemp[sndAddrsTemp.index(temperature['sndAdrHex'])], column + 2, temperature['motorTemp'])
	dictCounterRowTemp[sndAddrsTemp.index(temperature['sndAdrHex'])] += 1

	return {
		'dictCounterRowTemp' : dictCounterRowTemp, 
		'fileDescXlsxWorkSheetTemp' : fileDescXlsxWorkSheetTemp
		}


def writeToXlsx(we, row, p, s):
	column = 0

	we.write(row, column,		p['time'])
	we.write(row, column + 1,	p['counter'])
	we.write(row, column + 2,	s['speed'])
	we.write(row, column + 3,	s['mReal'])
	we.write(row, column + 4,	p['mUpr'])
	
	return None


init_dir = r'C:/avs/canlog/in'
files = fd.askopenfilenames(initialdir=init_dir)
for current in files:
	file = os.path.abspath(current)
	inPath = os.getcwd()
	name = os.path.basename(current)
	searchCmd = 'C7'
	inFilename = '\\in\\' + name
	outFilename = '\\out\\' + name
	# try:
	# 	searchCmd = sys.argv[2]			# sys.argv[ 2 ]
	# except:
	# 	searchCmd = 'C7'
	
	# if len(searchCmd) == 0:
	# 	searchCmd = 'C7'
	# 	iSrchCmd = 0xC7
	# else:
	# 	iSrchCmd = int.from_bytes(bytes.fromhex(searchCmd), byteorder='little', signed=False)

	outFilename = outFilename[:outFilename.rfind('.log')] + '_' + searchCmd + outFilename[outFilename.rfind('.log'):]

	#xlsx-file
	outPathXlsx = inPath
	filePathsXlsx = []
	outFilenameXlsx = outFilename[:len(outFilename)-4] + '.xlsx'
	outPathXlsx += outFilenameXlsx
	fileDescXlsxWorkBook = []
	
	# C7
	fileDescXlsxWorkSheetС7 = []
	dictCounterRowC7 = []

	# temperature
	fileDescXlsxWorkSheetTemp = []
	dictCounterRowTemp = []
	sndAddrsTemp = []

	# rundown
	fileDescXlsxWorkSheet = []
	dictCounterRow = []
	startStopDelt = []
	spd = {'prevCur': False, 'timedownEnd' : False, 'speed' : 0}
	runDownDic = {'24': [0, 0], '25' : [0, 0]}
	runDown = {}
	triggerMax = {'24': False, '25' : False}
	triggerMin = {'24': False, '25' : False}
	dicDwn = {}

	# position
	sndAddrs = []

	# meters
	pSpeed = []			#int =0
	pCounter = []		#int =0

	# statistic file
	statOutFileC7 = []
	statLineMetter = 0

	inPath += inFilename

	print('\nin filename\t\t\t: {!s}'.format(inPath))
	print('search command: 0x{!s}'.format(searchCmd))
	print('please wait...\n')
	
	inFile = open(file, 'r')

	rSrchID = '\\b0x[0-9a-fA-F]{8}'

	rSrchC7 = '\\b0x[0-9a-fA-F]{6}C7'

	wb = xlsxwriter.Workbook(outPathXlsx[:-7] + '_' + 'Down' +  '.xlsx')
	fileDescXlsxWorkBook.append(wb)
	wb1 = xlsxwriter.Workbook(outPathXlsx[:-7] + '_' + searchCmd +  '.xlsx')
	fileDescXlsxWorkBook.append(wb1)
	wb2 = xlsxwriter.Workbook(outPathXlsx[:-7] + '_' + 'temperature' +  '.xlsx')
	fileDescXlsxWorkBook.append(wb2)
	for line in inFile:
		statLineMetter += 1
		sID = r.findall(rSrchID, line)
		dID = processID(sID[0])
		sndAdrHex = '{:x}'.format(dID['sndAdr'])

		# Выбег при скорости от 6500 до 0 и меньше
		if spd['speed'] <= 0 and triggerMax[sndAdrHex] == True:   # spd['timedownEnd'] == True
			startStopDelt.append(runDown[sndAdrHex])
			startStopDelt.append(prm['time'])

			te = dt.datetime.strptime(startStopDelt[0], '%H:%M:%S,%f')

			ta = dt.datetime.strptime(startStopDelt[1], '%H:%M:%S,%f')

			tt = ta - te

			startStopDelt.append(str(tt).format('%H:%M:%S,%f'))

			# write .xlsx
			column = 0
			fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column, startStopDelt[0])
			fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column + 1, startStopDelt[1])
			fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column + 2, startStopDelt[2])

			dictCounterRow[sndAddrs.index(sndAdrHex)] += 1

			startStopDelt = []	
			triggerMax.update({sndAdrHex : False})

		# Выбег при скорости от -6500 до 0 и больше
		if spd['speed'] >= 0 and triggerMin[sndAdrHex] == True:   # spd['timedownEnd'] == True
			startStopDelt.append(runDown[sndAdrHex])
			startStopDelt.append(prm['time'])

			te = dt.datetime.strptime(startStopDelt[0], '%H:%M:%S,%f')

			ta = dt.datetime.strptime(startStopDelt[1], '%H:%M:%S,%f')

			tt = ta - te

			startStopDelt.append(str(tt).format('%H:%M:%S,%f'))

			# write .xlsx
			column = 0
			fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column, startStopDelt[0])
			fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column + 1, startStopDelt[1])
			fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column + 2, startStopDelt[2])

			dictCounterRow[sndAddrs.index(sndAdrHex)] += 1

			startStopDelt = []	
			triggerMin.update({sndAdrHex : False})

		# Расчет времени начала выбега
		if dID['codeOp'] == 0xFC and dID['arrCnt']==3 and dID['arrSgn']==4:

			downFrom = findDown(line, sndAdrHex, runDownDic, dicDwn)
			# Скорость > 6500
			if len(downFrom[0]) > 0 and spd['prevCur'] == True:
				runDown.update(downFrom[2])
				triggerMax.update({downFrom[0]['sndAdr'] : True})
			# Скорость < -6500
			if len(downFrom[0]) > 0 and spd['timedownEnd'] == True:
				runDown.update(downFrom[2])
				triggerMin.update({downFrom[0]['sndAdr'] : True})
    
		# Телеметрия C7
		if dID['codeOp'] == 0xC7:
			lsc = r.findall(rSrchC7, line)
			data = lsc[0]
			d = int(data[2:6], 16)
			rcvAdr = d & 0x003F
			if rcvAdr == 7:
				if sndAddrs.count(sndAdrHex) == 0:
					pSpeed.append(0)
					pCounter.append(0)
					
					sndAddrs.append(sndAdrHex)

					# xlsx-file
					filePath = outPathXlsx
					filePath = filePath[:filePath.rfind('.xlsx')] + '_' + sndAdrHex + filePath[filePath.rfind('.xlsx'):]
					filePathsXlsx.append(filePath)
     
					# С7
					we = wb1.add_worksheet('0x{!s}'.format(sndAdrHex))
					fileDescXlsxWorkSheetС7.append(we)
					dictCounterRowC7.append(0)
     
					# Выбег
					ws = wb.add_worksheet('0x{!s}'.format(sndAdrHex))
					fileDescXlsxWorkSheet.append(ws)
					dictCounterRow.append(0)
					statOutFileC7.append(1)

					# Запись для выбегов
					column = 0
					fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column, 'Начало выбега')
					fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column + 1, 'Конец выбега')
					fileDescXlsxWorkSheet[sndAddrs.index(sndAdrHex)].write (dictCounterRow[sndAddrs.index(sndAdrHex)], column + 2, 'Дельта')
					dictCounterRow[sndAddrs.index(sndAdrHex)] += 1

					# Запись для C7
					fileDescXlsxWorkSheetС7[sndAddrs.index(sndAdrHex)].write (dictCounterRowC7[sndAddrs.index(sndAdrHex)], column, 'Time')
					fileDescXlsxWorkSheetС7[sndAddrs.index(sndAdrHex)].write (dictCounterRowC7[sndAddrs.index(sndAdrHex)], column + 1, 'Counter')
					fileDescXlsxWorkSheetС7[sndAddrs.index(sndAdrHex)].write (dictCounterRowC7[sndAddrs.index(sndAdrHex)], column + 2, 'Speed')
					fileDescXlsxWorkSheetС7[sndAddrs.index(sndAdrHex)].write (dictCounterRowC7[sndAddrs.index(sndAdrHex)], column + 3, 'Mreal')
					fileDescXlsxWorkSheetС7[sndAddrs.index(sndAdrHex)].write (dictCounterRowC7[sndAddrs.index(sndAdrHex)], column + 4, 'M_upr')
					dictCounterRowC7[sndAddrs.index(sndAdrHex)] += 1
     
				else:
					statOutFileC7[sndAddrs.index(sndAdrHex)] += 1

				# Расчет данных C7
				prm = extractData(line)
				spd = evalMreal(pSpeed[sndAddrs.index(sndAdrHex)], pCounter[sndAddrs.index(sndAdrHex)], prm)

				pSpeed[sndAddrs.index(sndAdrHex)] = prm['curSpeed']
				pCounter[sndAddrs.index(sndAdrHex)] = prm['counter']
				
				# Запись С7
				writeToXlsx(fileDescXlsxWorkSheetС7[sndAddrs.index(sndAdrHex)], dictCounterRowC7[sndAddrs.index(sndAdrHex)], prm, spd)
				dictCounterRowC7[sndAddrs.index(sndAdrHex)] += 1

		# Расчет и запись температуры
		if dID['codeOp'] == 0xFC and dID['arrCnt']==2 and dID['arrSgn']==4:
			temperature = tmpr(line, sndAdrHex)
			if sndAddrsTemp.count(sndAdrHex) == 0:
				sndAddrsTemp.append(sndAdrHex)
				dictCounterRowTemp.append(0)
				wt = wb2.add_worksheet('0x{!s}'.format(sndAdrHex))
				fileDescXlsxWorkSheetTemp.append(wt)
			writetemp = writeTemp(temperature, fileDescXlsxWorkSheetTemp, sndAddrsTemp, dictCounterRowTemp)

	for xls in fileDescXlsxWorkBook:
		xls.close()
	print(f'out filename_xlsx_C7\t\t: {outPathXlsx}')
	print(f'out filename_xlsx_Down\t\t: {outPathXlsx[:-7]}' + 'Down' +  '.xlsx')
	print(f'out filename_xlsx_temperature\t: {outPathXlsx[:-7]}' + 'temperature' +  '.xlsx')
