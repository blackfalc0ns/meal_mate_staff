# Shared authentication refresh implementation plan

Goal: keep driver login and calls during access-token rotation; terminate local media only for definitive refresh/account failure.

Architecture: one Dart AuthRefreshService owns rotating refresh credentials, including native Android requests via a dedicated method channel. Dedicated refresh HTTP path avoids recursion. Atomic secure token-pair record, shared single flight, rejected-token deduplication, bounded request replay, and cooldown on transient failure. Android stores only synchronized token copies and retains voice session/proof.

- [x] Add regression tests for transient/terminal errors, concurrency, 409, atomic storage and native request replay.
- [x] Implement atomic token pair storage and shared refresh coordinator; preserve account restrictions.
- [x] Wire Dio, native bridge and lifecycle checks; remove independent native rotation.
- [x] Reconcile ambiguous initiation with original request key; refresh all native HTTP calls once and rebind existing SignalR session.
- [x] Validate Dart and Android tests and static checks; document real-device audio/background checks.
