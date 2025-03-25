import serial

def main():
    port_name = 'COM3'  # Prolific USB to Serial
    baudrate = 9600
    timeout = 5
    
    try:
        # Open serial connection
        with serial.Serial(port_name, baudrate, timeout=timeout) as ser:
            print(f"Listening on {port_name} at {baudrate} baud...")
            print("Press Ctrl+C to stop")
            
            while True:
                try:
                    # Read data from serial port
                    if ser.in_waiting > 0:
                        # Read all available bytes
                        data = ser.read(ser.in_waiting)
                        
                        # Print data RX
                        print("Received:", data.hex(' '))
                        print("ASCII:", data.decode('ascii', errors='replace'))
                        
                except KeyboardInterrupt:
                    print("\nStopping...")
                    break
                except Exception as e:
                    print(f"Error: {e}")
                    break
                    
    except serial.SerialException as e:
        print(f"Could not open serial port {port_name}: {e}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()