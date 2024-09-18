#!/usr/bin/env python3

from time import sleep, strftime, time
import board
import csv
import busio
from pathlib import Path
from os import path, uname
from adafruit_bme280 import basic as adafruit_bme280
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
import sys
import qwiic_titan_gps

# creating the sensor objects, uses the boards default I2C bus
i2c = board.I2C()
# Create the ADC object using the i2c bus and the lowest sample rate
ads = ADS.ADS1015(i2c, data_rate = 128)
# Create the GPS object
gps = qwiic_titan_gps.QwiicTitanGps()

if gps.connected is False:
	print("Could not connect to the SparkFun GPS unit. check wiring", file=sys.stderr)
	return
gps.begin()
try:
	bme280 = adafruit_bme280.Adafruit_BME280_I2C(i2c, 0x76)
	bme280b = adafruit_bme280.Adafruit_BME280_I2C(i2c, 0x77)
	# setting location's Pressure (hPa) at Sea level, Austin TX
	bme280.sea_level_pressure = 1019
	bme280b.sea_level_pressure = 1019
except:
	print(strftime("%Y-%m-%d-%H:%M:%S") + ": BME280 i2c address could not be found.")
try:
	ss1 = AnalogIn(ads, ADS.P0)
except:
	print(strftime("%Y-%m-%d-%H:%M:%S") + ": Soil Moisture Sensor 1 at A0  could not be found.")
try:
	ss2 = AnalogIn(ads, ADS.P1)
except:
	print(strftime("%Y-%m-%d-%H:%M:%S") + ": Soil Moisture Sensor 2 at A1 could not be found.")
try:
	st1 = AnalogIn(ads, ADS.P2)
except: 	
	print(strftime("%Y-%m-%d-%H:%M:%S") + ": Soil Temperature Sensor 1 at A2 could not be found.")
try:
	st2 = AnalogIn(ads, ADS.P3)
except:
	print(strftime("%Y-%m-%d-%H:%M:%S") + ": Soil Temperature Sensor 2 at A3 could not be found.")

# Get Hostname and Location
Hostname = uname()[1]
# print(Hostname)
Location = "unique_location"

# Create String for File Name
FilePath = Path("~/DATA/environmental/" + str(Hostname) + str("-") + strftime("%Y%m%d") + str(".csv")).expanduser()
# FilePath = Path("/DATA/environmental/" + str(Hostname) + str("-") + strftime("%Y%m%d") + str(".csv"))
#print(FileName)

# Check if Data file is already Created
if FilePath.exists() is False:
	# FilePath.parent.mkdir(parents=True, exist_ok=True)
	# print("file does not exist")
	# If not Create the File and add the Headers
	# Hostname - Location - Date - Time - Temp - Hum - Press - TempB - HumB - PressB - AltB - SM1_M - SM1_T- SM2_M - SM2_T
	with FilePath.open("a") as log:
		log.write("Hostname,Location,Date,Time,Temp,Hum,Press,Alt,TempB,HumB,PressB,AltB,SM1_M,SM1_T,SM2_M,SM2_T\n")


# Collecting and writing data to the CSV
with FilePath.open("a") as log:
#	while True:
		# creating the data variables
		try:
			temp = bme280.temperature
			hum = bme280.relative_humidity
			pres = bme280.pressure
			alt = bme280.altitude
			tempb = bme280b.temperature
			humb = bme280b.relative_humidity
			presb = bme280b.pressure
			altb = bme280b.altitude
		except:
			print(strftime("%Y-%m-%d-%H:%M:%S") + ": Could not collect data from the BME280.")
			temp="n/a"
			hum="n/a"
			pres="n/a"
			alt="n/a"
			tempb = "n/a"
			humb = "n/a"
			presb = "n/a"
			altb = "n/a"
		try:
			mois1 = ss1.voltage
			
		except:
			print(strftime("%Y-%m-%d-%H:%M:%S") + ": Could not collect data from SM1 at A0.")
			mois1="n/a"
		try:
			smtemp1 = st1.voltage
		except:
			print(strftime("%Y-%m-%d-%H:%M:%S") + ": Could not collect data from ST1 at A2.")
			smtemp1="n/a"
		try:
			mois2 = ss2.voltage
		except:
			print(strftime("%Y-%m-%d-%H:%M:%S") + ": Could not collect data from SM2 at A1.")
			mois2="n/a"
		try:
			smtemp2 = st2.voltage
		except:
			print(strftime("%Y-%m-%d-%H:%M:%S") + ": Could not collect data from ST2 at A3.")
			smtemp2="n/a"
		log.write("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}\n".format(str(Hostname),str(Location),strftime("%Y-%m-%d"),strftime("%H:%M:%S"),str(temp), str(hum), str(pres),str(alt),str(tempb),str(humb),str(presb),str(altb),str(mois1),str(smtemp1),str(mois2),str(smtemp2)))
		log.close()

# Print commands for testing
#		print("\nTemperature: %0.2f C" % bme280.temperature)
#		print("Humidity: %0.2f %%" % bme280.relative_humidity)
#		print("Pressure: %0.2f hPa" % bme280.pressure)
#		print("Altitude: %0.2f meters" % bme280.altitude)

#		sleep(2)
    while True:
        if gps.get_nmea_data() is True:
            print("Latitude: {}, Longitude: {}, Time: {}".format(
                gps.gnss_messages['Latitude'],
                gps.gnss_messages['Longitude'],
                gps.gnss_messages['Time']))
	sleep(2)

