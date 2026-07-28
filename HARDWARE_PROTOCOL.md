# AgriGuard Arduino USB Serial Protocol

Phase 4 uses Android USB OTG at 115200 baud, 8 data bits, 1 stop bit, and no
parity. Every UTF-8 message ends with a newline.

## Command frame

```text
AGRI|1|CMD|<ACTION>|<DURATION_SECONDS>|<REQUEST_ID>|<CHECKSUM>
```

Allowed actions:

- `STATUS` with duration `0`
- `ACTIVATE` with duration from `1` through `30`
- `STOP` with duration `0`

The checksum is a two-character uppercase hexadecimal XOR of every UTF-8/ASCII
byte before the final checksum separator.

Example:

```text
AGRI|1|CMD|ACTIVATE|10|12345-abcd|2F
```

The example checksum is illustrative; firmware must calculate it from the exact
payload rather than copying it.

## Acknowledgement frame

```text
AGRI|1|ACK|<REQUEST_ID>|<OK_OR_ERROR>|<MESSAGE>|<CHECKSUM>
```

Examples of `MESSAGE` are `READY`, `ACTIVATED`, `STOPPED`, `BUSY`, and
`INVALID_COMMAND`. Do not include the `|` delimiter inside the message.

The app waits four seconds for a matching request ID. A corrupt, late, or
unmatched acknowledgement is ignored. `ACTIVATE` is not automatically retried,
because retrying a physical action can produce an unsafe duplicate activation.

## Firmware safety requirements

- Reject unknown protocol versions and actions.
- Verify the checksum before executing a command.
- Reject activation durations outside 1–30 seconds.
- Remember recent request IDs and do not execute duplicates.
- Stop automatically when the requested duration expires.
- Make `STOP` idempotent and higher priority than other commands.
- Default to the inactive state after boot, communication loss, or an internal
  firmware error.
- Send an acknowledgement only after accepting or rejecting the command.

