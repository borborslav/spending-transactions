from flask import Flask, render_template, request, send_file
import subprocess
import os
from datetime import datetime
#import pandas as pd

app = Flask(__name__)

# Директорія для зберігання згенерованих файлів
OUTPUT_DIR = 'generated_files'

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        # Отримання даних з форми
        date_start = request.form['date_start']
        date_end = request.form['date_end']
        number1 = request.form['number1']
        number2 = request.form['number2']

        # Форматування файлу виводу
        output_filename = f"{OUTPUT_DIR}/output_{number1 or 'no_number'}_{datetime.now().strftime('%Y%m%d%H%M%S')}.csv"
        #xlsx_output_filename = f"{OUTPUT_DIR}/output_{number1 or 'no_number'}_{datetime.now().strftime('%Y%m%d%H%M%S')}.xlsx"

        # Виконання bash скрипта з параметрами
        script_path = './script.sh'
        
        # Передаємо параметри до скрипта
        subprocess.run([script_path, date_start, date_end, number1, number2, output_filename])

        # Перевірка наявності згенерованого файлу
        if os.path.exists(output_filename):
            # Надсилання файлу користувачеві
            # df = pd.read_csv(output_filename)
            # df.to_excel(xlsx_output_filename, index=False)
            # return send_file(xlsx_output_filename, as_attachment=True)
            return send_file(output_filename, as_attachment=True)

    return render_template('form.html')

if __name__ == '__main__':
    # Створюємо директорію для файлів, якщо її не існує
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    app.run(host='0.0.0.0', port=5000, debug=True)

