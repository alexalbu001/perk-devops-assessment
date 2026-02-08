FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy project files
COPY setup.py .
COPY hello/ ./hello/

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -e .

# Set env vars
ENV FLASK_APP=hello

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
