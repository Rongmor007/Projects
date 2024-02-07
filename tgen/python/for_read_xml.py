import xml.dom.minidom
import os
from report_helper import translate_en_ru

def get_xml(file):
	"""
	Возвращает корневой элемент XML-файла
	:param file: XML-файл (строка)
	"""
	if os.path.isfile(file):
		doc = xml.dom.minidom.parse(file)
		node = doc.documentElement
		return node
	return None

class XMLParser():
	def __init__(self, file):
		self._node = get_xml(file)
		
	def __del__(self):
		if not (self._node is None):
			self._node.unlink()
		
	@property
	def node(self):
		return self._node
		
	@node.setter
	def node(self, file):
		self._node = get_xml(file)

	# эта функция нужна для Jinja2, т.к. она не может присваивать значения атрибутам сторонних объектов
	def set_node(self, file):
		"""
		Устанавливает новый корневой элемент
		:param file: путь к считываемому XML-файлу (строка)
		"""
		self._node = get_xml(file)
		
	def get_first_attribute(self, current_node, nameOfAttribute):
		"""
		Возвращает значение первого найденного атрибута с именем nameOfAttribute в объекте current_node
		:param current_node: элемент XML-файла, в котором нужно найти значение атрибута
		:param nameOfAttribute: имя атрибута (строка)
		:return: значение атрибута (строка)
		"""
		value_of_attribute = ''
		if isinstance(nameOfAttribute, str) and not(current_node is None) and current_node.nodeType == xml.dom.Node.ELEMENT_NODE:
			for (name, value) in current_node.attributes.items():
				if name == nameOfAttribute:
					value_of_attribute = value
		return value_of_attribute
		
		
	def get_child_elements_by_tag_name(self, parent_node, tag_name):
		"""
		Возвращает список объектов, удовлетворяющих заданному имени тега
		:param parent_node: родительский объект, дочерние объекты которого ищутся
		:param tag_name: имя тега, по которому ищут дочерние объекты (строка)
		:return: список дочерних элементов, подходящих под аданное имя тега
		"""
		child_nodes = []
		if isinstance(tag_name, str) and tag_name != '' and not(parent_node is None) and parent_node.nodeType == xml.dom.Node.ELEMENT_NODE:
			all_child_nodes = parent_node.childNodes
			for child_node in all_child_nodes:
				if child_node.nodeType == xml.dom.Node.ELEMENT_NODE and child_node.tagName == tag_name:
					child_nodes.append(child_node)
		return child_nodes
		
	def get_elements(self, path, parent_node = None):
		"""
		Возвращает список элементов по пути path.
		:param path: строка, в которой через '/' описаны теги объектов, в которых находятся искомые объекты
		:param parent_node: объект, с которого начинается путь к искомым элементам
		:return: список искомых объектов Elements
		"""
		target_elements = []
		if isinstance(path, str) and path != '':
			current_node = self._node
			if not(parent_node is None) and parent_node.nodeType == xml.dom.Node.ELEMENT_NODE:
				current_node = parent_node
			tags = path.split('/')
			target_elements = self.get_child_elements_by_tag_name(current_node, tags[0])
			for i in range(1, len(tags)):
				if len(target_elements) < 1 or target_elements[0].nodeType != xml.dom.Node.ELEMENT_NODE:
					target_elements = []
					break
				target_elements = self.get_child_elements_by_tag_name(target_elements[0], tags[i])
		return target_elements
	
	def get_element_by_name(self, path = '', necessary_name = '', parent_node = None, list_of_elements = [], isNeedOneElement = True, isUsingPath = True):
		"""
		Возвращает элемент по пути path с атрибутом 'callerName' или 'name' со значением necessary_name.
		### 
		Пример: e.get_element_by_name('tr:Data/c:Collection/c:Item', 'Напряжение', '<DOM Element: tr:SessionAction at 0x204e2b7fd00>'), где 1-й элемент - путь до нужного блока, 2-й элемент name - <c:Item name = "Напряжение: ">, внутри которого нужное нам выражение <c:Datum value = "7" xsi:type="ts:TS_double" flags = "0x2000"/>, 3-й элемент - путь с которого начинается поиск . Возвращает <DOM Element: c:Item at 0x204e2b7d990>, то есть путь до элемента.
		###
		Если necessary_name равен '', то функция возвращает самый первый найденный элемент.
		:param path: строка, в которой через '/' описаны теги объектов, в которых находится искомый объект
		:param necessary_name: значение атрибута 'callerName' или 'name' искомого элемента (строка)
		:param parent_node: объект, с которого начинается путь 'path' к искомым элементам
		:param list_of_elements: список элементов, среди которых нужно найти искомые элементы (не используется при isUsingPath == True)
		:param isNeedOneElement: равен True, если ищется только один элемент, иначе равен False
		:param isUsingPath: равен True, если при поиске используется путь 'path' вместо списка элементов 'list_of_elements', иначе равен False
		:return: найденный элемент
		"""
		target_elements = []
		if isNeedOneElement:
			res_element = None
		else:
			res_element = []
		if isinstance(necessary_name, str):
			if isUsingPath:
				target_elements = self.get_elements(path, parent_node)
			else:
				target_elements = list_of_elements
			if len(target_elements) > 0:
				if necessary_name == '':
					if isNeedOneElement:
						res_element = target_elements[0]
					else:
						res_element.append(target_elements[0])
				else:
					for target_element in target_elements:
						if target_element.nodeType == xml.dom.Node.ELEMENT_NODE:
							target_caller_name = target_element.getAttribute('callerName')
							if target_caller_name == necessary_name:
								if isNeedOneElement:
									res_element = target_element
									break
								else:
									res_element.append(target_element)
							elif target_caller_name == '':
								target_caller_name = target_element.getAttribute('name')
								if target_caller_name == necessary_name:
									if isNeedOneElement:
										res_element = target_element
										break
									else:
										res_element.append(target_element)
		return res_element
	
	def get_value_of_text_node(self, parent_node):
		"""
		Возвращает значение первого текстового объекта по родительскому объекту
		:param parent_node: объект, содержащий текстовые объекты
		:return: найденное значение текстового объекта (строка)
		"""
		value_of_text_node = ''
		if not(parent_node is None) and parent_node.nodeType == xml.dom.Node.ELEMENT_NODE:
			text_nodes = parent_node.childNodes
			if text_nodes.length > 0 and text_nodes.item(0).nodeType == xml.dom.Node.TEXT_NODE:
				value_of_text_node = text_nodes.item(0).data
		return value_of_text_node
	
	def get_value_of_text_node_by_path(self, path):
		"""
		Возвращает текстовое значение текстового объекта XML-файла по заданному пути
		:param path: путь к искомому текстовому объекту
		:return: найденное значение текстового объекта (строка)
		"""
		value_of_text_node = ''
		if isinstance(path, str):
			parent_of_text_node = self.get_element_by_name(path)
			value_of_text_node = self.get_value_of_text_node(parent_of_text_node)
		return value_of_text_node
	
	def get_value_of_text_node_by_parent_node_and_internal_path(self, parent_node, internal_path):
		"""
		Возвращает текстовое значение текстового объекта XML-файла по заданному родительскому объекту и пути в нём
		:param parent_node: родительский объект, с которого начинается поиск текстовых объектов
		:param internal_path: путь из тегов, разделённых символом '/'
		:return: найденное значение текстового объекта (строка)
		"""
		value_of_text_node = ''
		if isinstance(internal_path, str) and not(parent_node is None):
			elements = self.get_elements(internal_path, parent_node)
			for element in elements:
				value_of_text_node = self.get_value_of_text_node(element)
				if value_of_text_node != '':
					break
		return value_of_text_node
		
	def get_value_of_attribute_by_parent_node_and_internal_path(self, parent_node, internal_path, name_of_attribute):
		"""
		Возвращает значение первого атрибута 'name_of_attribute' из дочернего элемента, расположенного по пути 'internal_path'
		относительно родительского элемента 'parent_node'
		:param parent_node: родительский объект, с которого начинается поиск искомого объекта
		:param internal_path: путь из тегов, разделённых символом '/'
		:param name_of_attribute: имя атрибута (строка)
		:return: значение атрибута (строка)
		"""
		value_of_attribute = ''
		if isinstance(name_of_attribute, str) and isinstance(internal_path, str) and not(parent_node is None) and parent_node.nodeType == xml.dom.Node.ELEMENT_NODE:
			elements = self.get_elements(internal_path, parent_node)
			for element in elements:
				value_of_attribute = self.get_first_attribute(element, name_of_attribute)
				if value_of_attribute != '':
					break
		return value_of_attribute

