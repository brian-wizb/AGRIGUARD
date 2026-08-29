#include <Servo.h>

const int BUTTON_PIN = 9;
const int IR_PIN = 2;
const int SERVO_PIN = 3;
const int LED_PIN = 13;
const int MAX_SECONDS = 30;

Servo servo;
int detectionCount = 0;
bool servoOpen = false;
bool lastButton = HIGH;
bool lastIr = HIGH;
unsigned long activationEndsAt = 0;
char input[160];
byte inputLength = 0;

void setup() {
  Serial.begin(115200); // Must match the Flutter USB transport.
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(IR_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  servo.attach(SERVO_PIN);
  closeTrap();
}

void loop() {
  readCommands();
  handleButton();
  handleSensor();
  if (activationEndsAt && millis() >= activationEndsAt) {
    closeTrap();
    activationEndsAt = 0;
  }
}

void openTrap() { servo.write(180); servoOpen = true; }
void closeTrap() { servo.write(0); servoOpen = false; }

void handleButton() {
  bool button = digitalRead(BUTTON_PIN);
  if (lastButton == HIGH && button == LOW) {
    activationEndsAt = 0;
    servoOpen ? closeTrap() : openTrap();
  }
  lastButton = button;
}

void handleSensor() {
  bool ir = digitalRead(IR_PIN);
  if (lastIr == HIGH && ir == LOW) {
    detectionCount++;
    digitalWrite(LED_PIN, HIGH);
  }
  if (ir == HIGH) digitalWrite(LED_PIN, LOW);
  lastIr = ir;
}

void readCommands() {
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\r') continue;
    if (c == '\n') {
      input[inputLength] = '\0';
      if (inputLength) handleCommand(input);
      inputLength = 0;
    } else if (inputLength < sizeof(input) - 1) {
      input[inputLength++] = c;
    } else {
      inputLength = 0;
    }
  }
}

byte checksum(const char* value) {
  byte result = 0;
  while (*value) result ^= *value++;
  return result;
}

bool validChecksum(const char* payload, const char* supplied) {
  char expected[3];
  sprintf(expected, "%02X", checksum(payload));
  return strcasecmp(expected, supplied) == 0;
}

void acknowledge(const char* id, bool ok, const char* message) {
  char payload[160];
  sprintf(payload, "AGRI|1|ACK|%s|%s|%s", id, ok ? "OK" : "ERR", message);
  char sum[3];
  sprintf(sum, "%02X", checksum(payload));
  Serial.print(payload); Serial.print('|'); Serial.println(sum);
}

void handleCommand(char* line) {
  char raw[160];
  strncpy(raw, line, sizeof(raw)); raw[sizeof(raw) - 1] = '\0';
  char* field[7]; byte count = 0;
  char* token = strtok(line, "|");
  while (token && count < 7) { field[count++] = token; token = strtok(NULL, "|"); }
  if (count != 7 || token) return;
  char* separator = strrchr(raw, '|');
  if (!separator) return;
  *separator = '\0';
  const char* requestId = field[5];
  if (strcmp(field[0], "AGRI") || strcmp(field[1], "1") || strcmp(field[2], "CMD") || !validChecksum(raw, field[6])) {
    acknowledge(requestId, false, "INVALID_COMMAND"); return;
  }
  if (!strcmp(field[3], "ACTIVATE")) {
    long seconds = strtol(field[4], NULL, 10);
    if (seconds < 0 || seconds > MAX_SECONDS) { acknowledge(requestId, false, "INVALID_DURATION"); return; }
    openTrap(); activationEndsAt = seconds == 0 ? 0 : millis() + seconds * 1000UL;
    acknowledge(requestId, true, "ACTIVATED"); return;
  }
  if (!strcmp(field[3], "STOP")) {
    closeTrap(); activationEndsAt = 0; acknowledge(requestId, true, "STOPPED"); return;
  }
  if (!strcmp(field[3], "STATUS")) {
    char status[48];
    sprintf(status, "COUNT_%d_SERVO_%s", detectionCount, servoOpen ? "OPEN" : "CLOSED");
    acknowledge(requestId, true, status); return;
  }
  acknowledge(requestId, false, "UNKNOWN_ACTION");
}