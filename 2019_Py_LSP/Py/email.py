# %%
import smtplib
from getpass import getpass
from email.message import EmailMessage
import imghdr
# %%
# https://myaccount.google.com/lesssecureapps
EMAIL_ADD = 'ericdrumond@gmail.com'
EMAIL_PAS = getpass(f'Senha do e-mail ({EMAIL_ADD}) : ')

with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
    try:
        smtp.ehlo()
        smtp.starttls()
        smtp.ehlo()
        smtp.login(EMAIL_ADD, EMAIL_PAS)

        subject = 'Teste...'
        body = 'blablablabla'

        msg = f'Subject: {subject}\n\n{body}'

        smtp.sendmail(EMAIL_ADD, EMAIL_ADD, msg)

        del(EMAIL_ADD)
        del(EMAIL_PAS)
        pass
    except Exception as error:
        del(EMAIL_ADD)
        del(EMAIL_PAS)
        print(f'Erro : {error}')
        pass
    pass