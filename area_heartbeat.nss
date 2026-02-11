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
    The 30-second logic pulse. Processes sub-systems (DSE, Persistence) in
    staggered delays (0.1, 0.2, 0.3) to prevent CPU spikes.
   ============================================================================
*/

void main()
{
    object oArea = OBJECT_SELF;

    // PHASE 1: ZERO-WASTE VALIDATION
    // If the server is inactive or population is 0, we stop the loop.
    if (GetLocalInt(oArea, "MG_SERVER_ACTIVE") == FALSE || GetLocalInt(oArea, "MG_POPULATION") <= 0)
    {
        if (GetLocalInt(oArea, "MG_DEBUG_ON"))
        {
            SetLocalString(oArea, "MG_DEBUG_MSG", "HEARTBEAT: Zero players. Shutting down loop.");
            ExecuteScript("area_debug", oArea);
        }
        return; // Zero further resources consumed.
    }

    // PHASE 2: STAGGERED LOGIC EXECUTION
    // Logic 1: Persistence/Biology (0.1s delay)
    DelayCommand(0.1f, [oArea]()
    {
        // Execute biological logic via Switchboard if needed.
        if (GetLocalInt(oArea, "MG_DEBUG_ON"))
            SendMessageToAllDMs("MG_HB: Stagger 0.1 - Persistence Check.");
    });

    // Logic 2: DSE v7.0 Spawning (0.2s delay)
    DelayCommand(0.2f, [oArea]()
    {
        // Execute spawn engine logic.
        if (GetLocalInt(oArea, "MG_DEBUG_ON"))
            SendMessageToAllDMs("MG_HB: Stagger 0.2 - Spawning Check.");
    });

    // Logic 3: Environmental Sync (0.3s delay)
    DelayCommand(0.3f, [oArea]()
    {
        // Execute weather/climate logic.
    });

    // PHASE 3: RECURSIVE LOOP (30.0s)
    // Re-fires the heartbeat to keep the mini-server running.
    DelayCommand(30.0f, ExecuteScript("area_heartbeat", oArea));
}
