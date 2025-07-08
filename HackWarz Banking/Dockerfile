FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt
RUN mkdir -p /app/static

COPY app/ /app
COPY flag.txt /flag.txt

EXPOSE 5000

CMD ["python", "app.py"]