class XMLConfigParser(XMLParser):
	def get_UUT_Names(self, res_dict):
		"""
		Изменяет исходный словарь res_dict, заполняя его именем отчёта и видом заголовка отчёта
		:param res_dict: заполняемый словарь
		"""
		rem = self._node.getElementsByTagName('Report')
		if rem.item(0).nodeType == xml.dom.Node.ELEMENT_NODE:
			for (name, value) in rem.item(0).attributes.items():
				if name == 'UUT_Name':
					res_dict['uut_name']=value
				if name == 'Headers':
					res_dict['headers']=value
					
	def get_list_of_headers_by_name(self, type_of_header):
		"""
		Возвращает список атрибутов по заданному типу заголовка
		:param type_of_header: заданный тип заголовка (строка)
		:return: список атрибутов и их значеиний или пустая строка при отсутствии нужного типа заголовка
		"""
		#считывание необходимых заголовков
		rem = self._node.getElementsByTagName('Headers')
		headers = ''
		end_loop = False
		for i in rem:
			if i.nodeType == xml.dom.Node.ELEMENT_NODE:
				for (name, value) in i.attributes.items():
					if name == 'Name' and value == type_of_header:
						headers = i.attributes.items()
						end_loop = True
						break
			if end_loop:
				break
		return headers
		
	def get_params_for_header(self, res_dict, type_of_header=''):
		"""
		Изменяет параметры по умолчанию для заголовка отчёта. Новые параметры считываются с XML-файла
		:param res_dict: словарь с первоначальными параметрами для заголовка отчёта (словарь)
		:param type_of_header: имя типа заголовка по-умолчанию (строка)
		"""
		if type_of_header == '':
			#получение типа заголовка
			dop_dict = {'headers': 'Default'}
			self.get_UUT_Names(dop_dict)
		else:
			dop_dict = {'headers': type_of_header}
		
		headers = self.get_list_of_headers_by_name(dop_dict['headers'])
		# если был указан неправильный тип заголовка, считывается тип заголовка с конфигурационного файла
		if not isinstance(headers, list):
			self.get_UUT_Names(dop_dict)
			headers = self.get_list_of_headers_by_name(dop_dict['headers'])
		if isinstance(headers, list):
			for (name, value) in headers:
				if value != '':
					if name == 'Head1':
						res_dict['head1'] = value
					if name == 'Head2':
						res_dict['head2'] = value
					if name == 'Head3':
						res_dict['head3'] = value
					if name == 'Date':
						res_dict['date'] = value
					
