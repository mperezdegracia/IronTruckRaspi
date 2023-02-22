# Use an official Python runtime as a parent image
FROM python:3.6.9-slim

# Set the working directory to /app
WORKDIR /app

# Install any needed packages specified in requirements.txt
RUN apt-get update -y && apt-get install -y build-essential
COPY requirements.txt /app/requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt
RUN apt-get install -y python3-rpi.gpio
RUN apt-get install -y libgpiod2

# Copy the current directory contents into the container at /app
COPY rpi/gas.py /app/gas.py
COPY rpi/temp.py /app/temp.py
COPY rpi/influx.py /app/influx.py
COPY rpi/settings.py /app/settings.py
COPY rpi/sensor.py /app/sensor.py
COPY rpi/alarm.py /app/alarm.py
COPY rpi/relay.py /app/relay.py
COPY rpi/main.py /app/main.py
COPY rpi/custom_logger.py /app/custom_logger.py
# Run app.py when the container launches
# The -u flag specifies to use the unbuffered ouput.
# in this way, what's printed by the app is visible on the host
# while the container is running
CMD python3 -u main.py

