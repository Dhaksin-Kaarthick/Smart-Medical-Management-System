#ifndef CONFIG_H
#define CONFIG_H

// Wi-Fi Credentials
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// Firebase Project Settings
#define FIREBASE_HOST "https://medical-management-syste-fd785-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "YOUR_FIREBASE_DATABASE_SECRET"
#define FIRESTORE_PROJECT_ID "medical-management-syste-fd785"
#define DEVICE_ID "esp32_001"
#define PATIENT_ID "pat_001"

// Hardware Pin Configuration (ESP32 DevKit V1)
#define PIN_IR_SENSOR    18   // IR Obstacle Sensor (Active LOW when pill/hand detected)
#define PIN_BUZZER       19   // Piezo Buzzer for audible reminder
#define PIN_LED_GREEN    23   // Status LED - Taken / Connected
#define PIN_LED_RED      4    // Status LED - Missed / Alert
#define PIN_SDA          21   // I2C SDA (DS3231 RTC & LCD 16x2)
#define PIN_SCL          22   // I2C SCL (DS3231 RTC & LCD 16x2)

// Timing Settings
#define HEARTBEAT_INTERVAL_MS 30000 // 30 seconds
#define DOSE_CHECK_INTERVAL_MS 1000 // 1 second
#define ALARM_DURATION_SECONDS 60   // Alarm sounds for 60s unless taken

#endif // CONFIG_H
