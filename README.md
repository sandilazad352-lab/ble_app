# SuperMini BLE Protocol — App Developer Guide

## Connection

| Parameter | Value |
|---|---|
| Advertising name | `SuperMini` |
| Transport | BLE UART (Nordic UART Service) |
| Service UUID | `6e400001-b5a3-f393-e0a9-e50e24dcca9e` |
| TX Characteristic (notify) | `6e400002-b5a3-f393-e0a9-e50e24dcca9e` |
| RX Characteristic (write) | `6e400003-b5a3-f393-e0a9-e50e24dcca9e` |
| Request MTU | 247 bytes on connect |
| Flow | `bufferTXD(true)` enabled — TX is buffered per MTU frame. Call `flushTXD()` after each send. |

## Message Format

- Commands are **newline-delimited** strings (`\n` terminated) written to RX characteristic.
- Events are **newline-delimited JSON** received on TX characteristic (notify).
- If the JSON line is malformed or not recognized, the device echoes it back as `{"event":"echo","data":"..."}`.

---

## Commands (app → device)

### `config`
Get full config JSON response.

**Request:**
```
config
```
**Response:**
```json
{"event":"config","data":{"ir_pin":22,"bat_pin":31,"bat_divider":3.0,"bat_read_ms":5000,"bat_full_mv":4200,"bat_empty_mv":3300,"prox_near_dbm":-70,"prox_far_dbm":-80,"prox_poll_ms":2000,"heartbeat_ms":1000,"ble_ready_delay":500,"ble_tx_power":4,"ble_mtu":247,"log_max_lines":500,"log_max_bytes":4096,"serial_baud":115200,"serial_timeout":3000,"adv_interval_min":32,"adv_interval_max":244,"adv_fast_timeout":30,"near_publish":0,"ir_total_count":0,"ir_last_time":"","ir_reset_time":""}}
```

### `config default`
Reset all settings to factory defaults (from `config.h`).

**Request:**
```
config default
```
**Response:**
```json
{"event":"config_saved"}
```

### `config {key:value,...}`
Update one or more settings. Only provided keys are changed; others keep their current value. Saved to flash immediately.

**Request:**
```
config {"near_publish":1,"heartbeat_ms":2000}
```
**Response (success):**
```json
{"event":"config_saved"}
```
**Response (parse error):**
```json
{"event":"config_error"}
```

### `time HH MM SS`
Set time (24-hour format).

**Request:**
```
time 14 30 00
```
**Response:**
```json
{"event":"time_set","time":"2026-05-24 14:30:00.000"}
```

### `time <epoch>`
Set time from Unix epoch seconds.

**Request:**
```
time 1716546600
```
**Response:**
```json
{"event":"time_set","time":"2026-05-24 14:30:00.000"}
```

### `date YYYY MM DD`
Set date. Time-of-day is preserved from current RTC value.

**Request:**
```
date 2026 05 24
```
**Response:**
```json
{"event":"date_set","time":"2026-05-24 14:30:00.000"}
```

### `log`
Get persistent counter status.

**Request:**
```
log
```
**Response:**
```json
{"event":"log","count":42,"last_time":"2026-05-24 14:30:00.123","reset_time":"2026-05-24 08:00:00.000"}
```

### `log clear`
Delete all lines from the IR event log file (`/ir_log.txt`).

**Request:**
```
log clear
```
**Response:**
```json
{"event":"log_cleared"}
```

### `log reset`
Reset persistent IR counter to 0 and record the reset timestamp.

**Request:**
```
log reset
```
**Response:**
```json
{"event":"log_reset","time":"2026-05-24 15:00:00.000"}
```

---

## Events (device → app)

### IR Count
Sent on every IR rising edge. Always logged to flash. Only sent over BLE if `near_publish` allows it.

```json
{"event":"ir","count":42,"time":"2026-05-24 10:30:00.123"}
```

| Field | Type | Description |
|---|---|---|
| `count` | int | Total IR count (persistent) |
| `time` | string | Timestamp `YYYY-MM-DD HH:mm:ss.sss` |

### Heartbeat
Sent at `heartbeat_ms` interval when BLE is ready and `near_publish` allows.

```json
{"event":"heartbeat","bat_mv":3980,"bat_pct":85,"rssi":-45}
```

| Field | Type | Description |
|---|---|---|
| `bat_mv` | int | Battery voltage in millivolts |
| `bat_pct` | int | Battery percentage (0–100) |
| `rssi` | int | Current RSSI, or -128 if not available |

### Proximity State Change
Sent when RSSI crosses near or far threshold. Always sent regardless of `near_publish`.

```json
{"event":"near","rssi":-45}
```
```json
{"event":"away","rssi":-90}
```

| Field | Type | Description |
|---|---|---|
| `rssi` | int | RSSI at the time of transition |

### Config Response
Sent in reply to `config` request.

```json
{"event":"config","data":{...}}
```

### Config Saved
Sent after `config {...}` or `config default` succeeds.

```json
{"event":"config_saved"}
```

### Config Error
Sent when `config {...}` JSON is malformed.

```json
{"event":"config_error"}
```

