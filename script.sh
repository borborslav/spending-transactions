#!/bin/bash

# Перевірка наявності jq
if ! command -v jq &> /dev/null; then
    echo "jq не встановлено. Встановіть jq, щоб продовжити."
    exit 1
fi

# Перевіряємо значення третього аргументу ($3)
if [ -z "$3" ]; then
    p3=""
else
    p3="payers_edrpous=$3"
fi

# Перевіряємо значення четвертого аргументу ($4)
if [ -z "$4" ]; then
    p4=""
else
    if [ -z "$3" ]; then
        p4="recipt_edrpous=$4"
    else
        p4="&recipt_edrpous=$4"
    fi
fi

# URL для отримання даних
#api_url="https://api.spending.gov.ua/api/v2/api/transactions/?payers_edrpous=02013047&startdate=2023-06-10&enddate=2023-06-10"
api_url="https://api.spending.gov.ua/api/v2/api/transactions/?$p3$p4&startdate=$1&enddate=$2"
echo $api_url >> log.txt

# Отримання JSON даних через curl
response=$(curl -s -X GET "$api_url")

# Перевірка, чи відповідь містить дані
if [ -z "$response" ]; then
    echo "Помилка: не вдалося отримати дані з API."
    exit 1
fi

# Ім'я вихідного файлу CSV
#output_file="transactions.csv"
output_file=$5

#echo "$response" > out.json

# Визначення заголовків для CSV (ключі JSON-об'єктів)
#headers=$(echo "$response" | jq -r '.[0] | keys | @csv')
#headers=$(echo "$response" | jq -r '.[0] | keys | @csv' | sed 's/,/;/g')
#headers='"amount","amount_cop","budgetCode","contractId","contractNumber","currency","doc_add_attr","doc_date","doc_number","doc_v_date","doc_vob","doc_vob_name","id","kekv","kpk","payer_account","payer_bank","payer_edrpou","payer_edrpou_fact","payer_mfo","payer_name","payer_name_fact","payment_data","payment_details","payment_type","recipt_account","recipt_bank","recipt_edrpou","recipt_edrpou_fact","recipt_mfo","recipt_name","recipt_name_fact","region_id","source_id","source_name","system_key","system_key_ff","trans_date"'
headers=$(echo '"сума оплати в гривнях з копійками","сума оплати в копійках","код бюджету","унікальний ідентифікатор договору про закупівлю в системі Prozorro","унікальний ідентифікатор закупівлі в системі Prozorro","літеральний код валюти","додатковий реквізит","дата складання розрахункового документа ","номер розрахункового документа","дата валютування документа ","код розрахункового документа","назва коду розрахункового документа","унікальний ідентифікатор трансакції в Системі","код економічної класифікації видатків","код програмної класифікації видатків та кредитування","рахунок платника (IBAN)","найменування банку платника","код ЄДРПОУ платника","код ЄДРПОУ фактичного платника","код банку платника","найменування платника","найменування фактичного платника","	додаткові дані для типу платіжної системи","призначення платежу","тип платіжної системи","рахунок отримувача (IBAN)","найменування банку отримувача","код ЄДРПОУ отримувача","код ЄДРПОУ фактичного отримувача","код банку отримувача","найменування отримувача","найменування фактичного отримувача","код регіону","унікальний ідентифікатор джерела даних в Системі","найменування джерела даних","Внутрішній номер документа","Ідентифікатор бюджетного фінансового зобов’язання","trans_date"' | sed 's/,/;/g')


# Конвертація JSON у CSV-рядки
#rows=$(echo "$response" | jq -r '.[] | [.id, .doc_vob, .doc_number, .doc_date, .amount, .currency, .payer_name, .recipt_name, .payment_details] | @csv')
#rows=$(echo "$response" | jq -r '.[] | [.id, .doc_vob, .doc_number, .doc_date, .amount, .currency, .payer_name, .recipt_name, .payment_details] | @csv' | sed 's/,/;/g')
rows=$(echo "$response" | jq -r '.[] | [
    .amount,
    .amount_cop,
    .budgetCode,
    .contractId,
    .contractNumber,
    .currency,
    .doc_add_attr,
    .doc_date,
    .doc_number,
    .doc_v_date,
    .doc_vob,
    .doc_vob_name,
    .id,
    .kekv,
    .kpk,
    .payer_account,
    .payer_bank,
    .payer_edrpou,
    .payer_edrpou_fact,
    .payer_mfo,
    .payer_name,
    .payer_name_fact,
    .payment_data,
    .payment_details,
    .payment_type,
    .recipt_account,
    .recipt_bank,
    .recipt_edrpou,
    .recipt_edrpou_fact,
    .recipt_mfo,
    .recipt_name,
    .recipt_name_fact,
    .region_id,
    .source_id,
    .source_name,
    .system_key,
    .system_key_ff,
    .trans_date
] | @csv' | sed 's/,/;/g')

# Збереження у CSV файл
{
    echo -e '\xEF\xBB\xBF'   # Додавання BOM для UTF-8
    echo "$headers"
    echo "$rows"
} | iconv -f UTF-8 -t UTF-16LE > "$output_file"

# Перевірка на успішне збереження
if [ $? -eq 0 ]; then
    echo "Файл успішно збережено як: $output_file"
else
    echo "Помилка при збереженні файлу."
fi

