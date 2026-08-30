/*
 * ====================================================================================
 * SMART MEDICAL MANAGEMENT SYSTEM — ESP32 FIRMWARE
 * IoT-Based Medicine Reminder & Detection System
 * Components: ESP32 + DS3231 RTC + 16x2 I2C LCD + IR Sensor + Buzzer + Dual LEDs
 * ====================================================================================
 */

#include <WiFi.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <RTClib.h>
#include <HTTPClient.h>
#include "config.h"

// Hardware Instances
LiquidCrystal_I2C lcd(0x27, 16, 2);
RTC_DS3231 rtc;

// Global State Variables
unsigned long lastHeartbeat = 0;
bool isAlarmActive = false;
String currentScheduledMedicine = "Paracetamol";
String currentScheduledTime = "09:00 AM";

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n[INIT] Starting Smart Medical Management Box...");

  // Initialize GPIO Pins
  pinMode(PIN_IR_SENSOR, INPUT);
  pinMode(PIN_BUZZER, OUTPUT);
  pinMode(PIN_LED_GREEN, OUTPUT);
  pinMode(PIN_LED_RED, OUTPUT);

  digitalWrite(PIN_BUZZER, LOW);
  digitalWrite(PIN_LED_GREEN, LOW);
  digitalWrite(PIN_LED_RED, LOW);

  // Initialize I2C Bus & LCD
  Wire.begin(PIN_SDA, PIN_SCL);
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Smart Med Box");
  lcd.setCursor(0, 1);
  lcd.print("Connecting WiFi");

  // Initialize DS3231 RTC
  if (!rtc.begin()) {
    Serial.println("[ERROR] DS3231 RTC not detected!");
    lcd.clear();
    lcd.print("RTC Error!");
  } else {
    Serial.println("[OK] DS3231 RTC Initialized.");
    if (rtc.lostPower()) {
      rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    }
  }

  // Connect to Wi-Fi
  connectWiFi();

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Smart Med Box");
  lcd.setCursor(0, 1);
  lcd.print("Status: READY");
  delay(1500);
}

void loop() {
  DateTime now = rtc.now();
  
  // 1. Maintain WiFi Connection
  if (WiFi.status() != WL_CONNECTED) {
    digitalWrite(PIN_LED_GREEN, LOW);
    connectWiFi();
  } else {
    digitalWrite(PIN_LED_GREEN, HIGH);
  }

  // 2. Periodic Firebase Heartbeat
  if (millis() - lastHeartbeat >= HEARTBEAT_INTERVAL_MS) {
    sendHeartbeat();
    lastHeartbeat = millis();
  }

  // 3. Display Current Time & Next Dose
  displayClockAndDose(now);

  // 4. Check If Dose Time Matches
  checkDoseSchedule(now);

  // 5. Check IR Sensor for Pill Extraction
  checkPillDetection(now);

  delay(200);
}

void connectWiFi() {
  Serial.print("[WIFI] Connecting to ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 15) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[WIFI] Connected! IP: " + WiFi.localIP().toString());
  } else {
    Serial.println("\n[WIFI] Connection Timeout. Running in offline RTC mode.");
  }
}

void displayClockAndDose(DateTime now) {
  if (!isAlarmActive) {
    lcd.setCursor(0, 0);
    char timeBuffer[17];
    snprintf(timeBuffer, sizeof(timeBuffer), "Time: %02d:%02d:%02d", now.hour(), now.minute(), now.second());
    lcd.print(timeBuffer);

    lcd.setCursor(0, 1);
    char doseBuffer[17];
    snprintf(doseBuffer, sizeof(doseBuffer), "Next:%s", currentScheduledTime.c_str());
    lcd.print(doseBuffer);
  }
}

void checkDoseSchedule(DateTime now) {
  // Example condition: Dose at 09:00:00 or 20:00:00
  if ((now.hour() == 9 || now.hour() == 13 || now.hour() == 20) && now.minute() == 0 && now.second() == 0) {
    triggerDoseAlarm();
  }
}

void triggerDoseAlarm() {
  isAlarmActive = true;
  Serial.println("[ALARM] Scheduled dose triggered: " + currentScheduledMedicine);
  
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("TAKE MEDICINE!");
  lcd.setCursor(0, 1);
  lcd.print(currentScheduledMedicine);

  // Sound Buzzer & Red Alert LED
  digitalWrite(PIN_LED_RED, HIGH);
  for (int i = 0; i < 3; i++) {
    digitalWrite(PIN_BUZZER, HIGH);
    delay(300);
    digitalWrite(PIN_BUZZER, LOW);
    delay(200);
  }
}

void checkPillDetection(DateTime now) {
  // IR sensor reads LOW when hand/pill breaks infrared beam
  int irState = digitalRead(PIN_IR_SENSOR);

  if (irState == LOW && isAlarmActive) {
    // Pill has been extracted!
    Serial.println("[SENSOR] IR Detection Triggered — Medicine Taken!");
    isAlarmActive = false;
    digitalWrite(PIN_LED_RED, LOW);
    digitalWrite(PIN_BUZZER, LOW);

    // Confirmation Tone
    digitalWrite(PIN_LED_GREEN, HIGH);
    tone(PIN_BUZZER, 1000, 200);

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("DOSE RECORDED!");
    lcd.setCursor(0, 1);
    lcd.print("Status: TAKEN");

    // Upload taken event to Firebase
    uploadDoseEvent("taken", now);
    delay(2000);
    lcd.clear();
  }
}

void uploadDoseEvent(String status, DateTime now) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[FIREBASE] Offline. Queued locally.");
    return;
  }

  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/medicine_logs.json";
  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  char timeIso[30];
  snprintf(timeIso, sizeof(timeIso), "%04d-%02d-%02dT%02d:%02d:%02dZ",
           now.year(), now.month(), now.day(), now.hour(), now.minute(), now.second());

  String jsonPayload = "{"
    "\"patientId\":\"" + String(PATIENT_ID) + "\","
    "\"medicineName\":\"" + currentScheduledMedicine + "\","
    "\"status\":\"" + status + "\","
    "\"takenTime\":\"" + String(timeIso) + "\","
    "\"deviceId\":\"" + String(DEVICE_ID) + "\""
  "}";

  int httpCode = http.POST(jsonPayload);
  Serial.printf("[FIREBASE] Upload Response Code: %d\n", httpCode);
  http.end();
}

void sendHeartbeat() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/devices/" + String(DEVICE_ID) + ".json";
  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  String jsonPayload = "{"
    "\"status\":\"connected\","
    "\"lastSeen\":\"" + String(millis()) + "\","
    "\"firmwareVersion\":\"v2.1.0-prod\""
  "}";

  http.PATCH(jsonPayload);
  http.end();
  Serial.println("[HEARTBEAT] ESP32 heartbeat sent to Firebase.");
}