class XMLReportParser(XMLParser):
	def get_data_from_string(self, data, data_type):
		"""
		Возвращает объект data, приведённый к типу data_type
		:param data: преобразуемые данные (строка)
		:param data_type: тип, к которому нужно привести данные (строка)
		:return: объект приведённого типа
		"""
		if data_type == 'ts:TS_double':
			try:
				data = float(data)
			except:
				data = ''
		return data
	
	def get_step_status(self, element):
		"""
		Возвращает статус шага по тегу "tr:Outcome"
		:param element: объект, определяющий шаг, статус которого необходимо найти
		:return: статус шага (строка)
		"""
		step_status = ''
		if not(element is None) and element.nodeType == xml.dom.Node.ELEMENT_NODE:
			#sub_elements = element.getElementsByTagName('tr:ActionOutcome')
			sub_elements = self.get_child_elements_by_tag_name(element, 'tr:ActionOutcome')
			if len(sub_elements) > 0 and sub_elements[0].nodeType == xml.dom.Node.ELEMENT_NODE:
				sub_element = sub_elements[0]
			else:
				#sub_elements = element.getElementsByTagName('tr:Outcome')
				sub_elements = self.get_child_elements_by_tag_name(element, 'tr:Outcome')
				if len(sub_elements) > 0 and sub_elements[0].nodeType == xml.dom.Node.ELEMENT_NODE:
					sub_element = sub_elements[0]
				else:
					sub_element = None
			if not(sub_element) is None:
				step_status = sub_element.getAttribute('value')
				if step_status == 'UserDefined':
					step_status = sub_element.getAttribute('qualifier')
		return step_status
		
	def get_step_name(self, element):
		"""
		Возвращает имя шага по атрибутам "callerName" или "name"
		:param element: объект, определяющий шаг, имя которого необходимо найти
		:return: имя шага (строка)
		"""
		step_name = ''
		if not(element is None) and element.nodeType == xml.dom.Node.ELEMENT_NODE:
			step_name = element.getAttribute('callerName')
			if step_name == '':
				step_name = element.getAttribute('name')
		return step_name
		
	def get_uut_serial_number(self):
		"""
		Возвращает серийный номер испытуемого прибора
		:return: серийный номер испытуемого прибора (строка)
		"""
		serial_number = self.get_value_of_text_node_by_path(r'trc:TestResults/tr:UUT/c:SerialNumber')
		index = serial_number.find(' ')
		if index > 0:
			serial_number = serial_number[:index]
		return serial_number
		
	def get_start_time(self):
		"""
		Возвращает время начала выполнения теста
		:return: время начала выполнения теста (строка)
		"""
		time_and_date = ''
		all_tests_element = self.get_element_by_name(r'trc:TestResults/tr:ResultSet')
		time_and_date = self.get_first_attribute(all_tests_element, 'startDateTime')
		return time_and_date 
	
	def get_steps(self, path, step_type, step_group):
		"""
		Возвращает список объектов на шаги, принадлежащие к заданному типу, группе и объекту, описанному через путь к нему
		:param path: путь к объекту, чьи шаги будут искаться (строка)
		:param step_type: заданный тип шагов (строка)
		:param step_group: заданная группа шагов (строка)
		:return: список 
		"""
		step_elements_list = []
		if isinstance(step_type, str) and isinstance(step_group, str) and isinstance(path, str):
			main_seq = self.get_element_by_name(path)
			if not(main_seq is None):
				step_nodes = self.get_child_elements_by_tag_name(main_seq, 'tr:ResultSet') + self.get_child_elements_by_tag_name(main_seq, 'tr:TestGroup') + \
							 self.get_child_elements_by_tag_name(main_seq, 'tr:SessionAction') + self.get_child_elements_by_tag_name(main_seq, 'tr:Test')
				for step_node in step_nodes:
					value_of_text_node = self.get_value_of_text_node_by_parent_node_and_internal_path(step_node, r'tr:Extension/ts:TSStepProperties/ts:StepType')
					if value_of_text_node == step_type:
						value_of_text_node = self.get_value_of_text_node_by_parent_node_and_internal_path(step_node, r'tr:Extension/ts:TSStepProperties/ts:StepGroup')
						if value_of_text_node == step_group:
							step_elements_list.append(step_node)
		return step_elements_list
	
	def sort_list_of_steps(self, seq):
		"""
		Сортировка списка ссылок на объекты XML по имени их шага
		:param seq: список ссылок на объекты XML
		:return: отсортированный список ссылок на объекты XML
		"""
		if isinstance(seq, list):
			length_of_list = len(seq)
			for j in range(1, length_of_list):
				for i in range(0, length_of_list - j):
					step_name1 = self.get_step_name(seq[i])
					step_name2 = self.get_step_name(seq[i+1])
					if step_name1 > step_name2:
						mem = seq[i+1].cloneNode(True)
						seq[i+1] = seq[i].cloneNode(True)
						seq[i] = mem.cloneNode(True)
		return seq
		
	def get_substeps(self, parent_node, step_type, step_group):
		"""
		Возвращает список объектов на подшаги, принадлежащих к заданному типу, группе и родительскому объекту
		:param parent_node: родительский объект, чьи подшаги будут искаться
		:param step_type: заданный тип шагов (строка)
		:param step_group: заданная группа шагов (строка)
		:return: список подшагов
		"""
		substep_elements_list = []
		if isinstance(step_type, str) and isinstance(step_group, str):
			if not(parent_node is None) and parent_node.nodeType == xml.dom.Node.ELEMENT_NODE:
				step_nodes = self.get_child_elements_by_tag_name(parent_node, 'tr:SessionAction') + self.get_child_elements_by_tag_name(parent_node, 'tr:Test')
				for step_node in step_nodes:
					value_of_text_node = self.get_value_of_text_node_by_parent_node_and_internal_path(step_node, r'tr:Extension/ts:TSStepProperties/ts:StepType')
					if value_of_text_node == step_type:
						value_of_text_node = self.get_value_of_text_node_by_parent_node_and_internal_path(step_node, r'tr:Extension/ts:TSStepProperties/ts:StepGroup')
						if value_of_text_node == step_group:
							substep_elements_list.append(step_node)
		return substep_elements_list
		
	def get_prop(self, substeps, name_of_substep, name_of_item, key=0, prec=3):
		"""
		Возвращает список значений дополнительных результатов в зависимости от их типа
		###
		Пример: WrSrcVlt = e.get_prop(substeps, 'Write Source Voltage', "Напряжение")
		###
		:param substeps: список элементов, относящихся к подшагам дополнительного результата
		:param name_of_substep: имя подшага, в котором ищутся результаты (строка)
		:param name_of_item: имя блока, хранящего искомое значение (строка)
		:param key: костыль для подтверждения корректного имени блока
		:return: список значений дополнительных результатов
		"""
		additional_results = []
		correct_substeps = []
		if isinstance(name_of_substep, str) and isinstance(name_of_item, str):
			if len(substeps) > 0 and substeps[0].nodeType == xml.dom.Node.ELEMENT_NODE:
				for substep in substeps:
					if key == 0:
						name_attribute = self.get_first_attribute(substep, 'name')
						if name_attribute == name_of_substep:
							correct_substeps.append(substep)
					if key == 1:
						correct_substeps.append(substep)
				if len(correct_substeps) > 0 and correct_substeps[0].nodeType == xml.dom.Node.ELEMENT_NODE:
					for correct_substep in correct_substeps:
						# item_element = self.get_element_by_name('tr:Data/c:Collection/c:Item', name_of_item, correct_substep)
						item_element = self.get_elements('tr:Data/c:Collection/c:Item', correct_substep)
						result_type = self.get_value_of_attribute_by_parent_node_and_internal_path(item_element[0], 'c:Datum', 'xsi:type')
						if result_type != '':
							additional_result = self.get_value_of_attribute_by_parent_node_and_internal_path(item_element[0], 'c:Datum', 'value')
							if additional_result == '':
								additional_result = self.get_value_of_text_node_by_parent_node_and_internal_path(item_element[0], 'c:Datum/c:Value')
							if additional_result != '':
								additional_result = self.format_float_number(self.get_data_from_string(additional_result, result_type))
								additional_results.append(additional_result)
			if len(additional_results) > 0:
				results = []
				for i in additional_results:
					results.append(str(i).replace('.', ','))
				return results
	
	def get_result_of_numeric_limit(self, test_result_node):
		"""
		Возвращает результат шага с предельными значениями по узлу результатов этого шага
		:param test_result_node: элемент, описывающий результаты шага NumericLimits
		:return: результат шага NumericLimits
		"""
		result_of_numeric_limit = ''
		if not(test_result_node is None):
			prop_nodes = self.get_elements('tr:TestData/c:Datum', test_result_node)
			if len(prop_nodes) > 0 and prop_nodes[0].nodeType == xml.dom.Node.ELEMENT_NODE:
				data_type = self.get_first_attribute(prop_nodes[0], 'xsi:type')
				result_of_numeric_limit = self.get_first_attribute(prop_nodes[0], 'value')
				result_of_numeric_limit = self.get_data_from_string(result_of_numeric_limit, data_type)
		return result_of_numeric_limit
	
	def get_prop_of_numeric_limit(self, test_result_node, name_of_prop):
		"""
		Возвращает дополнительные результаты, которые были сделаны в шаге типа NumericLimitTest
		:param test_result_node: элемент, описывающий результаты шага NumericLimitTest
		:param name_of_prop: название шага name
		:return: дополнительный результат шага NumericLimitTest
		"""
		additional_results = []
		if not(test_result_node is None) and isinstance(name_of_prop, str) and name_of_prop != '':
			prop_nodes = self.get_element_by_name('tr:TestResult', name_of_prop, test_result_node, isNeedOneElement = False)
			for prop_node in prop_nodes:
				datum_elements = self.get_elements('tr:TestData/c:Datum', prop_node)
				for datum_element in datum_elements:
					if datum_element.nodeType == xml.dom.Node.ELEMENT_NODE:
						data_type = self.get_first_attribute(datum_element, 'xsi:type')
						if data_type != '': 
							prop_result = self.get_value_of_text_node_by_parent_node_and_internal_path(datum_element, 'c:Value')
							if prop_result != '':
								prop_result = self.get_data_from_string(prop_result, data_type)
								additional_results.append(prop_result)
		return additional_results
		
	def get_numeric_limit(self, test_result_node, prec=3):
		"""
		Возвращает словарь, описывающий заданные пределы шага
		:param test_result_node: элемент, описывающий результаты шага NumericLimitTest
		:return: словарь, описывающий пределы шага
		"""
		#инициализация всего словаря сделана для большей наглядности
		res_limit = {'hi': '',
					 'lo': '',
					 'comp': '',
					 'units': '',
					 'result': '',
					 'status': ''}
		# Функция была изменена, теперь фрмат везде строка с ,
		if not(test_result_node is None):
			limit_status = self.get_step_status(test_result_node)
			res_limit['status'] = limit_status
			numeric_element = self.get_element_by_name('tr:TestResult', 'Numeric', test_result_node)
			# res_limit['result'] = self.get_result_of_numeric_limit(numeric_element)
			res_limit['result'] = str(self.format_float_number(self.get_result_of_numeric_limit(numeric_element), precision=prec)).replace('.', ',')
			limits_element = self.get_elements('tr:TestLimits/tr:Limits', numeric_element)
			if len(limits_element) > 0 and limits_element[0].nodeType == xml.dom.Node.ELEMENT_NODE:
				# первым дочерним элементом является текстовый элемент, содержащий
				# перенос строки и символы табуляции XML-файла, поэтому нужно обращаться ко второму элементу
				first_element_in_limits = limits_element[0].childNodes.item(1)
				if not(first_element_in_limits is None) and first_element_in_limits.nodeType == xml.dom.Node.ELEMENT_NODE:
					# если предел установлен с одной стороны
					if first_element_in_limits.tagName == 'c:SingleLimit':
						res_limit['comp'] = self.get_first_attribute(first_element_in_limits, 'comparator')
						datum_element = first_element_in_limits.childNodes.item(1)
						if not(datum_element is None) and datum_element.nodeType == xml.dom.Node.ELEMENT_NODE:
							res_limit['units'] = str(self.get_first_attribute(datum_element, 'nonStandardUnit')).replace('.', ',')
							data_type = self.get_first_attribute(datum_element, 'xsi:type')
							lo_limit = self.get_first_attribute(datum_element, 'value')
							# res_limit['lo'] = self.get_data_from_string(lo_limit, data_type)
							res_limit['lo'] = str(self.format_float_number(self.get_data_from_string(lo_limit, data_type), precision=1)).replace('.', ',')
					elif first_element_in_limits.tagName == 'c:LimitPair':
						# не учитывается возможность установки OR вместо AND, т.к. OR обычно не применяется
						if self.get_first_attribute(first_element_in_limits, 'operator') == 'AND':
							limits_pair = self.get_child_elements_by_tag_name(first_element_in_limits, 'c:Limit')
							for i in range(0, len(limits_pair)):
								comp_operator = self.get_first_attribute(limits_pair[i], 'comparator')
								res_limit['comp'] += comp_operator
								datum_element = limits_pair[i].childNodes.item(1)
								if not(datum_element is None) and datum_element.nodeType == xml.dom.Node.ELEMENT_NODE:
									if i == 0:
										res_limit['units'] = self.get_first_attribute(datum_element, 'nonStandardUnit')
									data_type = self.get_first_attribute(datum_element, 'xsi:type')
									lo_limit = self.get_first_attribute(datum_element, 'value')
									if comp_operator == 'GE' or comp_operator == 'GT':
										# test = self.get_data_from_string(lo_limit, data_type)
										# test = str(test).replace('.', ',')
										res_limit['lo'] = str(self.format_float_number(self.get_data_from_string(lo_limit, data_type), precision=1)).replace('.', ',')
									else:
										# test2 = str(self.get_data_from_string(lo_limit, data_type)).replace('.', ',')
										res_limit['hi'] = str(self.format_float_number(self.get_data_from_string(lo_limit, data_type), precision=1)).replace('.', ',')
		return res_limit
	
	def get_numeric_limits(self, substeps, name_of_substep):
		"""
		Возвращает список словарей, описывающих заданные пределы шага
		:param substeps: список подшагов, в которых нужно искать шаги с предельными значениями
		:param name_of_substep: имя искомых подшагов (строка)
		:return: список словарей, описывающих пределы
		"""
		numeric_limits = []
		correct_substeps = []
		if isinstance(name_of_substep, str) and len(substeps) > 0 and substeps[0].nodeType == xml.dom.Node.ELEMENT_NODE:
			correct_substeps = self.get_element_by_name(necessary_name = name_of_substep, list_of_elements = substeps, isNeedOneElement = False, isUsingPath = False)
			if len(correct_substeps) > 0 and correct_substeps[0].nodeType == xml.dom.Node.ELEMENT_NODE:
				for correct_substep in correct_substeps:
					res_limit = self.get_numeric_limit(correct_substep)
					numeric_limits.append(res_limit)
		return numeric_limits
	
	def get_session_action(self, steps):
		'''
		Возвращает список SessionAction в соответствии с проверками
		:rapam steps: Список всех проверок
		:return: Список SessionAction, где потенциально есть необходимые проверки waveform
		'''
		GetWaveForm = []
		for step in steps:
			findSesAct = self.get_elements('tr:SessionAction', parent_node=step)
			dump = self.get_element_by_name(list_of_elements=findSesAct, necessary_name='Get Waveform Parameters', isNeedOneElement=False, isUsingPath=False)
			GetWaveForm.append(dump)
	 
		return GetWaveForm
	
	def get_waveform_params(self, get_waveform):
		'''
		Возвращает список кортежей для постройки графика
		'''
		y = 0.00004
		dt = y
		WaveFormElem = []
		dump = self.get_elements('tr:Data/c:Collection/c:Item', parent_node=get_waveform)
		dump = self.get_elements('c:Collection/c:Item', parent_node=dump[1])
		dump = self.get_elements('c:IndexedArray/ts:Element', parent_node=dump[2])
		for i in range(len(dump)):
			value = '{:.5f}'.format(float(self.get_first_attribute(dump[i], 'value')))
			y = '{:.5f}'.format(y)
			WaveFormElem.append((float(y), float(value)))
			y = float(y) + dt
			
		return WaveFormElem
	
	
	
	def get_prop_of_numeric_limit_without_name(self, test_result_node, correct_substep):
		"""
		Возвращает дополнительные результаты, которые были сделаны в шаге типа NumericLimitTest без имени шага
		:param test_result_node: элемент, описывающий результаты шага NumericLimitTest
		:param correct_substep: шаг TestResult
		:return: дополнительный результат шага NumericLimitTest
		"""
		if not(test_result_node is None) and correct_substep != '':
			prop_node = correct_substep
			datum_elements = self.get_elements('tr:TestData/c:Datum', prop_node)
			for datum_element in datum_elements:
				if datum_element.nodeType == xml.dom.Node.ELEMENT_NODE:
					data_type = self.get_first_attribute(datum_element, 'xsi:type')
					if data_type != '': 
						prop_result = self.get_value_of_text_node_by_parent_node_and_internal_path(datum_element, 'c:Value')
						if prop_result != '':
							prop_result = self.get_data_from_string(prop_result, data_type)
		return prop_result
	
	
	def format_float_number(self, numb, precision=3, flags='', number_multiplication=1):
		"""
		Функция форматированного вывода вещественного числа
		:param numb: форматируемое число (вещественное число, целое число или строка, представляющая собой вещественное число)
		:param precision: количество цифр после запятой (целое число)
		:param flags: флаг форматирования (строка) может принимать значения '-' (выравнивание), '+' (вывод числа со знаком даже при положительных числах), '0' (наличие ведущих модулей)
		:param number_multiplication: число, на которое домножается numb (число)
		"""
		count = False
		if isinstance(numb, float):
			count = True
		result = ('%' + flags + '.' + str(precision) + 'f')%(float(numb) * number_multiplication)
		i = -1
		while result[i:] == '0' and count == True:
			result = result[:i]
		if result[i:] == '.':
			result = result[:i]
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


