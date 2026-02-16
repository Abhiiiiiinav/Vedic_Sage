/// Kundali Engine Orchestrator
/// Re-exports engines for backward compatibility
library;

// Re-export from legacy engine, hiding the old KundaliEngine wrapper
export 'accurate_kundali_engine.dart' hide KundaliEngine;

// Re-export the new high-precision KundaliEngine (v3.0)
export 'kundali_engine.dart';
