import openpyxl
import os
from cryptography.fernet import Fernet

# File Generation
file_name = input('Enter EXCEL file name\n >>> ')

workbook = openpyxl.Workbook()
workbook.save(f'{file_name}.xlsx')

# Key Generation
key = Fernet.generate_key()

key_file_name = f'key_{file_name}'

with open(f'{key_file_name}.key', 'wb') as file:  #
    file.write(key)

# Encrypt Datafile
with open(f'{key_file_name}.key', 'rb') as key_file:
    key = key_file.read()

with open(f'{file_name}.xlsx', 'rb') as unencrypted_datafile:
    data = unencrypted_datafile.read()

fernet = Fernet(key)
encrypted = fernet.encrypt(data)

with open(f'{file_name}.xlsx.encrypted', 'wb') as encrypted_datafile:
    encrypted_datafile.write(encrypted)

# Remove original spreadsheet
os.remove(f'{file_name}.xlsx')
