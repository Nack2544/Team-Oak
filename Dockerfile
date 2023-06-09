FROM python:3.8

ENV FLASK_ENV='development'
ENV FLASK_APP='app.py'

WORKDIR /usr/src/app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "./app.py"]