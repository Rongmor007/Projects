import requests
import datetime
from bs4 import BeautifulSoup

def get_data_today(date):
    response = requests.get(f'http://www.cbr.ru/scripts/XML_daily_eng.asp?date_req={date}').text
    soup = BeautifulSoup(response, 'xml')
    block_name = soup.find_all('Name')
    block_value = soup.find_all('VunitRate')
    currency = dict()
    for name in range(len(block_name)):
        # Запись в словарь
        cur_val = float((block_value[name].text).replace(',', '.'))
        cur_val = round(cur_val, 3)
        currency[block_name[name].text] = cur_val
    return currency


def get_maximum(current):
    counter = 0
    for k in current.items():
        maximum = max(k[1].values())
        if maximum > counter:
            key_val = [key for key in k[1] if k[1][key] == maximum]
            counter = maximum
            max_val = [maximum, key_val[0], k[0]]
    return max_val


def get_minimum(current, counter):
    for k in current.items():
        minimum = min(k[1].values())
        if minimum < counter:
            key_val = [key for key in k[1] if k[1][key] == minimum]
            counter = minimum
            min_val = [minimum, key_val[0], k[0]]
    return min_val    


def get_avg(current):
    avg_dict = {}
    length = list(current.values())
    length = len(length[0])
    for i in range(length):
        avg_list = []
        for j in current.values():
            k = list(j.keys())
            avg_list.append(j.get(k[i]))
        avg_res = round(sum(avg_list) / len(avg_list), 3)
        avg_dict[k[i]] = avg_res
    return avg_dict


#  Начало работы программы
start = datetime.datetime.now()

# Вычисление сегодняшней даты
current_date = datetime.date.today()
# Дата 90 дней назад
past_date = current_date - datetime.timedelta(days=90)
test = past_date
# Шаг в 1 день для цикла
step = datetime.timedelta(days=1)

# Словарь со всеми валютами за весь период
all_currency = {}
while past_date < current_date:
    # Преобразуем current_date в нужный формат
    date = past_date.strftime('%d/%m/20%y')
    all_currency[date] = get_data_today(date)
    past_date += step

# Вычисление максимального, минимального и среднего значения курса
maximum = get_maximum(all_currency)
minimum = get_minimum(all_currency, maximum[0])
avg_val = get_avg(all_currency)

# Запись результата программы
print(f'Result program:\nMaximum exchange rate: {maximum[0]}\n\tCurrency name: {maximum[1]}\n\tDate: {maximum[2]}\n')

print(f'Minimum exchange rate: {minimum[0]}\n\tCurrency name: {minimum[1]}\n\tDate: {minimum[2]}\n')

print(f'Avg exchange rate:\n\t{avg_val}')

# Конец работы программы
finish = datetime.datetime.now() - start
print(f'\n\nСкорость выполнения кода: {finish}')