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
    The central communication hub. All area events (Registry, Heartbeat, Janitor)
    must pass through here to be routed to their respective standalone packages.
   ============================================================================
*/

void main()
{
    // PHASE 1: DATA PACKET EXTRACTION
    object oArea = OBJECT_SELF;
    int nEventCode = GetLocalInt(oArea, "MG_SW_EVENT");
    object oTarget = GetLocalObject(oArea, "MG_SW_TARGET");

    // PHASE 2: DEBUG REPORTING
    // If debug is on, we report the routing action to area_debug.
    if (GetLocalInt(oArea, "MG_DEBUG_ON"))
    {
        SetLocalString(oArea, "MG_DEBUG_MSG", "SWITCHBOARD: Routing Event " + IntToString(nEventCode));
        ExecuteScript("area_debug", oArea);
    }

    // PHASE 3: STAGGERED ROUTING LOGIC
    // Using a switch statement ensures the engine finds the logic path instantly.
    switch (nEventCode)
    {
        case 100: // REGISTRY: Add player to VIP list.
            DelayCommand(0.01, ExecuteScript("area_registry", oArea));
            break;

        case 200: // HEARTBEAT: Start the 30-second pulse.
            DelayCommand(0.01, ExecuteScript("area_heartbeat", oArea));
            break;

        case 300: // JANITOR: Player exit and cleanup.
            DelayCommand(0.01, ExecuteScript("area_janitor", oArea));
            break;
    }

    // PHASE 4: CLEANUP
    // Delete the event code to ensure the "gate" is ready for the next packet.
    DeleteLocalInt(oArea, "MG_SW_EVENT");
}