### Time / Date Set
Sent after `time` or `date` command succeeds.

```json
{"event":"time_set","time":"2026-05-24 14:30:00.000"}
```
```json
{"event":"date_set","time":"2026-05-24 14:30:00.000"}
```

### Log Status
Sent in reply to `log` request.

```json
{"event":"log","count":42,"last_time":"2026-05-24 14:30:00.123","reset_time":"2026-05-24 08:00:00.000"}
```

| Field | Type | Description |
|---|---|---|
| `count` | int | Persistent IR counter (survives reboot) |
| `last_time` | string | Timestamp of last IR event, or empty |
| `reset_time` | string | Timestamp of last `log reset`, or empty |

### Log Cleared
Sent after `log clear` succeeds.

```json
{"event":"log_cleared"}
```

### Log Reset
Sent after `log reset` succeeds.

```json
{"event":"log_reset","time":"2026-05-24 15:00:00.000"}
```

### Echo
Sent for any unrecognized command.

```json
{"event":"echo","data":"<raw text>"}
```

---

## Configuration Reference

| Key | Type | Default | Description |
|---|---|---|---|
| `ir_pin` | int | 22 | IR sensor GPIO pin |
| `bat_pin` | int | 31 | Battery ADC GPIO pin |
| `bat_divider` | float | 3.0 | Voltage divider ratio (R1+R2)/R2 |
| `bat_read_ms` | int | 5000 | Battery read interval in ms |
| `bat_full_mv` | int | 4200 | Voltage for 100% battery |
| `bat_empty_mv` | int | 3300 | Voltage for 0% battery |
| `prox_near_dbm` | int | -70 | RSSI threshold for "near" (0 to -70 = near) |
| `prox_far_dbm` | int | -80 | RSSI threshold for "away" (below this = away) |
| `prox_poll_ms` | int | 2000 | Proximity poll interval in ms |
| `heartbeat_ms` | int | 1000 | Heartbeat interval in ms |
| `ble_ready_delay` | int | 500 | Delay after BLE connect before sending events (ms) |
| `ble_tx_power` | int | 4 | BLE TX power in dBm |
| `ble_mtu` | int | 247 | Requested ATT MTU |
| `log_max_lines` | int | 500 | Max lines in log file before auto-clear |
| `log_max_bytes` | int | 4096 | Max bytes in log file before auto-clear |
| `serial_baud` | int | 115200 | USB serial baud rate |
| `serial_timeout` | int | 3000 | USB serial wait timeout in ms |
| `adv_interval_min` | int | 32 | Min advertising interval (units: 0.625ms) |
| `adv_interval_max` | int | 244 | Max advertising interval (units: 0.625ms) |
| `adv_fast_timeout` | int | 30 | Fast advertising timeout in seconds |
| `near_publish` | int | 0 | 0 = always publish, 1 = only publish when RSSI > `prox_near_dbm` |
| `ir_total_count` | int | 0 | Persistent IR counter (read-only, reset via `log reset`) |
| `ir_last_time` | string | "" | Timestamp of last IR event (read-only) |
| `ir_reset_time` | string | "" | Timestamp of last counter reset (read-only) |

---

## Publishing Logic

When `near_publish = 0`:
- IR events, heartbeat, and proximity changes are **always sent** over BLE.

When `near_publish = 1`:
- **IR events** and **heartbeat** are only sent when a live RSSI read is > `prox_near_dbm`.
- **Proximity near/away events** are **always sent** (so the app knows when someone arrives/leaves).
- IR events are **always logged** to flash regardless of near_publish — BLE output is the only thing suppressed.

The RSSI check is performed live at the moment of the publishing decision (not a cached poll value), so the gate is immediate.

---

## Persistent Counter

- `ir_total_count` is stored in `/config.json` on InternalFS.
- On boot, the counter is restored from flash.
- Counter increases with each IR edge.
- Saved to flash every 30 seconds (if dirty) for wear leveling.
- Reset to 0 via `log reset` command (also records reset timestamp).

---

## Shell (USB Serial)

Same commands are available over USB serial at the `>` prompt. Useful for debugging during development.

```
> config
{"ir_pin":22,"near_publish":0,...}
> config {"near_publish":1}
Config saved
> log
Counter: 42, last: 2026-05-24 14:30:00.123, reset: 2026-05-24 08:00:00.000
```

---

## Implementation Notes

1. **MTU:** Always request MTU 247 on connect. Without this, the 20-byte default MTU will fragment large JSON config responses.
2. **Notify subscription:** Subscribe to the TX characteristic (6e400002) for notifications immediately on connection.
3. **Line buffering:** The device sends complete JSON objects each terminated by `\n`. Buffer incoming data and split on newlines.
4. **RSSI:** The device calls `monitorRssi()` once on connect. RSSI is updated by the BLE stack asynchronously. `getRssi()` returns 0 if no measurement is available yet — handle this in your app.
5. **Time:** The device has no battery-backed RTC. Time must be set by the app after each connection (the app should store the last known time and send it on reconnect).
6. **Counter:** The IR counter survives reboots (stored in flash config). The app can restore the last known count after reconnect by querying `config` or `log`.
