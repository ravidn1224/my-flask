FROM python:3.9-slim
COPY app.py .
RUN pip install flask
CMD ["python", "app.py"]
