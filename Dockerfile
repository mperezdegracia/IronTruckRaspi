# Use an official Python runtime as a parent image
FROM python:3.6.9-slim

# Set the working directory to /app
WORKDIR /IronTruckRaspi

# Install any needed packages specified in requirements.txt
RUN apt-get update -y && apt-get install -y build-essential
COPY requirements.txt /app/requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt
RUN apt-get install -y python3-rpi.gpio
RUN apt-get install -y libgpiod2

# Copy the current directory contents into the container at /app
COPY register.py /app/register.py
COPY test_influx.py /app/test_influx.py
COPY app.py /app/app.py
COPY register2.py /app/register2.py
# Run app.py when the container launches
# The -u flag specifies to use the unbuffered ouput.
# in this way, what's printed by the app is visible on the host
# while the container is running
#CMD python3 -u register2.py

