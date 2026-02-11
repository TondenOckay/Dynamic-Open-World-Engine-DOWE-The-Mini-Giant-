/* ============================================================================
    Project Name: Dynamic Open World Engine (DOWE) “The Mini Giant”
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_switchboard
    PILLARS: 
        1. Independent Mini-Servers Architecture 
        2. Phase-Staggered Performance Optimization 
        3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    The central router for all mini-server communication. It intercepts 
    event codes and directs traffic to standalone system packages.
   ============================================================================
*/

// --- 2DA REFERENCE NOTES ---
// // No 2DA files are required for the Switchboard routing logic.

void main()
{
    // PHASE 1: PACKET EXTRACTION
    object oArea = OBJECT_SELF;
    int nEvent = GetLocalInt(oArea, "MG_SW_EVENT");

    // PHASE 2: DEBUG REPORTING
    // Triple-Check: Only fires if MG_DEBUG_ON is enabled on the area.
    if (GetLocalInt(oArea, "MG_DEBUG_ON") == TRUE)
    {
        SetLocalString(oArea, "MG_DEBUG_MSG", "SWITCHBOARD: Processing Event Code " + IntToString(nEvent));
        ExecuteScript("area_debug", oArea);
    }

    // PHASE 3: ROUTING (Phased Staggering)
    // We use a switch for O(1) performance to ensure instant routing.
    switch (nEvent)
    {
        case 100: // REGISTRY: Add player/NPC to VIP list.
            ExecuteScript("area_registry", oArea);
            break;

        case 200: // HEARTBEAT CYCLE: Ignition or loop pulse.
            ExecuteScript("area_heartbeat", oArea);
            break;

        case 300: // JANITOR: Player exit and resource cleanup.
            ExecuteScript("area_janitor", oArea);
            break;

        case 400: // LIVE_NPC: Testing system for pseudo-players.
            ExecuteScript("live_npc", oArea);
            break;
    }

    // PHASE 4: PACKET CLEANUP
    // Delete the event to prevent logic loops or accidental double-firing.
    DeleteLocalInt(oArea, "MG_SW_EVENT");
}
