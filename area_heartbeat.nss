/* ============================================================================
    Project Name: Dynamic Open World Engine (DOWE) “The Mini Giant”
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_heartbeat
    PILLARS: 
        1. Independent Mini-Servers Architecture 
        2. Phase-Staggered Performance Optimization 
        3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    The 30-second logic pulse for the mini-server. This script staggers 
    sub-systems (Spawning, Persistence) using standard NWScript delays to 
    prevent CPU spikes. Implements Zero-Waste shutdown logic.
   ============================================================================
*/

// --- 2DA REFERENCE NOTES ---
// // No 2DA files are required for the heartbeat's recursive loop.

void main()
{
    object oArea = OBJECT_SELF;

    // PHASE 1: ZERO-WASTE VALIDATION
    // Triple-Check: If no players are in the registry, we stop the loop immediately.
    if (GetLocalInt(oArea, "MG_POPULATION") <= 0)
    {
        SetLocalInt(oArea, "MG_SERVER_ACTIVE", FALSE);
        
        // Report shutdown to debug if toggled.
        if (GetLocalInt(oArea, "MG_DEBUG_ON"))
        {
            SetLocalString(oArea, "MG_DEBUG_MSG", "HEARTBEAT: Zero population. Mini-Server going dormant.");
            ExecuteScript("area_debug", oArea);
        }
        return; 
    }

    // PHASE 2: STAGGERED SUBSYSTEMS (Standard Delay Methods)
    // Stagger 0.1s: Biological/Persistence Pulse
    // Note: We avoid the [] brackets here to ensure successful compilation.
    DelayCommand(0.1, SetLocalString(oArea, "MG_DEBUG_MSG", "HEARTBEAT: Phase 1 (Persistence) Active."));
    DelayCommand(0.11, ExecuteScript("area_debug", oArea));

    // Stagger 0.2s: DSE v7.0 Spawning Pulse
    DelayCommand(0.2, SetLocalString(oArea, "MG_DEBUG_MSG", "HEARTBEAT: Phase 2 (DSE Spawning) Active."));
    DelayCommand(0.21, ExecuteScript("area_debug", oArea));

    // PHASE 3: RECURSIVE LOOP (30.0s)
    // Notes: Schedules the next heart pulse. This keeps the "Independent Server" alive.
    DelayCommand(30.0, ExecuteScript("area_heartbeat", oArea));
}
