FROM python:3.11-slim AS build
WORKDIR /w
COPY requirements.txt .
RUN pip install --prefix=/out --no-cache-dir -r requirements.txt
COPY src/ ./src

FROM gcr.io/distroless/python3-debian12
WORKDIR /app
ENV PYTHONPATH=/app:/usr/local/lib/python3.11/site-packages
COPY --from=build /out /usr/local
COPY --from=build /w/src /app/src
USER 65532:65532
EXPOSE 8080
CMD ["-m", "uvicorn", "src.main:app", "--host=0.0.0.0", "--port=8080"]
