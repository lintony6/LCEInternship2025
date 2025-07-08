FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install docker
RUN apt update && apt install -y sudo

COPY app/ .

EXPOSE 8080

CMD ["python", "app.py"]