#для проверки 
if __name__ == '__main__':
	file = r'C:\avs\Utilities\Template_generator\For DWNT From XML\DWNT_Report_Configuration.xml'
	cp = XMLConfigParser(file)
	d = {'head1': '%device %serialNumber', 'head2': 'ПСИ. Проверка работоспособности', 'head3': 'Нормальные условия', 'date': 'DATE'}
	cp.get_params_for_header(d)
	for key in d:
		print(key, d[key])
	# удаление считывателя конфигурационного файла
	del cp
	file = r'C:\avs\Utilities\Template_generator\For DWNT From XML\Main_20GK-01_Report[11 14 02][09.01.2022]_62097206.xml'
	e = XMLReportParser(file)
	list_of_nodes = e.get_steps(r'trc:TestResults/tr:ResultSet', 'SequenceCall', 'Main')
	#e.sort_list_of_steps(list_of_nodes)
	for el in list_of_nodes:
		print(e.get_step_name(el))
	print('Попытка считывания дополнительных шагов и пределов')
	step6 = e.get_element_by_name('trc:TestResults/tr:ResultSet/tr:TestGroup', '3.2.06 Проверка тока обтекания пиросредств.')
	sublimits6 = e.get_substeps(step6, 'NumericLimitTest', 'Main')
	has_getted_limits = e.get_numeric_limits(sublimits6, 'Проверка тока обтекания линий 2 и 3 типа')
	for getted_limit in has_getted_limits:
		for (key, value) in getted_limit.items():
			print("Key: {0}. Value: {1}".format(key, value))
	step8 = e.get_element_by_name('trc:TestResults/tr:ResultSet/tr:TestGroup', '3.2.08 Проверка потребления БИОС при включенной максимально допустимой нагрузке, предельно допустимого тока в цепи питания потребителя, максимально допустимого тока в цепи первичного питания, и погрешности определения тока на шинах питания.')
	sublimits8 = e.get_substeps(step8, 'NumericLimitTest', 'Main')
	has_getted_limits = e.get_numeric_limits(sublimits8, '[Check Channel Voltage Drop]')
	for getted_limit in has_getted_limits:
		for (key, value) in getted_limit.items():
			print("Key: {0}. Value: {1}".format(key, value))
	for i in range(len(list_of_nodes) - 1, 0, -1):
		del list_of_nodes[i]
	del e
	
	