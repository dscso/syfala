/************************** BEGIN UartUI.h **************************/
/************************************************************************
 FAUST Architecture File
 Copyright (C) 2003-2017 GRAME, Centre National de Creation Musicale
 ---------------------------------------------------------------------
 This Architecture section is free software; you can redistribute it
 and/or modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3 of
 the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; If not, see <http://www.gnu.org/licenses/>.
 
 EXCEPTION : As a special exception, you may create a larger work
 that contains this FAUST architecture section and distribute
 that work under terms of your choice, so long as this FAUST
 architecture section is not modified.
 ************************************************************************/

#ifndef FAUST_UARTUISENDER_H
#define FAUST_UARTUISENDER_H



#if defined (_WIN32) || defined(_WIN64)
    #define SERIAL_PORT "COM1"
#endif
#if defined (__linux__) || defined(__APPLE__)
    #define SERIAL_PORT "/dev/ttyUSB1"
#endif

// Serial library
#include "./serialLib/serialib.h"

#include <string>
#include <stdio.h>
#include <unistd.h>
#include <iostream>
#include <thread>

#include "faust/gui/MapUI.h"

class UARTSenderUI : public MapUI
{
    
    private:
    
         // Serial object
    	serialib serial;
    	

    
        std::thread fThread;
        bool fRunning;
    
        static void update_cb(UARTSenderUI* uart_ui)
        {
            while (uart_ui->fRunning) {
                uart_ui->update();
                // Wait 20 ms
                usleep(200000);
            }
        }
    
    public:
        
        UARTSenderUI():fThread(update_cb, this), fRunning(true)
        {
            // Connection to serial port
            char errorOpening = serial.openDevice(SERIAL_PORT, 115200);
            // If connection fails, return the error code otherwise, display a success message
			switch ( errorOpening )
			{
				case 1:
				printf ("Successful connection to %s\n",SERIAL_PORT);
					break;
				case -1:
					printf ("[ERROR] device not found\n");
					break;
				case -2:
					printf ("[ERROR] while opening the device\n");
					break;
				default:
					printf ("[ERROR] %d\n",errorOpening);

			}



        }
    
        virtual ~UARTSenderUI()
        {
            // Close the serial device
            serial.closeDevice();
            fRunning = false;
            fThread.join();
        }
        
        void send()
        {
            for (const auto& it : fPathZoneMap) {
                
                const char* path = it.first.c_str();
                FAUSTFLOAT value = *it.second;

				serial.writeString(path);
				serial.writeChar('\n');
	   			serial.writeBytes(&value,4);
				//serial.writeChar('\n');
				//usleep(20000);
            }
        }
    
        void receive()
        {
            char receivedString[512]={'\0'};
			serial.readString(receivedString,'\0',512,10);
			if (receivedString[0]!='\0')fprintf( stdout, "%s\n", receivedString );
			serial.flushReceiver();
			/*
			char receivedString[512]={'\0'};
            char RecvB='\0';
			int idx=0;
            do{
			serial.readChar(&RecvB,20);
			receivedString[idx++]=RecvB;
			}while(serial.available());
			
			fprintf( stdout, "%s\n", receivedString );
			*/
            // Set value
            //*fPathZoneMap[path] = value;
        }
    
        void update()
        {
            send();
            receive();
        }
    
};

#endif // FAUST_UARTUISENDER_H
/**************************  END  UartSenderUI.h **************************/
